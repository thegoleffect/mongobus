# Mongobus = require("../src/")

# mbus = new Mongobus("mongodb://localhost/test")
# mbus.channel("mbus")

# # console.log(require("sys").inspect(mbus.event))

# mbus.test()
should = require("should")
Mongobus = require("../src/")

describe("Mongobus", () ->
  mbus = new Mongobus("mongodb://localhost/test")
  mbus.channel("mbus")
  
  describe("#subscribe", () ->
    it("should exist", (done) ->
      should.exist(mbus.subscribe)
      done()
    )
    
    it("should work as intended", (done) ->
      mbus.subscribe({x:1}, (err, doc) ->
        console.log(err, doc)
        
        done()
      )
      
      setTimeout((() ->
        mbus.publish({x:1, ts: Date.now()})
      ), 1000)
    )
  )
)