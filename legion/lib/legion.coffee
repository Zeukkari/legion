{parseString} = require 'xml2js'
openhab_request = require('request')
shell_exec = require('shell_exec').shell_exec
apiai = require('apiai')
wolframAlpha = require('wolfram-alpha')

# API keys
SUBSCRIPTION_KEY = process.env.SUBSCRIPTION_KEY_LEGION
ACCESS_KEY = process.env.ACCESS_KEY_LEGION
WOLFRAM_APPID = process.env.WOLFRAM_APPID

# Config
RestURL = 'http://192.168.1.106:8080/rest/items' # fix this..


class LegionIO

  constructor:(replyMethod) ->
    @wolfram = wolframAlpha.createClient(WOLFRAM_APPID) # Wolfram Alpha
    @AIService = apiai(ACCESS_KEY, SUBSCRIPTION_KEY) # api.ai

    # Override this per implementation
    @reply = replyMethod
    unless(@reply)
      @reply = @dummyReply

  dummyReply: (speech, chatID) ->
    console.log "#{chatID}: #{speech}"    

  ##
  # OpenHAB REST
  ##
  openhabRPC: (dialog_cb, request_type, item, state) ->
    #console.log "openhabRPC request_type: #{request_type}, item: #{item}, state: #{state}"
    url = RestURL + '/' + item
    #console.log "Item #{item}"
    cb = (err, httpResponse, body) =>
      parseString body, (err, result) =>
        item = result.item
        dialog_cb(item.state)
    if request_type == 'post'
      curl_cmd = 'curl --header "Content-Type: text/plain" --request POST --data "' + state + '" ' + url
      #curl_cmd = curl_cmd + " >/dev/null 2>&1"
      #console.log "Exec curl: "
      shell_exec curl_cmd
      dialog_cb("#{item}: sent command #{state}")
    else if request_type == 'get'
      openhab_request.get({ url: url }, cb)
    return

  ##
  # Wolfram API
  ##
  wolframQuery: (dialog_cb, query) =>
    console.log "Wolframquery: #{query}"
    @wolfram.query query, (err, result) ->
      console.log result
      console.log "---------------------result over----------"
      for pod in result when pod.primary == true && pod.title == "Result"
        #console.log pod
        for subpod in pod.subpods
          console.log subpod
          if subpod.text
            console.log "Wolfram says:\t #{subpod.text}"
            dialog_cb("Wolfram says:\t #{subpod.text}")


  dialog: (query, chatID) =>
    console.log 'Query: ' + query
    request = @AIService.textRequest(query)

    #dialog_cb = (text) =>

    request.on 'response', (response) =>
      #console.log 'Process response..', response
      if(response?.result?.source == "agent")

        # Callback
        dialog_cb = (state) =>
          replyTemplate = response?.result?.fulfillment?.speech or ""
          text = replyTemplate.replace /@state/, state
          @reply(text, chatID)

        # Speech output
        speech = response?.result?.fulfillment?.speech or 'processing..'

        # Command parsing
        device = response?.result?.parameters?.device or ''
        state = response?.result?.parameters?.state or ''
        action = response?.result?.action or ''

        #console.log "speech: #{speech}, device: #{device}, state: #{state}"

        if(!action)
          #console.log 'Missing action'
          @reply(speech,chatID)
        else if(!device)
          #console.log 'Missing device'
          @reply(speech,chatID)
        else if (action == "homecontrol.set")
          if(!state)
            @reply(speech,chatID)
          @openhabRPC dialog_cb, 'post', device, state
        else if (action == "homecontrol.get")
          @openhabRPC dialog_cb, 'get', device, state
      else if(response?.result?.source == "domains")
        #console.log "Lost in the domains.."
        speech = response?.result?.fulfillment?.speech or "I don't know this action! Action: #{response.result.action}"
        @reply(speech, chatID)
      else if(response?.result?.source == "agent")
        speech = response?.result?.fulfillment?.speech
        if(speech)
          @reply(speech,chatID)
        else
          #console.log "Try Wolfram? TBD.."
          #wolframQuery dialog_cb, response?.result?.resolvedQuery
          dialog_cb "Try Wolfram? TBD.."
    request.on 'error', (error) ->
      console.log error
    request.end()

module.exports = LegionIO