myArgs = process.argv.slice(2)
LegionIO = require './lib/legion'
reply = (text, chatID) =>
  console.log "lol @ #{text} person #{chatID}"
legion = new LegionIO(reply)
#console.log legion
legion.dialog myArgs[0], myArgs[1]