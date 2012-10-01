var coffee = require("coffee-script");
var Mongobus = require("../src/");

var mbus = new Mongobus("mongodb://localhost/test")
mbus.channel('mbus')

mbus.subscribe({x:1}, (err, doc) ->
  throw err if err
  
  console.log(doc)
)

