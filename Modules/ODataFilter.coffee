define  ->

  _val = (val, tokenName) =>
    #TO DO encoding contract with service part (why ' doesn't work ?)
    if typeof val == "string" then "'#{encodeURIComponent(val).replace("\'", "%ff")}'"
    else if val instanceof Date
      mt = moment new Date val
      if tokenName == "$lte" then mt.add "d", 1
      "DateTime'#{mt.format "YYYY-MM-DD"}'"
    else
      if typeof val == "object" then JSON.stringify val
      else if val then val.toString() else "null"

  _convertToken = (fieldName, tokenName, val) ->
    switch tokenName
      when "$eq" then "#{fieldName} eq #{_val val}"
      when "$lte" then "#{fieldName} le #{_val val, tokenName}"
      when "$gte" then "#{fieldName} ge #{_val val}"
      when "$LIKE" then "indexof(#{fieldName}, '#{val}') ne -1"
      when "$like" then "indexof(toupper(#{fieldName}), '#{val.toUpperCase()}') ne -1"
      when "$in"
        if val.length <= 10
          "(#{(val.map (x) -> "#{fieldName} eq #{_val x}").join " or "})"
        else
          res = {}
          res[fieldName] = val.map (x) -> _val(x)
          res
      else throw "can't convert token expression { #{fieldName} : { #{tokenName} : #{val} }}"

  _convertField = (fieldName, field) ->
    _results = []
    if typeof field == "object"
      for own tokenName of field
        t = _convertToken fieldName, tokenName, field[tokenName]
        if t then _results.push t
    else
      _results.push _convertToken fieldName, "$eq", field

    str : _results.filter((f) -> typeof f == "string").join " and "
    data : _results.filter((f) -> typeof f == "object")[0]

  _convert = (sentence) ->
    _results = []
    for own field of sentence
      if field == "$and"
        if sentence[field].length
          expr = sentence[field].map (s) -> _convert s
          if expr.length
            _results.push {name : "and", expr : expr}
      else if field == "$or"
        if sentence[field].length
          expr = sentence[field].map (s) -> _convert s
          if expr.length
            _results.push {name : "or", expr : expr}
      else
        expr = _convertField field, sentence[field]
        if expr
          _results.push {name : null, expr : expr}
    _results

  _joinSentences = (sentences) ->
    res = ""
    for st in sentences
      if res then res += " and "
      if st.name == "and" or st.name == "or"
        res += "(#{st.expr.map((e) -> _joinSentences e).filter((e)->e).join " #{st.name} "})"
      else
        res += st.expr.str
    res

  _joinData = (sentences) ->
    res = {}
    for st in sentences
      if st.name == "and" or st.name == "or"
        for e in st.expr
          d = _joinData e
          for own s of d
            res[s] = d[s]
      else
        if st.expr.data
          for own p of st.expr.data
            res[p] = st.expr.data[p]
    res


  ###
  Convert frameworkFilter to filter which is complied to format of odata query expressions (odata.org)
  Options
    - **$page** {Int, default:undefined}, page number to return
    - **$itemsPerPage** {Int, default:10}, number of items conteined in one page
    - **any field name**, field name with filter condition, see mongodb conventions
    @param {Object} [options] structure to convert
    @return converted structure {$skip, $top, $filter}
    @api public
  ###
  convert = (frameworkFilter) ->

    for own field of frameworkFilter
      if field == "$page"
        page = frameworkFilter[field]
      else if  field == "$itemsPerPage"
        itemsPerPage = frameworkFilter[field]
      else if field == "$expand"
        expand = frameworkFilter[field]
      else if field == "$orderby"
        orderby = frameworkFilter[field]
      else if field == "$filter"
        sts = _convert frameworkFilter[field]
        filter = _joinSentences sts
        filterData = _joinData sts
      else if field == "$args"
        if frameworkFilter[field]
          args = {}
          for own arg of frameworkFilter[field]
            args[arg] = _val frameworkFilter[field][arg]

    res = {}

    if filter
      res.$filter = filter
      res.$data = filterData

    if page
      itemsPerPage ?= 10
      res.$top = itemsPerPage
      res.$skip = (page - 1) * itemsPerPage

    if expand
      res.$expand = expand

    if orderby
      res.$orderby = orderby

    if args
      res.$args = args

    if (frameworkFilter.$isAction)
      res.$isAction = frameworkFilter.$isAction

    res

  convert : convert