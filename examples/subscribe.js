var coffee = require("coffee-script");
var Mongobus = require("../src/");

var mbus = new Mongobus("mongodb://localhost/test")
mbus.channel('mbus')

mbus.subscribe({x:1}, function(err, doc){
  if (err){ 
    throw err
  }
  
  console.log(doc)
})

