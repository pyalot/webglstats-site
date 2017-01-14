db = sys.import 'db'
NavlistExpand = sys.import 'navlist'
{StackedPercentage, Bar} = sys.import '/chart'

info =
    ALIASED_LINE_WIDTH_RANGE:
        description: '''
            The maximum thickness of line that can be rendered.
        '''
    ALIASED_POINT_SIZE_RANGE:
        description: '''
            The maximum size of point that can be rendered.
        '''
    DEPTH_BITS:
        description: '''
            The number of bits for the front depthbuffer. Bits may differ in case of a framebuffer.
        '''
    MAX_COMBINED_TEXTURE_IMAGE_UNITS:
        description: '''
            The maximum number of texture units that can be used.
            If a unit is used by both vertex and fragment shader, this counts as two units against this limit.
        '''
    MAX_CUBE_MAP_TEXTURE_SIZE:
        description: '''
            The maximum size of one side of a cubemap.
        '''
    MAX_FRAGMENT_UNIFORM_VECTORS:
        description: '''
            The maximum number of 4-element vectors that can be passed as uniform to the vertex shader. All uniforms are 4-element aligned, a single uniform counts at least as one 4-element vector.
        '''
    MAX_RENDERBUFFER_SIZE:
        description: '''
            The largest renderbuffer that can be used. This limit indicates the maximum usable canvas size as well as the maximum usable framebuffer size.
        '''
    MAX_TEXTURE_IMAGE_UNITS:
        description: '''
            The maxium number of texture units that can be used in a fragment shader.
        '''
    MAX_TEXTURE_SIZE:
        description: '''
            The largest texture size (either width or height) that can be created. Note that VRAM may not allow a texture of any given size, it just expresses hardware/driver support for a given size.
        '''
    MAX_VARYING_VECTORS:
        description: '''
            The maximum number of 4-element vectors that can be used as varyings. Each varying counts as at least one 4-element vector.
        '''
    MAX_VERTEX_ATTRIBS:
        description: '''
            The maximum number of 4-element vectors that can be used as attributes to a vertex shader. Each attribute counts as at least one 4-element vector.
        '''
    MAX_VERTEX_TEXTURE_IMAGE_UNITS:
        description: '''
            The maximum number of texture units that can be used by a vertex shader. The value may be 0 which indicates no vertex shader texturing support.
        '''
    MAX_VERTEX_UNIFORM_VECTORS:
        description: '''
            The maximum number of 4-element vectors that can be passed as uniform to a vertex shader.  All uniforms are 4-element aligned, a single uniform counts at least as one 4-element vector. 
        '''
    MAX_VIEWPORT_DIMS:
        description: '''
            The maximum viewport dimension (either width or height), that the viewport can be set to.
        '''
    SAMPLES:
        description: '''
            Indicates the coverage mask of the front framebuffer. This value affects anti-aliasing and depth to coverage. For instance a value of 4 would indicate a 4x4 mask.
        '''
    SAMPLE_BUFFERS:
        description: '''
            Indicates if a sample buffer is associated with the front framebuffer, this indicates support for anti-aliasing and alpha to coverage support.
        '''
    STENCIL_BITS:
        description: '''
            The number of bits of the front framebuffer usable for stenciling.
        '''
    SUBPIXEL_BITS:
        description: '''
            The bit-precision used to position primitives in window coordinates.
        '''

names = [
    'ALIASED_LINE_WIDTH_RANGE'
    'ALIASED_POINT_SIZE_RANGE'
    'DEPTH_BITS'
    'MAX_COMBINED_TEXTURE_IMAGE_UNITS'
    'MAX_CUBE_MAP_TEXTURE_SIZE'
    'MAX_FRAGMENT_UNIFORM_VECTORS'
    'MAX_RENDERBUFFER_SIZE'
    'MAX_TEXTURE_IMAGE_UNITS'
    'MAX_TEXTURE_SIZE'
    'MAX_VARYING_VECTORS'
    'MAX_VERTEX_ATTRIBS'
    'MAX_VERTEX_TEXTURE_IMAGE_UNITS'
    'MAX_VERTEX_UNIFORM_VECTORS'
    'MAX_VIEWPORT_DIMS'
    'SAMPLES'
    'SAMPLE_BUFFERS'
    'STENCIL_BITS'
    'SUBPIXEL_BITS'
]

fieldNames =
    MAX_VIEWPORT_DIMS: 'MAX_VIEWPORT_DIMS.width'
    ALIASED_LINE_WIDTH_RANGE: 'ALIASED_LINE_WIDTH_RANGE.max'
    ALIASED_POINT_SIZE_RANGE: 'ALIASED_POINT_SIZE_RANGE.max'

exports.index = class Parameters
    constructor: (@filter, search) ->
        @nav = new NavlistExpand('#parameter', 'parameter', names)
        @buildSearch(search)

    buildSearch: (search) ->
        for name in names
            search.add
                id: "/webgl/parameter/#{name}"
                titles: [
                    name
                    name.replace(/_/g, ' ')
                ]
                body: info[name].description
                type: 'Parameter'

    show: (name, pageload) ->
        @nav.activate(name, pageload)

        row = $('<div class="row responsive"></div>')
            .appendTo('main')
        
        col = $('<div></div>')
            .appendTo(row)

        widget = $('<div class="box"></div>')
            .appendTo(col)

        $('<h1></h1>')
            .text(name)
            .appendTo(widget)

        $('<div></div>')
            .append(info[name].description)
            .appendTo(widget)

        col = $('<div></div>')
            .appendTo(row)

        widget = $('<div class="box"></div>')
            .appendTo(col)

        $('<h1>Support (30 days)</h1>')
            .appendTo(widget)

        @barchart(name).appendTo(widget)
        
        full = $('<div class="full box"></div>')
            .appendTo('main')

        @series(name).appendTo(full)

    overview: ->
        flow = $('<div class="flow box"></div>')
            .appendTo('main')

        $('<h1>Parameters</h1>')
            .appendTo(flow)

        for name in names
            container = $('<div></div>')
                .appendTo(flow)

            @chart(name).appendTo(container)

            $('<a class="label"></a>')
                .attr('href', "/webgl/parameter/#{name}")
                .text(name)
                .appendTo(container)

    series: (name) ->
        if fieldNames[name]?
            fieldName = "webgl.params.#{fieldNames[name]}"
        else
            fieldName = "webgl.params.#{name}"

        chart = new StackedPercentage()

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

    barchart: (name) ->
        if fieldNames[name]?
            fieldName = "webgl.params.#{fieldNames[name]}"
        else
            fieldName = "webgl.params.#{name}"
                
        chart = new Bar()

        @filter.onChange chart.elem, =>
            query =
                filterBy:
                    webgl:true
                bucketBy:fieldName
                start: -30

            if @filter.platforms?
                query.filterBy.platform = @filter.platforms

            db.execute
                query: query
                success: (result) ->
                    values = result.values
                    keys = result.keys
                    if not keys[0]?
                        values.shift()
                        keys.shift()
                    chart.update(keys, values)

        return chart.elem

    chart: (name) ->
        if fieldNames[name]?
            fieldName = "webgl.params.#{fieldNames[name]}"
        else
            fieldName = "webgl.params.#{name}"

        container = $('<div></div>')
        
        db.execute
            query:
                filterBy:
                    webgl:true
                bucketBy:fieldName
                start: -30
            success: (result) ->
                values = result.values
                keys = result.keys
                if not keys[0]?
                    values.shift()
                    keys.shift()

                container.sparkline values,
                    type:'bar'
                    chartRangeMin:0
                    height:100
                    barWidth: 8
                    #width: 100
                    tooltipFormatter: (sparkline, options, fields) ->
                        offset = fields[0].offset
                        value = fields[0].value
                        label = result.keys[offset]
                        return "<span>#{label} - #{(value*100/result.total).toFixed(0)}%</span>"

        return container
