class Card
  constructor: (@index) ->

  suit: ->
    @index / 4

  rank: ->
    @index % 13

card = new Card(14)
console.log card.suit
console.log card.rank