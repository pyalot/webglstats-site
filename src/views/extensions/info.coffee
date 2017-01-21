exports.index =
    EXT_blend_minmax:
        description: '''
            This extension allows for a blending mode that uses the minimum or maximum of the incoming and present color.
            It is useful for medical imaging, volume rendering and general purpose computation on the gpu.
        '''
        status: 'ratified'
        versions: [1]
    WEBGL_color_buffer_float:
        description: '''
            This extension allows to render into a floating point texture. 
            <br/><br/>
            For historical reasons this is not reliably indicative of renderable floating point textures, and actual support has to be tested individually.
        '''
        status: 'community'
        versions: [1]
    EXT_color_buffer_half_float:
        description: '''
            This extension allows to render into a half precision floating point texture.
        '''
        status: 'community'
        versions: [1]
    WEBGL_compressed_texture_astc:
        description: '''
            Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/Adaptive_Scalable_Texture_Compression">ASTC</a>
        '''
        status: 'community'
        versions: [1,2]
        params: [
            {name:'supportedProfiles',nullable:true,type:'rel'}
        ]
    WEBGL_compressed_texture_atc:
        description: '''
            Offers compressed texture format support for <a href="https://www.khronos.org/registry/gles/extensions/AMD/AMD_compressed_ATC_texture.txt">ATC</a>.
        '''
        status: 'community'
        versions: [1,2]
    WEBGL_compressed_texture_etc1:
        description: '''
            Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/Ericsson_Texture_Compression">ETC1</a>.
        '''
        status: 'community'
        versions: [1,2]
    WEBGL_compressed_texture_pvrtc:
        description: '''
            Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/PVRTC">PVRTC</a>.
        '''
        status: 'community'
        versions: [1,2]
    WEBGL_compressed_texture_s3tc:
        description: '''
            Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/S3_Texture_Compression">S3TC</a>.
        '''
        status: 'ratified'
        versions: [1,2]
    WEBGL_debug_renderer_info:
        description: '''
            Allows to query the GPU vendor and model.
        '''
        status: 'ratified'
        versions: [1,2]
    WEBGL_depth_texture:
        description: '''
            This extension offers the ability to create depth textures to attach to a framebuffer object.
        '''
        status: 'ratified'
        versions: [1]
    EXT_disjoint_timer_query:
        description: '''
            This extension offers support for querying the execution time of commands on the GPU.
        '''
        status: 'community'
        versions: [1,2]
    WEBGL_draw_buffers:
        description: '''
            This extension allows a framebuffer object to hold several
            textures to render to and a fragment shader to output to them selectively.
            <br/><br/> 
            It is also known as <a href="https://en.wikipedia.org/wiki/Multiple_Render_Targets">multi render target (MRT)</a>.
        '''
        params: [
            'MAX_COLOR_ATTACHMENTS_WEBGL'
            'MAX_DRAW_BUFFERS_WEBGL'
        ]
        status: 'ratified'
        versions: [1]
    OES_element_index_uint:
        description: '''
            This extension allows for vertex buffer array indicies to be 32-bit unsigned integers.
        '''
        status: 'ratified'
        versions: [1]
    EXT_frag_depth:
        description: '''
            This extension allows a fragment shader to write the depth of a fragment by assigning to the builtin gl_FragDepth.
        '''
        status: 'ratified'
        versions: [1]
    ANGLE_instanced_arrays:
        description: '''
            This extension offers the ability to repeat some vertex attributes, which can be used to render many instances of an object.
            <br/><br/>
            The technique is also known as <a href="https://en.wikipedia.org/wiki/Geometry_instancing">Geometry Instancing</a>.
        '''
        status: 'ratified'
        versions: [1]
    WEBGL_lose_context:
        description: '''
            This extension simulates a context loss and regain for testing purposes.
        '''
        status: 'ratified'
        versions: [1,2]
    EXT_sRGB:
        description: '''
            This extension offers a texture format with internal storage in sRGB.
            <br/><br/>
            Rendering should usually be performed in linear space
            (see <a href="http://http.developer.nvidia.com/GPUGems3/gpugems3_ch24.html">the importance of being linear</a>).
            Using this extension banding artifacts and incorrect blending outcomes can be avoided or mitgitated.
        '''
        status: 'community'
        versions: [1]
    EXT_shader_texture_lod:
        description: '''
            Allows a fragment shader to specify the LOD level using the texture[2D,2DProj,Cube]LodEXT functions. Alternatively also allows to specify S/T derivatives by using the texture[2D,2DProj,Cube]GradEXT functions.
        '''
        status: 'ratified'
        versions: [1]
    OES_standard_derivatives:
        description: '''
            This extension allows a fragment shader to obtain the derivatives of a value in regards to neighboring fragments.
        '''
        status: 'ratified'
        versions: [1]
    EXT_texture_filter_anisotropic:
        description: '''
            This extension allows <a href="https://en.wikipedia.org/wiki/Anisotropic_filtering">anisotropic texture filtering</a>.
        '''
        params: [
            'MAX_TEXTURE_MAX_ANISOTROPY_EXT'
        ]
        status: 'ratified'
        versions: [1,2]
    OES_texture_float:
        description: '''
            Offers basic support for 32-bit floating point textures.
        '''
        status: 'ratified'
        versions: [1]
    OES_texture_float_linear:
        description: '''
            Offers the ability to linearly filter 32-bit floating point textures.
        '''
        status: 'ratified'
        versions: [1,2]
    OES_texture_half_float:
        description: '''
            Offers basic support for 16-bit floating point textures.
        '''
        status: 'ratified'
        versions: [1]
    OES_texture_half_float_linear:
        description: '''
            Offers the ability to linearly filter 16-bit floating point textures.
        '''
        status: 'ratified'
        versions: [1]
    OES_vertex_array_object:
        description: '''
            This extension provides a way to group vertex attribute pointer configurations into a vertex array object (VAO) for later use.
        '''
        status: 'ratified'
        versions: [1]
    WEBGL_compressed_texture_s3tc_srgb:
        description: '''
        '''
        status: 'draft'
        versions: [1,2]
    WEBGL_compressed_texture_etc:
        description: '''
            Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/Ericsson_Texture_Compression">ETC2 and EAC</a>.
        '''
        status: 'community'
        versions: [1,2]
    WEBGL_shared_resources:
        description: '''
        '''
        status: 'draft'
        versions: [1,2]
    WEBGL_security_sensitive_resources:
        description: '''
        '''
        status: 'draft'
        versions: [1,2]
    OES_EGL_image_external:
        description: '''
        '''
        status: 'proposal'
        versions: [1,2]
    WEBGL_debug:
        description: '''
        '''
        status: 'proposal'
        versions: [1,2]
    WEBGL_dynamic_texture:
        description: '''
        '''
        status: 'proposal'
        versions: [1,2]
    WEBGL_subarray_uploads:
        description: '''
        '''
        status: 'proposal'
        versions: [1,2]
    ###
    WEBGL_debug_shaders:
        description: '''
        '''
        status: 'ratified'
        versions: [1,2]
    ###
    EXT_color_buffer_float:
        description: '''
            This extension allows to render into a floating point texture.
        '''
        status: 'community'
        versions: [2]
    EXT_disjoint_timer_query_webgl2:
        description: '''
            This extension offers support for querying the execution time of commands on the GPU.
        '''
        status: 'community'
        versions: [2]
    WEBGL_get_buffer_sub_data_async:
        description: '''
        '''
        status: 'draft'
        versions: [2]
    EXT_float_blend:
        description: '''
        '''
        status: 'draft'
        versions: [2]
    EXT_clip_cull_distance:
        description: '''
        '''
        status: 'proposal'
        versions: [2]
    WEBGL_multiview:
        description: '''
        '''
        status: 'proposal'
        versions: [2]
    OES_fbo_render_mipmap:
        description: '''
        '''
        status: 'draft'
        versions: [1]

webgl1only = '''
OES_texture_float
OES_texture_half_float
OES_standard_derivatives
OES_vertex_array_object
WEBGL_depth_texture
OES_element_index_uint
EXT_frag_depth
WEBGL_draw_buffers
ANGLE_instanced_arrays
OES_texture_half_float_linear
EXT_blend_minmax
EXT_shader_texture_lod
EXT_color_buffer_half_float
WEBGL_color_buffer_float
EXT_sRGB
OES_fbo_render_mipmap
'''.trim().split('\n')

webgl2only = '''
EXT_color_buffer_float
EXT_disjoint_timer_query_webgl2
WEBGL_get_buffer_sub_data_async
EXT_float_blend
EXT_clip_cull_distance
WEBGL_multiview 
'''.trim().split('\n')

webgl12 = '''
WEBGL_lose_context
WEBGL_debug_renderer_info
WEBGL_compressed_texture_s3tc
WEBGL_compressed_texture_s3tc_srgb
EXT_texture_filter_anisotropic
OES_texture_float_linear
WEBGL_compressed_texture_atc
WEBGL_compressed_texture_pvrtc
WEBGL_compressed_texture_etc1
EXT_disjoint_timer_query
WEBGL_compressed_texture_etc
WEBGL_compressed_texture_astc
WEBGL_shared_resources
WEBGL_security_sensitive_resources
OES_EGL_image_external
WEBGL_debug
WEBGL_dynamic_texture
WEBGL_subarray_uploads
WEBGL_debug_shaders
'''.trim().split('\n')

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
