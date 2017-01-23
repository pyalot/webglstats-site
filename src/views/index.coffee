Parameters = sys.import 'parameters'
Extensions = sys.import 'extensions'
Main = sys.import 'main'
Traffic = sys.import 'traffic'
Contributors = sys.import 'contributors'
Filter = sys.import 'filter'
Search = sys.import 'search'
db = sys.import 'db'
notFound = sys.import 'not-found'
breadcrumbs = sys.import 'breadcrumbs'

exports.index = class Views
    constructor: (@app) ->
        db.init(@app.dbmeta)

        @search = new Search()
        @filter = new Filter('#filter', @app)
        @main = new Main(@filter, @search)
        @parameters = new Parameters(@filter, @search)
        @extensions = new Extensions(@filter, @search)
        @traffic = new Traffic(@filter, @search)
        @contributors = new Contributors()

    setFilter: (platforms) ->
        @filter.set(platforms)

    breadcrumbs: ->
        breadcrumbs []

    handle: (location, pageload=false) ->
        $('main').empty()
        $('body').removeClass('sidebar')

        switch location.path
            when '/'
                @breadcrumbs()
                @main.showInfo()
                @main.show('webgl1', false)
                @main.show('webgl2', false)
            when '/search'
                @search.show(location.query, pageload)
            when '/traffic'
                @traffic.show()
            when '/webgl'
                @main.show('webgl1')
                @extensions.overview('webgl1', pageload)
            when '/webgl2'
                @main.show('webgl2')
                @extensions.overview('webgl2', pageload)
            when '/contributors'
                @contributors.show()
            else
                path = location.path[1...]
                parts = path.split('/')
                webglVersion = ({webgl:'webgl1', webgl2:'webgl2'})[parts.shift()]
                category = parts.shift()
                name = parts.shift()

                if not webglVersion?
                    notFound()
                    return

                switch category
                    when 'parameter' then @parameters.show(webglVersion, name, pageload)
                    when 'extension' then @extensions.show(webglVersion, name, pageload)
                    else
                        notFound()
