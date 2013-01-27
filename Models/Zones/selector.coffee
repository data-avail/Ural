define ["Ural/Modules/pubSub"], (pubSub) ->

  class SelectorsList

    constructor: ->
      @toolbox = new SelectorToolbox()

    add: (name, Selector) ->
      this[name] = Selector

  class Selector

    constructor: (@form, @indexVM, @onSelect) ->

    update: (filter) ->
      @indexVM.load $filter : filter

    start: (data, event) =>
      event.preventDefault()
      pubSub.pub "selector", "show", form : @form
      @update()

    select: (itemVM, event) =>
      if event then event.preventDefault()
      @onSelect itemVM
      pubSub.pub "selector", "hide", form : @form

    cancel: (itemVM, event) ->
      event.preventDefault()
      pubSub.pub "selector", "hide", form : @form

    addNew: (data, event) ->
      if event then event.preventDefault()
      pubSub.pub "selector", "addNew", type : @indexVM.typeName, (err, item) =>
        if item
          @indexVM.add item
          @select item

  class TreeSelector

    constructor: (@form, @getSelected, @onSelect) ->

    start: (data, event) =>
      if event
        event.preventDefault()
      pubSub.pub "selector", "show", form : @form

    select: (node, event) =>
      if event
        event.preventDefault()
      @onSelect node
      pubSub.pub "selector", "hide", form : @form

    cancel: (itemVM, event) ->
      if event
        event.preventDefault()
      pubSub.pub "selector", "hide", form : @form

  class SelectorToolbox

    addRoot: (data, event) ->
      pubSub.pub "selector", "toolbox", action : "add_root", data : data

    add: (data, event) ->
      pubSub.pub "selector", "toolbox", action : "add", data : data

    rename: (data, event) ->
      pubSub.pub "selector", "toolbox", action : "rename", data : data

    remove: (data, event) ->
      pubSub.pub "selector", "toolbox", action : "remove", data : data


  SelectorsList : SelectorsList
  Selector : Selector
  TreeSelector : TreeSelector
  SelectorToolbox : SelectorToolbox
