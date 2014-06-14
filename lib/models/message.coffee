module.exports = class Message
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

