define ->

  class OptsList

    constructor: (@field, opts, selectedOpts, @valSerializer) ->
      @opts = ko.observableArray()
      @selectedOpts = ko.observableArray()
      if opts
        @opts.push t for t in opts
      if selectedOpts
        @selectedOpts.push t for t in selectedOpts
      @expr = ko.computed =>
        if @selectedOpts().length
          json = eval "({'#{field}' : {'$in' : []}})"
          json[field].$in.push @getExprArg t for t in @selectedOpts()
        json
      @valSerializer ?=
        serialize: (val) => val
        deserialize: (obj) => obj

    getExprArg: (opt) ->
      if opt.id then opt.id() else opt

    push: (item, event) =>
      if !@selectedOpts().filter((f) -> f.id() == item.id()).length
        @selectedOpts.push item

    update: (fromExpr) ->
      @selectedOpts.removeAll()
      for f in fromExpr[@field].$in
        f = @valSerializer.deserialize f
        @selectedOpts.push f

    serialize: ->
      vals : @selectedOpts().map((i) => @valSerializer.serialize(i))

    deserialize: (obj) ->
      @selectedOpts.removeAll()
      @selectedOpts.push @opts()[0]
      if obj.vals
        for v in obj.vals
          @selectedOpts.push @valSerializer.deserialize v

  OptsList : OptsList