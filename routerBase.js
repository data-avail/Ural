// Generated by CoffeeScript 1.3.3
(function() {

  define(["Ural/Controllers/controllerBase", "Ural/Modules/pubSub", "hasher", "crossroads", "Ural/text!Ural/Views/Shared/AppLoad.html"], function(controllerBase, pubSub, hasher, crossroads) {
    var RouterBase;
    RouterBase = (function() {

      function RouterBase(controllerDirectory, defaultRoute) {
        var _this = this;
        this.controllerDirectory = controllerDirectory;
        this.defaultRoute = defaultRoute;
        this.onLoading();
        this._recAction = {
          name: null,
          obj: null,
          action: null
        };
        this._recHash = null;
        this.addRoute('{controller}/index', true, function(ctr, ck) {
          return _this.onControllerRouter(ctr, "index", null, ck);
        });
        this.addRoute('{controller}/item/{idx}', true, function(ctr, idx, ck) {
          return _this.onControllerRouter(ctr, "item", idx, null, ck);
        });
        this.addRoute('{controller}', true, function(ctr, ck) {
          return _this.onControllerRouter(ctr, null, null, ck);
        });
      }

      RouterBase.prototype._exec = function(execArgs) {
        var args;
        args = execArgs.split("!").map(function(m) {
          return m.split("/").filter(function(f) {
            return f;
          });
        });
        return pubSub.pub("router", "exec", {
          args: args
        });
      };

      RouterBase.prototype._hash = function() {
        return hasher.getHash().replace(/^([^!]+)\/!\/(.*)/, "$1");
      };

      RouterBase.prototype._setHashSilently = function(hash) {
        hasher.changed.active = false;
        hasher.setHash(hash);
        return hasher.changed.active = true;
      };

      RouterBase.prototype.removeRoute = function(route) {
        return crossroads.removeRoute(route);
      };

      RouterBase.prototype.addRoute = function(route, appendExecRoute, callback) {
        var execRoute,
          _this = this;
        crossroads.addRoute(route, callback);
        if (appendExecRoute) {
          execRoute = "" + route + "/!/{exec*}";
          return crossroads.addRoute(execRoute, function() {
            var args, exec, hash;
            args = _u.argsToArray(arguments);
            exec = args[args.length - 1];
            hash = _this._hash();
            _this._setHashSilently(hash);
            if (_this._recHash !== hash) {
              args.splice(args.length - 1, 1, function() {
                return _this._exec(exec);
              });
              return callback.apply(_this, args);
            } else {
              return _this._exec(exec);
            }
          });
        }
      };

      RouterBase.prototype.getOnLoadingPage = function() {
        return "Ural/Views/Shared/AppLoad.html";
      };

      RouterBase.prototype.onLoading = function() {};

      RouterBase.prototype.onNotFound = function() {
        controllerBase.ControllerBase.loadView(null, "Ural/Views/Shared/NotFound.html");
        return this.onRouteChanged(null, null);
      };

      RouterBase.prototype.onControllerRouter = function(controller, action, index, callback, persistRoute) {
        var capControllerName, controllerName,
          _this = this;
        this._recHash = this._hash();
        if (this._recAction.obj && this._recAction.obj.afterAction) {
          this._recAction.obj.afterAction(this._recAction.action);
        }
        index = this.onParseIndex(controller, action, index);
        if (this._recAction.name !== controller) {
          if (action == null) {
            action = "index";
          }
          controllerName = "" + controller + "Controller";
          capControllerName = "" + (_.str.capitalize(controller)) + "Controller";
          return require(["" + this.controllerDirectory + "/" + controllerName], function(controllerModule) {
            var ctl;
            ctl = eval("new controllerModule." + capControllerName + "()");
            ctl[action](index);
            _this._recAction = {
              name: controller,
              obj: ctl,
              action: action
            };
            if (callback) {
              callback();
            }
            if (!persistRoute) {
              return _this.onRouteChanged(controller, action);
            }
          });
        } else {
          this._recAction.action = action;
          this._recAction.obj[action](index);
          if (!persistRoute) {
            return this.onRouteChanged(controller, action);
          }
        }
      };

      RouterBase.prototype.onRouteChanged = function(controller, action) {
        if (this.onRouteChangedCallback) {
          return this.onRouteChangedCallback(controller, action);
        }
      };

      RouterBase.prototype.startRouting = function() {
        var parseHash,
          _this = this;
        parseHash = function(newHash, oldHash) {
          return crossroads.parse(newHash);
        };
        hasher.initialized.add(parseHash);
        hasher.changed.add(parseHash);
        hasher.init();
        if (!hasher.getHash()) {
          hasher.setHash(this.defaultRoute);
        }
        return crossroads.bypassed.add(function(request) {
          console.log(request);
          return _this.onNotFound();
        });
      };

      RouterBase.prototype.onParseIndex = function(controller, action, index) {
        return index;
      };

      return RouterBase;

    })();
    return {
      RouterBase: RouterBase
    };
  });

}).call(this);
