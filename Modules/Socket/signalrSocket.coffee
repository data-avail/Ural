define ["order!Ural/Libs/signalr/jquery.signalR-0.5.0.min.js", "order!/signalr/hubs", "Ural/Libs/jquery.cookie"], ->

  class Socket

    constructor: (@url) ->
      @_channels = []

    _createChannel: (name) ->
      $.connection[name]

    _getChannel: (name) ->
      cn = @_channels.filter((c) -> c.name == name)[0]
      if !cn
        channel = @_createChannel name
        cn = name : name, channel : channel
        if @_channels.length == 0
          #TO DO: bug, wait ISSUE -
          $.connection.hub.start().done =>
            @userId = $.connection.hub.id
            $.cookie "SIGNALR_ID", @userId, path : "/"
        @_channels.push cn
      cn.channel

    _getUserId: -> $.cookie "SIGNALR_ID"

    sub: (channel, event, onData) ->
      @_getChannel(channel)[event] = (data) =>
        if !data._userId or @_getUserId() != data._userId
          onData data

    pub: (channel, event, data) ->
      @_getChannel[channel][event] data

  Socket : Socket
