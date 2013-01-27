define ->

  class User

    constructor: (@logon) ->
      @name = ko.observable()

    logOn : (data, event) =>
      if event then event.preventDefault()
      @logon.auth if typeof data == "string" then data else window.location.pathname

    logOff : (data, event) =>
      event.preventDefault()
      @logon.logOff()

  User : User
