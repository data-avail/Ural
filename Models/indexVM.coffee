define [
  "Ural/Modules/pubSub",
  "Ural/Models/itemVM",
  "Ural/Modules/DataProvider"],
(pubSub, itemVM, dataProvider) ->

  class IndexVM

    constructor: (@typeName, list) ->
      @active = ko.observable()
      @list = if !list then ko.observableArray() else list
      pubSub.sub "model", "list_changed", (data) =>
        @_itemChanged data

    map: (data, onDone) ->
      async.mapSeries data
        , (d, ck) =>
          item = @onCreateItemVM()
          item.map d, true, ck
        , (err, ivms) =>
          if !err then @_updateList ivms
          if onDone then onDone err, data

    _updateList: (items) ->
      #@list.removeAll()
      @list.push ivm for ivm in items

    onCreateItemVM: ->
      new itemVM.ItemVM @typeName

    _checkEventHandler:(event, name, type) ->
      eventHandler = $(event.target).attr "data-event-handler"
      if eventHandler
        eventHandler.split(":")[0] == name and eventHandler.split(":")[1] == type
      else
        true

    edit: (viewModel, event, type, onDone) =>
      if event
        if !@_checkEventHandler event, "edit", type then return
        event.preventDefault()
      if @active()
        @active().cancel()
      @active viewModel
      viewModel.edit null, null, type, (err, cancel) =>
        @active null
        if onDone then onDone err, cancel
        #!, type

    detail: (viewModel, event) =>
      @active viewModel
      @moveToDetails viewModel.item, event

    moveToDetails: (item, event) =>
      if !@_checkEventHandler event, "detail" then return
      event.preventDefault()
      if @active() and @active().isEdit()
        @active().cancel()
      pubSub.pub "model", "detail", item

    remove: (viewModel, event) =>
      if event
        if !@_checkEventHandler event, "remove" then return
        event.preventDefault()
      @onRemove viewModel

    onRemove: (viewModel) ->
      ###
      if @active()
        @active().cancel()
      ###
      viewModel.remove()

    add: (items, order) ->
      items = [items] if !Array.isArray items
      if items.length and _u.getClassName(items[0].item) == @typeName
        for item in items
          fromList = @list().filter((i)->i.item == item.item)[0]
          if !fromList
            @onAdded item, order

    onAdded: (viewModel, order) ->
      if !order or order == "top"
        @list.splice 0, 0, viewModel
      else
        @list.push viewModel

    onRemoved: (viewModel) ->
      @list.remove viewModel

    replaceAll: (items) ->
      @list.removeAll()
      @_updateList items.map (i) =>
        vm = @onCreateItemVM()
        vm.item = i
        vm

    load: (filter, isClear, callback) ->
      dataProvider.get().load @typeName, filter, (err, data) =>
        if !err
            if isClear then @removeAll()
            @map data, callback
        else
          if callback then callback err, data

    removeAll: ->
      @list.removeAll()

    #add new item
    addNew: (item) ->
      item ?= {} if !item
      ivm = @onCreateItemVM()
      ivm.map item, true, (err) =>
        @edit ivm, null, "create", (err, cancel) =>
          if !cancel and !err
            @add ivm

    _itemChanged: (data) ->
      if data.changeType == "added" and (!data.opts or !data.opts.ignore_insert)
        @add data.itemVM
      else if data.changeType == "removed"
        if _u.getClassName(data.itemVM.item) == @typeName
          @onRemoved data.itemVM

    #add new item (as raw json) to list
    addNewItem: (item, onDone) ->
      vm = @onCreateItemVM()
      vm.map item, true, (err) =>
        if !err
          @onAdded vm
        if onDone then onDone err

  IndexVM : IndexVM