#!/usr/bin/env coffee
Telegram = require('telegram-bot')

tg = new Telegram(process.env.TELEGRAM_BOT_TOKEN)
tg.sendMessage
  text: "bot online"
  chat_id: process.env.TELEGRAM_CHATID1
