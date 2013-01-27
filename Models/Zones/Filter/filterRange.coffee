define ->

  class FilterRange

    constructor: (@fieldFrom, @fieldTo, from, to, @valSerializer) ->
      @from = ko.observable from
      @to = ko.observable to
      @expr = ko.computed =>
        json = eval "({'#{fieldFrom}' : {'$gte' : null}, '#{fieldTo}' : {'$lte' : null}})"
        json[fieldFrom].$gte = @from()
        json[fieldTo].$lte = @to()
        json
      @valSerializer ?=
        serialize: (val) => val
        deserialize: (obj) => obj

    update: (fromExpr) ->
      from = fromExpr[@fieldFrom].$gte
      to = fromExpr[@fieldTo].$lte
      if @valSerializer
        from = @valSerializer.deserialize from
        to = @valSerializer.deserialize to
      @from from
      @to to

    serialize: ->
      range :
        from : @valSerializer.serialize @from()
        to : @valSerializer.serialize @to()

    deserialize: (obj) ->
      if obj.range
        @from @valSerializer.deserialize obj.range.from
        @to @valSerializer.deserialize obj.range.to

  FilterRange : FilterRange
