factory = (ko, exports) ->

  ko.validation.rules['notNullRef'] =

    validator: (val, otherVal) ->
      return !val or val.id() != __g.nullRefVal()

    message: "Поле должно быть заполнено."

  ko.validation.rules['lte'] =

    validator: (val, otherVal) ->
      return val <= otherVal()

    message: "Поле 'от' должно быть меньше или равно полю 'по'."

  ko.validation.rules['dmin'] =

    validator: (val, otherVal) ->
      return moment(val).sod().diff(moment(otherVal).sod()) >= 0

    message: (val) ->
      "Дата должна быть больше {0}."

  ko.validation.rules['dmax'] =

    validator: (val, otherVal) ->
      return moment(otherVal).sod().diff(moment(val).sod()) >= 0

    message: "Дата должна быть меньше {0}."

  ko.validation.validable = (item) ->
    item.errors = ko.validation.group item


# Module systems magic dance.
if typeof require == "function" and typeof exports == "object" and typeof module == "object"
  # CommonJS or Node: hard-coded dependency on "knockout"
  factory(require("knockout"), exports)
else if typeof define == "function" and define["amd"]
  # AMD anonymous module with hard-coded dependency on "knockout"
  define(["knockout", "exports"], factory)
else
  #<script> tag: use the global `ko` object, attaching a `mapping` property
  factory(ko, ko.mapping = {})
