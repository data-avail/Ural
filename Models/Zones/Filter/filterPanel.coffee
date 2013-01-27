define ->

  class FilterPanel

    constructor: (@filters, @orderBy) ->
      for f in @filters
        @[f.name] = ko.observable f.item

    update: (from) ->
      for f in from
        filter = @[f.__meta.name]
        if filter then filter().update f

    _expr: (isCustom) ->
      r = @filters.filter((f) -> (!isCustom and !f.item.isCustom) or (isCustom and f.item.isCustom))
        .map((f) -> f.item.expr()).filter((f)->f)
      if r.length then r else null

    expr: ->
      r = @_expr false
      if r then $and : r else null

    custom: ->
      r = @_expr true
      if r then $and : r else null

    exprMeta: ->
      res = {}
      for i in @filters.filter((f) -> f.item.exprMeta)
        m = i.item.exprMeta()
        for own p of m
          break
        res[p] = m[p]
      if $.isEmptyObject res then null else res

    order: ->
      if @orderBy then @orderBy.expr() else null

    change: ->
      if @onChangedCallback
        @onChangedCallback @expr(), @order(), @custom()

    onChanged: (@onChangedCallback) ->

    serialize: ->
      res = []
      for f in @filters
        if f.item.serialize then res.push name : f.name, expr : f.item.serialize()
      if @orderBy and @orderBy.serialize
        res.push name : "$orderby", expr : @orderBy.serialize()
      res

    deserialize: (obj, onDone) ->
      if obj
        for f in @filters
          if f.item.deserialize
            d = obj.filter((i) -> i.name == f.name)[0]
            if d then f.item.deserialize d.expr
        if @orderBy and @orderBy.deserialize
          d = obj.filter((i) -> i.name == "$orderby")[0]
          if d then @orderBy.deserialize d.expr
      onDone()

  FilterPanel : FilterPanel