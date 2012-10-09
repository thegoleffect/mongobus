(function() {
  var BusSchema, Mongobus, Schemaless, mongoose, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require("underscore");

  mongoose = require("mongoose");

  Schemaless = new mongoose.Schema({});

  BusSchema = (function() {

    function BusSchema(options) {
      this.options = options != null ? options : {};
    }

    BusSchema.prototype.wrapIncoming = function(data) {
      var d, key, value;
      d = {};
      for (key in data) {
        value = data[key];
        d["d." + key] = value;
      }
      if (this.options.debug === true) console.log(d);
      return d;
    };

    BusSchema.prototype.wrapOutgoing = function(data) {
      return {
        d: data
      };
    };

    return BusSchema;

  })();

  Mongobus = (function() {

    function Mongobus(hostStr, options) {
      var _this = this;
      this.hostStr = hostStr != null ? hostStr : "mongodb://localhost/test";
      if (options == null) options = {};
      this.delay = __bind(this.delay, this);
      this.options = _.extend({}, this._defaultOpts, options);
      this.schema = new BusSchema();
      this.isConnected = false;
      this.db = mongoose.connect(this.hostStr, this.options);
      this.db.connection.on("open", function(err, stuff) {
        return _this.isConnected = true;
      });
      this.db.connection.on("close", function(err) {
        return _this.isConnected = false;
      });
    }

    Mongobus.prototype._defaultOpts = {};

    Mongobus.prototype._defaultCreateOpts = {
      capped: true,
      size: 10000
    };

    Mongobus.prototype.delay = function(self, fn, args, seconds) {
      return setTimeout((function() {
        return self[fn].apply(self, Array.prototype.slice.apply(args));
      }), seconds);
    };

    Mongobus.prototype.create = function(collectionName, opts, callback) {
      var options,
        _this = this;
      if (!this.isConnected) return this.delay(this, "create", arguments, 2000);
      options = _.extend({}, this._defaultCreateOpts, opts);
      return this.exists(collectionName, function(err, exists) {
        if (exists) return callback("collection already exists");
        return _this.db.connection.db.createCollection(collectionName, options, function(err, coll) {
          if (err && typeof callback === "function") return callback(err);
          return _this.index(collectionName, {
            _id: 1
          }, {
            unique: 1,
            dropDups: 1
          }, callback);
        });
      });
    };

    Mongobus.prototype.index = function(collectionName, query, options, callback) {
      var indexObject;
      if (!this.isConnected) return this.delay(this, "index", arguments, 2000);
      indexObject = _.extend({}, {
        _id: 1
      }, query);
      return this.db.connection.collection(collectionName).ensureIndex(indexObject, options, callback);
    };

    Mongobus.prototype.exists = function(collectionName, callback) {
      return this.db.connection.collection(collectionName).isCapped(function(err, status) {
        if (status === void 0) return callback(err, true);
        if (status === null) return callback(err, false);
        return callback(err, true);
      });
    };

    Mongobus.prototype.verifyCapped = function(collectionName, callback) {
      return this.db.connection.collection(collectionName).isCapped(callback);
    };

    Mongobus.prototype.channel = function(collectionName) {
      this.collectionName = collectionName != null ? collectionName : "events";
      return this.collection = mongoose.model(this.collectionName, Schemaless, this.collectionName);
    };

    Mongobus.prototype.disconnect = function() {
      return this.db.disconnect();
    };

    Mongobus.prototype.subscribe = function(query, callback) {
      var opts;
      opts = {
        tailable: true
      };
      return this.db.connection.collection(this.collectionName).find(this.schema.wrapIncoming(query), opts, function(err, cursor) {
        if (err) return callback(err);
        return cursor.each(callback);
      });
    };

    Mongobus.prototype.publish = function(obj, callback) {
      return this.db.connection.collection(this.collectionName).insert(this.schema.wrapOutgoing(obj), callback);
    };

    return Mongobus;

  })();

  module.exports = Mongobus;

}).call(this);
