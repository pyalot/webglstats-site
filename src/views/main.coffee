db = sys.import 'db'
extensions = sys.import 'extensions'
Parameters = sys.import 'parameters'
{Gauge, Series} = sys.import '/chart'
Navigatable = sys.import 'navigatable'

exports.index = class Main extends Navigatable
    constructor: (@filter) ->
        super()

    show: ->
        @deactivateAll()

        row = $('<div></div>')
            .addClass('row')
            .addClass('responsive')
            .appendTo('main')
        
        col = $('<div></div>')
            .appendTo(row)

        widget = $('<div class="box"></div>')
            .appendTo(col)

        $('<h1>WebGL</h1>')
            .appendTo(widget)

        $('''<p>
            The statistics on this site help WebGL developers make decisions about hardware capabilities. 
        </p>''').appendTo(widget)
        
        $('''<p>
            If you want to help just embedd the code below into your page.
        </p>''').appendTo(widget)
        
        $('''
            <pre>&lt;script src=&quot;//cdn.webglstats.com/stat.js&quot;
                defer async&gt;&lt;/script&gt;</pre>''')
            .appendTo(widget)

        col = $('<div></div>')
            .appendTo(row)

        widget = $('<div class="box"></div>')
            .appendTo(col)
        
        $('<h1>Support (30 days)</h1>')
            .appendTo(widget)
        
        row = $('<div class="row center"></div>')
            .appendTo(widget)

        col = $('<div></div>')
            .appendTo(row)
        
        @gauge('large', 'All')
            .appendTo(col)

        smallCharts = $('<div></div>')
            .appendTo(row)

        row = $('<div class="row center"></div>')
            .appendTo(smallCharts)
        
        col = $('<div></div>').appendTo(row)
        @gauge('small', 'Desktop', 'desktop').appendTo(col)
        
        col = $('<div></div>').appendTo(row)
        @gauge('small', 'Smartphone', 'smartphone').appendTo(col)
        
        row = $('<div class="row center"></div>')
            .appendTo(smallCharts)
        
        col = $('<div></div>').appendTo(row)
        @gauge('small', 'Tablet', 'tablet').appendTo(col)
        
        col = $('<div></div>').appendTo(row)
        @gauge('small', 'Console', 'game_console').appendTo(col)

        widget = $('<div class="full box"></div>')
            .appendTo('main')

        $('<h1>WebGL Support</h1>')
            .appendTo(widget)

        @series().appendTo(widget)

    gauge: (size='small', label=null, device=null) ->
        chart = new Gauge(label:label, size:size)

        query =
            filterBy: {}
            bucketBy:'webgl'
            start: -30

        if device?
            query.filterBy['useragent.device'] = device

        initial = true
        update = =>
            if document.body.contains(chart.elem[0]) or initial
                chart.elem.addClass('spinner')
                initial = false
                if @filter.platforms?
                    query.filterBy.platform = @filter.platforms
                else
                    delete query.filterBy.platform

                db.execute
                    query: query
                    success: (result) ->
                        result = result.values[1]/result.total
                        chart.update(result*100)
                        chart.elem.removeClass('spinner')
            else
                @filter.offChange update
        @filter.onChange update
        update()

        return chart.elem

    series: ->
        chart = new Series()

        initial = true
        update = =>
            if document.body.contains(chart.elem[0]) or initial
                initial = false
                query =
                    bucketBy:'webgl'
                    series: 'daily'

                if @filter.platforms?
                    query.filterBy =
                        platform: @filter.platforms

                db.execute
                    query: query
                    success: (result) ->
                        chart.update(result.values)
            else
                @filter.offChange update

        @filter.onChange update
        update()

        return chart.elem

    deactivate: ->
        null
