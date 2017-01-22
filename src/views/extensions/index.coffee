db = sys.import '../db'
util = sys.import '/util'
{Gauge, Series, StackedPercentage} = sys.import '/chart'
NavlistExpand = sys.import '../navlist'
info = sys.import 'info'
notFound = sys.import '../not-found'
breadcrumbs = sys.import '../breadcrumbs'

extensionLabel = (name) ->
    parts = name.split('_')
    parts.shift()
    return parts.join('_')

exports.index = class Extensions
    constructor: (@filter, search) ->
        @webgl1 = []
        @webgl2 = []
        
        for name, meta of info
            if meta.status in ['ratified', 'community']
                if 1 in meta.versions
                    @webgl1.push
                        name: name
                        label: extensionLabel(name)
                if 2 in meta.versions
                    @webgl2.push
                        name: name
                        label: extensionLabel(name)
        
        @webgl1.sort (a,b) ->
            if a.label < b.label then return -1
            else if a.label > b.label then return 1
            else return 0

        @webgl2.sort (a,b) ->
            if a.label < b.label then return -1
            else if a.label > b.label then return 1
            else return 0

        @nav1 = new NavlistExpand('#extension-webgl1', 'webgl/extension', @webgl1)
        @nav2 = new NavlistExpand('#extension-webgl2', 'webgl2/extension', @webgl2)

        @buildSearch(search)
    
    buildSearch: (search) ->
        for entry in @webgl1
            @searchAdd search, 'webgl', 'webgl1', entry
        for entry in @webgl2
            @searchAdd search, 'webgl2', 'webgl2', entry

    searchAdd: (search, path, version, entry) ->
        meta = info[entry.name]
        search.add
            id: "/#{path}/extension/#{entry.name}"
            titles: [
                entry.label,
                entry.name,
                entry.name.replace(/_/g, ' ')
            ]
            body: meta.description
            extra: if meta.params? then meta.params.join(' ') else null
            type: "#{util.versionLabel(version)} Extension"
            gauge: =>
                @gauge(version, entry.name)

    breadcrumbs: (webglVersion, name) ->
        breadcrumbs [
            [util.versionLabel(webglVersion), "/#{util.versionPath(webglVersion)}"]
            'Extension'
            [name, "/#{util.versionPath(webglVersion)}/extension/#{name}"]
        ]

    show: (webglVersion, name, pageload) ->
        meta = info[name]

        if not meta?
            return notFound()

        if meta.status not in ['ratified', 'community']
            return notFound()

        if ({webgl1:1, webgl2:2})[webglVersion] not in meta.versions
            return notFound()

        switch webglVersion
            when 'webgl1' then @nav1.activate(name, pageload)
            when 'webgl2' then @nav2.activate(name, pageload)

        @breadcrumbs(webglVersion, name)

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

        @day30view(webglVersion, name, widget)

        widget = $('<div class="full box"></div>')
            .appendTo('main')

        @series(webglVersion, name)
            .appendTo(widget)

        if meta.params?
            for param in meta.params
                widget = $('<div class="full box"></div>')
                    .appendTo('main')

                $('<h1></h1>')
                    .text(param.name ? param)
                    .appendTo(widget)
                @stackedPercentage(webglVersion, name, param)
                    .appendTo(widget)

    overview: (webglVersion, pageload) ->
        flow = $('<div class="flow box"></div>')
            .appendTo('main')

        $('<h1></h1>')
            .text('Extensions')
            .appendTo(flow)

        if webglVersion == 'webgl1'
            collection = @webgl1
        else if webglVersion == 'webgl2'
            collection = @webgl2

        for entry in collection
            container = $('<div></div>')
                .appendTo(flow)

            @gauge(webglVersion, entry.name)
                .appendTo(container)

            $('<a class="label"></a>')
                .attr('href', "/#{util.versionPath(webglVersion)}/extension/#{entry.name}")
                .text(entry.label)
                .appendTo(container)

    gauge: (webglVersion, name, size='small', label=null, device=null) ->
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
                db: webglVersion
                query: query
                success: (result) ->
                    if result.total > 0
                        percentage = result.values[1]/result.total
                    else
                        percentage = 0
                    chart.setLabel(label + " (#{util.formatNumber(result.values[1])})")
                    chart.update(percentage*100)
                    chart.elem.removeClass('spinner')
        
        return chart.elem

    series: (webglVersion, name) ->
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
                db: webglVersion
                query: query
                success: (result) ->
                    chart.update(result.values)

        return chart.elem

    stackedPercentage: (webglVersion, name, param) ->
        if typeof(param) == 'string'
            param =
                name:param
                type:'abs'
                nullable:'false'

        extname = "webgl.extensions.#{name}"
        fieldname = "#{extname}.#{param.name}"
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
                db: webglVersion
                query: query
                success: (result) ->
                    keys = result.keys
                    xLabels = []
                    data = []
    
                    if param.nullable
                        if keys[0] == null
                            keys[0] = 'Unknown'
                        valueStart = 0
                    else
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
                        type: param.type
                        areaLabels: keys
                        xLabels: xLabels
                        data: data

        return $(chart.elem)

    day30view: (webglVersion, name, parent) ->
        $('<h1>Support (30d)</h1>')
            .appendTo(parent)

        row = $('<div class="row center"></div>')
            .appendTo(parent)

        col = $('<div></div>')
            .appendTo(row)

        @gauge(webglVersion, name, 'large', 'All')
            .appendTo(col)

        smallCharts = $('<div></div>')
            .appendTo(row)

        row = $('<div class="row center"></div>')
            .appendTo(smallCharts)
        
        col = $('<div></div>').appendTo(row)
        @gauge(webglVersion, name, 'small', 'Desktop', 'desktop').appendTo(col)
        
        col = $('<div></div>').appendTo(row)
        @gauge(webglVersion, name, 'small', 'Smartphone', 'smartphone').appendTo(col)
        
        row = $('<div class="row center"></div>')
            .appendTo(smallCharts)
        
        col = $('<div></div>').appendTo(row)
        @gauge(webglVersion, name, 'small', 'Tablet', 'tablet').appendTo(col)
        
        col = $('<div></div>').appendTo(row)
        @gauge(webglVersion, name, 'small', 'Console', 'game_console').appendTo(col)

