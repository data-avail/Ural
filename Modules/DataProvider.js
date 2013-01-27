// Generated by CoffeeScript 1.3.3
(function() {

  define(function() {
    var add, get, set, _currentProviderName, _providers;
    _currentProviderName = null;
    _providers = [];
    add = function(name, dataProvider) {
      return _providers.push({
        name: name,
        provider: dataProvider
      });
    };
    set = function(name) {
      return _currentProviderName = name;
    };
    get = function(name) {
      var prr;
      if (name == null) {
        name = _currentProviderName;
      }
      prr = _providers.filter(function(p) {
        return p.name === name;
      })[0];
      return prr.provider;
    };
    return {
      get: get,
      set: set,
      add: add
    };
  });

}).call(this);
