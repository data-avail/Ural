define  ->

  ini = ->

    ko.bindingHandlers.val =

      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        val = ko.utils.unwrapObservable valueAccessor()
        $(element).val parseInt val
        $(element).change ->
          val = $(element).val()
          if typeof val == "string"
            val = parseInt val
          valueAccessor() val

      update: (element, valueAccessor) ->
        val = ko.utils.unwrapObservable valueAccessor()
        $(element).val val

  ini : ini