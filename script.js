(function(){

/* does not work as expected
window.onerror = (message, url, line, column, error) ->
    #console.log message, url, line, column, error
    #console.log error.message
    #console.log [error.stack.toString()]

    lines = error.stack.split('\n')
    result = [lines.shift()]
    for line in lines
        result.push(line)
        result.push('        http://clients.codeflow.org/inzept3d/dev/src/webgl/index.coffee:3')

    lines = result.join('\n')

    console.error lines
 */
var File, moduleManager;

moduleManager = {
  File: File = (function() {
    function File(manager, absPath) {
      this.manager = manager;
      this.absPath = absPath;
      if (this.manager.files[this.absPath] == null) {
        throw new Error("file does not exist: " + this.absPath);
      }
    }

    File.prototype.read = function() {
      return this.manager.files[this.absPath];
    };

    return File;

  })(),
  modules: {},
  files: {},
  module: function(name, closure) {
    return this.modules[name] = {
      closure: closure,
      instance: null
    };
  },
  text: function(name, content) {
    return this.files[name] = content;
  },
  index: function() {
    this.getLocation();
    return this["import"]('/index');
  },
  getLocation: function() {
    var script, scripts;
    if (self.document != null) {
      scripts = document.getElementsByTagName('script');
      script = scripts[scripts.length - 1];
      this.script = script.src;
    } else {
      this.script = self.location.href;
    }
    return this.location = this.script.slice(0, this.script.lastIndexOf('/') + 1);
  },
  abspath: function(fromName, pathName) {
    var base, baseName, path;
    if (pathName === '.') {
      pathName = '';
    }
    baseName = fromName.split('/');
    baseName.pop();
    baseName = baseName.join('/');
    if (pathName[0] === '/') {
      return pathName;
    } else {
      path = pathName.split('/');
      if (baseName === '/') {
        base = [''];
      } else {
        base = baseName.split('/');
      }
      while (base.length > 0 && path.length > 0 && path[0] === '..') {
        base.pop();
        path.shift();
      }
      if (base.length === 0 || path.length === 0 || base[0] !== '') {
        throw new Error("Invalid path: " + (base.join('/')) + "/" + (path.join('/')));
      }
      return (base.join('/')) + "/" + (path.join('/'));
    }
  },
  "import": function(moduleName) {
    var exports, module, require, sys;
    if (moduleName != null) {
      module = this.modules[moduleName];
      if (module === void 0) {
        module = this.modules[moduleName + '/index'];
        if (module != null) {
          moduleName = moduleName + '/index';
        } else {
          throw new Error('Module not found: ' + moduleName);
        }
      }
      if (module.instance === null) {
        require = (function(_this) {
          return function(requirePath) {
            var path;
            path = _this.abspath(moduleName, requirePath);
            return _this["import"](path);
          };
        })(this);
        exports = {};
        sys = {
          script: this.script,
          location: this.location,
          "import": (function(_this) {
            return function(requirePath) {
              var path;
              path = _this.abspath(moduleName, requirePath);
              return _this["import"](path);
            };
          })(this),
          file: (function(_this) {
            return function(path) {
              path = _this.abspath(moduleName, path);
              return new _this.File(_this, path);
            };
          })(this),
          File: File
        };
        module.closure(exports, sys);
        if (exports.index != null) {
          module.instance = exports.index;
        } else {
          module.instance = exports;
        }
      }
      return module.instance;
    } else {
      throw new Error('no module name provided');
    }
  }
};
moduleManager.module('/index', function(exports,sys){
var Views, navLists;

navLists = [];

Views = sys["import"]('views');

$(function() {
  var path, query, views;
  views = new Views();
  document.addEventListener('click', function(event) {
    var href, ref, target;
    target = (ref = event.target) != null ? ref : event.srcElement;
    if (target.tagName === 'A') {
      href = target.getAttribute('href');
      if ((href != null) && href.startsWith('/')) {
        event.preventDefault();
        history.pushState(null, null, href);
        return views.handle(href);
      }
    }
  });
  $('nav > div.content').slimScroll({
    height: 'auto'
  });
  window.addEventListener('popstate', function() {
    var query;
    query = new URLSearchParams(document.location.search);
    return views.handle(document.location.pathname, query);
  });
  path = document.location.pathname;
  query = new URLSearchParams(document.location.search);
  views.handle(path, query, true);
  $('.navtoggle').click(function() {
    return $('body').toggleClass('sidebar');
  });
  return $('form.search').submit(function(event) {
    var term;
    term = $(this).find('input[type=text]').val();
    query = "?query=" + term;
    history.pushState(null, null, "/search" + query);
    query = new URLSearchParams(query);
    views.handle('/search', query);
    event.preventDefault();
    return event.stopPropagation();
  });
});
});
moduleManager.module('/views/index', function(exports,sys){
var Extensions, Filter, Main, Parameters, Search, Traffic, Views, db;

Parameters = sys["import"]('parameters');

Extensions = sys["import"]('extensions');

Main = sys["import"]('main');

Traffic = sys["import"]('traffic');

Filter = sys["import"]('filter');

Search = sys["import"]('search');

db = sys["import"]('db');

exports.index = Views = (function() {
  function Views() {
    db.init();
    this.search = new Search();
    this.filter = new Filter('#filter');
    this.main = new Main(this.filter, this.search);
    this.parameters = new Parameters(this.filter, this.search);
    this.extensions = new Extensions(this.filter, this.search);
    this.traffic = new Traffic(this.filter, this.search);
  }

  Views.prototype.handle = function(path, query, pageload) {
    var category, name, parts;
    if (pageload == null) {
      pageload = false;
    }
    $('main').empty();
    if (path === '/') {
      this.main.show(pageload);
      return this.extensions.overview(pageload);
    } else if (path === '/search') {
      return this.search.show(query, pageload);
    } else if (path === '/traffic') {
      return this.traffic.show();
    } else {
      path = path.slice(1);
      parts = path.split('/');
      console.assert(parts.shift() === 'webgl');
      category = parts.shift();
      name = parts.shift();
      switch (category) {
        case 'parameter':
          return this.parameters.show(name, pageload);
        case 'extension':
          return this.extensions.show(name, pageload);
      }
    }
  };

  return Views;

})();
});
moduleManager.module('/views/extensions', function(exports,sys){
var Extensions, Gauge, NavlistExpand, Series, StackedPercentage, db, info, names, ref, util;

db = sys["import"]('db');

util = sys["import"]('/util');

ref = sys["import"]('/chart'), Gauge = ref.Gauge, Series = ref.Series, StackedPercentage = ref.StackedPercentage;

NavlistExpand = sys["import"]('navlist');

info = {
  blend_minmax: {
    prefix: 'EXT',
    description: 'This extension allows for a blending mode that uses the minimum or maximum of the incoming and present color.\nIt is useful for medical imaging, volume rendering and general purpose computation on the gpu.',
    spec: '/extensions/EXT_blend_minmax/'
  },
  color_buffer_float: {
    prefix: 'WEBGL',
    description: 'This extension allows to render into a floating point texture. \n<br/><br/>\nFor historical reasons this is not reliably indicative of renderable floating point textures, and actual support has to be tested individually.',
    spec: '/extensions/WEBGL_color_buffer_float/'
  },
  color_buffer_half_float: {
    prefix: 'EXT',
    description: 'This extension allows to render into a half precision floating point texture.',
    spec: '/extensions/EXT_color_buffer_half_float/'
  },
  compressed_texture_astc: {
    prefix: 'WEBGL',
    description: 'Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/Adaptive_Scalable_Texture_Compression">ASTC</a>',
    spec: 'https://www.khronos.org/registry/webgl/extensions/WEBGL_compressed_texture_astc/'
  },
  compressed_texture_atc: {
    prefix: 'WEBGL',
    description: 'Offers compressed texture format support for ATC.',
    spec: '/extensions/WEBGL_compressed_texture_atc/'
  },
  compressed_texture_etc1: {
    prefix: 'WEBGL',
    description: 'Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/Ericsson_Texture_Compression">ETC1</a>.',
    spec: '/extensions/WEBGL_compressed_texture_etc1/'
  },
  compressed_texture_pvrtc: {
    prefix: 'WEBGL',
    description: 'Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/PVRTC">PVRTC</a>.',
    spec: '/extensions/WEBGL_compressed_texture_pvrtc/'
  },
  compressed_texture_s3tc: {
    prefix: 'WEBGL',
    description: 'Offers compressed texture format support for <a href="https://en.wikipedia.org/wiki/S3_Texture_Compression">S3TC</a>.',
    spec: '/extensions/WEBGL_compressed_texture_s3tc/'
  },
  debug_renderer_info: {
    prefix: 'WEBGL',
    description: 'Allows to query the GPU vendor and model.',
    spec: '/extensions/WEBGL_debug_renderer_info/'
  },
  depth_texture: {
    prefix: 'WEBGL',
    description: 'This extension offers the ability to create depth textures to attach to a framebuffer.',
    spec: '/extensions/WEBGL_depth_texture/'
  },
  disjoint_timer_query: {
    prefix: 'EXT',
    description: 'This extension offers support for querying the execution time of commands on the GPU.',
    spec: '/extensions/EXT_disjoint_timer_query/'
  },
  draw_buffers: {
    prefix: 'WEBGL',
    description: 'This extension allows a framebuffer to hold several textures to render to and a fragment shader to output to them.',
    spec: '/extensions/WEBGL_draw_buffers/',
    params: ['MAX_COLOR_ATTACHMENTS_WEBGL', 'MAX_DRAW_BUFFERS_WEBGL']
  },
  element_index_uint: {
    prefix: 'OES',
    description: 'This extension allows for vertex buffer array indicies to be 32-bit unsigned integers.',
    spec: '/extensions/OES_element_index_uint/'
  },
  frag_depth: {
    prefix: 'EXT',
    description: 'This extension allows a fragment shader to write the depth of a fragment.',
    spec: '/extensions/EXT_frag_depth/'
  },
  instanced_arrays: {
    prefix: 'ANGLE',
    description: 'This extension offers the ability to repeat some vertex attributes, which can be used to render many instances of an object.',
    spec: '/extensions/ANGLE_instanced_arrays/'
  },
  lose_context: {
    prefix: 'WEBGL',
    description: 'This extension simulates a context loss and regain for testing purposes.',
    spec: '/extensions/WEBGL_lose_context/'
  },
  sRGB: {
    prefix: 'EXT',
    description: 'This extension offers a texture format whose internal storage is sRGB.',
    spec: '/extensions/EXT_sRGB/'
  },
  shader_texture_lod: {
    prefix: 'EXT',
    description: 'This extension allows a texture lookup in a fragment shader to specify a LOD level explicitely.',
    spec: '/extensions/EXT_shader_texture_lod/'
  },
  standard_derivatives: {
    prefix: 'OES',
    description: 'This extension allows a fragment shader to obtain the derivatives of a value in regards to neighboring fragments.',
    spec: '/extensions/OES_standard_derivatives/'
  },
  texture_filter_anisotropic: {
    prefix: 'EXT',
    description: 'This extension allows textures to be filtered anisotropically.',
    spec: '/extensions/EXT_texture_filter_anisotropic/',
    params: ['MAX_TEXTURE_MAX_ANISOTROPY_EXT']
  },
  texture_float: {
    prefix: 'OES',
    description: 'This extension offers basic support for 32-bit floating point textures.',
    spec: '/extensions/OES_texture_float/'
  },
  texture_float_linear: {
    prefix: 'OES',
    description: 'This extension offers the ability to linearly filter 32-bit floating point textures.',
    spec: '/extensions/OES_texture_float_linear/'
  },
  texture_half_float: {
    prefix: 'OES',
    description: 'This extension offers basic support for 16-bit floating point textures.',
    spec: '/extensions/OES_texture_half_float/'
  },
  texture_half_float_linear: {
    prefix: 'OES',
    description: 'This extension offers the ability to linearly filter 16-bit floating point textures.',
    spec: '/extensions/OES_texture_half_float_linear/'
  },
  vertex_array_object: {
    prefix: 'OES',
    description: 'This extension provides a way to group vertex attribute pointer configurations into an object for later use.',
    spec: '/extensions/OES_vertex_array_object/'
  }
};

names = ['blend_minmax', 'color_buffer_float', 'color_buffer_half_float', 'compressed_texture_astc', 'compressed_texture_atc', 'compressed_texture_etc1', 'compressed_texture_pvrtc', 'compressed_texture_s3tc', 'debug_renderer_info', 'depth_texture', 'disjoint_timer_query', 'draw_buffers', 'element_index_uint', 'frag_depth', 'instanced_arrays', 'lose_context', 'sRGB', 'shader_texture_lod', 'standard_derivatives', 'texture_filter_anisotropic', 'texture_float', 'texture_float_linear', 'texture_half_float', 'texture_half_float_linear', 'vertex_array_object'];

exports.index = Extensions = (function() {
  function Extensions(filter, search) {
    this.filter = filter;
    this.nav = new NavlistExpand('#extension', 'extension', names);
    this.buildSearch(search);
  }

  Extensions.prototype.buildSearch = function(search) {
    var i, len, name, results;
    results = [];
    for (i = 0, len = names.length; i < len; i++) {
      name = names[i];
      results.push((function(_this) {
        return function(name) {
          var meta;
          meta = info[name];
          return search.add({
            id: "/webgl/extension/" + name,
            titles: [meta.prefix + '_' + name, name, name.replace(/_/g, ' ')],
            body: meta.description,
            extra: meta.params != null ? meta.params.join(' ') : null,
            type: 'Extension',
            gauge: function() {
              return _this.gauge(name);
            }
          });
        };
      })(this)(name));
    }
    return results;
  };

  Extensions.prototype.show = function(name, pageload) {
    var col, i, len, param, ref1, results, row, widget;
    this.nav.activate(name, pageload);
    row = $('<div></div>').addClass('row').addClass('responsive').appendTo('main');
    col = $('<div></div>').appendTo(row);
    widget = $('<div class="box"></div>').appendTo(col);
    $('<h1></h1>').text(info[name].prefix + '_' + name).appendTo(widget);
    $('<p></p>').append(info[name].description).appendTo(widget);
    $('<a>Specification</a>').attr('href', 'https://www.khronos.org/registry/webgl' + info[name].spec).appendTo(widget);
    col = $('<div></div>').appendTo(row);
    widget = $('<div class="box"></div>').appendTo(col);
    this.day30view(name, widget);
    widget = $('<div class="full box"></div>').appendTo('main');
    this.series(name).appendTo(widget);
    if (info[name].params != null) {
      ref1 = info[name].params;
      results = [];
      for (i = 0, len = ref1.length; i < len; i++) {
        param = ref1[i];
        widget = $('<div class="full box"></div>').appendTo('main');
        $('<h1></h1>').text(param).appendTo(widget);
        results.push(this.stackedPercentage(name, param).appendTo(widget));
      }
      return results;
    }
  };

  Extensions.prototype.overview = function(pageload) {
    var container, flow, i, len, name, results;
    flow = $('<div class="flow box"></div>').appendTo('main');
    $('<h1>Extensions</h1>').appendTo(flow);
    results = [];
    for (i = 0, len = names.length; i < len; i++) {
      name = names[i];
      container = $('<div></div>').appendTo(flow);
      this.gauge(name).appendTo(container);
      results.push($('<a class="label"></a>').attr('href', "/webgl/extension/" + name).text(name).appendTo(container));
    }
    return results;
  };

  Extensions.prototype.gauge = function(name, size, label, device) {
    var chart, fieldName;
    if (size == null) {
      size = 'small';
    }
    if (label == null) {
      label = null;
    }
    if (device == null) {
      device = null;
    }
    chart = new Gauge({
      label: label,
      size: size
    });
    fieldName = "webgl.extensions." + info[name].prefix + "_" + name;
    this.filter.onChange(chart.elem, (function(_this) {
      return function() {
        var query;
        chart.elem.addClass('spinner');
        query = {
          filterBy: {
            webgl: true
          },
          bucketBy: fieldName,
          start: -30
        };
        if (device != null) {
          query.filterBy['useragent.device'] = device;
        }
        if (_this.filter.platforms != null) {
          query.filterBy.platform = _this.filter.platforms;
        }
        return db.execute({
          query: query,
          success: function(result) {
            var percentage;
            if (result.total > 0) {
              percentage = result.values[1] / result.total;
            } else {
              percentage = 0;
            }
            chart.setLabel(label + (" (" + (util.formatNumber(result.total)) + ")"));
            chart.update(percentage * 100);
            return chart.elem.removeClass('spinner');
          }
        });
      };
    })(this));
    return chart.elem;
  };

  Extensions.prototype.series = function(name) {
    var chart, fieldName;
    fieldName = "webgl.extensions." + info[name].prefix + "_" + name;
    chart = new Series();
    this.filter.onChange(chart.elem, (function(_this) {
      return function() {
        var query;
        query = {
          filterBy: {
            webgl: true
          },
          bucketBy: fieldName,
          series: 'daily'
        };
        if (_this.filter.platforms != null) {
          query.filterBy.platform = _this.filter.platforms;
        }
        return db.execute({
          query: query,
          success: function(result) {
            return chart.update(result.values);
          }
        });
      };
    })(this));
    return chart.elem;
  };

  Extensions.prototype.stackedPercentage = function(name, param) {
    var chart, extname, fieldname;
    extname = "webgl.extensions." + info[name].prefix + "_" + name;
    fieldname = extname + "." + param;
    chart = new StackedPercentage();
    this.filter.onChange(chart.elem, (function(_this) {
      return function() {
        var obj, query;
        query = {
          filterBy: (
            obj = {
              webgl: true
            },
            obj["" + extname] = true,
            obj
          ),
          bucketBy: fieldname,
          series: 'daily'
        };
        if (_this.filter.platforms != null) {
          query.filterBy.platform = _this.filter.platforms;
        }
        return db.execute({
          query: query,
          success: function(result) {
            var data, i, item, j, keys, len, len1, ref1, ref2, value, valueStart, values, xLabels;
            keys = result.keys;
            xLabels = [];
            data = [];
            if (keys[0] === null) {
              valueStart = 1;
              keys.shift();
            } else {
              valueStart = 0;
            }
            ref1 = result.values;
            for (i = 0, len = ref1.length; i < len; i++) {
              item = ref1[i];
              xLabels.push(item.name);
              values = [];
              ref2 = item.values.slice(valueStart);
              for (j = 0, len1 = ref2.length; j < len1; j++) {
                value = ref2[j];
                if (item.total === 0) {
                  values.push(0);
                } else {
                  values.push(value / item.total);
                }
              }
              data.push(values);
            }
            return chart.update({
              areaLabels: keys,
              xLabels: xLabels,
              data: data
            });
          }
        });
      };
    })(this));
    return $(chart.elem);
  };

  Extensions.prototype.day30view = function(name, parent) {
    var col, row, smallCharts;
    $('<h1>Support (30 days)</h1>').appendTo(parent);
    row = $('<div class="row center"></div>').appendTo(parent);
    col = $('<div></div>').appendTo(row);
    this.gauge(name, 'large', 'All').appendTo(col);
    smallCharts = $('<div></div>').appendTo(row);
    row = $('<div class="row center"></div>').appendTo(smallCharts);
    col = $('<div></div>').appendTo(row);
    this.gauge(name, 'small', 'Desktop', 'desktop').appendTo(col);
    col = $('<div></div>').appendTo(row);
    this.gauge(name, 'small', 'Smartphone', 'smartphone').appendTo(col);
    row = $('<div class="row center"></div>').appendTo(smallCharts);
    col = $('<div></div>').appendTo(row);
    this.gauge(name, 'small', 'Tablet', 'tablet').appendTo(col);
    col = $('<div></div>').appendTo(row);
    return this.gauge(name, 'small', 'Console', 'game_console').appendTo(col);
  };

  return Extensions;

})();
});
moduleManager.module('/views/parameters', function(exports,sys){
var Bar, NavlistExpand, Parameters, StackedPercentage, db, fieldNames, info, names, ref;

db = sys["import"]('db');

NavlistExpand = sys["import"]('navlist');

ref = sys["import"]('/chart'), StackedPercentage = ref.StackedPercentage, Bar = ref.Bar;

info = {
  ALIASED_LINE_WIDTH_RANGE: {
    description: 'The maximum thickness of line that can be rendered.'
  },
  ALIASED_POINT_SIZE_RANGE: {
    description: 'The maximum size of point that can be rendered.'
  },
  DEPTH_BITS: {
    description: 'The number of bits for the front depthbuffer. Bits may differ in case of a framebuffer.'
  },
  MAX_COMBINED_TEXTURE_IMAGE_UNITS: {
    description: 'The maximum number of texture units that can be used.\nIf a unit is used by both vertex and fragment shader, this counts as two units against this limit.'
  },
  MAX_CUBE_MAP_TEXTURE_SIZE: {
    description: 'The maximum size of one side of a cubemap.'
  },
  MAX_FRAGMENT_UNIFORM_VECTORS: {
    description: 'The maximum number of 4-element vectors that can be passed as uniform to the vertex shader. All uniforms are 4-element aligned, a single uniform counts at least as one 4-element vector.'
  },
  MAX_RENDERBUFFER_SIZE: {
    description: 'The largest renderbuffer that can be used. This limit indicates the maximum usable canvas size as well as the maximum usable framebuffer size.'
  },
  MAX_TEXTURE_IMAGE_UNITS: {
    description: 'The maxium number of texture units that can be used in a fragment shader.'
  },
  MAX_TEXTURE_SIZE: {
    description: 'The largest texture size (either width or height) that can be created. Note that VRAM may not allow a texture of any given size, it just expresses hardware/driver support for a given size.'
  },
  MAX_VARYING_VECTORS: {
    description: 'The maximum number of 4-element vectors that can be used as varyings. Each varying counts as at least one 4-element vector.'
  },
  MAX_VERTEX_ATTRIBS: {
    description: 'The maximum number of 4-element vectors that can be used as attributes to a vertex shader. Each attribute counts as at least one 4-element vector.'
  },
  MAX_VERTEX_TEXTURE_IMAGE_UNITS: {
    description: 'The maximum number of texture units that can be used by a vertex shader. The value may be 0 which indicates no vertex shader texturing support.'
  },
  MAX_VERTEX_UNIFORM_VECTORS: {
    description: 'The maximum number of 4-element vectors that can be passed as uniform to a vertex shader.  All uniforms are 4-element aligned, a single uniform counts at least as one 4-element vector. '
  },
  MAX_VIEWPORT_DIMS: {
    description: 'The maximum viewport dimension (either width or height), that the viewport can be set to.'
  },
  SAMPLES: {
    description: 'Indicates the coverage mask of the front framebuffer. This value affects anti-aliasing and depth to coverage. For instance a value of 4 would indicate a 4x4 mask.'
  },
  SAMPLE_BUFFERS: {
    description: 'Indicates if a sample buffer is associated with the front framebuffer, this indicates support for anti-aliasing and alpha to coverage support.'
  },
  STENCIL_BITS: {
    description: 'The number of bits of the front framebuffer usable for stenciling.'
  },
  SUBPIXEL_BITS: {
    description: 'The bit-precision used to position primitives in window coordinates.'
  }
};

names = ['ALIASED_LINE_WIDTH_RANGE', 'ALIASED_POINT_SIZE_RANGE', 'DEPTH_BITS', 'MAX_COMBINED_TEXTURE_IMAGE_UNITS', 'MAX_CUBE_MAP_TEXTURE_SIZE', 'MAX_FRAGMENT_UNIFORM_VECTORS', 'MAX_RENDERBUFFER_SIZE', 'MAX_TEXTURE_IMAGE_UNITS', 'MAX_TEXTURE_SIZE', 'MAX_VARYING_VECTORS', 'MAX_VERTEX_ATTRIBS', 'MAX_VERTEX_TEXTURE_IMAGE_UNITS', 'MAX_VERTEX_UNIFORM_VECTORS', 'MAX_VIEWPORT_DIMS', 'SAMPLES', 'SAMPLE_BUFFERS', 'STENCIL_BITS', 'SUBPIXEL_BITS'];

fieldNames = {
  MAX_VIEWPORT_DIMS: 'MAX_VIEWPORT_DIMS.width',
  ALIASED_LINE_WIDTH_RANGE: 'ALIASED_LINE_WIDTH_RANGE.max',
  ALIASED_POINT_SIZE_RANGE: 'ALIASED_POINT_SIZE_RANGE.max'
};

exports.index = Parameters = (function() {
  function Parameters(filter, search) {
    this.filter = filter;
    this.nav = new NavlistExpand('#parameter', 'parameter', names);
    this.buildSearch(search);
  }

  Parameters.prototype.buildSearch = function(search) {
    var i, len, name, results;
    results = [];
    for (i = 0, len = names.length; i < len; i++) {
      name = names[i];
      results.push(search.add({
        id: "/webgl/parameter/" + name,
        titles: [name, name.replace(/_/g, ' ')],
        body: info[name].description,
        type: 'Parameter'
      }));
    }
    return results;
  };

  Parameters.prototype.show = function(name, pageload) {
    var col, full, row, widget;
    this.nav.activate(name, pageload);
    row = $('<div class="row responsive"></div>').appendTo('main');
    col = $('<div></div>').appendTo(row);
    widget = $('<div class="box"></div>').appendTo(col);
    $('<h1></h1>').text(name).appendTo(widget);
    $('<div></div>').append(info[name].description).appendTo(widget);
    col = $('<div></div>').appendTo(row);
    widget = $('<div class="box"></div>').appendTo(col);
    $('<h1>Support (30 days)</h1>').appendTo(widget);
    this.barchart(name).appendTo(widget);
    full = $('<div class="full box"></div>').appendTo('main');
    return this.series(name).appendTo(full);
  };

  Parameters.prototype.overview = function() {
    var container, flow, i, len, name, results;
    flow = $('<div class="flow box"></div>').appendTo('main');
    $('<h1>Parameters</h1>').appendTo(flow);
    results = [];
    for (i = 0, len = names.length; i < len; i++) {
      name = names[i];
      container = $('<div></div>').appendTo(flow);
      this.chart(name).appendTo(container);
      results.push($('<a class="label"></a>').attr('href', "/webgl/parameter/" + name).text(name).appendTo(container));
    }
    return results;
  };

  Parameters.prototype.series = function(name) {
    var chart, fieldName;
    if (fieldNames[name] != null) {
      fieldName = "webgl.params." + fieldNames[name];
    } else {
      fieldName = "webgl.params." + name;
    }
    chart = new StackedPercentage();
    this.filter.onChange(chart.elem, (function(_this) {
      return function() {
        var query;
        query = {
          filterBy: {
            webgl: true
          },
          bucketBy: fieldName,
          series: 'daily'
        };
        if (_this.filter.platforms != null) {
          query.filterBy.platform = _this.filter.platforms;
        }
        return db.execute({
          query: query,
          success: function(result) {
            var data, i, item, j, keys, len, len1, ref1, ref2, value, valueStart, values, xLabels;
            keys = result.keys;
            xLabels = [];
            data = [];
            if (keys[0] === null) {
              valueStart = 1;
              keys.shift();
            } else {
              valueStart = 0;
            }
            ref1 = result.values;
            for (i = 0, len = ref1.length; i < len; i++) {
              item = ref1[i];
              xLabels.push(item.name);
              values = [];
              ref2 = item.values.slice(valueStart);
              for (j = 0, len1 = ref2.length; j < len1; j++) {
                value = ref2[j];
                if (item.total === 0) {
                  values.push(0);
                } else {
                  values.push(value / item.total);
                }
              }
              data.push(values);
            }
            return chart.update({
              areaLabels: keys,
              xLabels: xLabels,
              data: data
            });
          }
        });
      };
    })(this));
    return $(chart.elem);
  };

  Parameters.prototype.barchart = function(name) {
    var chart, fieldName;
    if (fieldNames[name] != null) {
      fieldName = "webgl.params." + fieldNames[name];
    } else {
      fieldName = "webgl.params." + name;
    }
    chart = new Bar();
    this.filter.onChange(chart.elem, (function(_this) {
      return function() {
        var query;
        query = {
          filterBy: {
            webgl: true
          },
          bucketBy: fieldName,
          start: -30
        };
        if (_this.filter.platforms != null) {
          query.filterBy.platform = _this.filter.platforms;
        }
        return db.execute({
          query: query,
          success: function(result) {
            var keys, values;
            values = result.values;
            keys = result.keys;
            if (keys[0] == null) {
              values.shift();
              keys.shift();
            }
            return chart.update(keys, values);
          }
        });
      };
    })(this));
    return chart.elem;
  };

  Parameters.prototype.chart = function(name) {
    var container, fieldName;
    if (fieldNames[name] != null) {
      fieldName = "webgl.params." + fieldNames[name];
    } else {
      fieldName = "webgl.params." + name;
    }
    container = $('<div></div>');
    db.execute({
      query: {
        filterBy: {
          webgl: true
        },
        bucketBy: fieldName,
        start: -30
      },
      success: function(result) {
        var keys, values;
        values = result.values;
        keys = result.keys;
        if (keys[0] == null) {
          values.shift();
          keys.shift();
        }
        return container.sparkline(values, {
          type: 'bar',
          chartRangeMin: 0,
          height: 100,
          barWidth: 8,
          tooltipFormatter: function(sparkline, options, fields) {
            var label, offset, value;
            offset = fields[0].offset;
            value = fields[0].value;
            label = result.keys[offset];
            return "<span>" + label + " - " + ((value * 100 / result.total).toFixed(0)) + "%</span>";
          }
        });
      }
    });
    return container;
  };

  return Parameters;

})();
});
moduleManager.module('/views/main', function(exports,sys){
var Gauge, Main, Parameters, Series, behavior, db, extensions, ref, util,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

db = sys["import"]('db');

extensions = sys["import"]('extensions');

util = sys["import"]('/util');

behavior = sys["import"]('behavior');

Parameters = sys["import"]('parameters');

ref = sys["import"]('/chart'), Gauge = ref.Gauge, Series = ref.Series;

exports.index = Main = (function() {
  function Main(filter, search) {
    this.filter = filter;
    this.gauge = bind(this.gauge, this);
    behavior.activatable(this);
    search.add({
      id: '/',
      titles: 'WebGL Support',
      body: this.info($('<div></div>')).text(),
      type: 'Overview',
      gauge: this.gauge
    });
  }

  Main.prototype.info = function(parent) {
    $('<p>\n    The statistics on this site help WebGL developers make decisions about hardware capabilities. \n</p>').appendTo(parent);
    $('<p>\n    If you want help collecting data just embedd the code below into your page.\n</p>').appendTo(parent);
    $('<pre>&lt;script src=&quot;//cdn.webglstats.com/stat.js&quot;\n    defer async&gt;&lt;/script&gt;</pre>').appendTo(parent);
    $('<p>\n    You can check out the code for this site on <a href="https://github.com/pyalot/webglstats-site">github</a>.\n</p>').appendTo(parent);
    return parent;
  };

  Main.prototype.show = function() {
    var col, row, smallCharts, widget;
    behavior.deactivate();
    behavior.collapse(this);
    row = $('<div></div>').addClass('row').addClass('responsive').appendTo('main');
    col = $('<div></div>').appendTo(row);
    widget = $('<div class="box"></div>').appendTo(col);
    $('<h1>WebGL</h1>').appendTo(widget);
    this.info(widget);
    col = $('<div></div>').appendTo(row);
    widget = $('<div class="box"></div>').appendTo(col);
    $('<h1>Support (30 days)</h1>').appendTo(widget);
    row = $('<div class="row center"></div>').appendTo(widget);
    col = $('<div></div>').appendTo(row);
    this.gauge('large', 'All').appendTo(col);
    smallCharts = $('<div></div>').appendTo(row);
    row = $('<div class="row center"></div>').appendTo(smallCharts);
    col = $('<div></div>').appendTo(row);
    this.gauge('small', 'Desktop', 'desktop').appendTo(col);
    col = $('<div></div>').appendTo(row);
    this.gauge('small', 'Smartphone', 'smartphone').appendTo(col);
    row = $('<div class="row center"></div>').appendTo(smallCharts);
    col = $('<div></div>').appendTo(row);
    this.gauge('small', 'Tablet', 'tablet').appendTo(col);
    col = $('<div></div>').appendTo(row);
    this.gauge('small', 'Console', 'game_console').appendTo(col);
    widget = $('<div class="full box"></div>').appendTo('main');
    $('<h1>WebGL Support</h1>').appendTo(widget);
    return this.series().appendTo(widget);
  };

  Main.prototype.gauge = function(size, label, device) {
    var chart, query;
    if (size == null) {
      size = 'small';
    }
    if (label == null) {
      label = null;
    }
    if (device == null) {
      device = null;
    }
    chart = new Gauge({
      label: label,
      size: size
    });
    query = {
      filterBy: {},
      bucketBy: 'webgl',
      start: -30
    };
    if (device != null) {
      query.filterBy['useragent.device'] = device;
    }
    this.filter.onChange(chart.elem, (function(_this) {
      return function() {
        chart.elem.addClass('spinner');
        if (_this.filter.platforms != null) {
          query.filterBy.platform = _this.filter.platforms;
        } else {
          delete query.filterBy.platform;
        }
        return db.execute({
          query: query,
          success: function(result) {
            var percentage;
            percentage = result.values[1] / result.total;
            chart.setLabel(label + (" (" + (util.formatNumber(result.total)) + ")"));
            chart.update(percentage * 100);
            return chart.elem.removeClass('spinner');
          }
        });
      };
    })(this));
    return chart.elem;
  };

  Main.prototype.series = function() {
    var chart;
    chart = new Series();
    this.filter.onChange(chart.elem, (function(_this) {
      return function() {
        var query;
        query = {
          bucketBy: 'webgl',
          series: 'daily'
        };
        if (_this.filter.platforms != null) {
          query.filterBy = {
            platform: _this.filter.platforms
          };
        }
        return db.execute({
          query: query,
          success: function(result) {
            return chart.update(result.values);
          }
        });
      };
    })(this));
    return chart.elem;
  };

  Main.prototype.deactivate = function() {
    return null;
  };

  return Main;

})();
});
moduleManager.module('/views/db', function(exports,sys){
var completeRequest, completed, fadeOut, fadeOuttimeout, progress, requested, startRequest, updateProgress, visible;

progress = null;

exports.init = function() {
  return progress = $('<div class="progress"></div>').appendTo('header');
};

requested = 0;

completed = 0;

visible = false;

fadeOuttimeout = null;

fadeOut = function() {
  visible = false;
  return progress.hide();
};

updateProgress = function() {
  var f;
  f = completed / requested;
  return progress.width((100 - f * 100).toFixed(0) + '%');
};

startRequest = function() {
  var fadeOutTimeout;
  if (!visible) {
    progress.show();
    visible = true;
    requested = 0;
    completed = 0;
  }
  requested += 1;
  updateProgress();
  if (typeof fadeOutTimeout !== "undefined" && fadeOutTimeout !== null) {
    clearTimeout(fadeOutTimeout);
    return fadeOutTimeout = null;
  }
};

completeRequest = function() {
  var fadeOutTimeout;
  completed += 1;
  updateProgress();
  if (completed === requested) {
    if (typeof fadeOutTimeout !== "undefined" && fadeOutTimeout !== null) {
      clearTimeout(fadeOutTimeout);
    }
    return fadeOutTimeout = setTimeout(fadeOut, 1000);
  }
};

exports.execute = function(arg) {
  var query, success;
  query = arg.query, success = arg.success;
  startRequest();
  return $.post({
    url: 'https://data.webglstats.com/data',
    data: JSON.stringify(query),
    dataType: 'json',
    success: (function(_this) {
      return function(result) {
        completeRequest();
        return success(result);
      };
    })(this)
  });
};
});
moduleManager.module('/views/navlist', function(exports,sys){
var NavlistExpand, behavior,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

behavior = sys["import"]('behavior');

exports.index = NavlistExpand = (function() {
  function NavlistExpand(id, prefix, entries) {
    var entry, i, len;
    this.prefix = prefix;
    this.toggle = bind(this.toggle, this);
    behavior.activatable(this);
    behavior.collapsable(this);
    this.parent = $(id);
    this.link = this.parent.find('a');
    this.list = $('<ul></ul>').appendTo(this.parent);
    this.entries = {};
    for (i = 0, len = entries.length; i < len; i++) {
      entry = entries[i];
      this.add(entry);
    }
    this.list.css('display', 'block');
    this.height = this.list[0].getBoundingClientRect().height;
    this.list[0].style.height = '0px';
    this.link.on('click', this.toggle);
    this.expanded = false;
  }

  NavlistExpand.prototype.add = function(name) {
    var li;
    li = $('<li></li>').appendTo(this.list);
    $('<a></a>').appendTo(li).text(name).attr('href', "/webgl/" + this.prefix + "/" + name);
    return this.entries[name] = li;
  };

  NavlistExpand.prototype.toggle = function() {
    if (this.expanded) {
      return this.collapse();
    } else {
      return this.expand();
    }
  };

  NavlistExpand.prototype.expand = function(instant) {
    if (instant == null) {
      instant = false;
    }
    behavior.collapse(this);
    this.parent.addClass('expanded');
    this.expanded = true;
    if (instant) {
      this.list.addClass('notransition');
    }
    this.list[0].style.height = this.height + 'px';
    if (instant) {
      this.list[0].getBoundingClientRect();
      return this.list.removeClass('notransition');
    }
  };

  NavlistExpand.prototype.collapse = function(instant) {
    if (instant == null) {
      instant = false;
    }
    this.parent.removeClass('expanded');
    this.expanded = false;
    if (instant) {
      this.list.addClass('notransition');
    }
    this.list[0].style.height = '0px';
    if (instant) {
      this.list[0].getBoundingClientRect();
      return this.list.removeClass('notransition');
    }
  };

  NavlistExpand.prototype.deactivate = function() {
    var entry, name, ref, results;
    ref = this.entries;
    results = [];
    for (name in ref) {
      entry = ref[name];
      results.push(entry.removeClass('active'));
    }
    return results;
  };

  NavlistExpand.prototype.activate = function(name, instant) {
    if (instant == null) {
      instant = false;
    }
    behavior.deactivate();
    this.entries[name].addClass('active');
    return this.expand(instant);
  };

  return NavlistExpand;

})();
});
moduleManager.module('/views/layout', function(exports,sys){

});
moduleManager.module('/chart/index', function(exports,sys){
exports.StackedPercentage = sys["import"]('stacked-percentage');

exports.Gauge = sys["import"]('gauge');

exports.Series = sys["import"]('series');

exports.Bar = sys["import"]('bar');

exports.Donut = sys["import"]('donut');
});
moduleManager.module('/chart/stacked-percentage', function(exports,sys){

/*
colorStops = [
    [147,255,14]
    [0,47,232]
    [246,52,0]
]

colorStops = [
    [14,230,255]
    [232,0,203]
    [173,246,0]
]
 */
var Chart, Overlay, StackedPercentage, Table, colorStops, interpolateColors, mix,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

colorStops = [[160, 0, 65], [94, 76, 164], [44, 135, 191], [98, 195, 165], [170, 222, 162], [230, 246, 147], [255, 255, 188], [255, 255, 133], [255, 175, 89], [246, 109, 58]];

mix = function(a, b, f) {
  return Math.round(a * (1 - f) + b * f).toFixed(0);
};

interpolateColors = function(f, stops) {
  var b, c0, c1, g, r;
  c0 = Math.min(Math.floor(f * 2), 1);
  c1 = c0 + 1;
  f = (f % 0.5) * 2;
  c0 = stops[c0];
  c1 = stops[c1];
  r = mix(c0[0], c1[0], f);
  g = mix(c0[1], c1[1], f);
  b = mix(c0[2], c1[2], f);
  return [r, g, b];
};

Table = (function() {
  function Table(parent) {
    var thead;
    this.table = $('<table class="data-table"></table>').appendTo(parent);
    thead = $('<thead><tr><td/><td>Value</td><td colspan="2">%</td></thead>').appendTo(this.table);
    this.tbody = $('<tbody></tbody>').appendTo(this.table);
  }

  Table.prototype.fill = function(values) {
    var b, bar, color, connector, g, j, len, n, percent, r, ref, results, row, value;
    this.tbody.remove();
    this.tbody = $('<tbody></tbody>').appendTo(this.table);
    this.rows = [];
    results = [];
    for (n = j = 0, len = values.length; j < len; n = ++j) {
      value = values[n];
      ref = colorStops[n % colorStops.length], r = ref[0], g = ref[1], b = ref[2];
      color = "rgb(" + r + "," + g + "," + b + ")";
      row = $('<tr></tr>').appendTo(this.tbody);
      connector = $('<td></td>').css('background-color', color).appendTo(row)[0];
      $('<td></td>').text(value).appendTo(row);
      percent = $('<td class="percent"></td>').appendTo(row)[0];
      bar = $('<td class="bar"><div></div></td>').appendTo(row).find('div');
      results.push(this.rows.push({
        connector: connector,
        percent: percent,
        bar: bar
      }));
    }
    return results;
  };

  return Table;

})();

Chart = (function() {
  function Chart(parent) {
    this.check = bind(this.check, this);
    this.canvas = $('<canvas class="plot"></canvas>').appendTo(parent)[0];
    this.canvas.width = 500;
    this.canvas.height = 450;
    this.ctx = this.canvas.getContext('2d');
    this.paddingLeft = 50;
    this.paddingRight = 0;
    this.paddingTop = 20;
    this.paddingBottom = 50;
    requestAnimationFrame(this.check);
  }

  Chart.prototype.check = function() {
    if (document.body.contains(this.canvas)) {
      if (this.canvas.width !== this.canvas.clientWidth || this.canvas.height !== this.canvas.clientHeight) {
        this.canvas.width = this.canvas.clientWidth;
        this.canvas.height = this.canvas.clientHeight;
        this.draw();
      }
      return requestAnimationFrame(this.check);
    }
  };

  Chart.prototype.pruneData = function(areaLabels, areas) {
    var i, item, j, k, len, max, ref, ref1, resultAreas, resultLabels;
    resultLabels = [];
    resultAreas = [];
    for (i = j = 0, ref = areaLabels.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
      max = 0;
      ref1 = areas[i];
      for (k = 0, len = ref1.length; k < len; k++) {
        item = ref1[k];
        max = Math.max(max, item.rel);
      }
      if (max > 1.0 / 100) {
        resultLabels.push(areaLabels[i]);
        resultAreas.push(areas[i]);
      }
    }
    return [resultLabels, resultAreas];
  };

  Chart.prototype.update = function(arg) {
    var areaLabels, areas, ctx, data, height, i, item, j, k, len, len1, len2, m, o, ref, ref1, series, stacked, sum, value, values, width;
    areaLabels = arg.areaLabels, this.xLabels = arg.xLabels, data = arg.data, this.type = arg.type;
    if (this.type == null) {
      this.type = 'abs';
    }
    width = this.canvas.width;
    height = this.canvas.height;
    ctx = this.ctx;
    ctx.clearRect(0, 0, width, height);
    stacked = [];
    for (j = 0, len = data.length; j < len; j++) {
      item = data[j];
      values = [];
      sum = 1;
      for (k = 0, len1 = item.length; k < len1; k++) {
        value = item[k];
        values.push({
          abs: sum,
          rel: value
        });
        sum -= value;
      }
      stacked.push(values);
    }
    areas = [];
    for (i = m = 0, ref = areaLabels.length; 0 <= ref ? m < ref : m > ref; i = 0 <= ref ? ++m : --m) {
      series = [];
      for (o = 0, len2 = stacked.length; o < len2; o++) {
        item = stacked[o];
        series.push(item[i]);
      }
      areas.push(series);
    }
    ref1 = this.pruneData(areaLabels, areas), this.areaLabels = ref1[0], this.areas = ref1[1];
    this.count = data.length;
    return this.draw();
  };

  Chart.prototype.xToPos = function(x) {
    var f, width;
    f = x / (this.count - 1);
    width = this.canvas.width - this.paddingLeft - this.paddingRight;
    return this.paddingLeft + f * width;
  };

  Chart.prototype.yToPos = function(y) {
    var height;
    height = this.canvas.height - this.paddingTop - this.paddingBottom;
    return this.paddingTop + height - y * height;
  };

  Chart.prototype.drawYAxis = function() {
    var ctx, height, i, j, percent, results, x, y;
    ctx = this.ctx;
    height = 12;
    ctx.fillStyle = 'rgba(255,255,255,0.5)';
    ctx.font = height + "px 'Source Sans Pro'";
    ctx.textBaseline = 'middle';
    ctx.textAlign = 'end';
    results = [];
    for (i = j = 0; j < 5; i = ++j) {
      percent = (100 - (i / 4) * 100).toFixed(0) + '%';
      y = this.yToPos(1 - (i / 4));
      x = this.paddingLeft - 10;
      results.push(ctx.fillText(percent, x, y));
    }
    return results;
  };

  Chart.prototype.drawXAxisMonths = function() {
    var ctx, currentMonth, days, height, j, k, label, labelX, labelY, labels, len, len1, month, monthNames, months, name, num, results, x;
    labels = this.xLabels;
    currentMonth = null;
    days = null;
    months = [];
    for (x = j = 0, len = labels.length; j < len; x = ++j) {
      label = labels[x];
      month = label.split('-')[1];
      if (month !== currentMonth) {
        if (days != null) {
          months.push(days);
        }
        days = [];
        currentMonth = month;
      }
      days.push({
        day: label,
        x: x
      });
    }
    if (days != null) {
      months.push(days);
    }
    monthNames = [null, 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    ctx = this.ctx;
    ctx.strokeStyle = 'rgba(0,0,0,0.3)';
    height = 12;
    ctx.fillStyle = 'rgba(255,255,255,0.5)';
    ctx.font = height + "px 'Source Sans Pro'";
    ctx.textBaseline = 'alphabetic';
    ctx.textAlign = 'center';
    results = [];
    for (k = 0, len1 = months.length; k < len1; k++) {
      month = months[k];
      x = month[0].x;
      num = parseInt(month[0].day.split('-')[1], 10);
      name = monthNames[num];
      ctx.beginPath();
      ctx.moveTo(this.xToPos(x), this.yToPos(0));
      ctx.lineTo(this.xToPos(x), this.yToPos(1));
      ctx.stroke();
      labelX = Math.floor((this.xToPos(month[0].x) + this.xToPos(month[month.length - 1].x)) / 2);
      labelY = Math.floor(this.yToPos(0)) + height + 5;
      results.push(ctx.fillText(name, labelX, labelY));
    }
    return results;
  };

  Chart.prototype.drawXAxisYears = function() {
    var ctx, currentYear, days, height, j, k, label, labelX, labelY, labels, len, len1, name, results, x, year, years;
    labels = this.xLabels;
    currentYear = null;
    days = null;
    years = [];
    for (x = j = 0, len = labels.length; j < len; x = ++j) {
      label = labels[x];
      year = label.split('-')[0];
      if (year !== currentYear) {
        if (days != null) {
          years.push({
            days: days,
            name: currentYear
          });
        }
        days = [];
        currentYear = year;
      }
      days.push({
        day: label,
        x: x
      });
    }
    if (days != null) {
      years.push({
        days: days,
        name: year
      });
    }
    ctx = this.ctx;
    ctx.strokeStyle = 'rgba(0,0,0,0.3)';
    height = 12;
    ctx.fillStyle = 'rgba(255,255,255,0.5)';
    ctx.font = height + "px 'Source Sans Pro'";
    ctx.textBaseline = 'alphabetic';
    ctx.textAlign = 'center';
    results = [];
    for (k = 0, len1 = years.length; k < len1; k++) {
      year = years[k];
      x = year.days[0].x;
      name = year.name;
      ctx.beginPath();
      ctx.moveTo(this.xToPos(x), this.yToPos(0));
      ctx.lineTo(this.xToPos(x), this.yToPos(1));
      ctx.stroke();
      labelX = Math.floor((this.xToPos(year.days[0].x) + this.xToPos(year.days[year.days.length - 1].x)) / 2);
      labelY = Math.floor(this.yToPos(0)) + height + 5;
      results.push(ctx.fillText(name, labelX, labelY));
    }
    return results;
  };

  Chart.prototype.draw = function() {
    var area, areas, b, ctx, g, j, k, len, len1, m, n, o, r, ref, ref1, ref2, x;
    if (this.areas == null) {
      return;
    }
    areas = this.areas;
    ctx = this.ctx;
    for (n = j = 0, len = areas.length; j < len; n = ++j) {
      area = areas[n];
      ref = colorStops[n % colorStops.length], r = ref[0], g = ref[1], b = ref[2];
      ctx.fillStyle = "rgb(" + r + "," + g + "," + b + ")";
      ctx.beginPath();
      ctx.moveTo(this.xToPos(0), this.yToPos(0));
      ctx.lineTo(this.xToPos(0), this.yToPos(area[0].abs));
      for (x = k = 1, ref1 = area.length; 1 <= ref1 ? k < ref1 : k > ref1; x = 1 <= ref1 ? ++k : --k) {
        ctx.lineTo(this.xToPos(x), this.yToPos(area[x].abs));
      }
      ctx.lineTo(this.xToPos(this.count - 1), this.yToPos(0));
      ctx.closePath();
      ctx.fill();
    }
    ctx.strokeStyle = "rgba(0,0,0,0.5)";
    for (m = 0, len1 = areas.length; m < len1; m++) {
      area = areas[m];
      ctx.beginPath();
      ctx.moveTo(this.xToPos(0), this.yToPos(area[0].abs));
      for (x = o = 1, ref2 = area.length; 1 <= ref2 ? o < ref2 : o > ref2; x = 1 <= ref2 ? ++o : --o) {
        ctx.lineTo(this.xToPos(x), this.yToPos(area[x].abs));
      }
      ctx.stroke();
    }
    this.drawYAxis();
    return this.drawXAxisYears();
  };

  Chart.prototype.getSlice = function(f) {
    var area, i, j, k, len, len1, ref, ref1, results, results1;
    if (this.type === 'abs') {
      i = Math.round(f * (this.count - 1));
      ref = this.areas;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        area = ref[j];
        results.push({
          abs: area[i].abs,
          display: area[i].abs
        });
      }
      return results;
    } else if (this.type === 'rel') {
      i = Math.round(f * (this.count - 1));
      ref1 = this.areas;
      results1 = [];
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        area = ref1[k];
        results1.push({
          abs: area[i].abs,
          display: area[i].rel
        });
      }
      return results1;
    }
  };

  return Chart;

})();

Overlay = (function() {
  function Overlay(parent, chart, table) {
    this.chart = chart;
    this.table = table;
    this.mousemove = bind(this.mousemove, this);
    this.mouseleave = bind(this.mouseleave, this);
    this.mouseenter = bind(this.mouseenter, this);
    this.check = bind(this.check, this);
    this.canvas = $('<canvas class="overlay"></canvas>').appendTo(parent)[0];
    this.ctx = this.canvas.getContext('2d');
    $(this.chart.canvas).hover(this.mouseenter, this.mouseleave).mousemove(this.mousemove);
    requestAnimationFrame(this.check);
  }

  Overlay.prototype.check = function() {
    if (document.body.contains(this.canvas)) {
      if (this.canvas.width !== this.canvas.clientWidth || this.canvas.height !== this.canvas.clientHeight) {
        this.canvas.width = this.canvas.clientWidth;
        this.canvas.height = this.canvas.clientHeight;
        this.draw();
      }
      return requestAnimationFrame(this.check);
    }
  };

  Overlay.prototype.mouseenter = function() {
    return this.hover = true;
  };

  Overlay.prototype.mouseleave = function() {
    this.hover = false;
    return this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
  };

  Overlay.prototype.mousemove = function(arg) {
    var originalEvent;
    originalEvent = arg.originalEvent;
    return this.draw(originalEvent);
  };

  Overlay.prototype.draw = function(event) {
    var b, chartBottom, chartLeft, chartRect, chartRight, chartTop, color, ctx, f, g, height, j, len, n, r, rect, ref, slice, value, width, x, y;
    ctx = this.ctx;
    ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    if (!this.hover) {
      return;
    }
    rect = this.canvas.getBoundingClientRect();
    chartRect = this.chart.canvas.getBoundingClientRect();
    chartLeft = chartRect.left - rect.left + this.chart.paddingLeft;
    chartTop = chartRect.top - rect.top + this.chart.paddingTop;
    chartRight = chartRect.right - rect.left - this.chart.paddingRight;
    chartBottom = chartRect.bottom - rect.top - this.chart.paddingBottom;
    width = chartRight - chartLeft;
    height = chartBottom - chartTop;
    x = event.clientX - rect.left;
    y = event.clientY - rect.top;
    f = (x - chartLeft) / width;
    if (f >= 0 && f <= 1) {
      ctx.strokeStyle = 'rgba(0,0,0,0.3)';
      ctx.beginPath();
      ctx.moveTo(x, chartTop);
      ctx.lineTo(x, chartBottom);
      ctx.stroke();
      slice = this.chart.getSlice(f);
      for (n = j = 0, len = slice.length; j < len; n = ++j) {
        value = slice[n];
        ref = colorStops[n % colorStops.length], r = ref[0], g = ref[1], b = ref[2];
        color = "rgb(" + r + "," + g + "," + b + ")";
        y = chartTop + (1 - value.abs) * height;
        ctx.fillStyle = color;
        ctx.beginPath();
        ctx.arc(x, y, 3, 0, Math.PI * 2);
        ctx.fill();
        ctx.strokeStyle = "rgba(0,0,0,0.4)";
        ctx.arc(x, y, 3, 0, Math.PI * 2);
        ctx.stroke();
      }
      this.drawLabels(slice, x, chartTop, height);
      return this.updateTable(f);
    }
  };

  Overlay.prototype.updateTable = function(f) {
    var j, len, n, results, slice, value;
    slice = this.chart.getSlice(f);
    results = [];
    for (n = j = 0, len = slice.length; j < len; n = ++j) {
      value = slice[n];
      this.table.rows[n].percent.textContent = (value.display * 100).toFixed(1);
      results.push(this.table.rows[n].bar.css('width', value.display * 100));
    }
    return results;
  };

  Overlay.prototype.drawLabels = function(slice, x, chartTop, height) {
    var b, bevel, color, fontSize, g, i, item, j, k, l, label, labelWidth, labels, left, len, len1, len2, len3, m, o, percent, percentWidth, r, ref, results, right, t, value, y;
    fontSize = 14;
    this.ctx.font = fontSize + "px 'Source Sans Pro'";
    this.ctx.textBaseline = 'middle';
    labels = [];
    for (i = j = 0, len = slice.length; j < len; i = ++j) {
      value = slice[i];
      y = chartTop + (1 - value.abs) * height;
      label = this.chart.areaLabels[i] + ' =';
      percent = (value.display * 100).toFixed(1) + '%';
      ref = colorStops[i % colorStops.length], r = ref[0], g = ref[1], b = ref[2];
      r = Math.round(r * 0.75 + 255 * 0.25);
      g = Math.round(g * 0.75 + 255 * 0.25);
      b = Math.round(b * 0.75 + 255 * 0.25);
      color = "rgb(" + r + "," + g + "," + b + ")";
      labelWidth = this.ctx.measureText(label).width;
      percentWidth = this.ctx.measureText(percent).width;
      labels.push({
        label: label,
        labelWidth: labelWidth,
        percent: percent,
        percentWidth: percentWidth,
        width: labelWidth + percentWidth + 5,
        color: color,
        y: y
      });
    }
    left = [];
    right = [];
    for (i = k = 0, len1 = labels.length; k < len1; i = ++k) {
      label = labels[i];
      if (i % 2 === 0) {
        right.push(label);
      } else {
        left.push(label);
      }
    }
    bevel = Math.round(fontSize / 2 + 2);
    this.ctx.textAlign = 'left';
    l = Math.round(x + 6);
    for (m = 0, len2 = right.length; m < len2; m++) {
      item = right[m];
      y = Math.round(item.y);
      t = y - bevel;
      b = y + bevel;
      r = l + item.width + bevel + 6;
      this.ctx.fillStyle = 'black';
      this.ctx.beginPath();
      this.ctx.moveTo(l, y);
      this.ctx.lineTo(l + bevel, t);
      this.ctx.lineTo(r, t);
      this.ctx.lineTo(r, b);
      this.ctx.lineTo(l + bevel, b);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.strokeStyle = 'white';
      this.ctx.beginPath();
      this.ctx.moveTo(l, y);
      this.ctx.lineTo(l + bevel, t);
      this.ctx.lineTo(r, t);
      this.ctx.lineTo(r, b);
      this.ctx.lineTo(l + bevel, b);
      this.ctx.closePath();
      this.ctx.stroke();
      this.ctx.fillStyle = item.color;
      this.ctx.fillText(item.label, l + bevel + 1, y);
      this.ctx.fillStyle = 'white';
      this.ctx.fillText(item.percent, l + bevel + 1 + item.labelWidth + 5, y);
    }
    this.ctx.textAlign = 'left';
    r = x - 6;
    results = [];
    for (o = 0, len3 = left.length; o < len3; o++) {
      item = left[o];
      y = Math.round(item.y);
      t = y - bevel;
      b = y + bevel;
      l = r - item.width - bevel - 6;
      this.ctx.fillStyle = 'black';
      this.ctx.beginPath();
      this.ctx.moveTo(r, y);
      this.ctx.lineTo(r - bevel, b);
      this.ctx.lineTo(l, b);
      this.ctx.lineTo(l, t);
      this.ctx.lineTo(r - bevel, t);
      this.ctx.closePath();
      this.ctx.fill();
      this.ctx.fillStyle = 'white';
      this.ctx.beginPath();
      this.ctx.moveTo(r, y);
      this.ctx.lineTo(r - bevel, b);
      this.ctx.lineTo(l, b);
      this.ctx.lineTo(l, t);
      this.ctx.lineTo(r - bevel, t);
      this.ctx.closePath();
      this.ctx.stroke();
      this.ctx.fillStyle = item.color;
      this.ctx.fillText(item.label, l + 5, y);
      this.ctx.fillStyle = 'white';
      results.push(this.ctx.fillText(item.percent, l + 5 + item.labelWidth + 5, y));
    }
    return results;
  };

  return Overlay;

})();

exports.index = StackedPercentage = (function() {
  function StackedPercentage() {
    this.elem = $('<div class="stacked-percentage"></div>');
    this.chart = new Chart(this.elem);
    this.table = new Table(this.elem);
    this.overlay = new Overlay(this.elem, this.chart, this.table);
  }

  StackedPercentage.prototype.update = function(params) {
    this.chart.update(params);
    this.table.fill(this.chart.areaLabels, params);
    return this.overlay.updateTable(1);
  };

  return StackedPercentage;

})();
});
moduleManager.module('/chart/gauge', function(exports,sys){
var Gauge, colorStops, mix;

mix = function(a, b, f) {
  return Math.round(a * (1 - f) + b * f).toFixed(0);
};

colorStops = [[255, 70, 21], [21, 216, 255], [106, 255, 21]];

exports.index = Gauge = (function() {
  function Gauge(arg) {
    var label, percent, size;
    size = arg.size, label = arg.label;
    if (size == null) {
      size = 'small';
    }
    this.elem = $('<div class="gauge"></div>').addClass(size).easyPieChart({
      animate: 1000,
      onStep: (function(_this) {
        return function(start, end, value) {
          var b, c0, c1, f, g, r;
          percent.textContent = (value.toFixed(0)) + "%";
          f = value / 100;
          c0 = Math.min(Math.floor(f * 2), 1);
          c1 = c0 + 1;
          f = (f % 0.5) * 2;
          c0 = colorStops[c0];
          c1 = colorStops[c1];
          r = mix(c0[0], c1[0], f);
          g = mix(c0[1], c1[1], f);
          b = mix(c0[2], c1[2], f);
          return _this.chart.options.barColor = "rgb(" + r + "," + g + "," + b + ")";
        };
      })(this),
      lineWidth: 8,
      barColor: 'rgb(255,70,21)',
      trackColor: 'rgba(255,255,255,0.05)',
      scaleColor: 'rgba(255,255,255,0.2)',
      size: size === 'small' ? 80 : 160,
      lineCap: 'butt'
    });
    percent = $('<div class="percent">0%</div>').appendTo(this.elem)[0];
    if (label != null) {
      this.label = $('<label></label>').text(label).appendTo(this.elem);
    }
    this.chart = this.elem.data('easyPieChart');
  }

  Gauge.prototype.setLabel = function(text) {
    if (this.label != null) {
      return this.label.text(text);
    }
  };

  Gauge.prototype.update = function(value) {
    if (isNaN(value)) {
      value = 0;
    }
    return this.chart.update(value);
  };

  return Gauge;

})();
});
moduleManager.module('/chart/series', function(exports,sys){
var Series, smooth, util;

util = sys["import"]('/util');

smooth = function(size, src) {
  var i, j, k, l, ref, ref1, ref2, sum, values;
  values = src.slice(0, +size + 1 || 9e9);
  for (i = k = ref = size, ref1 = src.length; ref <= ref1 ? k < ref1 : k > ref1; i = ref <= ref1 ? ++k : --k) {
    sum = 0;
    for (j = l = 0, ref2 = size; 0 <= ref2 ? l < ref2 : l > ref2; j = 0 <= ref2 ? ++l : --l) {
      sum += src[i - j];
    }
    sum /= size;
    values.push(sum);
  }
  return values;
};

exports.index = Series = (function() {
  function Series() {
    this.elem = $('<div class="series"></div>');
  }

  Series.prototype.update = function(items) {
    var item, values;
    if (items[0].values != null) {
      values = (function() {
        var k, len, results;
        results = [];
        for (k = 0, len = items.length; k < len; k++) {
          item = items[k];
          if (item.total > 0) {
            results.push(item.values[1] / item.total);
          } else {
            results.push(0);
          }
        }
        return results;
      })();
    } else {
      values = (function() {
        var k, len, results;
        results = [];
        for (k = 0, len = items.length; k < len; k++) {
          item = items[k];
          results.push(item.value);
        }
        return results;
      })();
    }
    return this.elem.sparkline(values, {
      type: 'line',
      chartRangeMin: 0,
      chartRangeMax: 1,
      spotColor: false,
      minSpotColor: false,
      maxSpotColor: false,
      highlightLineColor: 'rgb(255,70,21)',
      spotRadius: 0,
      lineColor: 'rgba(255,255,255,0.5)',
      fillColor: '#348CFF',
      height: 300,
      width: '100%',
      tooltipFormatter: function(sparkline, options, fields) {
        var value, x;
        x = fields.x;
        item = items[x];
        if (item.total != null) {
          if (item.total > 0) {
            value = (item.values[1] / item.total) * 100;
          } else {
            value = 0;
          }
          return "<span>" + item.name + " - " + (value.toFixed(0)) + "%<br/>(" + (util.formatNumber(item.total)) + " samples)</span>";
        } else {
          return "<span>" + item.name + " - " + (util.formatNumber(item.value)) + "</span>";
        }
      }
    });
  };

  return Series;

})();
});
moduleManager.module('/views/filter', function(exports,sys){
var Filter, Tree, addNode, behavior, buildTree, db, sortNode, util,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

db = sys["import"]('db');

util = sys["import"]('/util');

behavior = sys["import"]('behavior');

Tree = sys["import"]('tree');

addNode = function(parent, parts, count, key) {
  var child, name;
  parent.count += count;
  name = parts.shift();
  if (parent.children == null) {
    parent.children = {};
  }
  child = parent.children[name];
  if (child == null) {
    child = parent.children[name] = {
      count: 0
    };
  }
  if (parts.length > 0) {
    return addNode(child, parts, count, key);
  } else {
    child.count = count;
    return child.key = key;
  }
};

buildTree = function(items, counts) {
  var count, i, item, j, len, parts, root;
  root = {
    count: 0
  };
  for (i = j = 0, len = items.length; j < len; i = ++j) {
    item = items[i];
    count = counts[i];
    parts = item.split('|');
    addNode(root, parts, count, item);
  }
  sortNode(root);
  return root;
};

sortNode = function(node) {
  var child, children, j, len, name;
  if (node.children != null) {
    children = (function() {
      var ref, results;
      ref = node.children;
      results = [];
      for (name in ref) {
        child = ref[name];
        child.name = name;
        results.push(child);
      }
      return results;
    })();
    children.sort(function(a, b) {
      if (a.count < b.count) {
        return 1;
      } else if (a.count > b.count) {
        return -1;
      }
      return 0;
    });
    for (j = 0, len = children.length; j < len; j++) {
      child = children[j];
      sortNode(child);
    }
    return node.children = children;
  }
};

exports.index = Filter = (function() {
  function Filter(parent) {
    this.toggle = bind(this.toggle, this);
    this.filterChanged = bind(this.filterChanged, this);
    behavior.collapsable(this);
    this.parent = $(parent);
    this.link = this.parent.find('a');
    this.container = $('<div></div>').appendTo(this.parent);
    this.container.css('display', 'block');
    this.container[0].style.height = '0px';
    this.height = util.measureHeight(this.container[0]);
    this.link.on('click', this.toggle);
    this.expanded = false;
    this.tree = new Tree({
      container: this.container,
      checkChange: this.filterChanged,
      name: 'All'
    });
    db.execute({
      query: {
        bucketBy: 'platform',
        start: -30
      },
      success: (function(_this) {
        return function(result) {
          var item, j, len, ref, tree;
          tree = buildTree(result.keys, result.values);
          ref = tree.children;
          for (j = 0, len = ref.length; j < len; j++) {
            item = ref[j];
            _this.addNode(_this.tree, tree, item);
          }
          return _this.height = util.measureHeight(_this.container[0]);
        };
      })(this)
    });
    this.platforms = null;
    this.listeners = [];
  }

  Filter.prototype.onChange = function(elem, listener) {
    this.listeners.push({
      elem: elem,
      change: listener
    });
    return listener();
  };

  Filter.prototype.filterChanged = function() {
    var j, len, listener, listeners, ref, values;
    if (this.tree.status === 'checked') {
      this.platforms = null;
    } else {
      values = [];
      this.tree.visitActive(function(node) {
        if (node.key != null) {
          return values.push(node.key);
        }
      });
      this.platforms = values;
    }
    listeners = [];
    ref = this.listeners;
    for (j = 0, len = ref.length; j < len; j++) {
      listener = ref[j];
      if (document.body.contains(listener.elem[0])) {
        listener.change(false);
        listeners.push(listener);
      }
    }
    return this.listeners = listeners;
  };

  Filter.prototype.addNode = function(parentNode, dataParent, dataChild, depth) {
    var childNode, item, j, len, name, ref, results;
    if (depth == null) {
      depth = 0;
    }
    name = dataChild.name + ' ' + Math.round(dataChild.count * 100 / dataParent.count).toFixed(0) + '%';
    childNode = parentNode.add(name, depth < 0 ? true : false);
    if (dataChild.children != null) {
      ref = dataChild.children;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        results.push(this.addNode(childNode, dataChild, item, depth + 1));
      }
      return results;
    } else {
      return childNode.key = dataChild.key;
    }
  };

  Filter.prototype.toggle = function() {
    if (this.expanded) {
      return this.collapse();
    } else {
      return this.expand();
    }
  };

  Filter.prototype.expand = function(instant) {
    if (instant == null) {
      instant = false;
    }
    behavior.collapse(this);
    this.parent.addClass('expanded');
    this.expanded = true;
    if (instant) {
      this.container.addClass('notransition');
    }
    this.container[0].style.height = this.height + 'px';
    util.after(0.4, (function(_this) {
      return function() {
        return _this.container[0].style.height = 'auto';
      };
    })(this));
    if (instant) {
      this.container[0].getBoundingClientRect();
      return this.container.removeClass('notransition');
    }
  };

  Filter.prototype.collapse = function(instant) {
    if (instant == null) {
      instant = false;
    }
    if (this.expanded) {
      this.expanded = false;
      this.height = util.measureHeight(this.container[0]);
      this.container.addClass('notransition');
      this.container[0].style.height = this.height + 'px';
      this.container.removeClass('notransition');
      return util.nextFrame((function(_this) {
        return function() {
          _this.parent.removeClass('expanded');
          if (instant) {
            _this.container.addClass('notransition');
          }
          _this.container[0].style.height = '0px';
          if (instant) {
            _this.container[0].getBoundingClientRect();
            return _this.container.removeClass('notransition');
          }
        };
      })(this));
    }
  };

  Filter.prototype.visitActive = function(fun) {
    return this.tree.visitActive(fun);
  };

  return Filter;

})();
});
moduleManager.module('/views/tree', function(exports,sys){
var Node,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

exports.index = Node = (function() {
  function Node(arg) {
    var name;
    name = arg.name, this.container = arg.container, this.parent = arg.parent, this.checkChange = arg.checkChange, this.expanded = arg.expanded;
    this.toggleCheck = bind(this.toggleCheck, this);
    this.toggleExpand = bind(this.toggleExpand, this);
    if (this.checkChange == null) {
      this.checkChange = function() {};
    }
    if (this.expanded == null) {
      this.expanded = true;
    }
    if (name != null) {
      this.item = $('<div></div>').text(name).appendTo(this.container).click(this.toggleExpand);
      this.checkbox = $('<span class="checkbox"></span>').appendTo(this.item).click(this.toggleCheck);
    }
    this.children = [];
    this.setStatus('checked');
  }

  Node.prototype.toggleExpand = function() {
    if (this.expanded) {
      return this.collapse();
    } else {
      return this.expand();
    }
  };

  Node.prototype.collapse = function() {
    this.expanded = false;
    if (this.item != null) {
      this.item.removeClass('expanded').addClass('collapsed');
    }
    if (this.list != null) {
      return this.list.hide();
    }
  };

  Node.prototype.expand = function() {
    this.expanded = true;
    if (this.item != null) {
      this.item.removeClass('collapsed').addClass('expanded');
    }
    if (this.list != null) {
      return this.list.show();
    }
  };

  Node.prototype.toggleCheck = function(event) {
    event.preventDefault();
    event.stopPropagation();
    if (this.status === 'checked') {
      this.uncheck();
    } else {
      this.check();
    }
    if (this.parent != null) {
      return this.parent.updateCheck();
    } else {
      return this.checkChange();
    }
  };

  Node.prototype.check = function() {
    var child, i, len, ref, results;
    if (this.checkbox != null) {
      this.checkbox.removeClass('unchecked').removeClass('semichecked').addClass('checked');
    }
    this.setStatus('checked');
    ref = this.children;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      child = ref[i];
      results.push(child.check());
    }
    return results;
  };

  Node.prototype.uncheck = function() {
    var child, i, len, ref, results;
    if (this.checkbox != null) {
      this.checkbox.addClass('unchecked').removeClass('semichecked').removeClass('checked');
    }
    this.setStatus('unchecked');
    ref = this.children;
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      child = ref[i];
      results.push(child.uncheck());
    }
    return results;
  };

  Node.prototype.updateCheck = function() {
    var allChecked, child, i, len, noneChecked, ref;
    allChecked = true;
    noneChecked = true;
    ref = this.children;
    for (i = 0, len = ref.length; i < len; i++) {
      child = ref[i];
      if (child.status === 'checked' || child.status === 'semichecked') {
        noneChecked = false;
      }
      if (child.status !== 'checked') {
        allChecked = false;
      }
    }
    if (allChecked) {
      this.setStatus('checked');
    } else if (noneChecked) {
      this.setStatus('unchecked');
    } else {
      this.setStatus('semichecked');
    }
    if (this.parent != null) {
      this.parent.updateCheck();
    }
    return this.checkChange();
  };

  Node.prototype.setStatus = function(status) {
    this.status = status;
    if (this.checkbox != null) {
      return this.checkbox.removeClass('unchecked').removeClass('semichecked').removeClass('checked').addClass(this.status);
    }
  };

  Node.prototype.add = function(name, expanded) {
    var container, node;
    if (expanded == null) {
      expanded = true;
    }
    if (this.list == null) {
      this.list = $('<ul></ul>').appendTo(this.container);
      if (this.expanded) {
        if (this.item != null) {
          this.item.addClass('expanded');
        }
      } else {
        if (this.item != null) {
          this.item.addClass('collapsed');
        }
        this.list.hide();
      }
      $('<span class="arrow"></span>').prependTo(this.item);
    }
    container = $('<li></li>').appendTo(this.list);
    node = new Node({
      name: name,
      container: container,
      parent: this,
      expanded: expanded
    });
    this.children.push(node);
    return node;
  };

  Node.prototype.isActive = function() {
    return this.status === 'checked' || this.status === 'semichecked';
  };

  Node.prototype.visitActive = function(fun) {
    var child, i, len, ref, results;
    if (this.isActive()) {
      fun(this);
      ref = this.children;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        child = ref[i];
        results.push(child.visitActive(fun));
      }
      return results;
    }
  };

  return Node;

})();
});
moduleManager.module('/chart/bar', function(exports,sys){
var Bar, normalize;

normalize = function(labels, values) {
  var abs, cum, i, j, k, l, label, len, len1, len2, newLabels, newValues, total, value;
  total = 0;
  for (j = 0, len = values.length; j < len; j++) {
    value = values[j];
    total += value;
  }
  newValues = [];
  cum = 1;
  for (i = k = 0, len1 = values.length; k < len1; i = ++k) {
    value = values[i];
    label = labels[i];
    abs = value / total;
    newValues.push({
      abs: abs,
      cum: cum
    });
    cum -= abs;
  }
  values = newValues;
  newValues = [];
  newLabels = [];
  for (i = l = 0, len2 = values.length; l < len2; i = ++l) {
    value = values[i];
    label = labels[i];
    if (value.abs > 0.0001) {
      newValues.push(value);
      newLabels.push(label);
    }
  }
  return [newLabels, newValues];
};

exports.index = Bar = (function() {
  function Bar() {
    this.elem = this.table = $('<table class="data-table"></table>');
    $('<thead><tr><td>Value</td><td colspan="2">Abs.</td><td colspan="2">Cum.</td></thead>').appendTo(this.table);
    this.tbody = $('<tbody></tbody>').appendTo(this.table);
  }

  Bar.prototype.update = function(labels, values) {
    var i, j, label, len, ref, results, row, value;
    ref = normalize(labels, values), labels = ref[0], values = ref[1];
    this.tbody.remove();
    this.tbody = $('<tbody></tbody>').appendTo(this.table);
    this.rows = [];
    results = [];
    for (i = j = 0, len = values.length; j < len; i = ++j) {
      value = values[i];
      label = labels[i];
      row = $('<tr></tr>').appendTo(this.tbody);
      $('<td></td>').text(label).appendTo(row);
      $('<td class="percent"></td>').text((value.abs * 100).toFixed(1) + '%').appendTo(row);
      $('<td class="bar"><div></div></td>').appendTo(row).find('div').css('width', value.abs * 100);
      $('<td class="percent"></td>').text((value.cum * 100).toFixed(1) + '%').appendTo(row);
      results.push($('<td class="bar"><div></div></td>').appendTo(row).find('div').css('width', value.cum * 100));
    }
    return results;
  };

  return Bar;

})();
});
moduleManager.module('/util', function(exports,sys){
exports.measureHeight = function(elem) {
  var height, origHeight, origTransition, style;
  style = elem.style;
  origTransition = style.transition;
  origHeight = style.height;
  style.transition = 'none !important';
  style.height = 'auto';
  height = elem.getBoundingClientRect().height;
  style.height = origHeight;
  style.transition = origTransition;
  return height;
};

exports.after = function(timeout, fun) {
  return setTimeout(fun, timeout * 1000);
};

exports.nextFrame = function(fun) {
  return requestAnimationFrame(fun);
};

exports.formatNumber = function(n) {
  if (n < 1e3) {
    return n.toFixed(0);
  } else if (n >= 1e3 && n < 1e6) {
    return (n / 1e3).toFixed(1) + 'k';
  } else if (n >= 1e6 && n < 1e9) {
    return (n / 1e6).toFixed(1) + 'M';
  } else if (n >= 1e9 && n < 1e12) {
    return (n / 1e9).toFixed(1) + 'G';
  } else {
    return (n / 1e12).toFixed(1) + 'T';
  }
};

exports.capitalize = function(s) {
  return s[0].toUpperCase() + s.slice(1);
};
});
moduleManager.module('/views/behavior', function(exports,sys){
var activatables, collapsables;

activatables = [];

collapsables = [];

exports.activatable = function(instance) {
  return activatables.push(instance);
};

exports.collapsable = function(instance) {
  return collapsables.push(instance);
};

exports.collapse = function(origin) {
  var i, instance, len, results;
  results = [];
  for (i = 0, len = collapsables.length; i < len; i++) {
    instance = collapsables[i];
    if (origin !== instance) {
      results.push(instance.collapse());
    } else {
      results.push(void 0);
    }
  }
  return results;
};

exports.deactivate = function() {
  var i, instance, len, results;
  results = [];
  for (i = 0, len = activatables.length; i < len; i++) {
    instance = activatables[i];
    results.push(instance.deactivate());
  }
  return results;
};
});
moduleManager.module('/views/search', function(exports,sys){
var Search, behavior;

behavior = sys["import"]('behavior');

exports.index = Search = (function() {
  function Search() {
    this.index = lunr(function() {
      this.field('title', {
        boost: 10
      });
      this.field('body');
      this.field('extra');
      return this.ref('id');
    });
    this.entries = {};
  }

  Search.prototype.show = function(query, instant) {
    var entry, i, len, link, result, results, results1, text, widget;
    query = query.get('query');
    results = this.index.search(query);
    behavior.deactivate();
    behavior.collapse();
    widget = $('<div class="full box"></div>').appendTo('main');
    $('<span>Search Results for: </span>').appendTo(widget);
    $('<span class="query"></span>').appendTo(widget).text('"' + query + '". ');
    $("<span>" + results.length + " results found.</span>").appendTo(widget);
    results1 = [];
    for (i = 0, len = results.length; i < len; i++) {
      result = results[i];
      entry = this.entries[result.ref];
      widget = $('<div class="full box search-result"></div>').appendTo('main');
      if (entry.gauge != null) {
        entry.gauge().appendTo(widget);
      }
      text = $('<div></div>').appendTo(widget);
      link = $('<a></a>').appendTo(text).attr('href', result.ref).text(entry.type + ' ' + entry.title);
      results1.push($('<p></p>').appendTo(text).append(entry.body));
    }
    return results1;
  };

  Search.prototype.add = function(arg) {
    var body, extra, gauge, id, titles, type;
    id = arg.id, titles = arg.titles, body = arg.body, extra = arg.extra, type = arg.type, gauge = arg.gauge;
    if (!(titles instanceof Array)) {
      titles = [titles];
    }
    if (extra == null) {
      extra = null;
    }
    this.entries[id] = {
      title: titles[0],
      body: body,
      type: type,
      gauge: gauge
    };
    return this.index.add({
      id: id,
      title: titles.join(' '),
      body: $('<div></div>').append(body).text(),
      extra: extra
    });
  };

  return Search;

})();
});
moduleManager.module('/views/traffic', function(exports,sys){
var Donut, Gauge, Series, StackedPercentage, Traffic, behavior, db, ref, util;

db = sys["import"]('db');

util = sys["import"]('/util');

behavior = sys["import"]('behavior');

ref = sys["import"]('/chart'), Gauge = ref.Gauge, Series = ref.Series, Donut = ref.Donut, StackedPercentage = ref.StackedPercentage;

exports.index = Traffic = (function() {
  function Traffic(filter, search) {
    this.filter = filter;
    null;
  }

  Traffic.prototype.show = function() {
    var col, full, mainRow, widget;
    behavior.deactivate();
    behavior.collapse(this);
    mainRow = $('<div></div>').addClass('row').addClass('responsive').appendTo('main');
    col = $('<div></div>').appendTo(mainRow);
    widget = $('<div class="box"></div>').appendTo(col);
    $('<h1>Visits</h1>').appendTo(widget);
    this.series().appendTo(widget);
    col = $('<div></div>').appendTo(mainRow);
    widget = $('<div class="box"></div>').appendTo(col);
    $('<h1>Platform (30 days)</h1>').appendTo(widget);
    this.donut('useragent.device').appendTo(widget);
    mainRow = $('<div></div>').addClass('row').addClass('responsive').appendTo('main');
    col = $('<div></div>').appendTo(mainRow);
    widget = $('<div class="box"></div>').appendTo(col);
    $('<h1>Operating System (30 days)</h1>').appendTo(widget);
    this.donut('useragent.os').appendTo(widget);
    col = $('<div></div>').appendTo(mainRow);
    widget = $('<div class="box"></div>').appendTo(col);
    $('<h1>Browser (30 days)</h1>').appendTo(widget);
    this.donut('useragent.family').appendTo(widget);
    full = $('<div class="full box"></div>').appendTo('main');
    $('<h1>Platform</h1>').appendTo(full);
    this.stackedPercentage('useragent.device').appendTo(full);
    full = $('<div class="full box"></div>').appendTo('main');
    $('<h1>Operating System</h1>').appendTo(full);
    this.stackedPercentage('useragent.os').appendTo(full);
    full = $('<div class="full box"></div>').appendTo('main');
    $('<h1>Browser</h1>').appendTo(full);
    return this.stackedPercentage('useragent.family').appendTo(full);
  };

  Traffic.prototype.donut = function(bucketBy) {
    var chart;
    chart = new Donut();
    this.filter.onChange(chart.elem, (function(_this) {
      return function() {
        var query;
        chart.elem.addClass('spinner');
        query = {
          filterBy: {},
          bucketBy: bucketBy,
          start: -30
        };
        if (_this.filter.platforms != null) {
          query.filterBy.platform = _this.filter.platforms;
        }
        return db.execute({
          query: query,
          success: function(result) {
            var label, n, value, values;
            chart.elem.removeClass('spinner');
            values = (function() {
              var i, len, ref1, results;
              ref1 = result.keys;
              results = [];
              for (n = i = 0, len = ref1.length; i < len; n = ++i) {
                label = ref1[n];
                value = result.values[n];
                results.push({
                  label: util.capitalize(label.replace(/_/g, ' ')) + (" " + ((value * 100 / result.total).toFixed(1)) + "% (" + (util.formatNumber(value)) + ")"),
                  value: result.values[n]
                });
              }
              return results;
            })();
            return chart.update(values);
          }
        });
      };
    })(this));
    return $(chart.elem);
  };

  Traffic.prototype.series = function(name) {
    var chart;
    chart = new Series();
    this.filter.onChange(chart.elem, (function(_this) {
      return function() {
        var query;
        query = {
          filterBy: {},
          series: 'daily'
        };
        if (_this.filter.platforms != null) {
          query.filterBy.platform = _this.filter.platforms;
        }
        return db.execute({
          query: query,
          success: function(result) {
            return chart.update(result.values);
          }
        });
      };
    })(this));
    return chart.elem;
  };

  Traffic.prototype.stackedPercentage = function(bucketBy) {
    var chart;
    chart = new StackedPercentage();
    this.filter.onChange(chart.elem, (function(_this) {
      return function() {
        var query;
        query = {
          filterBy: {},
          bucketBy: bucketBy,
          series: 'daily'
        };
        if (_this.filter.platforms != null) {
          query.filterBy.platform = _this.filter.platforms;
        }
        return db.execute({
          query: query,
          success: function(result) {
            var data, i, item, j, keys, len, len1, ref1, ref2, value, valueStart, values, xLabels;
            keys = result.keys;
            xLabels = [];
            data = [];
            if (keys[0] === null) {
              valueStart = 1;
              keys.shift();
            } else {
              valueStart = 0;
            }
            ref1 = result.values;
            for (i = 0, len = ref1.length; i < len; i++) {
              item = ref1[i];
              xLabels.push(item.name);
              values = [];
              ref2 = item.values.slice(valueStart);
              for (j = 0, len1 = ref2.length; j < len1; j++) {
                value = ref2[j];
                if (item.total === 0) {
                  values.push(0);
                } else {
                  values.push(value / item.total);
                }
              }
              data.push(values);
            }
            return chart.update({
              areaLabels: keys,
              xLabels: xLabels,
              data: data,
              type: 'rel'
            });
          }
        });
      };
    })(this));
    return $(chart.elem);
  };

  return Traffic;

})();
});
moduleManager.module('/chart/donut', function(exports,sys){
var Donut, colors;

colors = [[160, 0, 65], [94, 76, 164], [44, 135, 191], [98, 195, 165], [170, 222, 162], [230, 246, 147], [255, 255, 188], [255, 255, 133], [255, 175, 89], [246, 109, 58]];

exports.index = Donut = (function() {
  function Donut(options) {
    var canvas, ref, ref1;
    if (options == null) {
      options = {};
    }
    this.width = (ref = options.width) != null ? ref : 160;
    this.height = (ref1 = options.height) != null ? ref1 : 160;
    this.elem = $('<div class="donut"></div>');
    canvas = $('<canvas></canvas>').appendTo(this.elem)[0];
    canvas.width = this.width;
    canvas.height = this.height;
    this.ctx = canvas.getContext('2d');
    this.legend = $('<div></div>').appendTo(this.elem);
  }

  Donut.prototype.update = function(values) {
    var b, color, end, entry, g, i, j, len, len1, n, r, ref, results, start, total;
    values.sort(function(a, b) {
      return b.value - a.value;
    });
    values = values.filter(function(entry) {
      return entry.value > 0;
    });
    this.legend.empty();
    this.ctx.clearRect(0, 0, this.width, this.height);
    total = 0;
    for (i = 0, len = values.length; i < len; i++) {
      entry = values[i];
      total += entry.value;
    }
    start = 0;
    results = [];
    for (n = j = 0, len1 = values.length; j < len1; n = ++j) {
      entry = values[n];
      ref = colors[n % colors.length], r = ref[0], g = ref[1], b = ref[2];
      color = "rgb(" + r + "," + g + "," + b + ")";
      end = start + entry.value / total;
      $('<div></div>').appendTo(this.legend).text(entry.label).css('border-color', color);
      this.segment(start, end, color);
      this.separator(end);
      results.push(start = end);
    }
    return results;
  };

  Donut.prototype.separator = function(pos) {
    var a, cx, cy, r1, r2, x1, x2, y1, y2;
    r2 = Math.min(this.width, this.height) / 2;
    r1 = r2 * 0.8;
    a = Math.PI * 2 * pos - Math.PI / 2;
    cx = this.width / 2;
    cy = this.height / 2;
    x1 = cx + Math.cos(a) * r1;
    y1 = cy + Math.sin(a) * r1;
    x2 = cx + Math.cos(a) * r2;
    y2 = cy + Math.sin(a) * r2;
    this.ctx.beginPath();
    this.ctx.moveTo(x1, y1);
    this.ctx.lineTo(x2, y2);
    return this.ctx.stroke();
  };

  Donut.prototype.segment = function(start, end, color) {
    var r1, r2;
    start = Math.PI * 2 * start - Math.PI / 2;
    end = Math.PI * 2 * end - Math.PI / 2;
    this.ctx.fillStyle = color;
    r2 = Math.min(this.width, this.height) / 2;
    r1 = r2 * 0.8;
    this.ctx.beginPath();
    this.ctx.arc(this.width / 2, this.height / 2, r2, start, end, false);
    this.ctx.arc(this.width / 2, this.height / 2, r1, end, start, true);
    return this.ctx.fill();
  };

  return Donut;

})();
});
moduleManager.index();
})();

//# sourceMappingURL=./script.js.json