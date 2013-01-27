define ->

  class OptSingle

    constructor: (@field, opts, selectedOpt, @valSerializer) ->
      @opts = ko.observableArray()
      if opts
        @opts.push t for t in opts
      @selectedOpt = ko.observable selectedOpt
      @expr = ko.computed =>
        if @selectedOpt()
          eval "({'#{field}' : #{@getExprArg @selectedOpt()}})"
      @valSerializer ?=
          serialize: (val) => val
          deserialize: (obj) => obj

    update: (fromExpr) ->
      val = fromExpr[@field]
      val = @valSerializer.deserialize val
      @selectedOpt val

    getExprArg: (opt) ->
      opt = opt.id() if opt.id
      if typeof opt == "string" then "'#{opt}'" else opt

    text: ->
      if @selectedOpt().id and @selectedOpt().name
        @_getOptName @selectedOpt().id()

    _getOptName: (id) ->
      @opts().filter((f) -> f.id() == id)[0].name()

    serialize: -> @valSerializer.serialize @selectedOpt()

    deserialize: (obj) ->
      @selectedOpt @valSerializer.deserialize obj

  OptSingle : OptSingle