
module.exports = class BadTokenError
  constructor: (message) ->
    identifier = 0
    if message
      identifier = message.identifier()

    @buffer = new Buffer(6)
    @buffer[0] = 8
    @buffer[1] = 8
    @buffer.writeUInt32BE(identifier, 2)

