// Generated by CoffeeScript 1.3.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(function() {
    var User;
    User = (function() {

      function User(logon) {
        this.logon = logon;
        this.logOff = __bind(this.logOff, this);

        this.logOn = __bind(this.logOn, this);

        this.name = ko.observable();
      }

      User.prototype.logOn = function(data, event) {
        if (event) {
          event.preventDefault();
        }
        return this.logon.auth(typeof data === "string" ? data : window.location.pathname);
      };

      User.prototype.logOff = function(data, event) {
        event.preventDefault();
        return this.logon.logOff();
      };

      return User;

    })();
    return {
      User: User
    };
  });

}).call(this);