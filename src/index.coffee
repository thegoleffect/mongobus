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
    @schema = new BusSchema()
    @isConnected = false
    
    @db = mongoose.connect(@hostStr, @options)
    @db.connection.on("open", (err, stuff) =>
      @isConnected = true
    )
    @db.connection.on("close", (err) =>
      @isConnected = false
    )
  
  _defaultOpts: {}
  
  _defaultCreateOpts: {
    capped: true,
    size: 10000
  }
  
  delay: (self, fn, args, seconds) =>
    setTimeout((() ->
      self[fn].apply(self, Array.prototype.slice.apply(args))
    ), seconds)
  
  create: (collectionName, opts, callback) ->
    return @delay(this, "create", arguments, 2000) if not @isConnected
      
    options = _.extend({}, @_defaultCreateOpts, opts)
    @exists(collectionName, (err, exists) =>
      return callback("collection already exists") if exists
      
      @db.connection.db.createCollection(collectionName, options, (err, coll) =>
        return callback(err) if err and typeof callback == "function"
        
        @index(collectionName, {_id:1}, {unique: 1, dropDups: 1}, callback)
      )
    )
  
  index: (collectionName, query, options, callback) ->
    return @delay(this, "index", arguments, 2000) if not @isConnected
    
    indexObject = _.extend({}, {_id: 1}, query)
    @db.connection.collection(collectionName).ensureIndex(indexObject, options, callback)
  
  
  exists: (collectionName, callback) ->
    @db.connection.collection(collectionName).isCapped((err, status) ->
      return callback(err, true) if status == undefined
      return callback(err, false) if status == null
      return callback(err, true)
    )
  
  verifyCapped: (collectionName, callback) ->
    @db.connection.collection(collectionName).isCapped(callback)
  
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