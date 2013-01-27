define ["Ural/Models/itemVM"], (itemVM) ->

  class ItemRefVM extends itemVM.ItemVM

    constructor: (@indexRefVM, typeName) ->
      super typeName

    _getMode: -> "updateParent"

    cancel: ->
      if @item.id() == -1
        @onNotifyChanged "removed", null, ignore_msg : true
      super()

    onEdit: (onDoneCallback) ->
      if @item.id() == -1
        @indexRefVM.add @
      super onDoneCallback

    update: (onDone) ->
      if @_getMode() == "updateParent"
        if @isValid()
          @indexRefVM.parentItemVM.update onDone
        else
          type = if @item.id() == -1 then "added" else "updated"
          @showValidationError true
          @onNotifyChanged type, __g.i18n.messages.validation_error
          #@showUpdateMessage __g.i18n.messages.validation_error
      else
        onDone null

    remove: (onDone) ->
      if @_getMode() == "updateParent"
        #@onNotifyRemoved()
        @onNotifyChanged "removed", null, ignore_msg : true
        @indexRefVM.parentItemVM.update (err) =>
          #@onNotifyChanged "removed", err
          #@showUpdateMessage err
          @onNotifyChanged "removed", err
          if onDone then onDone err
      else
        onDone null

    onNotifyChanged: (type, err, opts) ->
      if type != "added"
        super type, err, opts
      else
        opts = ignore_insert : true
        super type, err, opts

    onUpdate: (state, onDone) ->
      onDone null, @item

    onRemove: (onDone) ->
      onDone null, @item

  ItemRefVM : ItemRefVM