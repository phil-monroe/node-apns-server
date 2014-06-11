net = require('net')
util = require('util')
tls = require('tls')
fs  = require('fs')

HOST = '127.0.0.1'
PORT = 7777

options = {
  key: fs.readFileSync('./certs/server-key.pem'),
  cert: fs.readFileSync('./certs/server-cert.pem'),
  allowHalfOpen: true,

  # // This is necessary only if using the client certificate authentication.
  requestCert: true

  # // This is necessary only if the client uses the self-signed certificate.
  # ca: [ fs.readFileSync('client-cert.pem') ]
}

class Message
  constructor: () ->
    @items = []


  itemWithId: (id) ->
    items = @items.filter (item) ->
      item.id == id
    items[0] || {}

  token: () ->
    @itemWithId(1).data

  data: () ->
    @itemWithId(2).data

  identifier: () ->
    @itemWithId(3).data

  expiry: () ->
    @itemWithId(4).data

  priority: () ->
    @itemWithId(5).data

  to_s: () ->
    "Message(token: #{@token()}, data: #{@data()}, id: #{@identifier()}, expire: #{@expiry()}, priority: #{@priority()})"


class Item
  constructor: (id, data)->
    @id = id
    @data = data


parseMessages = (data) ->
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

messages = []

server = tls.createServer options, (conn) ->
  count = 0
  bytes = 0

  console.log('server connected', conn.authorized ? 'authorized' : 'unauthorized')
  # console.log(conn.getPeerCertificate())

  conn.on 'data', (data) ->
    console.log("======")
    messages = parseMessages(data)
    console.log(message.to_s()) for message in messages




  conn.on 'end', () ->
    console.log("fin")
    conn.end

server.listen PORT, HOST, () ->
  console.log('server bound');
