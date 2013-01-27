// Generated by CoffeeScript 1.3.3
(function() {
  var _start;

  define(function() {
    /*
      window.applicationCache.addEventListener 'updateready', ->
        if (window.applicationCache.status == window.applicationCache.UPDATEREADY)
          # Browser downloaded a new app cache.
          # Swap it in and reload the page to get the new hotness.
          window.applicationCache.swapCache()
          window.location.reload();
    */
    return require(["Ural/order!Ural/Libs/jquery", "Ural/order!Ural/Libs/knockout", "Ural/order!Ural/Libs/jquery.ui", "Ural/order!Ural/Libs/jsrender", "Ural/order!Ural/Libs/pluralize", "Ural/Libs/async", "Ural/utils", "Ural/Libs/underscore.string", "Ural/Libs/moment"], function(jq, ko) {
      window.ko = ko;
      require.config({
        baseUrl: "/App",
        paths: {
          hasher: 'Ural/Libs/hasher',
          crossroads: 'Ural/Libs/crossroads',
          signals: 'Ural/Libs/signals'
        }
      });
      return require(["router", "setup", "Ural/Libs/knockout.mapping", "order!Ural/Libs/knockout.validation", "order!Ural/Libs/knockout.validation.extensions", "order!Ural/Libs/i18n/knockout.validation-ru"], function(router, setup) {});
    });
    /*
            if !setup or setup.isComplete
              _start router
            else
              setup.onComplete -> _start router
    */

  });

  _start = function(router) {
    var rr;
    ko.validation.configure({
      registerExtenders: true,
      messagesOnModified: false,
      insertMessages: false,
      parseInputAttributes: false,
      messageTemplate: null
    });
    rr = new router.Router();
    return rr.startRouting();
  };

}).call(this);