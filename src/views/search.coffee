behavior = sys.import 'behavior'
breadcrumbs = sys.import 'breadcrumbs'

exports.index = class Search
    constructor: ->
        @index = lunr ->
            @field 'title', boost:10
            @field 'body'
            @field 'extra'
            @ref 'id'

        @entries = {}
    
    breadcrumbs: ->
        breadcrumbs [
            'Search'
        ]

    show: (query, instant) ->
        @breadcrumbs()

        query = query.get('query')
        results = @index.search(query)

        behavior.deactivate()
        behavior.collapse()
            
        widget = $('<div class="full box"></div>')
            .appendTo('main')

        $('<span>Search Results for: </span>')
            .appendTo(widget)

        $('<span class="query"></span>')
            .appendTo(widget)
            .text('"' + query + '". ')

        $("<span>#{results.length} results found.</span>")
            .appendTo(widget)

        for result in results
            entry = @entries[result.ref]

            widget = $('<div class="full box search-result"></div>')
                .appendTo('main')

            if entry.gauge?
                entry.gauge().appendTo(widget)

            text = $('<div></div>')
                .appendTo(widget)

            link = $('<a></a>')
                .appendTo(text)
                .attr('href', result.ref)
                .text(entry.type + ' ' + entry.title)

            $('<p></p>')
                .appendTo(text)
                .append(entry.body)

    add: ({id,titles,body,extra,type,gauge}) ->
        if not (titles instanceof Array)
            titles = [titles]

        extra ?= null

        @entries[id] =
            title: titles[0]
            body: body
            type: type
            gauge: gauge

        @index.add(id:id, title:titles.join(' '), body:$('<div></div>').append(body).text(),extra:extra)
