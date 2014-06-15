Frame = require('./models/frame')
BadTokenError       = require('./models/bad_token_error')
ServerShutdownError = require('./models/server_shutdown_error')


module.exports = class APNSConnection
  constructor: (server, connection) ->
    @server     = server
    @connection = connection

    @connection.on 'data', @dataReceived
    @connection.on 'end',  @connectionClosed

    @totalMessages = 0
    @debug = process.env.DEBUG == "true"
    @lastIdentifier = undefined


  dataReceived: (data) =>
    return if @error

    if @error = @serverShutdownError()
      messages = []
    else
      [messages, @error] = @parseMessages(data)


    if @error
      @handleError(@error)

    if(@debug)
      console.log(message.to_s()) for message in messages

    if(messages.length > 0)
      @lastIdentifier = messages[messages.length-1].identifier()
      @server.recievedMessages(messages)


  connectionClosed: () ->



  serverShutdownError: () ->
    if @lastIdentifier != undefined && Math.random() < 0.05
      new ServerShutdownError(@lastIdentifier)


  handleError: (error) =>
    console.log(error.constructor.name)
    @connection.write(@error.buffer)
    @connection.end()


  parseMessages: (data) ->
    error = undefined
    messages = @parseFrames(data).map (frame) ->
      unless error
        message = frame.message()
        if message.valid()
          message
        else
          error = new BadTokenError(message)
          undefined

    messages = messages.filter (msg) ->
      msg != undefined

    [messages, error]


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
