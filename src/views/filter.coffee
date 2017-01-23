db = sys.import 'db'
util = sys.import '/util'
behavior = sys.import 'behavior'
hex = sys.import 'hex'
Tree = sys.import 'tree'

addNode = (parent, parts, count, key) ->
    parent.count += count
    name = parts.shift()

    if not parent.children?
        parent.children = {}

    child = parent.children[name]
    if not child?
        child = parent.children[name] = {count:0}

    if parts.length > 0
        addNode child, parts, count, key
    else
        child.count = count
        child.key = key

buildTree = (items, counts) ->
    root = {count:0}

    for item, i in items
        count = counts[i]
        parts = item.split('|')
        addNode root, parts, count, item

    sortNode root
    return root

sortNode = (node) ->
    if node.children?
        children = for name, child of node.children
            child.name = name
            child

        children.sort (a,b) ->
            if a.count < b.count then return 1
            else if a.count > b.count then return -1
            return 0

        for child in children
            sortNode child

        node.children = children

class Radio
    constructor: (parent, @change) ->
        @change ?= ->

        @container = $('<div class="radio"></div>')
            .appendTo(parent)

        @options = {}
        @value = null

    add: ({label, value, active=false}) ->
        value ?= label

        option = @options[value] = $('<div></div>')
            .text(label)
            .appendTo(@container)
            .click(=> @activate(value))

        if active
            @value = value
            option.addClass('active')

        return @

    activate: (activateValue) ->
        for value, option of @options
            option.removeClass('active')

        @options[activateValue].addClass('active')
        @value = activateValue
        @change(@value)

exports.index = class Filter
    constructor: (parent, @app) ->
        for field in @app.dbmeta.webgl1.fields
            if field.name == 'platform'
                @platformBits = {}
                @platformList = field.values
                @platformBitCount = field.values.length
                @platformByteCount = Math.ceil(@platformBitCount/8)
                for name, i in field.values
                    @platformBits[name] = i
                break

        #behavior.collapsable(@)
        @parent = $(parent)
        @link = @parent.find('a')
        @indicator = @link.find('span.indicator')
        @nodesByKey = {}

        @container = $('<div class="filter"></div>')
            .appendTo(@parent)

        @content = $('<div></div>')
            .appendTo(@container)
        
        series = $('<div class="option"></div>')
            .appendTo(@content)
        $('<label>Series</label>')
            .appendTo(series)
        @series = 'weekly'
        new Radio(series, @seriesChanged)
            .add(label: 'Day', value:'daily')
            .add(label:'Week', value:'weekly', active:true)
            .add(label:'Month', value:'monthly')
            .add(label:'Year', value:'yearly')

        @treeContainer = $('<div class="tree"></div>')
            .appendTo(@content)
        
        @container.css('display', 'block')
        @container[0].style.height = '0px'
        @height = util.measureHeight(@container[0])
        @link.on 'click', @toggle
        @expanded = false

        @tree = new Tree container:@treeContainer, checkChange:@filterChanged, name:'All'
    
        db.execute
            query:
                bucketBy:'platform'
                start: -30
            success: (result) =>
                tree = buildTree result.keys, result.values

                for item in tree.children
                    @addNode @tree, tree, item

                @tree.updateStatus()
        
                @height = util.measureHeight(@container[0])

        @platforms = @decodeQueryBits(@app.location.platforms)
        @updateIndicator()
        @listeners = []

    updateIndicator: ->
        if @platforms?
            @indicator.show()
        else
            @indicator.hide()

    set: (platforms) ->
        @platforms = @decodeQueryBits(platforms)
        @updateIndicator()

        if @platforms?
            for platform, node of @nodesByKey
                if platform in @platforms
                    node.setStatus('checked')
                else
                    node.setStatus('unchecked')
        else
            for platform, node of @nodesByKey
                node.setStatus('checked')

        @tree.updateStatus()
        @notifyListeners()

    onChange: (elem, listener) ->
        @listeners.push(elem:elem, change:listener)
        listener()

    notifyListeners: =>
        listeners = []
        for listener in @listeners
            if document.body.contains(listener.elem[0])
                listener.change()
                listeners.push(listener)
        @listeners = listeners

    seriesChanged: (value) =>
        @series = value
        @notifyListeners()

    filterChanged: =>
        if @tree.status == 'checked'
            @platforms = null
            @updateIndicator()
            @queryBits = null
            @app.location.setFilter(null)
        else
            values = []
            @tree.visitActive (node) ->
                if node.key?
                    values.push(node.key)
            @platforms = values
            @updateIndicator()
            bits = @encodeQueryBits(@platforms)
            @app.location.setFilter(bits)

        @notifyListeners()

    encodeQueryBits: (platforms) ->
        bits = new Uint8Array(@platformByteCount)
        for name in platforms
            bitNum = @platformBits[name]
            byte = Math.floor(bitNum/8)
            bit = bitNum % 8
            bits[byte] |= 1 << bit
        bits = hex.encode(bits)

        return '0000' + bits #reserved 2 bytes at the front for future use

    decodeQueryBits: (bits) ->
        if not bits?
            return null

        bits = bits[4...] # reserved 2 bytes at the front for future use

        bits = hex.decode(bits)
        platforms = []
        for value, byte in bits
            for bit in [0...8]
                bitNum = byte*8 + bit
                if bitNum >= @platformList.length
                    break

                if value & (1<<bit)
                    platforms.push @platformList[bitNum]
        return platforms

    addNode: (parentNode, dataParent, dataChild, depth=0) ->
        name = dataChild.name + ' ' + Math.round(dataChild.count*100/dataParent.count).toFixed(0) + '%'
        childNode = parentNode.add(name, if depth < 0 then true else false)
        if dataChild.children?
            for item in dataChild.children
                @addNode childNode, dataChild, item, depth+1
        else
            childNode.key = dataChild.key
            @nodesByKey[dataChild.key] = childNode
            if @platforms?
                if childNode.key not in @platforms
                    childNode.setStatus('unchecked')
    
    toggle: =>
        if @expanded
            @collapse()
        else
            @expand()

    expand: (instant=false) ->
        #behavior.collapse(@)
        @parent.addClass('expanded')

        @expanded = true
        if instant
            @container.addClass('notransition')

        @container[0].style.height = @height + 'px'
        util.after 0.4, =>
            @container[0].style.height = 'auto'

        if instant
            @container[0].getBoundingClientRect()
            @container.removeClass('notransition')

    collapse: (instant=false) ->
        if @expanded
            @expanded = false
            @height = util.measureHeight(@container[0])
            @container.addClass('notransition')
            @container[0].style.height = @height + 'px'
            @container.removeClass('notransition')

            util.nextFrame =>
                @parent.removeClass('expanded')
                if instant
                    @container.addClass('notransition')
                @container[0].style.height = '0px'
                if instant
                    @container[0].getBoundingClientRect()
                    @container.removeClass('notransition')

    visitActive: (fun) ->
        @tree.visitActive(fun)
