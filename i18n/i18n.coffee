define ->

  ini = (lang, onDone) ->
    require ["Ural/i18n/#{lang}/messages"], (msg) ->
      onDone
        messages : msg.messages

  ini : ini