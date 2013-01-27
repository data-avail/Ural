define ["Ural/Modules/pubSub"], (pubSub) ->

  class User

    constructor: ->

      name = ko.observable name


  class Root

    constructor: ->

      @user = ko.observable()

      @vm = null

    _loginPopup: (returnRoute, returnExec) ->
      returnUrl = "##{returnRoute}/!/user/$user"
      returnUrl += "/!/" + returnExec if returnExec
      returnUrl = escape returnUrl
      _u.popup "/Account/OAuth?serviceName=Twitter&extWindow=true&returnUrl=#{returnUrl}", 600, 400

    login: (returnRoute, returnExec) ->

    logoff: (href) ->
      $.get href, =>
        @user null


  Root : Root