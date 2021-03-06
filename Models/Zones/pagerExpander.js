// Generated by CoffeeScript 1.3.3
(function() {

  define(function() {
    var Pager;
    Pager = (function() {

      function Pager(list, maxLimit) {
        var _this = this;
        this.list = list;
        this.maxLimit = maxLimit;
        this.itemsPerPage = ko.observable(0);
        this.latestLoadCount = ko.observable(-1);
        this.lastLength = ko.observable(-1);
        this.movingTo = ko.observable(null);
        this.current = ko.observable(0);
        this.canMovePerv = false;
        this.canMoveNext = ko.computed(function() {
          return (_this.latestLoadCount() === -1 || _this.latestLoadCount() >= _this.itemsPerPage()) && _this.maxLimit > list().length;
        });
      }

      Pager.prototype.moveTo = function(page) {
        if (this.onChangedCallback) {
          this.movingTo(page);
          return this.onChangedCallback(page);
        }
      };

      Pager.prototype.movePerv = function() {
        throw "not implemented";
      };

      Pager.prototype.moveNext = function() {
        if (this.canMoveNext()) {
          return this.moveTo(this.current() + 1);
        }
      };

      Pager.prototype.onChanged = function(onChangedCallback) {
        this.onChangedCallback = onChangedCallback;
      };

      Pager.prototype.setPaging = function(data) {
        this.movingTo(null);
        this.current(data.page);
        this.latestLoadCount(data.latestLoadCount);
        return this.itemsPerPage(data.itemsPerPage);
      };

      return Pager;

    })();
    return {
      Pager: Pager
    };
  });

}).call(this);
