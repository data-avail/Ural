define ->

  class OrderByList
    #opts key : xxx, val : yyy
    constructor: (opts, selectedKey) ->
      @opts = ko.observableArray()
      if opts
        @opts.push t for t in opts
      @selectedOpt = ko.observable()
      if selectedKey then @select selectedKey

      @expr = ko.computed =>
        if @selectedOpt()
          @selectedOpt().key

    select: (key) ->
      @selectedOpt @opts().filter((f) -> f.key == key)[0]

    serialize: ->
      key : @selectedOpt().key

    deserialize: (obj) ->
      if obj.key
        @select obj.key

  OrderByList : OrderByList