// Generated by CoffeeScript 1.3.3
(function() {

  define(function() {
    var ini;
    ini = function(opts) {
      var _ref, _setBadge;
      if (!opts) {
        opts = {};
      }
      if ((_ref = opts.type) == null) {
        opts.type = "warning";
      }
      _setBadge = function(element, text, type) {
        if (text) {
          $(element).addClass("badge");
          $(element).addClass("badge-" + type);
        } else {
          $(element).removeClass("badge");
          $(element).removeClass("badge-" + type);
        }
        return $(element).text(text);
      };
      return ko.bindingHandlers.badge = {
        init: function(element, valueAccessor, allBindingsAccessor, viewModel) {
          var option, type, valAccessor;
          option = allBindingsAccessor().labelOpts;
          if (option) {
            type = option.type;
          }
          if (type == null) {
            type = opts.type;
          }
          valAccessor = valueAccessor();
          _setBadge(element, ko.utils.unwrapObservable(valAccessor), type);
          return valAccessor.subscribe(function(newValue) {
            return _setBadge(element, newValue, type);
          });
        }
      };
    };
    return {
      ini: ini
    };
  });

}).call(this);
