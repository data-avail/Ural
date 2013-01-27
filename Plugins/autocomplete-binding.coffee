define ->

  ini = (opts) ->

    ko.bindingHandlers.autocomplete =
      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        bindingOpts = allBindingsAccessor().autocompleteOpts
        lastLabel = ""
        autocompleteOpts =
          source: (req, resp) ->
            req.link = bindingOpts.link
            selectionStart = $(element).context.selectionStart
            $(element).val $(element).context.value.replace(/\\/g,"/")
            $(element).context.selectionStart = selectionStart
            $(element).context.selectionEnd = selectionStart
            opts.source req, resp
          select: (event, ui) ->
            lastLabel = ui.item.value
            valueAccessor() opts._parse ui.item
          change: (event, ui) ->
            if lastLabel != $(element).val()
              lastLabel = $(element).val()
              val = opts._parse opts._empty()
              if _u.trim($(element).val()) && !bindingOpts.prohibitNew
                val = opts._parse key : -1, value : $(element).val(), label : $(element).val()
              valueAccessor() val

        $(element).blur ->
          value = ko.utils.unwrapObservable valueAccessor()
          value = opts._format value
          if $(element).val() != value.value
            $(element).autocomplete('option','change').call($(element))

        $(element).autocomplete autocompleteOpts

      update: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        value = ko.utils.unwrapObservable valueAccessor()
        value = opts._format value
        if $(element).val() != value.value
          @lastLabel = value.value
          $(element).val value.value

  ini : ini