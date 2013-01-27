define ->

  ini = (opts) ->

    opts = {} if !opts
    opts.type ?= "warning"

    _setLabel = (element, text, type) ->
      if text
        $(element).addClass "label"
        $(element).addClass "label-#{type}"
      else
        $(element).removeClass "label"
        $(element).removeClass "label-#{type}"
      text = "" if  !text
      $(element).text text

    ko.bindingHandlers.label =
      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        option = allBindingsAccessor().labelOpts
        type =  option.type if option
        type ?= opts.type
        valAccessor = valueAccessor()
        _setLabel element, ko.utils.unwrapObservable(valAccessor), type
        valAccessor.subscribe (newValue) ->
          _setLabel element, newValue, type

  ini : ini