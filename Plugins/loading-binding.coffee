define ->

  ko.bindingHandlers.loading =

    init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
      $(element).hide()

    update: (element, valueAccessor, allBindingsAccessor, viewModel) ->
      bindingOpts = allBindingsAccessor().loadingOpts
      toggleLayout = bindingOpts.toggleLayout
      value = ko.utils.unwrapObservable valueAccessor()
      if value
        $("#" + toggleLayout).hide()
        $(element).show()
      else
        $(element).hide()
        $("#" + toggleLayout).show()

