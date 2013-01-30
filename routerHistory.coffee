define ["Ural/Controllers/controllerBase", "Ural/Modules/pubSub", "crossroads", "hasher"],
(controllerBase, pubSub, crossroads, hasher) ->

  class RouterBase
    constructor: (@controllerDirectory, @defaultRoute, @defaultFile) ->
      @_recAction = name : null , obj : null, action : null
      @_recHash = null
      @addRoute '{controller}/index', true, (ctr, ck) =>
        @onControllerRouter ctr, "index", null, ck
      @addRoute '{controller}/item/{idx}', true, (ctr, idx, ck) =>
        @onControllerRouter ctr, "item", idx, null, ck
      @addRoute '{controller}', true, (ctr, ck) =>
        @onControllerRouter ctr, null, null, ck
      pubSub.sub "href", "change", (data) =>
        @_hash data.href

    _exec: (execArgs) ->
      args = execArgs.split("!").map (m) -> m.split("/").filter((f) -> f)
      pubSub.pub "router", "exec", args : args

    _hash: (val, silent) ->
      #hasher.getHash().replace(/^([^!]+)\/!\/(.*)/, "$1")
      if val == undefined
        hash = window.history.state
        if hash then hash.replace(/^([^!]+)\/!\/(.*)/, "$1") else null
      else
        val = val.replace /^(\/)/, ""
        hash = "/" + val
        if !silent
          window.history.pushState val, val, hash
          crossroads.parse val
        else
          window.history.replaceState val, val, hash


    removeRoute: (route) ->
      crossroads.removeRoute route

    addRoute: (route, appendExecRoute, callback) ->
      crossroads.addRoute route, callback

    onNotFound: ->
      @onRouteChanged null, null

    onControllerRouter: (controller, action, index, callback, persistRoute) ->
      @_recHash = @_hash()
      if @_recAction.obj and @_recAction.obj.afterAction
        @_recAction.obj.afterAction @_recAction.action
      index = @onParseIndex controller, action, index
      if @_recAction.name != controller
        action ?= "index"
        controllerName = "#{controller}Controller"
        capControllerName = "#{_.str.capitalize controller}Controller"
        require ["#{@controllerDirectory}/#{controllerName}"], (controllerModule) =>
          ctl = eval "new controllerModule.#{capControllerName}()"
          ctl[action] index
          @_recAction = name : controller, obj : ctl, action : action
          if callback then callback()
          if !persistRoute
            @onRouteChanged controller, action
      else
        @_recAction.action = action
        @_recAction.obj[action] index
        if !persistRoute
          @onRouteChanged controller, action

    onRouteChanged: (controller, action) ->
      if @onRouteChangedCallback then @onRouteChangedCallback controller, action

    startRouting: ->
      window.onpopstate = (e) =>
        crossroads.parse e.state

      crossroads.bypassed.add (request) =>
        @onNotFound()

      #this sction used for authoriztion callbacks only
      hasher.changed.add @parseHash #parse hash changes
      hasher.init() #start listening for history change


      hash = window.location.pathname.replace /^(\/)/, ""
      hash = @defaultRoute if !hash or hash == @defaultFile
      if hash
        @_hash hash

    #onParseIndex: (controller, action, index) -> parseInt index
    onParseIndex: (controller, action, index) -> index

    parseHash: (newHash, oldHash) =>
      @_exec newHash
      hasher.replaceHash null

  RouterBase : RouterBase
