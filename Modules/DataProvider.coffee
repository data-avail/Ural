define ->

  _currentProviderName = null
  _providers = []

  add = (name, dataProvider) ->
    _providers.push name : name, provider : dataProvider

  set = (name) ->
    _currentProviderName = name

  get = (name) ->
    name ?= _currentProviderName
    prr = _providers.filter((p) -> p.name == name)[0]
    prr.provider

  get : get
  set : set
  add : add