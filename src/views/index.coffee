Parameters = sys.import 'parameters'
Extensions = sys.import 'extensions'
Main = sys.import 'main'
Traffic = sys.import 'traffic'
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
        @traffic = new Traffic(@filter, @search)

    handle: (path, query, pageload=false) ->
        $('main').empty()

        switch path
            when '/'
                @main.showInfo()
                @main.show('webgl1', pageload)
                @main.show('webgl2', pageload)
            when '/search'
                @search.show(query, pageload)
            when '/traffic'
                @traffic.show()
            when '/webgl'
                @main.show('webgl1', pageload)
                @extensions.overview('webgl1', pageload)
            when '/webgl2'
                @main.show('webgl2', pageload)
                @extensions.overview('webgl2', pageload)
            else
                path = path[1...]
                parts = path.split('/')
                webglVersion = ({webgl:'webgl1', webgl2:'webgl2'})[parts.shift()]
                category = parts.shift()
                name = parts.shift()

                switch category
                    when 'parameter' then @parameters.show(webglVersion, name, pageload)
                    when 'extension' then @extensions.show(webglVersion, name, pageload)
