#!/usr/bin/env coffee
LegionIO = require('..')
Telegram = require('telegram-bot')


tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN)

tgMessage = (text, chatID) ->
  tg.sendMessage
    text: text
    chat_id: chatID 

legion = new LegionIO(tgMessage)

# Historical reasons..
myChatID = process.env.TELEGRAM_CHATID1
myChatID2 = process.env.TELEGRAM_CHATID2
tg.on 'message', (msg) ->
  console.log 'msg', msg
  if !msg.text
    return
  if msg.chat.id != myChatID
    if msg.chat.id != myChatID2
      return
  legion.dialog msg.text, msg.chat.id
  console.log 'Dialog over'
  return
tg.start()