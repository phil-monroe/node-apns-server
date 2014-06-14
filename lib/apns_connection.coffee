Message        = require('./models/message')
Item           = require('./models/item')

module.exports = class APNSConnection
  constructor: (server, connection) ->
    @server     = server
    @connection = connection

    @connection.on 'data', @dataReceived
    @connection.on 'end',  @connectionClosed

  dataReceived: (data) =>
    console.log("======")
    console.log(message.to_s()) for message in @parseMessages(data)

  connectionClosed: () =>
    console.log("fin")

  parseMessages: (data) =>
    offset = 0
    messages = []
    try
      while offset < data.length
        message = new Message
        baseOffset = offset
        command = data.readUInt8(offset)
        offset += 1

        frameLength = data.readUInt32BE(offset)
        offset += 4

        while (offset - baseOffset) < frameLength + 2
          itemId = data.readUInt8(offset)
          offset += 1

          itemDataLength = data.readUInt16BE(offset)
          offset += 2

          itemData = data.slice(offset, offset+itemDataLength)
          offset += itemDataLength

          switch itemId
            when 1 # Token
              itemData = itemData.toString('hex')

            when 2 # Data
              itemData = itemData.toString()

            when 3 # Identifier
              itemData = itemData.readUInt32BE(0)

            when 4 # Expiration
              itemData = itemData.readUInt32BE(0)

            when 5 # Priority
              itemData = itemData.readUInt8(0)

            else # Unknown
              throw "NOPE"

          message.items.push(new Item(itemId, itemData))
        messages.push(message)
    catch error
      console.log(error)

    messages



