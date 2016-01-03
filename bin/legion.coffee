#!/usr/bin/env coffee
myArgs = process.argv.slice(2)
LegionIO = require '..'
legion = new LegionIO()
legion.dialog myArgs[0], myArgs[1]