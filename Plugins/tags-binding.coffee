define ["Ural/Plugins/baio.tag-widget"], ->

  ini = (_opts) ->

    _format = (valueAccessor) ->
      values = ko.utils.unwrapObservable valueAccessor()
      if values
        values.map (v) -> _opts._format(v)
      else
        []

    _lock = false

    ko.bindingHandlers.tags =

      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        tagsOpts = allBindingsAccessor().tagsOpts
        link = tagsOpts.link if tagsOpts
        linkType = tagsOpts.linkType if tagsOpts
        opts = $.extend true, {}, _opts
        opts.link = link if link
        if ko.utils.unwrapObservable(valueAccessor())
          opts.onTagAdded = (tag, userInput) ->
            if userInput
              _lock = true
              valueAccessor().push opts._parse tag
              _lock = false
          opts.onTagRemoved = (tag, userInput) ->
            if userInput
              _lock = true
              for t, index in _format(valueAccessor)
                if t.value == tag.value then break
              t = ko.utils.unwrapObservable(valueAccessor())[index]
              valueAccessor().remove t
              _lock = false
        $(element).tag opts

      update: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        names = $(element).tag "assignedTags"
        vals = _format valueAccessor
        if !_lock
          $(element).tag "add", vals

  ini : ini