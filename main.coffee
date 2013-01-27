define ->
  #first of all chack new version
  ###
  window.applicationCache.addEventListener 'updateready', ->
    if (window.applicationCache.status == window.applicationCache.UPDATEREADY)
      # Browser downloaded a new app cache.
      # Swap it in and reload the page to get the new hotness.
      window.applicationCache.swapCache()
      window.location.reload();
  ###
  require [
    "Libs/jquery"
    ]
    , ->
      appPath = $("[data-main]").attr("data-main-path")
      appPath = if appPath then appPath[0] else "/App"

      require.config
        baseUrl: appPath,
        paths:
          jquery : "Ural/Libs/jquery"
          knockout: "Ural/Libs/knockout"
          "knockout.mapping": "Ural/Libs/knockout.mapping"
          "knockout.validation": "Ural/Libs/knockout.validation"
          "knockout.validation.extensions": "Ural/Libs/knockout.validation.extensions"
          "knockout.validation.ru": "Ural/Libs/i18n/knockout.validation-ru"
          "knockout.deferred": "Ural/Libs/knockout-deferred-updates"
          hasher: "Ural/Libs/hasher"
          crossroads: "Ural/Libs/crossroads"
          signals: "Ural/Libs/signals"
          "jquery.ui" : "Ural/Libs/jquery.ui"
          jsrender : "Ural/Libs/jsrender"
          pluralize : "Ural/Libs/pluralize"
          async : "Ural/Libs/async"
          utils : "Ural/utils"
          "underscore.string" : "Ural/Libs/underscore.string"
          moment : "Ural/Libs/moment"
        shim:
          knockout: ["jquery"]
          "jquery.ui" : ["jquery"]
          "jsrender" : ["jquery"]
          "knockout.mapping": ["knockout"]
          "knockout.validation": ["knockout"]
          "knockout.deferred": ["knockout"]
          "knockout.validation.ru": ["knockout", "knockout.validation"]
          "knockout.validation.extensions": ["knockout", "knockout.validation"]

      require [
        "knockout"
        , "knockout.mapping"
        , "underscore.string"
        , "knockout.validation"
        , "knockout.validation.ru"
        , "knockout.validation.extensions"
        #, "knockout.deferred"
        , "jquery.ui"
        , "jsrender"
        , "pluralize"
        , "async"
        , "utils"
        , "moment"
        ], (ko, koMapping, _str) ->
          #global initialization (kinda wrong)
          ko.mapping = koMapping
          window.ko = ko
          window._ = {str : _str._s}
          require ["router", "setup"], (router, setup)->
            if !setup or !setup.onComplete
              _start router
            else if setup.onComplete
              setup.onComplete -> _start router

  _start = (router) ->
    ko.validation.configure
      registerExtenders: true
      messagesOnModified: false
      insertMessages: false
      parseInputAttributes: false
      messageTemplate: null
    rr = new router.Router()
    rr.startRouting()
