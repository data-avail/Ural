define ["Ural/Models/indexVM"
  , "Ural/Models/itemVM"
  , "Ural/Modules/pubSub"
  , "Ural/Models/Zones/state"
  , "Ural/Modules/socket"
  , "Ural/Libs/toastr"
], (indexVM, itemVM, pubSub, state, socket) ->

  class ControllerBase
    constructor: (@modelName, @opts)->
      @modelName ?= @_getControllerName()
      @defaultIndexLayout = "Shared/_layout"
      @defaultItemLayout = "Shared/_layout"
      @defaultIndexBody = "index"
      @defaultItemBody = "item"
      @viewModel = null
      #opts
      @opts ?= {}
      @opts.index ?= {}
      @opts.index.itemsPerPage ?= 20
      @opts.index.clearOnPageMove ?= true

      pubSub.subOnce "form", "show", "controller", (data) =>
        @onShow data.formId

      pubSub.subOnce "model", "edit", "controller", (data, name) =>
        @_showForm data.formType, _u.getClassName(data.itemVM.item), data.itemVM

      pubSub.subOnce "model", "end_edit", "controller", (data, name) =>
        @_hideForm data.formType, _u.getClassName data.itemVM.item

      pubSub.subOnce "selector", "show", "controller", (data) =>
        @_showSelector data.form

      pubSub.subOnce "selector", "hide", "controller", (data) =>
        @_hideSelector data.form

      pubSub.subOnce "model", "detail", "controller", (model, name) =>
        @onShowDetails model, _u.getClassName model

      pubSub.subOnce "message", "show", "controller", (data) =>
        @onShowMessage data.type, data.msg, data.cap

      pubSub.subOnce "router", "exec", "controller", (data) =>
        @_exec data

      pubSub.subOnce "selector", "addNew", "controller", (data, name, onDone) =>
        @_addNewSelector data.type, (err, item) ->
          onDone err, item

      pubSub.subOnce "model", "list_changed", "controller", (data, name) =>
        @_listChanged data

    onExec: (method, prms) ->
      false

    _exec: (data) ->
      for args in data.args
        prms = args.splice 1, args.length - 1
        if ! @onExec args[0], prms
          method = eval "this.#{args[0]}"
          if method then method.apply @, prms

    _listChanged: (data) ->
      @onListChanged data.changeType, data.itemVM, data.err, data.opts

    onListChanged: (changeType, itemVM, err, opts) ->
      console.log "list changed : #{ changeType }, err : #{err}, opts : #{opts}"
      if opts and opts.ignore_msg then return
      if changeType == "update_begin"
        @onUpdateBegins()
      else
        if err
          @onShowMessage "error", err, __g.i18n.messages.update_fail
        else
          @onShowMessage "success", __g.i18n.messages.update_success
          #if this is index context - then item is update's root in the case of item context - item could be ref item, then use context's view model instead
          item = if @isIndexContext()  then itemVM.item else @viewModel.item
          @onCommitModel @getId(item), itemVM, changeType

    onUpdateBegins : ->

    isIndexContext: ->
      _u.getClassName(@viewModel) != "ItemVM"

    _showSelector: (form) ->
      @onShowForm $("[data-selector='#{form}']")

    _addNewSelector: (type, onDone) ->
      if @viewModel.zones.toolbox and @viewModel.zones.toolbox.addNew
        @viewModel.zones.toolbox.addNew type, onDone

    _hideSelector: (form) ->
      @onHideForm $("[data-selector='#{form}']")

    _showForm: (type, typeName, itemVM) ->
      form = $("[data-form-model-type='#{typeName}'][data-form-type='#{type}']")
      @onShowForm form, itemVM

    onShowForm: ($form, itemVM) ->
      $form.show()

    _hideForm: (type, typeName) ->
      @onHideForm $("[data-form-model-type='#{typeName}'][data-form-type='#{type}']")

    onCommitModel: (rootId, itemVM, actionType) ->

    onHideForm: ($form) ->
      $form.hide()

    onShow: (formId) ->
      form = $("##{formId}")
      @onShowForm form

    onShowDetails: (model, typeName) ->
      @showDetails @getId(model), typeName, model

    showDetails: (id, typeName, model) ->
      window.location.hash = "/#{typeName.toLowerCase()}/item/#{id}"

    onShowMessage: (type, msg, cap) ->
      _u.toastrMsg type, msg, cap

    getId: (model) -> if !$.isFunction model.id then model.id else model.id()

    #type [index|item]
    action: (name, type, modelType, filter, onDone) ->
      if type == "index"
        @modelName = _.str.capitalize modelType
        @createIndexViewModel null
        async.waterfall [
          (ck) =>
            @onAction action : name, begins : true, ck
          (ck) =>
            @onIndex null, null, null, filter, ck
          (data, ck) =>
            @onAction action : name, begins : false, ck
          ], (err) -> if onDone then onDone err
      else
        throw msg : "type arg out of range"

    #context.action, context.begins, context.err
    onAction: (context, onDone) ->
      @pubAction context
      onDone()

    pubAction: (context) ->
      context.controller = @_getControllerName().toLowerCase()
      pubSub.pub "controller", "action", context

    index: (filter, onDone)->
      @action "index", "index", @modelName, filter, onDone
      #@onIndex null, null, null, filter, onDone

    onIndex: (type, bodyView, layoutView, filter, onDone) ->
      #@createIndexViewModel type
      bodyView ?= @defaultIndexBody
      layoutView ?= @defaultIndexLayout
      async.waterfall [
        (ck) =>
          @deserialize @getDefaultDeserializedNames(), ck
        (ck) =>
          @onLoadIndex filter, true, ck
      ,(cnt, ck) =>
          @view bodyView, layoutView, ck
      ], (err) =>
        if onDone then onDone err, @viewModel

    onLoadIndex: (userFilter, isFiltering, onDone) ->
      skipLoad = userFilter and userFilter.$skipLoad
      if skipLoad then userFilter = null
      filter =
        $page : 1
        $itemsPerPage : @opts.index.itemsPerPage
        $expand : "$index"
      if userFilter
        $.extend filter, userFilter
      fr = @filterZone()
      pr = @pagerZone()
      if fr
        filter.$filter = fr.expr()
        filter.$orderby = fr.order()
        filter.$args = customFilter : fr.custom() if fr.custom()
      if !skipLoad
        @onLoadBegins "index", isFiltering
        isCleanUp = isFiltering or @opts.index.clearOnPageMove
        @viewModel.load filter, isCleanUp, (err, data) =>
          @onLoadEnds err, "index"
          if pr
            page = if isFiltering then 1 else filter.$page
            pr.setPaging page : page, itemsPerPage : filter.$itemsPerPage, count : @viewModel.list().length, latestLoadCount : data.length
          if onDone then onDone err, @viewModel.list().length
      else
        if pr then pr.setPaging page : 1, itemsPerPage : filter.$itemsPerPage, count : @viewModel.list().length, latestLoadCount : filter.$itemsPerPage
        if onDone then onDone null, 0

    onLoadBegins: (context, isFiltering) ->
      @stateZone().isLoading true
      @stateZone().isPageMove !isFiltering

    onLoadEnds: (err, context) ->
      @stateZone().isLoading false
      @stateZone().isPageMove false
      @stateZone().isEmptyResult @viewModel.list().length == 0

    createIndexViewModel: (type) ->
      @onCreateIndexViewModel type
      @onCreateZones "index"
      fr = @filterZone()
      pr = @pagerZone()
      if pr
        pr.onChanged (page) =>
          @onLoadIndex $page : page, false
      if fr
        fr.onChanged =>
          @serialize "filter"
          @onLoadIndex null, true

    onCreateIndexViewModel: (type) ->
      type ?= @modelName
      @viewModel = new indexVM.IndexVM type

    item: (id, onDone) ->
      if !@viewModel or _u.getClassName(@viewModel) != "ItemVM"
        @createItemViewModel()
      async.waterfall [
        (ck) =>
          @viewModel.load id, ck
        (item, ck) =>
          @view @defaultItemBody, @defaultItemLayout, ck
      ], (err) =>
        if onDone then onDone err, @viewModel

    createItemViewModel: ->
      @onCreateItemViewModel()
      @onCreateZones "item"

    onCreateItemViewModel: ->
      @viewModel = new itemVM.ItemVM @modelName

    ### zones ###
    onCreateZones: (context) ->
      @viewModel.zones = {}
      @onCreateStateZone context
      @onCreateToolboxZone context
      if context == "index"
          @onCreateFilterZone()
          @onCreatePagerZone()

    onCreateToolboxZone: ->
    onCreateFilterZone: ->
    onCreateStateZone: ->
      @viewModel.zones.state = new state.State()

    onCreatePagerZone: ->
      #@viewModel.zones.pager = new pager.Pager()
      #if @pagerZone().maxLimit then @pagerZone().maxLimit @opts.index.maxItems

    toolboxZone: ->
      if @viewModel.zones then @viewModel.zones.toolbox else null

    filterZone: ->
      if @toolboxZone() and @toolboxZone().filter
        @toolboxZone().filter
      else if @viewModel.zones
        @viewModel.zones.filter
      else
        null

    pagerZone: ->
      if @viewModel.zones then @viewModel.zones.pager else null

    stateZone: ->
      if @viewModel.zones then @viewModel.zones.state else null
    ### ^zones ###

    view: (viewPath, layoutViewPath, onDone) ->
      crName = @_getControllerName()
      lvp = ControllerBase._prepareViewPath crName, layoutViewPath, @defaultItemLayout
      bvp = ControllerBase._prepareViewPath crName, viewPath
      @onViewStartsLoad()
      @loadView crName, lvp, bvp, (err) =>
        if !err
          @root().vm = @viewModel
          ko.applyBindings @root() #@viewModel
        @onViewLoaded err
        if onDone then onDone err

    onViewStartsLoad: ->

    onViewEndsLoad: (layoutHtml, bodyHtml, onDone) ->
      if onDone then onDone()

    @SwapLayout: (layoutHtml, bodyHtml) ->
      $("#_layout").empty()
      $("#_layout").append layoutHtml
      if bodyHtml then $("#_body").append bodyHtml

    onViewLoaded: (err) ->
      @setDefaultFocuses()

    setDefaultFocuses: ->
      $("[data-default-input]").focus()
      if $("[data-default-button]").length
        $(document).bind "keyup", (e) ->
          if e.keyCode == 13
            $("[data-default-button]").click()

    loadView: (controllerName, layoutViewPath, bodyViewPath, onDone) ->
      ControllerBase.LoadView  controllerName, layoutViewPath, bodyViewPath, (err) =>
        @onViewLoaded err
        if onDone then onDone err

    @LoadView: (controllerName, layoutViewPath, bodyViewPath, onDone) ->
      async.waterfall [
        (ck) ->
          require ["Ural/text!#{layoutViewPath}"], (layoutHtml) ->
            ck null, layoutHtml
      ,(layoutHtml, ck) ->
          ControllerBase._renderPartialViews controllerName, layoutHtml, ck
      ,(layoutHtml, ck) ->
          if bodyViewPath
            require ["Ural/text!#{bodyViewPath}"], (bodyHtml) ->
              ck null, layoutHtml, bodyHtml
          else
            ck null, layoutHtml, null
      ,(layoutHtml, bodyHtml, ck) ->
          if bodyHtml
            ControllerBase._renderPartialViews controllerName, bodyHtml, (err, renderedBody) ->
              ck err, layoutHtml, renderedBody
          else
            ck null, layoutHtml, null
      ], (err, layoutHtml, bodyHtml) ->
        ControllerBase.SwapLayout layoutHtml, bodyHtml
        if onDone then onDone err

    @_renderPartialViews: (controllerName, html, callback) ->
      html = _u.wrapHtml html
      ControllerBase.__renderPartialViews controllerName, html, (err, renderedHtml) ->
        if renderedHtml then renderedHtml = $(renderedHtml).html()
        callback err, renderedHtml

    @__renderPartialViews: (controllerName, html, callback) ->
      partialViews = $("[data-partial-view]", html)
      rawPaths = $.makeArray(partialViews.map (i, p) -> $(p).attr "data-partial-view")
      paths = rawPaths.map (p) ->
        "Ural/text!#{ControllerBase._prepareViewPath controllerName, p}"
      if paths.length
        require paths, ->
          partialHtmls = _u.argsToArray arguments
          viewsHash = []
          for partialHtml, i in partialHtmls
            $h = $(html)
            idx = viewsHash[rawPaths[i]]
            idx ?= 0
            $pratialViewTag = $h.find "[data-partial-view='#{rawPaths[i]}']:eq(#{idx})"
            viewsHash[rawPaths[i]] = idx+1
            viewBag = $pratialViewTag.attr "data-partial-view-bag"
            $pratialViewTag.removeAttr "data-partial-view"
            $pratialViewTag.removeAttr "data-partial-view-bag"
            jViewBag = if viewBag then eval "(#{viewBag})" else {}
            $.templates pvt : partialHtml
            partialHtml = $.render.pvt jViewBag
            $pratialViewTag.html partialHtml
            html = _u.wrapHtml $h.html()
          async.forEachSeries partialHtmls
            ,(ph, ck) ->
              ControllerBase.__renderPartialViews controllerName, html, (err, renderedHtml) ->
                html = renderedHtml
                ck err
            ,(err) -> callback err, html
      else
        callback null, html

    @_prepareViewPath: (controllerName, path, defPath) ->
      if path and _.str.count(path, '/') >= 2
        if !path.match /^Views\/.*/ or _.str.count(path, '/') > 2
          if !path.match /.*\.htm[l]?/
            path += ".html"
          return path
      path ?= defPath
      if path
        if !path.match /.*\.htm[l]?/
          path += ".html"
        if !path.match /^Views\/.*/
          if !path.match /.*\/.*/
            "Views/#{controllerName}/#{path}"
          else
            "Views/#{path}"
        else
          path

    _getControllerName: -> _u.getClassName(@).replace /^(\w*)Controller$/, "$1"

    setRoute: (route, silently) ->
      pubSub.pub "router", "set", { route : route, silently : silently }

    ### serialize / deserialize ###

    getSerializationName: ->
      "controller.#{@modelName}.#{if _u.getClassName(@viewModel) == "ItemVM" then "item" else "index"}"

    _store: (name, obj) ->
      storeName = @getSerializationName()
      name = "#{storeName}.#{name}"
      amplify.store name, obj

    _restore: (name) ->
      storeName = @getSerializationName()
      name = "#{storeName}.#{name}"
      amplify.store name

    serialize: (names) ->
      names ?= []
      names = [names] if !Array.isArray names
      for name in names
        data = @onSerialize name
        if data
          @_store name, data

    getDefaultDeserializedNames: -> ["filter"]

    deserialize: (names, onDone) ->
      names ?= []
      names = [names] if !Array.isArray names
      @_onDeserialize (name for name in names), onDone

    _onDeserialize: (names, onDone) ->
      async.forEach names, ((name, ck) => @onDeserialize(name, @_restore(name), ck)), onDone

    onSerialize: (name) ->
      if name == "filter"
        @filterZoneSerialize()

    onDeserialize: (name, data, onDone)->
      if name == "filter"
        @filterZoneDeserialize data, onDone

    filterZoneSerialize: ->
      fr = @filterZone()
      if fr and fr.serialize
        fr.serialize()

    filterZoneDeserialize: (data, onDone)->
      fr = @filterZone()
      if data and fr and fr.deserialize
        fr.deserialize data, onDone
      else onDone()

    ### serialize / deserialize ###

    ###Sockets###

    setStreamSocket: (channel, event) ->
      socket.get().sub channel, event, (data) =>
        @onStreamSocket channel, event, data

    releaseStreamSocket: (channel, event)->
      socket.get().unsub channel, event

    onStreamSocket: (channel, event, data) ->
      console.log data
      if event == "added"
        @onIndexStreamSocket data

    setIndexStreamSocket: (channelName) ->
      channelName ?= "#{@modelName.toLowerCase()}_index"
      @setStreamSocket channelName, "added"

    releaseIndexStreamSocket: (channelName) ->
      channelName ?= "#{@modelName.toLowerCase()}_index"
      @releaseStreamSocket channelName, "added"

    onIndexStreamSocket: (data) ->
      @viewModel.addNewItem data

    ###Sockets###

    root: -> __g.root

  ControllerBase : ControllerBase