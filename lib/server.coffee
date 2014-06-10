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
  constructor: ->
    @items = []


  itemWithId: (id) ->
    items = @items.filter (item) ->
      item.id == id
    items[0]

  token: ->
    @itemWithId(1).data

  data: ->
    @itemWithId(2).data

  identifier: ->
    @itemWithId(3).data

  expiry: ->
    @itemWithId(4).data

  priority: ->
    @itemWithId(5).data


class Item
  constructor: (id, data)->
    @id = id
    @data = data


parseMessages = (data) ->
  offset = 0
  messages = []

  while offset < data.length
    console.log("new message")
    message = new Message
    baseOffset = offset
    command = data.readUInt8(offset)
    offset += 1
    console.log(command)

    frameLength = data.readUInt32BE(offset)
    offset += 4

    while (offset - baseOffset) < frameLength
      console.log("dataLenth:   #{data.length}")
      console.log("offset:      #{offset}")
      console.log("baseoffset:  #{baseOffset}")
      console.log("adjusted:    #{offset-baseOffset}")
      console.log("frameLength: #{frameLength}")

      itemId = data.readUInt8(offset)
      offset += 1

      itemDataLength = data.readUInt16BE(offset)
      offset += 2

      itemData = data.slice(offset, offset+itemDataLength)




      switch itemId
        when 1 # Token
          console.log(">>> TOKEN")
          itemData = itemData.toString('hex')
          console.log(itemData)
          offset += itemData.length
        when 2 # Data
          console.log(">>> payload")
          itemData = itemData.toString()
          console.log(itemData)
          offset += itemData.length
        when 3 # Identifier
          console.log(">>> 3")
          itemData = itemData.readUInt32BE(0)
          offset += 4
        when 4 # Expiration
          console.log(">>> 4")
          itemData = itemData.readUInt32BE(0)
          offset += 4
        when 5 # Priority
          console.log(">>> 5")
          itemData = itemData.readUInt8(0)
          offset += 1
        else # Unknown
          console.log("ELSE!!! #{itemId}")
          itemData = itemId


      message.items.push(new Item(itemId, itemData))

    console.log("end message")
    console.log()
    messages.push(message)

  messages

messages = []

server = tls.createServer options, (conn) ->
  count = 0
  bytes = 0

  console.log('server connected', conn.authorized ? 'authorized' : 'unauthorized')
  # console.log(conn.getPeerCertificate())

  conn.on 'data', (data) ->
    console.log("======")
    parseMessages(data)
    console.log("Received Messages")





  conn.on 'end', () ->
    console.log("fin")
    conn.end

server.listen PORT, HOST, () ->
  console.log('server bound');
