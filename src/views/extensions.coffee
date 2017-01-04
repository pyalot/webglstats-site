db = sys.import 'db'
{Gauge, Series, StackedPercentage} = sys.import '/chart'
NavlistExpand = sys.import 'navlist'

info =
    blend_minmax:
        prefix: 'EXT'
        description: '''
            This extension allows for a blending mode that uses the mimimum or maximum of the incoming and present color.
            It is useful for medical imaging, volume rendering and general purpose computation on the gpu.
        '''
        spec: '/extensions/EXT_blend_minmax/'
    color_buffer_float:
        prefix: 'WEBGL'
        description: '''
            This extension allows to render into a floating point texture.
        '''
        spec: '/extensions/WEBGL_color_buffer_float/'
    color_buffer_half_float:
        prefix: 'EXT'
        description: '''
            This extension allows to render into a half precision floating point texture.
        '''
        spec: '/extensions/EXT_color_buffer_half_float/'
    compressed_texture_astc:
        prefix: 'WEBGL'
        description: '''
            Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/Adaptive_Scalable_Texture_Compression">ASTC</a>
        '''
        spec: 'https://www.khronos.org/registry/webgl/extensions/WEBGL_compressed_texture_astc/'
    compressed_texture_atc:
        prefix: 'WEBGL'
        description: '''
            Offers compressed texture format support for ATC.
        '''
        spec: '/extensions/WEBGL_compressed_texture_atc/'
    compressed_texture_etc1:
        prefix: 'WEBGL'
        description: '''
            Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/Ericsson_Texture_Compression">ETC1</a>.
        '''
        spec: '/extensions/WEBGL_compressed_texture_etc1/'
    compressed_texture_pvrtc:
        prefix: 'WEBGL'
        description: '''
            Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/PVRTC">PVRTC</a>.
        '''
        spec: '/extensions/WEBGL_compressed_texture_pvrtc/'
    compressed_texture_s3tc:
        prefix: 'WEBGL'
        description: '''
            Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/S3_Texture_Compression">S3TC</a>.
        '''
        spec: '/extensions/WEBGL_compressed_texture_s3tc/'
    debug_renderer_info:
        prefix: 'WEBGL'
        description: '''
            Allows to query the GPU vendor and model.
        '''
        spec: '/extensions/WEBGL_debug_renderer_info/'
    depth_texture:
        prefix: 'WEBGL'
        description: '''
            This extension offers the ability to create depth textures to attach to a framebuffer.
        '''
        spec: '/extensions/WEBGL_depth_texture/'
    disjoint_timer_query:
        prefix: 'EXT'
        description: '''
            This extension offers support for querying the execution time of commands on the GPU.
        '''
        spec: '/extensions/EXT_disjoint_timer_query/'
    draw_buffers:
        prefix: 'WEBGL'
        description: '''
            This extension allows a framebuffer to hold several textures to render to and a fragment shader to output to them.
        '''
        spec: '/extensions/WEBGL_draw_buffers/'
        params: [
            'MAX_COLOR_ATTACHMENTS_WEBGL'
            'MAX_DRAW_BUFFERS_WEBGL'
        ]
    element_index_uint:
        prefix: 'OES'
        description: '''
            This extension allows for vertex buffer array indicies to be 32-bit unsigned integers.
        '''
        spec: '/extensions/OES_element_index_uint/'
    frag_depth:
        prefix: 'EXT'
        description: '''
            This extension allows a fragment shader to write the depth of a fragment.
        '''
        spec: '/extensions/EXT_frag_depth/'
    instanced_arrays:
        prefix: 'ANGLE'
        description: '''
            This extension offers the ability to repeat some vertex attributes, which can be used to render many instances of an object.
        '''
        spec: '/extensions/ANGLE_instanced_arrays/'
    lose_context:
        prefix: 'WEBGL'
        description: '''
            This extension simulates a context loss and regain for testing purposes.
        '''
        spec: '/extensions/WEBGL_lose_context/'
    sRGB:
        prefix: 'EXT'
        description: '''
            This extension offers a texture format whose internal storage is sRGB.
        '''
        spec: '/extensions/EXT_sRGB/'
    shader_texture_lod:
        prefix: 'EXT'
        description: '''
            This extension allows a texture lookup in a fragment shader to specify a LOD level explicitely.
        '''
        spec: '/extensions/EXT_shader_texture_lod/'
    standard_derivatives:
        prefix: 'OES'
        description: '''
            This extension allows a fragment shader to obtain the derivatives of a value in regards to neighboring fragments.
        '''
        spec: '/extensions/OES_standard_derivatives/'
    texture_filter_anisotropic:
        prefix: 'EXT'
        description: '''
            This extension allows textures to be filtered anisotropically.
        '''
        spec: '/extensions/EXT_texture_filter_anisotropic/'
        params: [
            'MAX_TEXTURE_MAX_ANISOTROPY_EXT'
        ]
    texture_float:
        prefix: 'OES'
        description: '''
            This extension offers basic support for 32-bit floating point textures.
        '''
        spec: '/extensions/OES_texture_float/'
    texture_float_linear:
        prefix: 'OES'
        description: '''
            This extension offers the ability to linearly filter 32-bit floating point textures.
        '''
        spec: '/extensions/OES_texture_float_linear/'
    texture_half_float:
        prefix: 'OES'
        description: '''
            This extension offers basic support for 16-bit floating point textures.
        '''
        spec: '/extensions/OES_texture_half_float/'
    texture_half_float_linear:
        prefix: 'OES'
        description: '''
            This extension offers the ability to linearly filter 16-bit floating point textures.
        '''
        spec: '/extensions/OES_texture_half_float_linear/'
    vertex_array_object:
        prefix: 'OES'
        description: '''
            This extension provides a way to group vertex attribute pointer configurations into an object for later use.
        '''
        spec: '/extensions/OES_vertex_array_object/'

names = [
    'blend_minmax'
    'color_buffer_float'
    'color_buffer_half_float'
    'compressed_texture_astc'
    'compressed_texture_atc'
    #'compressed_texture_es3' #was recently renamed
    'compressed_texture_etc1'
    'compressed_texture_pvrtc'
    'compressed_texture_s3tc'
    'debug_renderer_info'
    'depth_texture'
    'disjoint_timer_query'
    'draw_buffers'
    'element_index_uint'
    'frag_depth'
    'instanced_arrays'
    'lose_context'
    'sRGB'
    'shader_texture_lod'
    'standard_derivatives'
    'texture_filter_anisotropic'
    'texture_float'
    'texture_float_linear'
    'texture_half_float'
    'texture_half_float_linear'
    'vertex_array_object'
]

exports.index = class Extensions
    constructor: (@filter) ->
        @nav = new NavlistExpand('#extension', 'extension', names)

    show: (name, pageload) ->
        @nav.activate(name, pageload)

        row = $('<div></div>')
            .addClass('row')
            .addClass('responsive')
            .appendTo('main')
        
        col = $('<div></div>')
            .appendTo(row)

        widget = $('<div class="box"></div>')
            .appendTo(col)

        $('<h1></h1>')
            .text(info[name].prefix + '_' + name)
            .appendTo(widget)

        $('<p></p>')
            .append(info[name].description)
            .appendTo(widget)

        $('<a>Specification</a>')
            .attr('href', 'https://www.khronos.org/registry/webgl' + info[name].spec)
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

        if info[name].params?
            for param in info[name].params
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

        for name in names
            container = $('<div></div>')
                .appendTo(flow)

            @gauge(name)
                .appendTo(container)

            $('<a class="label"></a>')
                .attr('href', "/webgl/extension/#{name}")
                .text(name)
                .appendTo(container)

    gauge: (name, size='small', label=null, device=null) ->
        chart = new Gauge(label:label, size:size)
        
        fieldName = "webgl.extensions.#{info[name].prefix}_#{name}"

        initial = true
        update = =>
            chart.elem.addClass('spinner')
            if document.body.contains(chart.elem[0]) or initial
                initial = false
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
                            result = result.values[1]/result.total
                        else
                            result = 0
                        chart.update(result*100)
                        chart.elem.removeClass('spinner')
            else
                @filter.offChange(update)
        @filter.onChange(update)
        update()
        
        return chart.elem

    series: (name) ->
        fieldName = "webgl.extensions.#{info[name].prefix}_#{name}"
        
        chart = new Series()

        initial = true
        update = =>
            if document.body.contains(chart.elem[0]) or initial
                initial = false
                query =
                    filterBy:
                        webgl:true
                    bucketBy:fieldName
                    series: 'daily'

                if @filter.platforms?
                    query.filterBy.platform = @filter.platforms

                db.execute
                    query: query
                    success: (result) ->
                        chart.update(result.values)
            else
                @filter.offChange(update)

        @filter.onChange(update)
        update()

        return chart.elem

    stackedPercentage: (name, param) ->
        extname = "webgl.extensions.#{info[name].prefix}_#{name}"
        fieldname = "#{extname}.#{param}"
        chart = new StackedPercentage()

        initial = true
        update = =>
            if document.body.contains(chart.elem[0]) or initial
                initial = false
                query =
                    filterBy:
                        webgl:true
                        "#{extname}":true
                    bucketBy:fieldname
                    series: 'daily'

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
            else
                @filter.offChange(update)
        update()
        @filter.onChange(update)

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
