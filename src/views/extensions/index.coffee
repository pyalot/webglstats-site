db = sys.import '../db'
util = sys.import '/util'
{Gauge, Series, StackedPercentage} = sys.import '/chart'
NavlistExpand = sys.import '../navlist'
info = sys.import 'info'

extensionLabel = (name) ->
    parts = name.split('_')
    parts.shift()
    return parts.join('_')

exports.index = class Extensions
    constructor: (@filter, search) ->
        @webgl1 = []
        
        for name, meta of info
            if (1 in meta.versions) and (meta.status in ['ratified', 'community'])
                @webgl1.push
                    name: name
                    label: extensionLabel(name)

        @webgl1.sort (a,b) ->
            if a.label < b.label then -1
            else if b.label > a.label then 1
            else 0

        @nav = new NavlistExpand('#extension', 'extension', @webgl1)

        @buildSearch(search)
    
    buildSearch: (search) ->
        for entry in @webgl1
            do (entry) =>
                meta = info[entry.name]
                search.add
                    id: "/webgl/extension/#{entry.name}"
                    titles: [
                        entry.label,
                        entry.name,
                        entry.name.replace(/_/g, ' ')
                    ]
                    body: meta.description
                    extra: if meta.params? then meta.params.join(' ') else null
                    type: 'Extension'
                    gauge: =>
                        @gauge(entry.name)

    show: (name, pageload) ->
        @nav.activate(name, pageload)

        meta = info[name]

        row = $('<div></div>')
            .addClass('row')
            .addClass('responsive')
            .appendTo('main')
        
        col = $('<div></div>')
            .appendTo(row)

        widget = $('<div class="box"></div>')
            .appendTo(col)

        $('<h1></h1>')
            .text(name)
            .appendTo(widget)

        $('<p></p>')
            .append(meta.description)
            .appendTo(widget)

        for version in meta.versions
            $('<span class="tag"></span>')
                .text("WebGL #{version}")
                .appendTo(widget)

        $('<span class="tag"></span>')
            .text(util.capitalize(meta.status))
            .appendTo(widget)

        $('<a>Specification</a>')
            .attr('href', 'https://www.khronos.org/registry/webgl/extensions/' + name)
            .appendTo(widget)

        col = $('<div></div>')
            .appendTo(row)

        widget = $('<div class="box"></div>')
            .appendTo(col)

        @day30view(name, widget)

        widget = $('<div class="full box"></div>')
            .appendTo('main')

        @series(name)
            .appendTo(widget)

        if meta.params?
            for param in meta.params
                widget = $('<div class="full box"></div>')
                    .appendTo('main')

                $('<h1></h1>')
                    .text(param)
                    .appendTo(widget)
                @stackedPercentage(name, param)
                    .appendTo(widget)

    overview: (pageload) ->
        flow = $('<div class="flow box"></div>')
            .appendTo('main')

        $('<h1>Extensions</h1>')
            .appendTo(flow)

        for entry in @webgl1
            container = $('<div></div>')
                .appendTo(flow)

            @gauge(entry.name)
                .appendTo(container)

            $('<a class="label"></a>')
                .attr('href', "/webgl/extension/#{entry.name}")
                .text(entry.label)
                .appendTo(container)

    gauge: (name, size='small', label=null, device=null) ->
        chart = new Gauge(label:label, size:size)
        
        fieldName = "webgl.extensions.#{name}"

        @filter.onChange chart.elem, =>
            chart.elem.addClass('spinner')
            query =
                filterBy:
                    webgl:true
                bucketBy:fieldName
                start: -30

            if device?
                query.filterBy['useragent.device'] = device

            if @filter.platforms?
                query.filterBy.platform = @filter.platforms

            db.execute
                query: query
                success: (result) ->
                    if result.total > 0
                        percentage = result.values[1]/result.total
                    else
                        percentage = 0
                    chart.setLabel(label + " (#{util.formatNumber(result.total)})")
                    chart.update(percentage*100)
                    chart.elem.removeClass('spinner')
        
        return chart.elem

    series: (name) ->
        fieldName = "webgl.extensions.#{name}"
        
        chart = new Series()

        @filter.onChange chart.elem, =>
            query =
                filterBy:
                    webgl:true
                bucketBy:fieldName
                series: @filter.series

            if @filter.platforms?
                query.filterBy.platform = @filter.platforms

            db.execute
                query: query
                success: (result) ->
                    chart.update(result.values)

        return chart.elem

    stackedPercentage: (name, param) ->
        extname = "webgl.extensions.#{name}"
        fieldname = "#{extname}.#{param}"
        chart = new StackedPercentage()

        @filter.onChange chart.elem, =>
            query =
                filterBy:
                    webgl:true
                    "#{extname}":true
                bucketBy:fieldname
                series: @filter.series

            if @filter.platforms?
                query.filterBy.platform = @filter.platforms

            db.execute
                query: query
                success: (result) ->
                    keys = result.keys
                    xLabels = []
                    data = []
                    
                    if keys[0] == null
                        valueStart = 1
                        keys.shift()
                    else
                        valueStart = 0

                    for item in result.values
                        xLabels.push(item.name)
                        values = []

                        for value in item.values[valueStart...]
                            if item.total == 0
                                values.push(0)
                            else
                                values.push(value/item.total)

                        data.push(values)

                    chart.update
                        areaLabels: keys
                        xLabels: xLabels
                        data: data

        return $(chart.elem)

    day30view: (name, parent) ->
        $('<h1>Support (30 days)</h1>')
            .appendTo(parent)

        row = $('<div class="row center"></div>')
            .appendTo(parent)

        col = $('<div></div>')
            .appendTo(row)

        @gauge(name, 'large', 'All')
            .appendTo(col)

        smallCharts = $('<div></div>')
            .appendTo(row)

        row = $('<div class="row center"></div>')
            .appendTo(smallCharts)
        
        col = $('<div></div>').appendTo(row)
        @gauge(name, 'small', 'Desktop', 'desktop').appendTo(col)
        
        col = $('<div></div>').appendTo(row)
        @gauge(name, 'small', 'Smartphone', 'smartphone').appendTo(col)
        
        row = $('<div class="row center"></div>')
            .appendTo(smallCharts)
        
        col = $('<div></div>').appendTo(row)
        @gauge(name, 'small', 'Tablet', 'tablet').appendTo(col)
        
        col = $('<div></div>').appendTo(row)
        @gauge(name, 'small', 'Console', 'game_console').appendTo(col)

