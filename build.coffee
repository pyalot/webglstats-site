cs = require 'coffee-script'
fs = require 'fs'
path = require 'path'
sourceMap = require("source-map")
exec = require('child_process').exec

## utility functions ##

__dir  = path.dirname fs.realpathSync(__filename)
libDir = path.join(__dir, 'lib')
srcDir = path.join(__dir, 'src')
cachePath = path.join(__dir, '.cache')
distDir = __dir

class Cache
    constructor: ->
        @data = null
        @load()

    get: (name) ->
        return @data[name]

    put: (name, value) ->
        @data[name] = value

    load: ->
        if process.argv[2] == 'clean'
            @data = {}
        else
            if fs.existsSync(cachePath)
                @data = JSON.parse(fs.readFileSync(cachePath, 'utf-8'))
            else
                @data = {}

    write: (data) ->
        fs.writeFileSync(
            cachePath,
            JSON.stringify(data),
        )

    save: ->
        newCache = {}
        cacheChanged = false

        for name, value of @data
            if value.seen
                if value.fresh
                    cacheChanged = true
                delete value.seen
                delete value.fresh
                newCache[name] = value
            else
                cacheChanged = true

        if cacheChanged
            console.log 'saving cache'
            @write(newCache)

    iterate: -> @data

visitDir = (directory) ->
    result = []
    for name in fs.readdirSync directory
        fullname = path.join directory, name
        stat = fs.statSync fullname
        if stat.isDirectory()
            for child in visitDir fullname
                result.push child
        else
            result.push fullname
    return result

walk = (root) ->
    for name in visitDir root
        name[root.length...]

read = (name) -> fs.readFileSync(name, 'utf-8')

## compiling ##

compile = (absPath, name) ->
    cached = cache.get(name)
    mtime = fs.statSync(absPath).mtime.getTime()
    if cached?
        cached.seen = true
        if cached.mtime < mtime
            doCompile = true
    else
        doCompile = true
    
    if doCompile
        console.log '\tcompile:', name

        source = read(absPath)

        compiled = cs.compile source,
            bare:true
            sourceMap:true
            sourceFiles:[name]

        #console.log compiled.v3SourceMap

        result = {
            code: compiled.js
            map: JSON.parse(compiled.v3SourceMap)
            mtime: mtime
            seen: true
            fresh: true
        }
        result.map.sourcesContent = [source]
        cache.put(name, result)
        return result
    else
        return cached

include = (absPath, name) ->
    cached = cache.get(name)
    mtime = fs.statSync(absPath).mtime.getTime()
    
    if cached?
        cached.seen = true
        if cached.mtime < mtime
            doCompile = true
    else
        doCompile = true

    if doCompile
        console.log '\tinclude:', name
        source = read(absPath)
        result = {
            code: source,
            mtime: mtime
            seen: true
            fresh: true
        }
        cache.put(name, result)
        return result
    else
        return cached

compileModule = (absPath) ->
    result = compile(absPath, path.relative(__dir, absPath))
    result.isModule = true
    return result

compileText = (absPath) ->
    cacheName = path.relative(__dir, absPath)
    cached = cache.get(cacheName)
    mtime = fs.statSync(absPath).mtime.getTime()
    if cached?
        cached.seen = true
        if cached.mtime < mtime
            doCompile = true
    else
        doCompile = true

    if doCompile
        console.log '\tcompile:', cacheName
        text = read(absPath)

        compiled = cs.compile("'''" + text + "'''", header:false, bare:true).trim()
        if compiled[compiled.length-1] == ';'
            compiled = compiled[...compiled.length-1]
            
        result = {
            code: compiled
            mtime: mtime
            seen: true
            fresh: true
            isText: true
        }
        
        cache.put(path.relative(__dir, absPath), result)
        return result
    else
        return cached

addNode = (name, source, result) ->
    if source.map?
        node = sourceMap.SourceNode.fromStringWithSourceMap(
            source.code,
            new sourceMap.SourceMapConsumer(source.map),
        )
    else
        node = new sourceMap.SourceNode(null, null, null, source.code)
        node.add('\n')

    if source.isModule
        moduleName = name.split('.')
        moduleName.pop()
        moduleName = moduleName.join('.')
        moduleName = '/' + moduleName

        node.prepend("moduleManager.module('#{moduleName}', function(exports,sys){\n")
        node.add('});\n')
    else if source.isText
        node.prepend("moduleManager.text('/#{name}', ")
        node.add(');\n')

    result.add(node)

addLib = (name, result) ->
    source = cache.get(name)
    addNode(name, source, result)

compilePackage = ({root, target, libs}) ->
    result = new sourceMap.SourceNode()
    result.add('(function(){\n')

    for library in libs
        addLib library, result

    dirty = false
    for name, value of cache.iterate()
        if name.indexOf(root) == 0
            relname = path.relative(root, name)
            if value.seen
                if value.fresh
                    dirty = true
                addNode relname, value, result
            else
                dirty = true

    result.add('moduleManager.index();\n})();\n')

    if dirty
        console.log 'save', target
        result = result.toStringWithSourceMap()
        
        map = JSON.parse(JSON.stringify(result.map))
        map.sourceRoot = '..'

        fs.writeFileSync(
            path.join(distDir, target),
            result.code + "\n//# sourceMappingURL=./#{path.basename(target)}.json",
        )
        fs.writeFileSync(
            path.join(distDir, "#{target}.json"),
            JSON.stringify(map, null, '  '),
        )

compileSources = ->
    for name in walk libDir
        absPath = path.join libDir, name
        relPath = path.relative __dir, absPath
        extension = name.split('.').pop()
        switch extension
            when 'coffee'
                compile(absPath, relPath)
            when 'js'
                include(absPath, relPath)

    for name in walk srcDir
        absPath = path.join srcDir, name
        extension = name.split('.').pop()
        switch extension
            when 'coffee'
                compileModule(absPath)
            else
                compileText(absPath)

compileLess = ({src, dst}) ->
    console.log 'compile less'
    src = path.join(__dir, src)
    dst = path.join(__dir, dst)
    
    flags = [
        "--source-map=#{dst}.json"
        "--source-map-url=./#{path.basename(dst)}.json"
    ]
    exec "lessc #{src} #{flags.join(' ')}", (error, stdout, stderr) ->
        if error?
            console.log 'stderr: ' + stderr
            console.log 'exec error: ' + error
        else
            fs.writeFileSync(dst, stdout)
        
if require.main is module
    cache = new Cache()

    compileLess
        src: 'less/index.less'
        dst: 'style.css'

    compileSources()
    compilePackage
        root: 'src'
        target: 'script.js'
        libs: [
            'lib/require.coffee'
        ]

    cache.save()
