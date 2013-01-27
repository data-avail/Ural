define ["Ural/Modules/pubSub", "Ural/Libs/jquery.dynatree", "Ural/Plugins/baio.tree-widget"], (pubSub) ->

  _getOpts = (selector, treeOpts, iniOpts) ->
    opts =
      select: "single"
      source: iniOpts.source
      update: iniOpts.update
      remove: iniOpts.remove
      editable : true
      onSelected: (node) ->
        if selector then selector.select node
      selected:
        if selector then selector.getSelected() else null
    if treeOpts
      if selector
        opts.select = if treeOpts.multi then "multi" else "single"
      else
        opts.select = false
      if treeOpts.link
        opts.link = treeOpts.link
      if treeOpts.selectedLink
        opts.selectedLink = treeOpts.selectedLink
      if treeOpts.root
        opts.root = treeOpts.root
      opts.editable = false if treeOpts.editable == false
    opts

  _iniToolbox = (tr) ->
    pubSub.subOnce "selector", "toolbox", "selector", (data)->
      if typeof data.data == "string"
        t = $("#" + data.data)
      else
        t = tr
      switch data.action
        when "add" then t.tree("add")
        when "add_root" then t.tree("addRoot")
        when "rename" then t.tree("rename")
        when "remove" then t.tree("remove")

  ini = (iniOpts) ->
    ko.bindingHandlers.tree =
      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        selector = ko.utils.unwrapObservable valueAccessor()
        treeOpts = allBindingsAccessor().treeOpts
        lt = if treeOpts and treeOpts.layout then $("#"+treeOpts.layout) else $(element)
        if selector == null
          tr = lt.tree _getOpts selector, treeOpts, iniOpts
          _iniToolbox tr
        else
          $(element).click (event) ->
            event.preventDefault()
            lt.tree "destroy"
            tr = lt.tree _getOpts selector, treeOpts, iniOpts
            _iniToolbox tr
            selector.start()

  ini : ini