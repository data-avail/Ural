define ->

  ini = (opts) ->

    opts = {} if !opts
    opts.type ?= "warning"

    _setBadge = (element, text, type) ->
      if text
        $(element).addClass "badge"
        $(element).addClass "badge-#{type}"
      else
        $(element).removeClass "badge"
        $(element).removeClass "badge-#{type}"
      $(element).text text

    ko.bindingHandlers.badge =
      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        option = allBindingsAccessor().labelOpts
        type =  option.type if option
        type ?= opts.type
        valAccessor = valueAccessor()
        _setBadge element, ko.utils.unwrapObservable(valAccessor), type
        valAccessor.subscribe (newValue) ->
          _setBadge element, newValue, type

  ini : ini