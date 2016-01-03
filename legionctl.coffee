myArgs = process.argv.slice(2)
LegionIO = require './lib/legion'
legion = new LegionIO()
legion.dialog myArgs[0], myArgs[1]