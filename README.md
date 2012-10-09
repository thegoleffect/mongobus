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
    
    mbus.create(channelName, {size: 10000000}, function(err, channel){
        // mongobus capped collection created for you
    })
    
    mbus.drop(channelName, function(err){
        // channelName collection dropped 
    })
    
    mbus.index({signin: 1}, options, function(err){
        // index created (uses Schema)
    })


## Note

Mongobus uses an abstracted, flexible Schema for storing the data and associated metadata. So if you tried to insert `{signin: 1, ts: Date.now()}` directly, it would not be detected by mbus.`subscribe({signin:1})`. Please use `mbus.publish({siginin: 1, ts: Date.now()})` instead.

Aggregations & Alerts have been removed until they can be properly ported from the other repos.