#masked  value binding
define ->

  ini = ->
    ko.bindingHandlers.mval =
      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        opts = allBindingsAccessor().mvalOpts
        mask = new RegExp "^(#{opts.mask})$"
        num = opts.num
        ko.utils.registerEventHandler element, "change", ->
          observable = valueAccessor()
          val = $(element).val().trim()
          if mask.test val
            if num
              val = parseInt val
            observable val
          else
            $(element).val observable()

      #update the control when the view model changes
      update: (element, valueAccessor) ->
        val = ko.utils.unwrapObservable valueAccessor()
        $(element).val val

  ini : ini