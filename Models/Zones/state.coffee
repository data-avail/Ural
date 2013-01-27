define ["Ural/Modules/pubSub"], (pubSub) ->

  #unchanged|modifyed|added|updating
  #now implemented only 2 - modifyed|updating
  class State

    constructor: ->

      @isLoading = ko.observable false
      @isPageMove = ko.observable false
      @loadingStarts = ko.observable()
      @isEmptyResult = ko.observable false
      @isNotEmptyResult = ko.computed => !@isEmptyResult()
      @isFiltering = ko.computed =>
        @isLoading() and !@isPageMove()

      @state = ko.observable "modifyed"

      pubSub.subOnce "model", "list_changed", "state", (data) =>
        if data.changeType == "update_begin"
          @state "updating"
        else
          @state "modifyed"

  State : State
