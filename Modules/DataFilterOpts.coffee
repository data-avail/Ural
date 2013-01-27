define ->

  class ExpandOpts

    constructor: ->
      @opts = []

    add: (srcName, optName, expand) ->
      srcName ?= ""
      @opts[srcName+":"+optName] = expand

    remove: (srcName, optName) ->
      srcName ?= ""
      delete @opts[srcName+":"+optName]

    get: (srcName, optName) ->
      res = @opts[srcName+":"+optName]
      res ?= @opts[":"+optName]

  class OrderBy

    constructor: ->
      @opts = []

    add: (srcName, orderBy, asc) ->
      srcName ?= ""
      asc ?= "asc"
      @opts[srcName] = "#{orderBy} #{asc}"

    remove: (srcName) ->
      delete @opts[srcName]

    get: (srcName) ->
      res = @opts[srcName]
      res ?= @opts[""]
      res = null if res and res.split(' ')[0] == "null"
      res

  class FilterOpts

    constructor: ->

    nullRefVal: (val) ->
      if val != undefined
        @_nullRefVal = val
      @_nullRefVal

    isNullRef: (item) -> item.id == @_nullRefVal



  expandOpts : new ExpandOpts()
  orderBy : new OrderBy()
  filterOpts : new FilterOpts()