#!/usr/bin/env coffee
myArgs = process.argv.slice(2)
LegionIO = require '..'
shell_exec = require('shell_exec').shell_exec
reply = (text, chatID) =>
  shell_exec "./util/speak.sh \"#{text}\""
legion = new LegionIO(reply)
legion.dialog myArgs[0], 3301