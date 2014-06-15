
module.exports = class BadTokenError
  constructor: (message) ->
    identifier = 0
    if message
      identifier = message.identifier()

    @buffer = new Buffer(6)
    @buffer[0] = 8
    @buffer.writeUInt8(8, 1)
    @buffer.writeUInt32BE(identifier, 2)
