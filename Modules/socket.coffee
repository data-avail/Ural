define ->

  _currentSocketName = null
  _sockets = []

  add = (name, socket) ->
    _sockets.push name : name, socket : socket

  set = (name) ->
    _currentSocketName = name

  get = (name) ->
    name ?= _currentSocketName
    s = _sockets.filter((p) -> p.name == name)[0]
    s.socket

  get : get
  set : set
  add : add