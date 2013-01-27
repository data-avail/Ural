define ["Ural/Libs/tag-it"], ->

  #tagit with autocomplete
  $.widget "baio.tag",

    options:
      tagSource : null
      link : "Tag"
      onTagAdded : null
      onTagRemoved : null

    _create: ->
      @tags = []
      @lastRespTags = []
      opts =
        animate : false
        allowSpaces : true
        tagSource : (req, resp) =>
          req.link = @options.link
          @options.tagSource req, (respTags) =>
            @lastRespTags = if respTags then respTags else []
            resp respTags
        onTagAdded : (e, tag) =>
          t = @__tagToBe
          if !t
            tagLabel = $(e.target).tagit "tagLabel", tag
            t = @lastRespTags.filter((f) -> f.value == tagLabel)[0]
            t ?= key : -1, value : tagLabel, label : tagLabel
          @tags.push t
          if @options.onTagAdded
            @options.onTagAdded t, if @__tagToBe then false else true
        onTagRemoved : (e, tag) =>
          tagLabel = $(e.target).tagit "tagLabel", tag
          t = @tags.filter((i) -> i.value == tagLabel)[0]
          @tags.splice @tags.indexOf(t), 1
          if @options.onTagRemoved
            @options.onTagRemoved t, if @__tagToBe then false else true

      css = $(@element[0]).attr "class"
      $(@element[0]).tagit opts
      $(@element[0]).next().addClass css

    add: (tags) ->
      @__tagToBe = true
      $(@element[0]).tagit "removeAll"
      @__tagToBe = null

      for tag in tags
        @__tagToBe = tag
        $(@element[0]).tagit "createTag", tag.value
        @__tagToBe = null

    remove: (tags) ->
      @__tagToBe = true
      $(@element[0]).tagit "removeAll"
      @__tagToBe = null
      for tag in tags
        @__tagToBe = tag
        $(@element[0]).tagit "removeTag", tag, false
        @__tagToBe = null


    assignedTags: ->
      $(@element[0]).tagit "assignedTags"



