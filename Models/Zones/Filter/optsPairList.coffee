define ->

  class OptsPairList

    constructor: (@field, opts, selectedOpts, @valSerializer, @exprField) ->
      @selectAllNullExpr = true
      @opts = ko.observableArray()
      @selectedOpts = ko.observableArray()
      @activeOpts = ko.observableArray()
      @unselectedOpts = ko.computed =>
        sid = @selectedOpts().map (m) -> m.id()
        @opts().filter (f) -> sid.indexOf(f.id()) == -1
      @refresh opts, selectedOpts
      @expr = ko.computed =>
        selected = @selectedOpts()
        if selected.length and (selected.length != @opts().length or !@selectAllNullExpr)
          json = eval "({'#{field}' : {'$in' : []}})"
          json[field].$in.push @getExprArg t for t in @selectedOpts()
        json
      @valSerializer ?=
        serialize: (val) => val
        deserialize: (obj) => obj

    refresh: (opts, selectedOpts) ->
      if opts
        d = (if Array.isArray opts then opts else opts()).map (m) -> m
        @opts d
      if selectedOpts
        d = (if Array.isArray selectedOpts then selectedOpts else selectedOpts()).map (m) -> m
        @selectedOpts d
      else
        sid = @opts().map (m) -> m.id()
        d = @selectedOpts().filter (f) -> sid.indexOf(f.id()) != -1
        @selectedOpts d.map (m) -> m

    getExprArg: (opt) ->
      if @exprField
        opt[@exprField]()
      else if opt.id then opt.id() else opt

    push: (item, event) =>
      if !@selectedOpts().filter((f) -> f.id() == item.id()).length
        @selectedOpts.push item

    update: (fromExpr) ->
      @selectedOpts.removeAll()
      @selectedOpts fromExpr[@field].$in.map (m) => @valSerializer.deserialize m

    toggleSelect: (data, event) ->
      event.preventDefault()
      selected = @selectedOpts().filter((f) => @activeOpts().indexOf(f.id()) != -1)
      r = @opts().filter (f) => @activeOpts().indexOf(f.id()) != -1
      if selected.length
        @selectedOpts.removeAll r
      else
        r = r.concat @selectedOpts()
        @selectedOpts r.map (m) -> m

    selectAll: (data, event) ->
      event.preventDefault()
      @selectedOpts @opts().map (m) -> m

    unselectAll: (data,event) ->
      event.preventDefault()
      @selectedOpts.removeAll()

    serialize: ->
      vals : @selectedOpts().map((i) => @valSerializer.serialize(i))

    deserialize: (obj) ->
      if obj.vals
        @selectedOpts obj.vals.map((m) => @valSerializer.deserialize m).filter((f) => f)

  OptsPairList : OptsPairList