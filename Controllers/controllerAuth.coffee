define ["Ural/Controllers/controllerBootstrap"
  , "Ural/Models/Zones/user"
  , "Ural/Libs/jquery.cookie"
  , "Ural/Modules/pubSub"
], (controllerBootstrap
  , user
  , cookie
  , pubSub
) ->

  class ControllerAuth extends controllerBootstrap.ControllerBootstrap

    constructor: (type, opts) ->
      super type, opts
      @_initialLoad = true

      pubSub.subOnce "auth", "logon", "controller", =>
        @auth()

      pubSub.subOnce "auth", "logoff", "controller", =>
        @logOff()

    onAction: (data, onDone) ->
      super data, ->
      if !data.begins and @_initialLoad
        @_initialLoad = false
        @onLoadUserStuff onDone
      else
        if onDone then onDone()

    onLoadUserStuff: (onDone) ->
      if onDone then onDone null

    getAuthReturnRoute: ->
      window.location.hash

    getAuthLogOff: -> "/Account/OAuthLogOff"

    _loginPopup: (returnRoute, returnExec) ->
      returnUrl = "##{returnRoute}/!/user/$user"
      returnUrl += "/!/" + returnExec if returnExec
      returnUrl = escape returnUrl
      _u.popup "/Account/OAuth?serviceName=Twitter&extWindow=true&returnUrl=#{returnUrl}", 600, 400

    #logon interface

    auth: (returnRoute, returnExec) ->
      if !@user()
        returnRoute ?= @getAuthReturnRoute()
        @_loginPopup returnRoute, returnExec
        false
      else
        true

    logOff: (onDone) ->
      $.get @getAuthLogOff(), =>
        @user null

    user: (userName) ->
      if userName == undefined
        @userZone().name()
      else
        if @user() != userName
          @userZone().name userName
          @onLoadUserStuff ->

    #^logon interface

    createUserZone: ->
      @viewModel.zones.user = new user.User @
      @userZone().name.subscribe (val) ->
        pubSub.pub "auth", "user_changed", name : val
      @userZone().name $.cookie(".ASPXAUTH_USER")

    userZone: ->
      @viewModel.zones.user

    createIndexViewModel: (filter) ->
      super filter
      @createUserZone()

    createItemViewModel: ->
      super()
      @createUserZone()

  ControllerAuth : ControllerAuth