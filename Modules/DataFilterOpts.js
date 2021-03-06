// Generated by CoffeeScript 1.3.3
(function() {

  define(function() {
    var ExpandOpts, FilterOpts, OrderBy;
    ExpandOpts = (function() {

      function ExpandOpts() {
        this.opts = [];
      }

      ExpandOpts.prototype.add = function(srcName, optName, expand) {
        if (srcName == null) {
          srcName = "";
        }
        return this.opts[srcName + ":" + optName] = expand;
      };

      ExpandOpts.prototype.remove = function(srcName, optName) {
        if (srcName == null) {
          srcName = "";
        }
        return delete this.opts[srcName + ":" + optName];
      };

      ExpandOpts.prototype.get = function(srcName, optName) {
        var res;
        res = this.opts[srcName + ":" + optName];
        return res != null ? res : res = this.opts[":" + optName];
      };

      return ExpandOpts;

    })();
    OrderBy = (function() {

      function OrderBy() {
        this.opts = [];
      }

      OrderBy.prototype.add = function(srcName, orderBy, asc) {
        if (srcName == null) {
          srcName = "";
        }
        if (asc == null) {
          asc = "asc";
        }
        return this.opts[srcName] = "" + orderBy + " " + asc;
      };

      OrderBy.prototype.remove = function(srcName) {
        return delete this.opts[srcName];
      };

      OrderBy.prototype.get = function(srcName) {
        var res;
        res = this.opts[srcName];
        if (res == null) {
          res = this.opts[""];
        }
        if (res && res.split(' ')[0] === "null") {
          res = null;
        }
        return res;
      };

      return OrderBy;

    })();
    FilterOpts = (function() {

      function FilterOpts() {}

      FilterOpts.prototype.nullRefVal = function(val) {
        if (val !== void 0) {
          this._nullRefVal = val;
        }
        return this._nullRefVal;
      };

      FilterOpts.prototype.isNullRef = function(item) {
        return item.id === this._nullRefVal;
      };

      return FilterOpts;

    })();
    return {
      expandOpts: new ExpandOpts(),
      orderBy: new OrderBy(),
      filterOpts: new FilterOpts()
    };
  });

}).call(this);
