util = sys.import 'util'

copyObj = (obj) ->
    result = {}
    for name, value of obj
        result[name] = value
    return result

query2obj = (query) ->
    result = {}
    for name in util.iter2list(query.keys())
        result[name] = query.get(name)
    return result

obj2query = (obj) ->
    query = new URLSearchParams()
    for name, value of obj
        query.set(name, value)
    return query

equalObj = (a, b) ->
    if a? and not b?
        return false

    if b? and not a?
        return false

    for name, value of a
        if b[name] != value
            return false

    for name, value of b
        if a[name] != value
            return false

    return true
    
parseQuery = (string) ->
    query = new URLSearchParams(string)
    return query2obj(query)

exports.index = class Location
    constructor: (@app) ->
        @path = document.location.pathname
        @query = parseQuery(document.location.search)
        if @query?
            @platforms = @query.platforms
            delete @query.platforms

        window.addEventListener 'popstate', @popstate
        document.addEventListener 'click', @click
        $('form').submit @formSubmit

    setLocation: (path, query=null) ->
        if not equalObj(query, @query) or path != @path
            @path = path
            @query = query
            @push()
            @app.navigate(false)

    push: ->
        query = obj2query(@query)
        if @platforms?
            query.set('platforms', @platforms)

        query = query.toString().trim()
        if query.length > 0
            history.pushState(null, null, "#{@path}?#{query}")
        else
            history.pushState(null, null, @path)

    popstate: (event) =>
        path = document.location.pathname
        query = parseQuery(document.location.search)
        platforms = query.platforms ? null
        delete query.platforms
        
        if platforms != @platforms
            @platforms = platforms
            @app.views.setFilter(platforms)
        
        if not equalObj(query, @query) or path != @path
            @path = path
            @query = query
            @app.navigate(false)

    click: (event) =>
        if event.ctrlKey or event.shiftKey or event.metaKey or event.altKey
            return

        target = event.target ? event.srcElement
        anchor = $(target).closest('a')[0]
        if anchor?
            path = anchor.getAttribute('href')
            if path? and path.startsWith('/')
                event.preventDefault()
                @setLocation(path)

    formSubmit: (event) =>
        event.preventDefault()

        params = {}
        for {name,value} in $(event.target).serializeArray()
            params[name] = value

        path = $(event.target).attr('action')
        @setLocation(path, params)

    setFilter: (platforms) ->
        @platforms = platforms
        @push()
