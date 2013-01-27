define ["Ural/Libs/socket.io/socket.io.min.js"], ->

  class Socket

    constructor: (@url) ->
      @channels = []

    _createChannel: (name) ->
      io.connect "#{@url}/#{name}"

    _getChannel: (name) ->
      cn = @channels.filter((c) -> c.name == name)[0]
      if !cn
        channel = @_createChannel name
        cn = name : name, channel : channel
        @channels.push cn
      cn.channel

    sub: (channel, event, onData) ->
      @_getChannel(channel).on event, onData

    pub: (channel, event, data) ->
      @_getChannel(channel).emit event, data

  Socket : Socket

