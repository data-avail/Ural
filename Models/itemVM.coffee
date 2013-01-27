define ["Ural/Modules/DataProvider", "Ural/Modules/pubSub"], (dataProvider, pubSub) ->

  class ItemVM

    constructor: (@typeName) ->
      @originItem = null
      @zones = {}
      @endPointBinding = null

    map: (data, ini, onDone) ->
      require ["Models/#{@typeName.toLowerCase()}"], (module) =>
        if module and module.metadata
          meta = module.metadata
          #TO DO: make mapping and defs automatically when not defined in meta
          if !meta then throw "not impl: meta must be defined"
          if !meta.mapping then throw "not impl: mapping must be defined"
          #if !meta.def then throw "not impl: def must be defined"
          meta.def ?= {}
          if !data and !ini then throw "data arg must be provided"
          if ini
            @item = new module.ModelConstructor()
            @endPointBinding = ItemVM._getEndPointBinding module
            ko.mapping.fromJS (if data then data else meta.def), meta.mapping, @item
            if meta.viewModels
              require ["Ural/Models/indexRefVM"], (indexRefVM) =>
                for viewModel in meta.viewModels
                  @item[viewModel.name] = new indexRefVM.IndexRefVM @, viewModel.typeName, @item[viewModel.field]
                onDone null, @
            else
              onDone null, @
          else
            @_prepareMap()
            ko.mapping.fromJS data, meta.mapping, @item
            onDone null, @
        else
          if ini
            if module and module.ModelConstructor
              @item = new module.ModelConstructor()
              ko.mapping.fromJS data , {}, @item
            else
              @item = data
            onDone null, @

    load: (id, onDone) ->
      #dataProvider.get().load @typeName, id : id, (err, data) =>
      dataProvider.get().load @typeName, {$filter : {id : { $eq : id}}, $expand : "$item"}, (err, data) =>
        if !err
            @map data[0], true, onDone
        else
          onDone err

    _createOrigin: ->
      @originItem = ko.mapping.toJS @item

    _copyFromOrigin: ->
      ko.mapping.fromJS @originItem, @mappingRules, @item

    getState: ->
      ItemVM._getState @originItem, @item

    @_isModified: (state) ->
      for own p of state
        val = state[p]
        f = true
        if typeof val == "object"
          f = ItemVM._isModified val
        else if Array.isArray val
          for i in val
            f = IemVM._isModified val
            if f then break;
        else
          f = val == "added" || val == "removed" || val == "modifyed"
        if f then return true
      false

    isModified: ->
      ItemVM._isModified @getState()

    _prepareMap: ->
      _u.iterObj @item, (type, val, _val) ->
        #TODO: comment needed, completle forgot for what it is necessary
        if type == "array"
          if val.remove then val.remove (v) -> if ko.isObservable v.id then v.id() == -1 else false
        else if type == "object" and val == _val #not observable (IndexVM)
          return false

    @_getState: (item, observItem)->
      res = {}
      if item
        if !item.id or item.id == -1 then res.__status = "added"
        for own prop of item
          if prop == "constructor" then continue
          val = item[prop]
          _val = observItem[prop]
          _val = _val() if $.isFunction _val
          if prop == "id"
            res.id = val
            if val != _val
              if _val == __g.nullRefVal()
                res.__status = "removed"
                return res
              else
                res[prop] = "modifyed"
                return res #TODO
          else if Array.isArray val
            removed = val.filter((v) -> ko.utils.arrayFirst(_val, (i) -> i.id() == v.id) == null)
              .map (v) -> v.id
            res[prop] = _val.map (v) -> ItemVM._getState val.filter((f)-> f.id == v.id())[0], v
            res[prop].push id : r , __status : "removed" for r in removed
          else if val != null and !(val instanceof Date) and typeof val == "object"
            res[prop] = ItemVM._getState val, _val
          else
            res[prop] = if val != _val then "modifyed" else "unchanged"
      else
        res.__status = "added"
        for own prop of observItem
          _val = observItem[prop]
          _val = _val() if $.isFunction _val
          if Array.isArray _val
            res[prop] = __status : "added" for v in _val
          else if typeof _val == "object"
            res[prop] = __status : "added"
      res

    @_getEndPointBinding: (module)->
      #TO DO: work only for root, for nested - models must be loaded at app start
      if module.metadata and module.metadata.endPointBinding
        module.metadata.endPointBinding

    edit: (viewModel, event, formType, callback) =>
      if event then event.preventDefault()
      @onEdit (err, cancel) =>
        @hideEdit null, null, formType
        @onDoneCallback = null
        if callback then callback err, cancel
      @showEdit null, null, formType

    showEdit: (viewModel, event, formType) ->
      formType ?= "edit"
      if event then event.preventDefault()
      pubSub.pub "model", "edit", {formType : formType, itemVM : @}

    hideEdit: (viewModel, event, formType) ->
      formType ?= "edit"
      if event then event.preventDefault()
      pubSub.pub "model", "end_edit", {formType : formType, itemVM : @}

    onEdit: (@onDoneCallback)->
      @showValidationError false
      if @isEdit() then @endEdit() #throw "item already in edit state"
      @_createOrigin()

    showValidationError: (show) ->
      if @item.errors
        @item.errors.showAllMessages show

    isValid: ->
      !@item.isValid or @item.isValid()

    onDone: (err, cancel) ->
      #if !cancel then @showUpdateMessage err
      if !err
        @endEdit()
        if @onDoneCallback then @onDoneCallback err, cancel

    ###
    showUpdateMessage: (err) ->
      if !err
        pubSub.msg __g.i18n.messages.update_success
      else
        pubSub.msg err, __g.i18n.messages.update_fail, "error"
    ###

    endEdit: ->
      if !@isEdit() then throw "item not in edit state"
      @originItem = null

    cancel: ->
      @_save true

    isEdit: ->  @originItem != null

    save: (data, event) ->
      event.preventDefault()
      @_save false

    _save: (isCancel) ->
      if !@isEdit() then throw "item not in edit state"
      if isCancel
        @_copyFromOrigin()
        @onDone null, true
      else
        type = if @item.id() == -1 then "added" else "updated"
        @update (err) =>
          @onNotifyChanged type, err
          @onDone err, false

    _fixEdit: ->
      @_createOrigin()

    onNotifyChanged: (type, err, opts) ->
      pubSub.pub "model", "list_changed", itemVM : @, changeType : type, err : err, opts : opts

    update: (onDone) ->
      if @isValid()
        @onNotifyChanged "update_begin"
        if @isModified()
          console.log "modifyed"
          @onUpdate @getState(), (err) =>
            if !err then @_fixEdit()
            if onDone then onDone err
        else
          if onDone then onDone __g.i18n.messages.nothing_to_commit
      else
        @showValidationError true
        if onDone then onDone __g.i18n.messages.validation_error

    remove: (onDone) ->
      @onNotifyChanged "update_begin"
      @onRemove (err) =>
        @onNotifyChanged "removed", err
        if onDone then onDone err, @item

    #--- update region

    #convert app model to raw data (json)
    _mapToData: ->
      data = ko.mapping.toJS @item
      if @item.__ko_mapping__.__afterToJS
        @item.__ko_mapping__.__afterToJS data
      data

    onUpdate: (state, onDone) ->
      dataForSave = @_mapToData()
      dataForSave.__state = state
      dataForSave.__endPointBinding = @endPointBinding if @endPointBinding
      async.waterfall [
        (ck) =>
          @onSave @typeName, dataForSave, ck
        , (data, ck) =>
            @map data, false, ck
        ], onDone

    onRemove: (onDone) ->
      dataProvider.get().delete @typeName, @item.id(), onDone

    onSave: (typeName, dataForSave, onDone) ->
      dataProvider.get().save typeName, dataForSave, onDone

    #--- update region ^

  ItemVM : ItemVM
