Parameters = sys.import 'parameters'
Extensions = sys.import 'extensions'
Main = sys.import 'main'
Filter = sys.import 'filter'
Search = sys.import 'search'
db = sys.import 'db'

exports.index = class Views
    constructor: ->
        db.init()

        @search = new Search()
        @filter = new Filter('#filter')
        @main = new Main(@filter, @search)
        @parameters = new Parameters(@filter, @search)
        @extensions = new Extensions(@filter, @search)

    handle: (path, query, pageload=false) ->
        $('main').empty()

        if path == '/'
            @main.show(pageload)
            @extensions.overview(pageload)
            #@parameters.overview(pageload) #these charts are not really informative
        else if path == '/search'
            @search.show(query, pageload)
        else
            path = path[1...]
            parts = path.split('/')
            console.assert parts.shift() == 'webgl'
            category = parts.shift()
            name = parts.shift()

            switch category
                when 'parameter' then @parameters.show(name, pageload)
                when 'extension' then @extensions.show(name, pageload)
