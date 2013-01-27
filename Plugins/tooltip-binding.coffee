define  ->

  ini = ->

    ko.bindingHandlers.tooltip =

      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        val = ko.utils.unwrapObservable valueAccessor()
        $(element).tooltip title : val
        $(element).bind "click", (e) -> e.preventDefault()
        ko.utils.domNodeDisposal.addDisposeCallback element, ->
          $(element).tooltip "hide"
          $(element).triggerHandler("destroyed");

  ini : ini