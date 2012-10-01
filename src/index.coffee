_ = require("underscore")
mongoose = require("mongoose")
Schemaless = new mongoose.Schema({})

class Mongobus
  constructor: (@hostStr, options = {}) ->
    @options = _.extend({}, @_defaultOpts, options)
    @db = mongoose.connect(@hostStr, @options)
  
  _defaultOpts: {}
  
  channel: (@collectionName = "events") ->
    @collection = mongoose.model(@collectionName, Schemaless, @collectionName)
  
  disconnect: () ->
    @db.disconnect()
  
  wrapIncoming: (data) ->
    d = {}
    for key,value of data
      d["d." + key] = value
    console.log(d) if @options.debug == true
    return d
  
  wrapOutgoing: (data) ->
    return {d: data}
  
  subscribe: (query, callback) ->
    opts = {tailable: true}
    @db.connection.collection(@collectionName).find(@wrapIncoming(query), opts, (err, cursor) ->
      throw err if err
      
      cursor.each((err, doc) ->
        callback(err, doc)
      )
    )
  
  publish: (obj, callback) ->
    @db.connection.collection(@collectionName).insert(@wrapOutgoing(obj), callback)

module.exports = Mongobus