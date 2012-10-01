(function() {
  var BusSchema, Mongobus, Schemaless, mongoose, _;

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
      this.hostStr = hostStr != null ? hostStr : "mongodb://localhost/test";
      if (options == null) options = {};
      this.options = _.extend({}, this._defaultOpts, options);
      this.db = mongoose.connect(this.hostStr, this.options);
      this.schema = new BusSchema();
    }

    Mongobus.prototype._defaultOpts = {};

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
