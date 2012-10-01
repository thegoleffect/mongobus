Mongobus = require("../src/")

mbus = new Mongobus("mongodb://localhost/test")
mbus.channel()

# console.log(require("sys").inspect(mbus.event))

mbus.test()