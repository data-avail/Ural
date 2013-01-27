define ["Ural/Modules/ODataFilter", "Ural/Modules/DataFilterOpts", "Ural/Libs/datajs"], (fr, frOpts) ->
  class ODataProvider

    @serviceHost: -> __g.serviceHost

    @_parse: (item, parent)->
      if item == null or item == undefined or item instanceof Date or typeof item != "object" then return item
      if item.results and Array.isArray item.results
        arr = item.results
      if item.d && Array.isArray item.d
        arr = item.d
      if Array.isArray item
        arr = item
      if (arr) then return arr.map (i) -> ODataProvider._parse i, parent
      obj = {}
      for own prop of item
        if prop == "__deferred"
          return if _.str.endsWith parent, "s" then [] else id : __g.nullRefVal()
        if prop != "__metadata"
          obj[prop] = ODataProvider._parse item[prop], prop
      obj

    @_isDelete: (item) -> item and item.__state and item.__state.__status == "removed"

    @_getEndPoint: (name, item, isIndex) ->
      if item.__endPointBinding == null then return null
      if item.__endPointBinding
        root = item.__endPointBinding["$root"]
        root = item.__endPointBinding if typeof item.__endPointBinding == "string"
      if root
        if typeof root == "object"
          indexEndPoint = root.index
          itemEndPoint = root.item
        else
          itemEndPoint = root
      else
        itemEndPoint = name.replace /^(.*)s$/, "$1"
      indexEndPoint ?= itemEndPoint.pluralize()
      if isIndex then indexEndPoint else itemEndPoint

    @_isNew: (item) ->
      item.id == null or item.id == -1

    @_getKeyVal: (id) ->
      if typeof id == "string" then "'#{id}'" else id

    @isChanged: (state) ->
      for own p of state
        if state[p] == "modifyed" or state.__status == "added" or state.__status == "removed"
          return true
      return false

    @_formatRequest: (name, item, metadata, parentName, parent, parentContentId, totalCount) ->
      res = []
      expnads = []
      totalCount ?= 1
      cid = totalCount
      cidOrig = cid
      isDelete = ODataProvider._isDelete item
      parentId = parent.id if parent
      key = ODataProvider._getKeyVal item.id
      parentKey = ODataProvider._getKeyVal parentId

      status = item.__state.__status if item.__state

      if !item.__state or ODataProvider.isChanged item.__state

        if !isDelete
          flattered = {}
          for own prop of item
            val = item[prop]
            if val != null and (typeof val != "object" or val instanceof Date) and !Array.isArray(val) and prop != "__endPointBinding"
              flattered[prop] = val
            if val == null
              flattered[prop] = null

        isArrayProp = if parent then Array.isArray parent[name] else false
        typeName = if isArrayProp then name.singularize() else name

        itemEP = ODataProvider._getEndPoint name, item, false
        indexEP = ODataProvider._getEndPoint name, item, true

        if !parentName
          #root item
          if isDelete
            data = method: "DELETE", uri: "#{indexEP}(#{key})"
          else
            data = if ODataProvider._isNew item then  method: "POST", uri: indexEP else method: "PUT", uri: "#{indexEP}(#{key})"
        else
          parentName = parentName.replace /^(.*)s$/, "$1"
          parIndexEP = ODataProvider._getEndPoint parentName, parent, true
          #nested item
          if isDelete
            ref = if !isArrayProp then name else "#{name}(#{item.id})"
            data = method: "DELETE", uri: "#{parIndexEP}(#{parentId})/$links/#{ref}"
          else
            if item.id == __g.nullRefVal() then return res
            ref = if ODataProvider._isNew parent then "$#{parentContentId}" else "#{parIndexEP}(#{parentId})"
            if !ODataProvider._isNew item
              ###here actual update of referenced item###
              res.push
                headers: {"Content-ID": cid}
                requestUri: "#{indexEP}(#{item.id})"
                method: "PUT"
                data: flattered
              cid++
              ###here update link to referenced item###
              data = method: (if isArrayProp then "POST" else "PUT"), uri: "#{ref}/$links/#{name}"
              flattered = uri : "#{indexEP}(#{item.id})"
            else
              if isArrayProp
                data = method: "POST", uri: "#{ref}/#{name}"
              else
                res.push
                  headers: {"Content-ID": cid}
                  requestUri: indexEP
                  method: "POST"
                  data: flattered
                data = method: "PUT", uri: "#{ref}/$links/#{name}"
                flattered = uri : "$#{cid}"
                cid++

        res.push
          headers: {"Content-ID": cid}
          requestUri: data.uri
          method: data.method
          data: flattered

        totalCount += res.length

      if !isDelete
        for own prop of item
          if prop == "__state" || prop == "__parent" || prop == "__endPointBinding" then continue
          val = item[prop]
          epb =  item.__endPointBinding[prop] if item.__endPointBinding
          if epb == null then continue
          if Array.isArray val
            states = item.__state[prop] if item.__state
            val = val.concat states.filter((v) -> v.__status == "removed") if states
            for i, ix in val
              i.__state = states[ix] if states
              i.__endPointBinding = epb if epb
              nested = ODataProvider._formatRequest prop, i, metadata, name, item, cidOrig, totalCount
              totalCount += nested.length
              res = res.concat nested
          else if val != null and typeof val == "object" and !(val instanceof Date)
            val.__state = item.__state[prop] if item.__state
            val.__endPointBinding = epb if epb
            nested = ODataProvider._formatRequest prop, val, metadata, name, item, cidOrig, totalCount
            totalCount += nested.length
            res = res.concat nested
      res

    @_unpackArray: (ar) ->
      if Array.isArray ar[0]
        res = []
        for r in ar
          res.push s for s in ODataProvider._unpackArray r
        res
      else
        ar


    load: (srcName, filter, callback) ->
      ofr = fr.convert filter
      stt = @_getSatementByODataFilter srcName, ofr
      if ofr.$data
        #TO DO
        rid = new Date().getTime()
      OData.read stt, (data) ->
        console.log data
        callback null, ODataProvider._parse(data)


    _getExpand: (srcName, expand) ->
      res = frOpts.expandOpts.get srcName, expand
      if res == "" then null
      res ?= expand

    _getOrderBy: (srcName, filter, orderby) ->
      singleItemFilter = filter.match /^.*id eq .*$/ if filter
      if singleItemFilter then return null
      orderby ?= frOpts.orderBy.get srcName

    _getSatementByODataFilter: (srcName, oDataFilter) ->
      expand = @_getExpand srcName, oDataFilter.$expand
      if !oDataFilter.$isAction
        orderby = @_getOrderBy srcName, oDataFilter.$filter, oDataFilter.$orderby
        srcName = srcName.pluralize()
      srch = _u.urlAddSearch "#{ODataProvider.serviceHost()}#{srcName}",
        if oDataFilter.$filter then "$filter=#{oDataFilter.$filter}",
        if oDataFilter.$top then "$top=#{oDataFilter.$top}",
        if oDataFilter.$skip then "$skip=#{oDataFilter.$skip}",
        if expand then "$expand=#{expand}",
        if orderby then "$orderby=#{orderby}"
      if oDataFilter.$args
        for own arg of oDataFilter.$args
          srch = _u.urlAddSearch srch, "#{arg}=#{oDataFilter.$args[arg]}"
      srch

    @_getMetadata: (srcName, item) ->
      null

    @_getSaveRequestData: (srcName, item) ->
      #metadata = ODataProvider._getMetadata srcName, item
      if item.__parent
        parentId = item.__parent.id
        parentTypeName = item.__parent.typeName
      req = ODataProvider._formatRequest srcName, item, null, parentTypeName, parentId
      if req.length
        req.sort (a, b) -> a.headers["Content-ID"] - b.headers["Content-ID"]
        __batchRequests: [
          __changeRequests: req
        ]
      else
        return null

    @_getBodyError: (body) ->
      #JSON.parse(body).error.message.value
      xmlDoc = $.parseXML body
      $xml = $(body)
      #TO DO
      $xml[1].children[1].textContent

    @_parseSaveResponseData: (data) ->
      res = []
      for batchResponse in data.__batchResponses
        for changeResponse in batchResponse.__changeResponses
          res.push
            type: null
            contentId: changeResponse.headers["Content-ID"] if changeResponse.headers
            data: changeResponse.data
            error: changeResponse.message
            bodyError : if changeResponse.response and changeResponse.response.body then ODataProvider._getBodyError changeResponse.response.body else null
      res

    save: (srcName, item, callback) ->
      data = ODataProvider._getSaveRequestData srcName, item
      if data
        request =
          requestUri: "#{ODataProvider.serviceHost()}$batch"
          method: "POST"
          data: data

        OData.request request
          , (data) =>
            resp = ODataProvider._parseSaveResponseData data
            errs = resp.filter (f) -> f.error
            status = item.__state.__status if item.__state
            if !errs.length and status != "removed"
              expand = @_getExpand srcName, "$item"
              rootResp = resp.filter((x) -> x.contentId == "1")[0]
              if status
                id = if rootResp and rootResp.data and status == "added" then rootResp.data.id else item.id
              else
                id = if !item.id or item.id == -1 then rootResp.data.id else item.id
              @load srcName, $filter : { id: {$eq: id}}, $expand: expand, (err, data) ->
                if !err then data = data[0]
                callback err, data
            else
              callback errs.map((err) -> if err.bodyError then err.bodyError else err.error).join '\n'
          , (err) ->
            callback err
          , OData.batchHandler
      else
        callback __g.i18n.messages.nothing_to_commit

    delete: (srcName, id, callback) ->
      @save srcName, {id : id, __state : {__status : "removed"} } , callback

  dataProvider: new ODataProvider()

