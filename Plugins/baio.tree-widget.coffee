$.widget "baio.tree",

  #key, val
  options:
    source : null
    update : null
    remove : null
    link : "TreeTag"
    root : null
    select : false #"multi|single"
    onSelected : null
    selected : []
    selectedLink : null
    editable : true

  _prepareLink: (srcLink, parent) ->
    link = $.extend true, {}, srcLink
    parent ?= @options.root
    if link.filter
      _u.replaceFieldVal link.filter, "$parent", parent
      if @options.selected
        _u.replaceFieldVal link.filter, "$selected", @options.selected.toString()
    if link.args
      _u.replaceFieldVal link.args, "$parent", parent
      if @options.selected
        _u.replaceFieldVal link.args, "$selected", @options.selected.toString()
    link

  _load: (link, parent, res) ->
    req = link : if typeof link == "string" then link else @_prepareLink(link, parent)
    @options.source req, (respTags) ->
      res respTags.map (t) ->
            title : t.value
            isLazy : true
            key : t.key
            label : t.label
            parent : t.parent

  _tree: ->  $(@element[0]).dynatree "getTree"

  _focusedNode: ->
    ###
    nodes = @_tree().getSelectedNodes()
    focused = nodes.filter((f)->f.isFocused())[0]
    focused ?= nodes[0]
    focused ?= @_tree().getActiveNode()
    focused
    ###
    @_tree().getActiveNode()

  _loadSelected: ->
    if @options.selectedLink
      @_load @options.selectedLink, null, (res) =>
        for r in res.sort((a,b) -> a.key > b.key)
          node = @_tree().getNodeByKey r.parent
          if node != null
            node.addChild r
        @_setSelected()
    else
      @_setSelected()

  _setSelected: ->
    if @options.selected
      for s in @options.selected
        node = @_tree().getNodeByKey s
        if node
          node.activate()
          node.select()
          node.focus()


  _editNode: (node, onDone) ->
    prevTitle = node.data.title
    tree = node.tree
    #Disable dynatree mouse- and key handling
    tree.$widget.unbind()
    $(".dynatree-title").bind "click", (event) -> event.preventDefault()
    #Replace node with <input>
    $(".dynatree-title", node.span).html "<input id='editNode' value='" + prevTitle + "'>"
    # Focus <input> and bind keyboard handler
    $("input#editNode")
      .focus()
      .keydown  (event) ->
        switch event.which
          when 27
            $("input#editNode").val prevTitle
            $(this).blur()
          when 13
            if !$("input#editNode").val()
              $("input#editNode").val prevTitle
              #simulate blur to accept new value
            $(this).blur()
          when 220
            if (this.value && this.selectionStart != this.value.length)
                selectionStart = this.selectionStart
                this.value = this.value.substring(0,this.selectionStart) + '/' + this.value.substring(this.selectionStart,this.value.length)
                this.selectionStart = selectionStart + 1
                this.selectionEnd = this.selectionStart
            else
                this.value = this.value + '/'
            false
      .click (event) ->
        false
      .blur (event) =>
        val = $("input#editNode").val()
        if val and prevTitle != val
          n = @_convert node
          n.value = val
          @options.update @options.link, n, (err) ->
            if !err
              node.data.key = n.key
              node.data.label = n.label
              node.data.parent = n.parent
              #Accept new value, when user leaves <input>
              node.setTitle n.value
              #Re-enable mouse and keyboard handlling
              tree.$widget.bind()
              node.focus()
            if onDone then onDone err
        else
          tree.$widget.bind()
          node.setTitle prevTitle
          node.focus()
          if onDone then onDone null

  __createNode: (root) ->
    newNode = root.addChild
      key: -1
      title: ""
      label: ""
      parent: if root.data.key == "_1" then @options.root else root.data.key
      isLazy: true
    newNode.focus()
    @_editNode newNode, (err) ->
      if newNode.data.key == -1
        newNode.remove()
        root.focus()

  _createNode: (root) ->
    root.activate()
    if root.childList == null and !root.isExpanded()
      @_onAfterLazyLoading = (err) =>
        @_onAfterLazyLoading = null
        if !err then @__createNode root
      root.expand()
    else
      @__createNode root

  _createSibling: (node) ->
    if node.parent
      root = node.parent
    else
      root = $(@element[0]).dynatree("getRoot")
    @_createNode root

  _moveNode:  (draggedNode, parent, onDone) ->
    n = @_convert draggedNode
    n.parent = parent
    @options.update @options.link, n, (err) ->
      onDone err

  _convert: (node) ->
    key : node.data.key
    value : node.data.title
    label : node.data.label
    parent : if node.data.parent then node.data.parent else @options.root

  _removeNode: (node) ->
    @options.remove @options.link, node.data.key, (err) ->
      if !err
        if node.parent.data.key != "_1" then node.parent.focus() else node.getPrevSibling().focus()
        node.remove()

  _create: ->
    opts =
      title: "Baio tree",
      onActivate: (node) ->
      onDeactivate: (node) ->
      onFocus: (node) ->
        node.activate()
      onBlur: (node) ->
      onLazyRead: (node) =>
        @_load @options.link, node.data.key, (res) =>
          node.addChild res
          node.setLazyNodeStatus DTNodeStatus_Ok
          if @_onAfterLazyLoading then @_onAfterLazyLoading()
      onDblClick: (node, event) =>
        if @options.select == "single"
          @options.onSelected @_convert node
        else
          nodes =  node.tree.getSelectedNodes().map (n) => @_convert n
          @options.onSelected nodes
          #@_editNode node
        false
      onKeydown: (node, event) =>
        switch event.which
          when 13
            if @options.select == "single"
              @options.onSelected @_convert node
            else if @options.select == "multi"
              nodes =  node.tree.getSelectedNodes().map (n) => @_convert n
              @options.onSelected nodes
            else if @options.editable
              #@_editNode node
              @_createSibling node
              false
          when 113
            if @options.editable
              @_editNode node
          when 46
            #@_removeNode node
            #false
            true
          when 45
            @_createNode node
            false
          when 107
            if event.shiftKey
              @_createSibling node
            else
              @_createNode node
            false
            ###
              if node.parent
                root = node.parent
              else
                root = $(@element[0]).dynatree("getRoot")
            else
              root = node
            @_createNode root
            false
            ###
          when 32
            if @options.select == "multi"
              node.toggleSelect()
              false
      dnd:
        preventVoidMoves: true,
        onDragStart: (node)  -> true
        onDragEnter: (node, sourceNode) -> true
        onDrop: (node, sourceNode, hitMode, ui, draggable) =>
          if hitMode == "over"
            parent = node.data.key
          else
            parent = if node.data.parent then node.data.parent else null
          @_moveNode sourceNode, parent, (err) ->
            if !err
              sourceNode.move node, hitMode

    if @options.select == "multi"
      opts.checkbox = true
      opts.selectMode = 2
    else if @options.select == "single"
      opts.checkbox = false
      opts.selectMode = 1
    else
      opts.checkbox = false
      opts.selectMode = 0

    $(@element[0]).dynatree opts

    @_update =>
      if @options.selected and @options.selected.length
        @_loadSelected()
      else
        fcrn = $(@element[0]).dynatree("getRoot").getChildren()[0]
        if fcrn then fcrn.focus()

  _update: (onDone) ->
    $(@element[0]).dynatree("getRoot").removeChildren()
    @_load @options.link, null, (res) =>
      $(@element[0]).dynatree("getRoot").addChild res
      if onDone then onDone()


  add: ->
    root = @_focusedNode()
    @_createNode root

  addRoot: ->
    ###
    root = @_focusedNode()
    if root
      root = root.parent
    else
    ###
    root = @_tree().getRoot()
    @_createNode root

  remove: ->
    root = @_focusedNode()
    if root then @_removeNode root

  rename: ->
    root = @_focusedNode()
    if root then @_editNode root
