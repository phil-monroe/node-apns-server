http           = require('http')
tls            = require('tls')
fs             = require('fs')
APNSConnection = require('./apns_connection')

module.exports = class APNSServer
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

  constructor: () ->
    @messages = []

    @server     = tls.createServer options, @newConnection
    @httpServer = http.createServer @handleHttpRequest




  newConnection: (conn) =>
    new APNSConnection(this, conn)

  recievedMessages: (messages) ->
    @messages = @messages.concat(messages)
    console.log("received #{messages.length} messages, #{@messages.length} total")

  handleHttpRequest: (req, res) =>
      if(req.url == "/reset")
        console.log("Resetting Messages")
        @messages = []

      else
        messages = @messages.map (m) ->
          m.to_hash()

        res.setHeader("Content-Type", "application/json");
        res.write(JSON.stringify(messages))

      res.end()

  start: =>
    @server.listen PORT, HOST, ->
      console.log('apns server bound')

    @httpServer.listen 9999, HOST, ->
      console.log('http server bound')
