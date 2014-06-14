Message = require('./message')

module.exports = class Frame
  constructor: (data) ->
    offset = 0
    @command = data.readUInt8(offset)
    offset += 1

    @dataLength = data.readUInt32BE(offset)
    offset += 4

    @length = @dataLength + 5

    @data = data.slice(offset, offset + @dataLength)


  valid: ->
    @dataLength == @data.length


  message: ->
    new Message(@data)