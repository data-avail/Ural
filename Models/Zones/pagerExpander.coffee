define ->

  class Pager

    constructor: (@list, @maxLimit) ->


      @itemsPerPage = ko.observable(0)
      @latestLoadCount = ko.observable -1
      @lastLength = ko.observable -1

      @movingTo = ko.observable(null)
      @current = ko.observable(0)
      @canMovePerv = false
      @canMoveNext = ko.computed =>
        (@latestLoadCount() == -1 or @latestLoadCount() >= @itemsPerPage()) and @maxLimit > list().length

    moveTo: (page) ->
      if @onChangedCallback
        @movingTo page
        @onChangedCallback page

    movePerv: ->
      throw "not implemented"

    moveNext: ->
      if @canMoveNext()
        @moveTo @current() + 1

    onChanged: (@onChangedCallback) ->

    setPaging: (data) ->
      @movingTo null
      @current data.page
      @latestLoadCount data.latestLoadCount
      @itemsPerPage data.itemsPerPage

  Pager : Pager