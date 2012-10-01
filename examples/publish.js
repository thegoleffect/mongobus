var coffee = require("coffee-script");
var Mongobus = require("../src/");

var mbus = new Mongobus("mongodb://localhost/test")
mbus.channel('mbus')

mbus.publish({x:1, ts: Date.now()}, function(){
  mbus.disconnect()
})
