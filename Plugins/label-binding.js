// Generated by CoffeeScript 1.3.3
(function() {

  define(function() {
    var ini;
    ini = function(opts) {
      var _ref, _setLabel;
      if (!opts) {
        opts = {};
      }
      if ((_ref = opts.type) == null) {
        opts.type = "warning";
      }
      _setLabel = function(element, text, type) {
        if (text) {
          $(element).addClass("label");
          $(element).addClass("label-" + type);
        } else {
          $(element).removeClass("label");
          $(element).removeClass("label-" + type);
        }
        if (!text) {
          text = "";
        }
        return $(element).text(text);
      };
      return ko.bindingHandlers.label = {
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
          _setLabel(element, ko.utils.unwrapObservable(valAccessor), type);
          return valAccessor.subscribe(function(newValue) {
            return _setLabel(element, newValue, type);
          });
        }
      };
    };
    return {
      ini: ini
    };
  });

}).call(this);
