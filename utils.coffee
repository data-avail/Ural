class Utils

  getClassName: (obj) ->
    if typeof obj != "object" or obj == null then return false
    /(\w+)\(/.exec(obj.constructor.toString())[1]

  getKey: (hashtable, index) ->
    cnt = 0
    for own key of hashtable
      if cnt == index then return key
      cnt++
    null

  firstKey: (hashtable) ->
    @getKey hashtable, 0

  first: (hashtable) ->
    hashtable[@firstKey(hashtable)]

  toHashTable: (array) ->
    hashtable = []
    for i in array
      hashtable[i[@getKey i, 0]] = i[@getKey i, 1]
    hashtable

  urlAddSearch: (baseUrl, prms) ->
    url = arguments[0]
    if !url then throw "baseUrl must be defined"
    for i in [1..arguments.length - 1]
      if arguments[i]
        if url.indexOf("?") == -1 then url += "?" else url += "&"
        url += arguments[i]
    url

  clone: (src, exceptProps) ->
    res = {}
    exceptProps = Array.prototype.slice.call(arguments).slice 1
    for own prop of src
      if exceptProps.indexOf(prop) == -1 then res[prop] = src[prop]
    res

  argsToArray: (args) ->
    for i in [0..args.length-1]
      args[i]

  trim: (str) ->
    str.replace(/^\s\s*/, '').replace(/\s\s*$/, '')

  wrapHtml: (html) -> "<div>#{html}</div>"

  ###
    is complex object (contatins nested properties for processing)
  ###
  isComplex: (obj) ->
    typeof obj == "object" and !(obj instanceof Date)

  iterObj: (obj, iter) ->
    _obj = ko.utils.unwrapObservable obj
    if _obj == null then return
    for own prop of _obj
      if prop != "__ko_mapping__"
        val = _obj[prop]
        _val = ko.utils.unwrapObservable val
        if Array.isArray _val
          if iter("array", val, _val, prop) != false
            _u.iterObj _v, iter for _v in _val
        else if _u.isComplex _val
          if iter("object", val, _val, prop) != false
            _u.iterObj val, iter
        else
          iter "value", val, _val

  removeFromArray: (array, e) -> array[t..t] = [] if (t = array.indexOf(e)) > -1

  toastrMsg: (type, msg, cap) ->
    func = null
    switch type
      when "success" then f = toastr.success
      when "info" then f = toastr.info
      when "warn" then f = toastr.warning
      when "error" then f = toastr.error
    if f then f msg, cap

  replaceFieldVal: (obj, origVal, replaceVal) ->
    for own prop of obj
      if typeof obj[prop] == "object"
        @replaceFieldVal obj[prop], origVal, replaceVal
      else if obj[prop] == origVal
        obj[prop] = replaceVal

  popup: (url, width, height) ->
    if navigator.userAgent.toLowerCase().indexOf("opera") != -1
      w = document.body.offsetWidth
      h = document.body.offsetHeight
    else
      w = screen.width
      h = screen.height
    t = Math.floor (h - height) / 2 -14
    l = Math.floor (w - width) / 2 - 5
    window.open url, "", "status=no,scrollbars=yes,resizable=yes,width=#{width},height=#{height},top=#{t},left=#{l}"

  str2hash: (str) ->
    hash = 0
    if this.length == 0 then hash
    for i in [0..this.length-1]
      char = this.charCodeAt i
      hash = ((hash<<5)-hash)+char
      hash = hash & hash;
    return hash

  lowerize: (str) ->
    str += ''
    str.charAt(0).toLowerCase() + str.substr 1

  roundDecimals: (val, dec) ->
    Math.round(val*Math.pow(10, dec)) / Math.pow(10, dec)

@_u = new Utils()
