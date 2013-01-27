define ->

  ini = ->

    ko.bindingHandlers.slider =

      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->

        opts = allBindingsAccessor().sliderOpts
        valAccessor = valueAccessor()
        val = ko.utils.unwrapObservable valAccessor

        min = opts.min if opts
        max = opts.max if opts
        min ?= 0
        max ?= 100

        $(element).slider
            range : true
            min : min
            max : max
            values : [val.from(), val.to()]
            slide: (event, ui) ->
              val.from ui.values[0]
              val.to ui.values[1]

      update: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        valAccessor = valueAccessor()
        val = ko.utils.unwrapObservable valAccessor

        $(element).slider "values", 0, val.from()
        $(element).slider "values", 1, val.to()


  ini : ini