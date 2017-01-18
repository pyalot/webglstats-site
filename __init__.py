import os

path = os.path.dirname(os.path.realpath(__file__))

validPaths = set('''
/
/search
/traffic
/webgl
/webgl/parameter/ALIASED_LINE_WIDTH_RANGE
/webgl/parameter/ALIASED_POINT_SIZE_RANGE
/webgl/parameter/DEPTH_BITS
/webgl/parameter/MAX_COMBINED_TEXTURE_IMAGE_UNITS
/webgl/parameter/MAX_CUBE_MAP_TEXTURE_SIZE
/webgl/parameter/MAX_FRAGMENT_UNIFORM_VECTORS
/webgl/parameter/MAX_RENDERBUFFER_SIZE
/webgl/parameter/MAX_TEXTURE_IMAGE_UNITS
/webgl/parameter/MAX_TEXTURE_SIZE
/webgl/parameter/MAX_VARYING_VECTORS
/webgl/parameter/MAX_VERTEX_ATTRIBS
/webgl/parameter/MAX_VERTEX_TEXTURE_IMAGE_UNITS
/webgl/parameter/MAX_VERTEX_UNIFORM_VECTORS
/webgl/parameter/MAX_VIEWPORT_DIMS
/webgl/parameter/SAMPLES
/webgl/parameter/SAMPLE_BUFFERS
/webgl/parameter/STENCIL_BITS
/webgl/parameter/SUBPIXEL_BITS
/webgl/extension/EXT_blend_minmax
/webgl/extension/WEBGL_color_buffer_float
/webgl/extension/EXT_color_buffer_half_float
/webgl/extension/WEBGL_compressed_texture_atc
/webgl/extension/WEBGL_compressed_texture_etc
/webgl/extension/WEBGL_compressed_texture_etc1
/webgl/extension/WEBGL_compressed_texture_pvrtc
/webgl/extension/WEBGL_compressed_texture_s3tc
/webgl/extension/WEBGL_debug_renderer_info
/webgl/extension/WEBGL_depth_texture
/webgl/extension/EXT_disjoint_timer_query
/webgl/extension/WEBGL_draw_buffers
/webgl/extension/OES_element_index_uint
/webgl/extension/EXT_frag_depth
/webgl/extension/ANGLE_instanced_arrays
/webgl/extension/WEBGL_lose_context
/webgl/extension/EXT_sRGB
/webgl/extension/EXT_shader_texture_lod
/webgl/extension/OES_standard_derivatives
/webgl/extension/EXT_texture_filter_anisotropic
/webgl/extension/OES_texture_float
/webgl/extension/OES_texture_float_linear
/webgl/extension/OES_texture_half_float
/webgl/extension/OES_texture_half_float_linear
/webgl/extension/OES_vertex_array_object
/webgl2
/webgl2/parameter/ALIASED_LINE_WIDTH_RANGE
/webgl2/parameter/ALIASED_POINT_SIZE_RANGE
/webgl2/parameter/DEPTH_BITS
/webgl2/parameter/MAX_3D_TEXTURE_SIZE
/webgl2/parameter/MAX_ARRAY_TEXTURE_LAYERS
/webgl2/parameter/MAX_COLOR_ATTACHMENTS
/webgl2/parameter/MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS
/webgl2/parameter/MAX_COMBINED_TEXTURE_IMAGE_UNITS
/webgl2/parameter/MAX_COMBINED_UNIFORM_BLOCKS
/webgl2/parameter/MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS
/webgl2/parameter/MAX_CUBE_MAP_TEXTURE_SIZE
/webgl2/parameter/MAX_DRAW_BUFFERS
/webgl2/parameter/MAX_ELEMENTS_INDICES
/webgl2/parameter/MAX_ELEMENTS_VERTICES
/webgl2/parameter/MAX_ELEMENT_INDEX
/webgl2/parameter/MAX_FRAGMENT_INPUT_COMPONENTS
/webgl2/parameter/MAX_FRAGMENT_UNIFORM_BLOCKS
/webgl2/parameter/MAX_FRAGMENT_UNIFORM_COMPONENTS
/webgl2/parameter/MAX_FRAGMENT_UNIFORM_VECTORS
/webgl2/parameter/MAX_PROGRAM_TEXEL_OFFSET
/webgl2/parameter/MAX_RENDERBUFFER_SIZE
/webgl2/parameter/MAX_SAMPLES
/webgl2/parameter/MAX_SERVER_WAIT_TIMEOUT
/webgl2/parameter/MAX_TEXTURE_IMAGE_UNITS
/webgl2/parameter/MAX_TEXTURE_LOD_BIAS
/webgl2/parameter/MAX_TEXTURE_SIZE
/webgl2/parameter/MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS
/webgl2/parameter/MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS
/webgl2/parameter/MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS
/webgl2/parameter/MAX_UNIFORM_BLOCK_SIZE
/webgl2/parameter/MAX_UNIFORM_BUFFER_BINDINGS
/webgl2/parameter/MAX_VARYING_COMPONENTS
/webgl2/parameter/MAX_VARYING_VECTORS
/webgl2/parameter/MAX_VERTEX_ATTRIBS
/webgl2/parameter/MAX_VERTEX_OUTPUT_COMPONENTS
/webgl2/parameter/MAX_VERTEX_TEXTURE_IMAGE_UNITS
/webgl2/parameter/MAX_VERTEX_UNIFORM_BLOCKS
/webgl2/parameter/MAX_VERTEX_UNIFORM_COMPONENTS
/webgl2/parameter/MAX_VERTEX_UNIFORM_VECTORS
/webgl2/parameter/MAX_VIEWPORT_DIMS
/webgl2/parameter/MIN_PROGRAM_TEXEL_OFFSET
/webgl2/parameter/SAMPLES
/webgl2/parameter/SAMPLE_BUFFERS
/webgl2/parameter/STENCIL_BITS
/webgl2/parameter/SUBPIXEL_BITS
/webgl2/extension/EXT_color_buffer_float
/webgl2/extension/WEBGL_compressed_texture_atc
/webgl2/extension/WEBGL_compressed_texture_etc
/webgl2/extension/WEBGL_compressed_texture_etc1
/webgl2/extension/WEBGL_compressed_texture_pvrtc
/webgl2/extension/WEBGL_compressed_texture_s3tc
/webgl2/extension/WEBGL_debug_renderer_info
/webgl2/extension/EXT_disjoint_timer_query
/extension/EXT_disjoint_timer_query_webgl2
/webgl2/extension/WEBGL_lose_context
/webgl2/extension/EXT_texture_filter_anisotropic
/webgl2/extension/OES_texture_float_linear
'''.strip().split('\n'))

class Site:
    def __init__(self, server, config, log):
        self.log = log

    def __call__(self, request, response, config):
        content = open(os.path.join(path, 'index.html'), 'rb').read()
        response['Content-Type'] = 'text/html; charset=utf-8'
        if request.path not in validPaths:
            response.status = '404 Not Found'
        return content
