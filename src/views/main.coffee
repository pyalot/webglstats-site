db = sys.import 'db'
extensions = sys.import 'extensions'
util = sys.import '/util'
behavior = sys.import 'behavior'
Parameters = sys.import 'parameters'
{Gauge, Series} = sys.import '/chart'

exports.index = class Main
    constructor: (@filter, search) ->
        behavior.activatable @
       
    showInfo: ->
        widget = $('<div class="full box"></div>')
            .appendTo('main')

        $('<h1>WebGL Stats</h1>')
            .appendTo(widget)

        $('''<p>
            The statistics on this site help WebGL developers make decisions about hardware capabilities. 
        </p>''').appendTo(widget)
        
        $('''<p>
            If you want help collecting data just embedd the code below into your page.
        </p>''').appendTo(widget)

        
        $('''<pre>&lt;script src=&quot;//cdn.webglstats.com/stat.js&quot; defer async&gt;&lt;/script&gt;</pre>''')
            .appendTo(widget)
        
        $('''<p>
            You can check out the code for this site on <a href="https://github.com/pyalot/webglstats-site">github</a>.
        </p>''').appendTo(widget)

    show: (webglVersion) ->
        behavior.deactivate()
        behavior.collapse(@)

        mainRow = $('<div></div>')
            .addClass('row')
            .addClass('responsive')
            .appendTo('main')
       
        #gauges
        col = $('<div></div>')
            .appendTo(mainRow)
        widget = $('<div class="box"></div>')
            .appendTo(col)
        $('<h1>Support (30 days)</h1>')
            .text(util.versionLabel(webglVersion) + ' Support (30 days)')
            .appendTo(widget)
        row = $('<div class="row center"></div>')
            .appendTo(widget)
        col = $('<div></div>')
            .appendTo(row)
        @gauge(webglVersion, 'large', 'All')
            .appendTo(col)
        smallCharts = $('<div></div>')
            .appendTo(row)
        row = $('<div class="row center"></div>')
            .appendTo(smallCharts)
        col = $('<div></div>').appendTo(row)
        @gauge(webglVersion, 'small', 'Desktop', 'desktop').appendTo(col)
        col = $('<div></div>').appendTo(row)
        @gauge(webglVersion, 'small', 'Smartphone', 'smartphone').appendTo(col)
        row = $('<div class="row center"></div>')
            .appendTo(smallCharts)
        col = $('<div></div>').appendTo(row)
        @gauge(webglVersion, 'small', 'Tablet', 'tablet').appendTo(col)
        col = $('<div></div>').appendTo(row)
        @gauge(webglVersion, 'small', 'Console', 'game_console').appendTo(col)
        
        #time series
        col = $('<div></div>')
            .appendTo(mainRow)
        widget = $('<div class="box"></div>')
            .appendTo(col)
        $('<h1></h1>')
            .text(util.versionLabel(webglVersion) + ' Support')
            .appendTo(widget)
        @series(webglVersion).appendTo(widget)

    gauge: (webglVersion, size='small', label=null, device=null) =>
        chart = new Gauge(label:label, size:size)

        query =
            filterBy: {}
            bucketBy:'webgl'
            start: -30

        if device?
            query.filterBy['useragent.device'] = device

        @filter.onChange chart.elem, =>
            chart.elem.addClass('spinner')
            if @filter.platforms?
                query.filterBy.platform = @filter.platforms
            else
                delete query.filterBy.platform

            db.execute
                db: webglVersion
                query: query
                success: (result) ->
                    percentage = result.values[1]/result.total
                    chart.setLabel(label + " (#{util.formatNumber(result.total)})")
                    chart.update(percentage*100)
                    chart.elem.removeClass('spinner')

        return chart.elem

    series: (webglVersion) ->
        chart = new Series()

        @filter.onChange chart.elem, =>
            query =
                bucketBy:'webgl'
                series: @filter.series

            if @filter.platforms?
                query.filterBy =
                    platform: @filter.platforms

            db.execute
                db: webglVersion
                query: query
                success: (result) ->
                    chart.update(result.values)

        return chart.elem

    deactivate: ->
        null
