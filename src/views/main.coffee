db = sys.import 'db'
extensions = sys.import 'extensions'
util = sys.import '/util'
behavior = sys.import 'behavior'
Parameters = sys.import 'parameters'
{Donut, Gauge, Series} = sys.import '/chart'

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

        $('''<p>
            <a href="http://webglreport.com/">WebGL Report</a> allows you to see the parameters your browser has implemented.
        </p>''').appendTo(widget)

    breadcrumbs: (webglVersion) ->
        breadcrumbs = $('<ol class="breadcrumbs"></ol>')
            .appendTo('main')
        
        $('<a></a>')
            .attr('href', '/')
            .text('Home')
            .appendTo(breadcrumbs)
            .wrap('<li></li>')

        $('<a></a>')
            .attr('href', '/' + util.versionPath(webglVersion))
            .text(util.versionLabel(webglVersion))
            .appendTo(breadcrumbs)
            .wrap('<li></li>')

    show: (version, breadcrumbs=true) ->
        behavior.deactivate()
        behavior.collapse(@)

        if breadcrumbs
            @breadcrumbs(version)
            versionLabel = ''
        else
            versionLabel = util.versionLabel(version) + ' '

        mainRow = $('<div></div>')
            .addClass('row')
            .addClass('responsive')
            .appendTo('main')
        @supportGauges(version, versionLabel, mainRow)
        @caveatDonut(version, versionLabel, mainRow)
        
        @supportSeries(version, versionLabel)

    caveatDonut: (version, versionLabel, parent) ->
        col = $('<div></div>')
            .appendTo(parent)
        widget = $('<div class="box"></div>')
            .appendTo(col)
        $('<h1></h1>')
            .text(versionLabel + 'Major Performance Caveat (30d)')
            .appendTo(widget)
        @donut(version, versionLabel).appendTo(widget)
        
    supportSeries: (version, versionLabel) ->
        widget = $('<div class="full box"></div>')
            .appendTo('main')
        $('<h1></h1>')
            .text(versionLabel + 'Support')
            .appendTo(widget)
        @series(version).appendTo(widget)

    supportGauges: (version, versionLabel, parent) ->
        col = $('<div></div>')
            .appendTo(parent)
        widget = $('<div class="box"></div>')
            .appendTo(col)
        $('<h1>Support (30d)</h1>')
            .text(versionLabel + 'Support (30d)')
            .appendTo(widget)
        row = $('<div class="row center"></div>')
            .appendTo(widget)
        col = $('<div></div>')
            .appendTo(row)
        @gauge(version, 'large', 'All')
            .appendTo(col)
        smallCharts = $('<div></div>')
            .appendTo(row)
        row = $('<div class="row center"></div>')
            .appendTo(smallCharts)
        col = $('<div></div>').appendTo(row)
        @gauge(version, 'small', 'Desktop', 'desktop').appendTo(col)
        col = $('<div></div>').appendTo(row)
        @gauge(version, 'small', 'Smartphone', 'smartphone').appendTo(col)
        row = $('<div class="row center"></div>')
            .appendTo(smallCharts)
        col = $('<div></div>').appendTo(row)
        @gauge(version, 'small', 'Tablet', 'tablet').appendTo(col)
        col = $('<div></div>').appendTo(row)
        @gauge(version, 'small', 'Console', 'game_console').appendTo(col)

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
                    chart.setLabel(label + " (#{util.formatNumber(result.values[1])})")
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
    
    donut: (version, versionLabel) ->
        chart = new Donut()

        @filter.onChange chart.elem, =>
            chart.elem.addClass('spinner')
            query =
                filterBy: {webgl:true}
                bucketBy: 'webgl.majorPerformanceCaveat'
                start: -30

            if @filter.platforms?
                query.filterBy.platform = @filter.platforms

            db.execute
                db: version
                query: query
                success: (result) ->
                    chart.elem.removeClass('spinner')

                    values = for label, n in result.keys
                        if not label?
                            label = 'Unknown'

                        value = result.values[n]
                        {
                            label: (
                                util.capitalize(label.replace(/_/g, ' ')) +
                                " #{((value*100/result.total).toFixed(1))}% (#{util.formatNumber(value)})"
                            )
                            value:result.values[n]
                        }

                    chart.update(values)

        return $(chart.elem)

    deactivate: ->
        null
