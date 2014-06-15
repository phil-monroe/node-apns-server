Frame = require('./models/frame')
BadTokenError = require('./models/bad_token_error')

module.exports = class APNSConnection
  constructor: (server, connection) ->
    @server     = server
    @connection = connection

    @connection.on 'data', @dataReceived
    @connection.on 'end',  @connectionClosed

    @totalMessages = 0
    @debug = process.env.DEBUG == "true"


  dataReceived: (data) =>
    if @error
      return

    messages = @parseMessages(data)

    idx = -1
    for message, i in messages
      if !message.valid()
        idx = i
        break

    if idx > -1
      @error = new BadTokenError(messages[idx])
      @connection.write(@error.buffer)
      @connection.end()

      if idx == 0
        messages = []
      else
        messages = messages.slice(0, idx)

    if(@debug)
      console.log(message.to_s()) for message in messages

    if(messages.length > 0)
      @server.recievedMessages(messages)



  connectionClosed: () =>


  parseMessages: (data) ->
    @parseFrames(data).map (frame) ->
      frame.message()


  parseFrames: (data) ->
    frames = []
    frameData = data

    if @extraData
      frameData = Buffer.concat([@extraData, frameData])

    while frameData.length != 0
      frame = new Frame(frameData)
      if frame.valid()
        frames.push(frame)
        frameData = frameData.slice(frame.length)
        @extraData = null
      else
        @extraData = frameData
        break

    frames
