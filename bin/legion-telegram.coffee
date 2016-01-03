#!/usr/bin/env coffee
LegionIO = require('..')
Telegram = require('telegram-bot')

# Historical reasons..
myChatID = process.env.TELEGRAM_CHATID1
myChatID2 = process.env.TELEGRAM_CHATID2

tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN)

tgMessage = (text, chatID) ->
  console.log "tgMessage #{text}"
  tg.sendMessage
    text: text
    chat_id: chatID 

# Notify me
tgMessage 'Legion online', myChatID


legion = new LegionIO(tgMessage)

tg.on 'message', (msg) ->
  if !msg.text
    console.log "no text.."
    return
  if "#{msg.chat.id}" != myChatID
    if "#{msg.chat.id}" != myChatID2
      console.log "chatID fubar"
      return
  console.log "legion dialog.."
  legion.dialog msg.text, msg.chat.id
  console.log 'Dialog over'
  return
tg.start()
