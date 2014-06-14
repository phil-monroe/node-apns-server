Frame = require('./models/frame')

module.exports = class APNSConnection
  constructor: (server, connection) ->
    @server     = server
    @connection = connection

    @connection.on 'data', @dataReceived
    @connection.on 'end',  @connectionClosed

    @totalMessages = 0


  dataReceived: (data) =>
    messages = @parseMessages(data)
    console.log(message.to_s()) for message in messages
    @totalMessages += messages.length


  connectionClosed: () =>
    console.log("received messages: #{@totalMessages}")
    console.log("fin")


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
