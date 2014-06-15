
module.exports = class ServerShutdownError
  constructor: (identifier) ->
    @buffer = new Buffer(6)
    @buffer[0] = 8
    @buffer.writeUInt8(10, 1)
    @buffer.writeUInt32BE(identifier, 2)
