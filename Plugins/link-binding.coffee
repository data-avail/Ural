define  ["Ural/Modules/pubSub"], (pubSub) ->

  ko.bindingHandlers.link =

    init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
      href = $(element).attr "href"
      $(element).bind "click", (e) ->
        e.preventDefault()
        href = href.replace /^\/?#\/?/, ""
        pubSub.pub "href", "change", href : href

      ko.utils.domNodeDisposal.addDisposeCallback element, ->
        $(element).unbind "click"

