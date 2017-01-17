db = sys.import 'db'
util = sys.import '/util'
NavlistExpand = sys.import 'navlist'
{StackedPercentage, Bar} = sys.import '/chart'

info =
    ALIASED_LINE_WIDTH_RANGE:
        description: '''
            The maximum thickness of line that can be rendered.
        '''
        versions: [1,2]
    ALIASED_POINT_SIZE_RANGE:
        description: '''
            The maximum size of point that can be rendered.
        '''
        versions: [1,2]
    DEPTH_BITS:
        description: '''
            The number of bits for the front depthbuffer. Bits may differ in case of a framebuffer.
        '''
        versions: [1,2]
    MAX_COMBINED_TEXTURE_IMAGE_UNITS:
        description: '''
            The maximum number of texture units that can be used.
            If a unit is used by both vertex and fragment shader, this counts as two units against this limit.
        '''
        versions: [1,2]
    MAX_CUBE_MAP_TEXTURE_SIZE:
        description: '''
            The maximum size of one side of a cubemap.
        '''
        versions: [1,2]
    MAX_FRAGMENT_UNIFORM_VECTORS:
        description: '''
            The maximum number of 4-element vectors that can be passed as uniform to the vertex shader. All uniforms are 4-element aligned, a single uniform counts at least as one 4-element vector.
        '''
        versions: [1,2]
    MAX_RENDERBUFFER_SIZE:
        description: '''
            The largest renderbuffer that can be used. This limit indicates the maximum usable canvas size as well as the maximum usable framebuffer size.
        '''
        versions: [1,2]
    MAX_TEXTURE_IMAGE_UNITS:
        description: '''
            The maxium number of texture units that can be used in a fragment shader.
        '''
        versions: [1,2]
    MAX_TEXTURE_SIZE:
        description: '''
            The largest texture size (either width or height) that can be created. Note that VRAM may not allow a texture of any given size, it just expresses hardware/driver support for a given size.
        '''
        versions: [1,2]
    MAX_VARYING_VECTORS:
        description: '''
            The maximum number of 4-element vectors that can be used as varyings. Each varying counts as at least one 4-element vector.
        '''
        versions: [1,2]
    MAX_VERTEX_ATTRIBS:
        description: '''
            The maximum number of 4-element vectors that can be used as attributes to a vertex shader. Each attribute counts as at least one 4-element vector.
        '''
        versions: [1,2]
    MAX_VERTEX_TEXTURE_IMAGE_UNITS:
        description: '''
            The maximum number of texture units that can be used by a vertex shader. The value may be 0 which indicates no vertex shader texturing support.
        '''
        versions: [1,2]
    MAX_VERTEX_UNIFORM_VECTORS:
        description: '''
            The maximum number of 4-element vectors that can be passed as uniform to a vertex shader.  All uniforms are 4-element aligned, a single uniform counts at least as one 4-element vector. 
        '''
        versions: [1,2]
    MAX_VIEWPORT_DIMS:
        description: '''
            The maximum viewport dimension (either width or height), that the viewport can be set to.
        '''
        versions: [1,2]
    SAMPLES:
        description: '''
            Indicates the coverage mask of the front framebuffer. This value affects anti-aliasing and depth to coverage. For instance a value of 4 would indicate a 4x4 mask.
        '''
        versions: [1,2]
    SAMPLE_BUFFERS:
        description: '''
            Indicates if a sample buffer is associated with the front framebuffer, this indicates support for anti-aliasing and alpha to coverage support.
        '''
        versions: [1,2]
    STENCIL_BITS:
        description: '''
            The number of bits of the front framebuffer usable for stenciling.
        '''
        versions: [1,2]
    SUBPIXEL_BITS:
        description: '''
            The bit-precision used to position primitives in window coordinates.
        '''
        versions: [1,2]
    MAX_3D_TEXTURE_SIZE:
        description: '''
            The largest 3D texture size (width, height or depth) that can be created. Note that VRAM may not allow a texture of any given size, it just expresses hardware/driver support for a given size.
        '''
        versions: [2]
    MAX_ARRAY_TEXTURE_LAYERS:
        description: '''
            The maximum amount of texture layers an array texture can hold.
        '''
        versions: [2]
    MAX_COLOR_ATTACHMENTS:
        description: '''
            The maximum number of color attachments that a framebuffer object support. 
        '''
        versions: [2]
    MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS:
        description: '''
            The maximum amount 4-byte components allowable in fragment shader uniform blocks.
        '''
        versions: [2]
    MAX_COMBINED_UNIFORM_BLOCKS:
        description: '''
            The maximum of uniform blocks allowed per program.
        '''
        versions: [2]
    MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS:
        description: '''
            The maximum of of 4-byte components allowable in vertex shader uniform blocks.
        '''
        versions: [2]
    MAX_DRAW_BUFFERS:
        description: '''
            The maximum amount of simultaneous outputs that may be written in a fragment shader.
        '''
        versions: [2]
    MAX_ELEMENT_INDEX:
        description: '''
            The maximum index value usable for an indexed vertex array.
        '''
        versions: [2]
    MAX_ELEMENTS_INDICES:
        description: '''
           The maximum amount of indices that can be used with an indexed vertex array. 
        '''
        versions: [2]
    MAX_ELEMENTS_VERTICES:
        description: '''
            The maximum amount of vertex array vertices that's recommended.
        '''
        versions: [2]
    MAX_FRAGMENT_INPUT_COMPONENTS:
        description: '''
            The maximum amount of inputs for a fragment shader.
        '''
        versions: [2]
    MAX_FRAGMENT_UNIFORM_BLOCKS:
        description: '''
            The maximum amount of uniform blocks alowable for a fragment shader.
        '''
        versions: [2]
    MAX_FRAGMENT_UNIFORM_COMPONENTS:
        description: '''
            The maximum amount of of floats, integers or bools that can be in uniform storage for fragment shaders.
        '''
        versions: [2]
    MAX_PROGRAM_TEXEL_OFFSET:
        description: '''
            The maximum alowable texel offset in texture lookups.
        '''
        versions: [2]
    MAX_SAMPLES:
        description: '''
            Idicates the maximum supported number of samples for multisampling.
        '''
        versions: [2]
    MAX_SERVER_WAIT_TIMEOUT:
        description: '''
            The maximum glWaitSync timeout interval.
        '''
        versions: [2]
    MAX_TEXTURE_LOD_BIAS:
        description: '''
            The maximum supported texture lookup LOD bias.
        '''
        versions: [2]
    MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS:
        description: '''
            The maximum number of components writable in interleaved feedback buffer mode.
        '''
        versions: [2]
    MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS:
        description: '''
            The maximum number of attributes or outputs which is supported for capture in separate transform feedback mode.
        '''
        versions: [2]
    MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS:
        description: '''
            The maximum number of components per attribute which is supported in separate transform feedback mode.
        '''
        versions: [2]
    MAX_UNIFORM_BLOCK_SIZE:
        description: '''
            The maximum size of a uniform block in 4-byte units.
        '''
        versions: [2]
    MAX_UNIFORM_BUFFER_BINDINGS:
        description: '''
            The maximum number of simultaneously usable uniform blocks.
        '''
        versions: [2]
    MAX_VARYING_COMPONENTS:
        description: '''
            The maximum number of 4-component vectors usable for varyings.
        '''
        versions: [2]
    MAX_VERTEX_OUTPUT_COMPONENTS:
        description: '''
            The maximum number of 4-component vectors that a vertex shader can write. 
        '''
        versions: [2]
    MAX_VERTEX_UNIFORM_BLOCKS:
        description: '''
            The maximum number of uniform blocks per vertex shader.
        '''
        versions: [2]
    MAX_VERTEX_UNIFORM_COMPONENTS:
        description: '''
            The maximum number of floats, integers or booleans that can be in storage for a vertex shader.
        '''
        versions: [2]
    MIN_PROGRAM_TEXEL_OFFSET:
        description: '''
            The minimum texel offset for texture lookups.
        '''
        versions: [2]

fieldNames =
    MAX_VIEWPORT_DIMS: 'MAX_VIEWPORT_DIMS.width'
    ALIASED_LINE_WIDTH_RANGE: 'ALIASED_LINE_WIDTH_RANGE.max'
    ALIASED_POINT_SIZE_RANGE: 'ALIASED_POINT_SIZE_RANGE.max'

exports.index = class Parameters
    constructor: (@filter, search) ->
        @webgl1 = []
        @webgl2 = []

        for name, entry of info
            if 1 in entry.versions
                @webgl1.push
                    name: name
                    label: name
            if 2 in entry.versions
                @webgl2.push
                    name: name
                    label: name

        @webgl1.sort (a,b) ->
            if a.label < b.label then return -1
            else if a.label > b.label then return 1
            else return 0

        @webgl2.sort (a,b) ->
            if a.label < b.label then return -1
            else if a.label > b.label then return 1
            else return 0

        @nav1 = new NavlistExpand('#parameter-webgl1', 'webgl/parameter', @webgl1)
        @nav2 = new NavlistExpand('#parameter-webgl2', 'webgl2/parameter', @webgl2)

        @buildSearch(search)

    buildSearch: (search) ->
        for entry in @webgl1
            @searchAdd search, 'webgl', 'webgl1', entry.name
        for entry in @webgl2
            @searchAdd search, 'webgl2', 'webgl2', entry.name
        
    searchAdd: (search, path, version, name) ->
        search.add
            id: "/#{path}/parameter/#{name}"
            titles: [
                name
                name.replace(/_/g, ' ')
            ]
            body: info[name].description
            type: "#{util.versionLabel(version)} Parameter"
    
    breadcrumbs: (webglVersion, name) ->
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

        $('<li>Parameter</li>')
            .appendTo(breadcrumbs)
        
        $('<a></a>')
            .attr('href', "/#{util.versionPath(webglVersion)}/parameter/#{name}")
            .text(name)
            .appendTo(breadcrumbs)
            .wrap('<li></li>')

    show: (webglVersion, name, pageload) ->
        switch webglVersion
            when 'webgl1' then @nav1.activate(name, pageload)
            when 'webgl2' then @nav2.activate(name, pageload)

        @breadcrumbs webglVersion, name

        row = $('<div class="row responsive"></div>')
            .appendTo('main')
        
        col = $('<div></div>')
            .appendTo(row)

        widget = $('<div class="box"></div>')
            .appendTo(col)

        $('<h1></h1>')
            .text(name)
            .appendTo(widget)

        $('<p></p>')
            .append(info[name].description)
            .appendTo(widget)
        
        for version in info[name].versions
            $('<span class="tag"></span>')
                .text("WebGL #{version}")
                .appendTo(widget)

        col = $('<div></div>')
            .appendTo(row)

        widget = $('<div class="box"></div>')
            .appendTo(col)

        $('<h1>Support (30 days)</h1>')
            .appendTo(widget)

        @barchart(webglVersion, name).appendTo(widget)
        
        full = $('<div class="full box"></div>')
            .appendTo('main')

        @series(webglVersion, name).appendTo(full)

    overview: (webglVersion) ->
        flow = $('<div class="flow box"></div>')
            .appendTo('main')

        $('<h1>Parameters</h1>')
            .appendTo(flow)

        if webglVersion == 'webgl1'
            collection = @webgl1
        else if webglVersion == 'webgl2'
            collection = @webgl2

        for entry in collection
            container = $('<div></div>')
                .appendTo(flow)

            @chart(webglVersion, entry.name).appendTo(container)

            $('<a class="label"></a>')
                .attr('href', "/webgl/parameter/#{entry.name}")
                .text(entry.label)
                .appendTo(container)

    series: (webglVersion, name) ->
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
                db: webglVersion
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

    barchart: (webglVersion, name) ->
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
                db: webglVersion
                query: query
                success: (result) ->
                    values = result.values
                    keys = result.keys
                    if not keys[0]?
                        values.shift()
                        keys.shift()
                    chart.update(keys, values)

        return chart.elem

    chart: (webglVersion, name) ->
        if fieldNames[name]?
            fieldName = "webgl.params.#{fieldNames[name]}"
        else
            fieldName = "webgl.params.#{name}"

        container = $('<div></div>')
        
        db.execute
            query:
                db: webglVersion
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
