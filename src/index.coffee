_ = require("underscore")
mongoose = require("mongoose")
Schema = mongoose.Schema

Event = new Schema({})

class Mongobus
  constructor: (@hostStr, options = {}) ->
    @options = _.extend({}, @_defaultOpts, options)
    @db = mongoose.connect(@hostStr, @options)
  
  _defaultOpts: {}
  
  channel: (@collectionName = "events") ->
    @collection = mongoose.model(@collectionName, Event)
  
  create: (@collectionName) ->
    
  
  subscribe: (query, options, callback) ->
    if typeof options == "function"
      callback = options
      options = {}
    
  test: () ->
    @collection.find({}, (err, docs) ->
      throw err if err
      
      console.log(docs)
    )
    # console.log(@event)
    # return @event
    # @event.connection.find({}, (err, cursor) ->
    #   throw err if err
      
    #   cursor.toArray((err, docs) ->
    #     throw err if err
        
    #     console.log(docs)
    #   )
    # )

module.exports = Mongobus