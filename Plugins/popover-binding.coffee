define  ->

  ini = ->

    ko.bindingHandlers.popover =

      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        if typeof valueAccessor() == 'string'
          val = valueAccessor()
          if val.indexOf "#" == 0
            template = $(val)[0].outerHTML
            val = $(val + " .popover-content").html()
        else
          val = ko.utils.unwrapObservable valueAccessor()
        opts = allBindingsAccessor()
        opts = opts.popoverOpts if opts
        if opts
          title = opts.title if opts.title
          placement = opts.placement if opts.placement
          template = $("#" + opts.template)[0].outerHTML if opts.template
        placement ?= "top"
        popoverOpts = content : val, placement : placement
        popoverOpts.title = if title then title else ""
        popoverOpts.template = template if template
        $(element).popover popoverOpts
        $(element).bind "click", (e) -> e.preventDefault()
        ko.utils.domNodeDisposal.addDisposeCallback element, ->
          $(element).popover "hide"
          $(element).triggerHandler("destroyed");

  ini : ini