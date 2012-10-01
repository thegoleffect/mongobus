Mongobus
========

Install:

    npm install mongobus


Use:

    var Mongobus = require("mongobus")
    
    var mbus = new Mongobus("mongodb://localhost/test")
    mbus.channel("mbus")
    
    mbus.subscribe({signin: 1}, function(err, doc){
      // do stuff with doc
    })
    
    mbus.publish({signin: 1, ts: Date.now(), moredata: {x:1}}, function(err){
      // published
    })


## Note

Aggregations & Alerts have been removed until they can be properly ported from the other repos.