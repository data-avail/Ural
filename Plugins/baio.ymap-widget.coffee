$.widget "baio.ymap",

  #key, val
  options:
    source : null

  _create: ->
    opts =
      center :  [55.76, 37.64]
      zoom : 7

    @map = new ymaps.Map @element[0], opts

