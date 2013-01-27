define ["http://js.pusher.com/1.11/pusher.min.js"], ->

  class PusherSocket

    constructor: (key) ->
      @pusher = new Pusher key
      @channels = []

    sub: (channelName, event, onRec) ->
      channel = @pusher.subscribe channelName
      channel.bind event, onRec
      @channels[channelName+"."+event] = channel : channel, callback : onRec

    unsub: (channelName, event) ->
      s = @channels[channelName+"."+event]
      s.channel.unbind event, s.callback

  Socket : PusherSocket
