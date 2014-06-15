Item = require('./item')

module.exports = class Message
  constructor: (data) ->
    @items = []

    itemData = data

    while itemData.length > 0
      item = new Item(itemData)
      itemData = itemData.slice(item.length)
      @items.push(item)


  itemWithId: (id) =>
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


  valid: () ->
    @token()[0] != "5"

  to_hash: () ->
    { token: @token(), data: @data(), id: @identifier(), expiry: @expiry(), priority: @priority() }


  to_s: () ->
    "Message(token: #{@token()}, valid: #{@valid()}, data: #{@data()}, id: #{@identifier()}, expire: #{@expiry()}, priority: #{@priority()})"

