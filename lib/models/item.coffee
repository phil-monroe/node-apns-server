module.exports = class Item
  constructor: (data)->
    offset = 0

    @id = data.readUInt8(offset)
    offset += 1

    @dataLength = data.readUInt16BE(offset)
    offset += 2

    @length = @dataLength + 3

    itemData = data.slice(offset, offset + @dataLength)

    switch @id
      when 1 # Token
        @data = itemData.toString('hex')

      when 2 # Data
        @data = itemData.toString()

      when 3 # Identifier
        @data = itemData.readUInt32BE(0)

      when 4 # Expiration
        @data = itemData.readUInt32BE(0)

      when 5 # Priority
        @data = itemData.readUInt8(0)

      else # Unknown
        throw "NOPE"
