define ->

  ini = (opts) ->

    opts = {} if !opts
    opts.format ?= "DD MMMM YYYY"
    opts.formatDateTime ?= "DD MMMM YYYY HH:mm"

    _setDateDuration = (element, date) ->
      $(element).text if date then moment(date).fromNow() else ""

    _setDate = (element, date, format) ->
      $(element).text if date then moment(date).format format else ""

    ko.bindingHandlers.durdate =
      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        option = allBindingsAccessor().ddateOpts
        format =  option.format if option
        format ?= opts.format
        valAccessor = valueAccessor()
        _setDateDuration element, ko.utils.unwrapObservable(valAccessor)
        if valAccessor.subscribe
          valAccessor.subscribe (newValue) ->
            _setDateDuration element, newValue

    ko.bindingHandlers.tdate =
      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        option = allBindingsAccessor().ddateOpts
        format =  option.format if option
        format ?= opts.formatDateTime
        valAccessor = valueAccessor()
        _setDate element, ko.utils.unwrapObservable(valAccessor), format
        valAccessor.subscribe (newValue) ->
          _setDate element, newValue, format

    ko.bindingHandlers.ddate =
      init: (element, valueAccessor, allBindingsAccessor, viewModel) ->
        option = allBindingsAccessor().ddateOpts
        format =  option.format if option
        format ?= opts.format
        valAccessor = valueAccessor()
        _setDate element, ko.utils.unwrapObservable(valAccessor), format
        valAccessor.subscribe (newValue) ->
          _setDate element, newValue, format

  ko.bindingHandlers.date =
    init: (element, valueAccessor, allBindingsAccessor) ->

      #initialize datepicker with some optional options
      css = $(element).attr "class"
      dminRule = valueAccessor().extend().rules().filter((f) -> f.rule == "dmin")[0]
      minDate = moment(dminRule.params).toDate() if dminRule
      dmaxRule = valueAccessor().extend().rules().filter((f) -> f.rule == "dmax")[0]
      maxDate = moment(dmaxRule.params).toDate() if dmaxRule
      $(element).datepicker { minDate: minDate, maxDate: maxDate }
      $(element).addClass css

      #handle the field changing
      ko.utils.registerEventHandler element, "change", ->
        observable = valueAccessor()
        date = $(element).datepicker "getDate"
        d = moment(date).add "h", -1 * date.getTimezoneOffset() / 60
        observable d.toDate()

      #handle disposal (if KO removes by the template binding)
      ko.utils.domNodeDisposal.addDisposeCallback element, ->
        $(element).datepicker "destroy"

    update: (element, valueAccessor) ->
      value = ko.utils.unwrapObservable valueAccessor()
      $(element).datepicker "setDate", value
      valueAccessor()($(element).datepicker "getDate")
      #valueAccessor().extend().notifySubscribers()

  ini : ini