Parameters = sys.import 'parameters'
Extensions = sys.import 'extensions'
Main = sys.import 'main'
Traffic = sys.import 'traffic'
Contributors = sys.import 'contributors'
Filter = sys.import 'filter'
Search = sys.import 'search'
db = sys.import 'db'
notFound = sys.import 'not-found'

exports.index = class Views
    constructor: (dbmeta) ->
        db.init(dbmeta)

        @search = new Search()
        @filter = new Filter('#filter', dbmeta)
        @main = new Main(@filter, @search)
        @parameters = new Parameters(@filter, @search)
        @extensions = new Extensions(@filter, @search)
        @traffic = new Traffic(@filter, @search)
        @contributors = new Contributors()

    breadcrumbs: ->
        breadcrumbs = $('<ol class="breadcrumbs"></ol>')
            .appendTo('main')

        $('<a></a>')
            .attr('href', '/')
            .text('Home')
            .appendTo(breadcrumbs)
            .wrap('<li></li>')

    handle: (path, query, pageload=false) ->
        $('main').empty()
        $('body').removeClass('sidebar')

        switch path
            when '/'
                @breadcrumbs()
                @main.showInfo()
                @main.show('webgl1', false)
                @main.show('webgl2', false)
            when '/search'
                @search.show(query, pageload)
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
                path = path[1...]
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
