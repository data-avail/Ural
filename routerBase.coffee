define ["Ural/Controllers/controllerBase", "Ural/Modules/pubSub", "hasher", "crossroads", "Ural/text!Ural/Views/Shared/AppLoad.html"],
(controllerBase, pubSub, hasher, crossroads) ->

  class RouterBase
    constructor: (@controllerDirectory, @defaultRoute) ->
      @onLoading()
      @_recAction = name : null , obj : null, action : null
      @_recHash = null
      @addRoute '{controller}/index', true, (ctr, ck) =>
        @onControllerRouter ctr, "index", null, ck
      @addRoute '{controller}/item/{idx}', true, (ctr, idx, ck) =>
        @onControllerRouter ctr, "item", idx, null, ck
      @addRoute '{controller}', true, (ctr, ck) =>
        @onControllerRouter ctr, null, null, ck


    _exec: (execArgs) ->
      args = execArgs.split("!").map (m) -> m.split("/").filter((f) -> f)
      pubSub.pub "router", "exec", args : args

    _hash: ->
      hasher.getHash().replace(/^([^!]+)\/!\/(.*)/, "$1")

    _setHashSilently: (hash) ->
      hasher.changed.active = false
      hasher.setHash hash
      hasher.changed.active = true

    removeRoute: (route) ->
      crossroads.removeRoute route

    addRoute: (route, appendExecRoute, callback) ->
      crossroads.addRoute route, callback
      if appendExecRoute
        execRoute = "#{route}/!/{exec*}"
        crossroads.addRoute execRoute, =>
          args = _u.argsToArray arguments
          exec = args[args.length - 1]
          hash = @_hash()
          @_setHashSilently hash
          if @_recHash != hash
            args.splice args.length - 1, 1, => @_exec exec
            callback.apply @, args
          else
            @_exec exec

    getOnLoadingPage: -> "Ural/Views/Shared/AppLoad.html"

    onLoading: ->
      #controllerBase.ControllerBase.loadView null, @getOnLoadingPage()

    onNotFound: ->
      controllerBase.ControllerBase.loadView null, "Ural/Views/Shared/NotFound.html"
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
      #setup hasher
      parseHash = (newHash, oldHash) -> crossroads.parse newHash
      hasher.initialized.add(parseHash); #parse initial hash
      hasher.changed.add(parseHash); #parse hash changes
      hasher.init(); #start listening for history change
      if !hasher.getHash()
        hasher.setHash @defaultRoute
      crossroads.bypassed.add (request) =>
        console.log request
        @onNotFound()

    #onParseIndex: (controller, action, index) -> parseInt index
    onParseIndex: (controller, action, index) -> index

  RouterBase : RouterBase
