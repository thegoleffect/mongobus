var mongoose = require("mongoose")
var Schema = mongoose.Schema;
var Schemaless = new Schema({});

var db = mongoose.connect("mongodb://localhost/test")

var coll = db.model("mbus", Schemaless, "mbus")

module.exports = {}
module.exports.coll = coll.collection
module.exports.db = db