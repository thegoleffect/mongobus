_ = require("underscore")
mongoose = require("mongoose")
Schemaless = new mongoose.Schema({})

class BusSchema
  constructor: (@options = {}) ->
  
  wrapIncoming: (data) ->
    d = {}
    for key,value of data
      d["d." + key] = value
    console.log(d) if @options.debug == true
    return d
  
  wrapOutgoing: (data) ->
    return {d: data}

class Mongobus
  constructor: (@hostStr = "mongodb://localhost/test", options = {}) ->
    @options = _.extend({}, @_defaultOpts, options)
    @db = mongoose.connect(@hostStr, @options)
    @schema = new BusSchema()
  
  _defaultOpts: {}
  
  channel: (@collectionName = "events") ->
    @collection = mongoose.model(@collectionName, Schemaless, @collectionName)
  
  disconnect: () ->
    @db.disconnect()
  
  subscribe: (query, callback) ->
    opts = {tailable: true}
    @db.connection.collection(@collectionName).find(@schema.wrapIncoming(query), opts, (err, cursor) ->
      return callback(err) if err
      
      cursor.each(callback)
    )
  
  publish: (obj, callback) ->
    @db.connection.collection(@collectionName).insert(@schema.wrapOutgoing(obj), callback)

module.exports = Mongobus