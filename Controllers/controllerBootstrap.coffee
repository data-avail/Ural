define ["Ural/Controllers/controllerBase"
, "Models/Zones/itemToolbox"
, "Models/Zones/indexToolbox"
, "Ural/Models/Zones/selector"
],
(controllerBase, itemToolbox, indexToolbox, selector) ->
  class ControllerBootstrap extends controllerBase.ControllerBase

    constructor: (modelName, opts)->
      super modelName, opts
      @defaultIndexLayout = "Shared/__LayoutIndex"
      @defaultItemLayout = "Shared/__LayoutItem"
      @_formsStack = []

    onShowForm: ($form, itemVM) ->
      @_stackForm $form
      $form.data "item", itemVM
      $form.modal("show").on "hidden", =>
        if $form.data("stacked") == "active"
          i = $form.data "item"
          if i and i.isEdit()
            i.cancel()
          @_unstackActive()

      $form.modal 'show'

    onHideForm: ($form) ->
      $form.modal 'hide'

    _stackForm: (form) ->
      @_overrideActive()
      form = $ form
      form.data "stacked", "active"
      @_formsStack.push form

    _overrideActive: ->
      if @_formsStack.length
        form = @_formsStack[@_formsStack.length - 1]
        form.data "stacked", "overriden"
        @onHideForm form

    _unstackActive: ->
      form = @_formsStack.pop()
      if form
        form.data "stacked", null
      pervForm = @_formsStack[@_formsStack.length - 1]
      if pervForm
        pervForm.data "stacked", "active"
        pervForm.modal("show")


  ControllerBootstrap : ControllerBootstrap