define ->

  ini = (opts) ->

    ko.bindingHandlers.cautocomplete =

      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        bindingOpts = allBindingsAccessor().cautocompleteOpts
        keyField = bindingOpts.keyField
        valField = bindingOpts.valField
        valField ?= keyField
        labelField = bindingOpts.labelField
        labelField ?= valField
        modelModule = require bindingOpts.typePath
        lastLabel = null

        filterField = bindingOpts.filterField
        filterField ?= "lastName"

        autocompleteOpts =
          source: (req, resp) ->
            req.link = bindingOpts.link
            req.filter = $filter : {} #{lastName : {$like : req.term}}
            req.filter.$filter[filterField] = {$like : req.term}
            r = (data) ->
              resp data.map (d) ->
                item = new modelModule.ModelConstructor()
                ko.mapping.fromJS d, modelModule.metadata.mapping, item
                key : item[keyField]()
                value : item[valField]()
                label : item[labelField]()
                data : item
            opts.source req, r
          select: (event, ui) ->
            item = valueAccessor()
            item ui.item.data
            lastLabel = ui.item.value
          change: (event, ui) =>
            if lastLabel != $(element).val()
              _setNullRef modelModule, valueAccessor()
              #$(element).val null
              #valueAccessor().id id : __g.nullRefVal()

        $(element).autocomplete autocompleteOpts

      update: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        bindingOpts = allBindingsAccessor().cautocompleteOpts
        keyField = bindingOpts.keyField
        valField = bindingOpts.valField
        valField ?= keyField
        item = valueAccessor()
        if item() and $(element).val() != item()[valField]()
          $(element).val item()[valField]()
        else if !item()
          $(element).val null

    _setNullRef = (modelModule, item) ->
      emptyItem = new modelModule.ModelConstructor()
      emptyItem.id __g.nullRefVal()
      item emptyItem

  ini : ini