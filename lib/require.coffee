### does not work as expected
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
###

moduleManager =
    File: class File
        constructor: (@manager, @absPath) ->
            if not @manager.files[@absPath]?
                throw new Error("file does not exist: #{@absPath}")
        read: -> @manager.files[@absPath]

    modules: {}
    files: {}
    module: (name, closure) ->
        @modules[name] =
            closure: closure
            instance: null

    text: (name, content) ->
        @files[name] = content

    index: ->
        @getLocation()
        @import('/index')

    getLocation: ->
        if self.document?
            scripts = document.getElementsByTagName 'script'
            script = scripts[scripts.length-1]
            @script = script.src
        else
            @script = self.location.href

        @location = @script[...@script.lastIndexOf('/')+1]

    abspath: (fromName, pathName) ->
        if pathName == '.'
            pathName = ''

        baseName = fromName.split('/')
        baseName.pop()
        baseName = baseName.join('/')

        if pathName[0] == '/'
            return pathName
        else
            path = pathName.split '/'
            if baseName == '/'
                base = ['']
            else
                base = baseName.split '/'

            while base.length > 0 and path.length > 0 and path[0] == '..'
                base.pop()
                path.shift()

            if base.length == 0 || path.length == 0 || base[0] != ''
                throw new Error("Invalid path: #{base.join '/'}/#{path.join '/'}")
            return "#{base.join('/')}/#{path.join('/')}"
    
    import: (moduleName) ->
        if moduleName?
            module = @modules[moduleName]

            if module == undefined
                module = @modules[moduleName+'/index']
                if module?
                    moduleName = moduleName+'/index'
                else
                    throw new Error('Module not found: ' + moduleName)
            
            if module.instance == null
                require = (requirePath) =>
                    path = @abspath(moduleName, requirePath)
                    return @import(path)

                exports = {}
                sys = {
                    script: @script
                    location: @location
                    import: (requirePath) =>
                        path = @abspath(moduleName, requirePath)
                        return @import(path)
                    file: (path) =>
                        path = @abspath(moduleName, path)
                        return new @File(@, path)
                    File: File
                }
                module.closure(exports, sys)
                if exports.index?
                    module.instance = exports.index
                else
                    module.instance = exports

            return module.instance
        else
            throw new Error('no module name provided')
