define ->

  class Pager

    constructor: ->

      #IPager
      @current = ko.observable(0)
      @pagesCount = ko.observable(0)

      @canMovePerv = ko.computed =>
        @current() > 1
      @canMoveNext = ko.computed =>
        @current() < @pagesCount()

      @movingTo = ko.observable(null)
      #^IPager

      @sequence = ko.computed =>
        [1..@pagesCount()]

    #IPager

    onChanged: (@onChangedCallback) ->

    movePerv: ->
      @moveTo @current() - 1

    moveNext: ->
      @moveTo @current() + 1

    moveTo: (page) =>
      if @onChangedCallback
        @movingTo page
        @onChangedCallback page

    setPaging: (data) ->
      @movingTo null
      @current data.page
      @pagesCount if data.latestLoadCount >= data.itemsPerPage then data.page + 1 else data.page

  #^IPager

  Pager : Pager
