db = sys.import 'db'
util = sys.import 'util'
Tree = sys.import 'tree'
EventHub = sys.import 'event-hub'

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

exports.index = class Filter
    constructor: (parent) ->
        @parent = $(parent)
        @link = @parent.find('a')
        @container = $('<div></div>')
            .appendTo(@parent)
        
        @container.css('display', 'block')
        @container[0].style.height = '0px'
        @height = util.measureHeight(@container[0])
        @link.on 'click', @toggle
        @expanded = false

        @changeHandlers = new EventHub()

        @tree = new Tree container:@container, checkChange:@filterChanged, name:'All'
    
        db.execute
            query:
                bucketBy:'platform'
                start: -30
            success: (result) =>
                tree = buildTree result.keys, result.values

                for item in tree.children
                    @addNode @tree, tree, item
        
                @height = util.measureHeight(@container[0])

        @platforms = null

    onChange: (fun) ->
        @changeHandlers.bind(fun)

    offChange: (fun) ->
        @changeHandlers.unbind(fun)

    filterChanged: =>
        if @tree.status == 'checked'
            @platforms = null
        else
            values = []
            @tree.visitActive (node) ->
                if node.key?
                    values.push(node.key)
            @platforms = values
        @changeHandlers.trigger(values)

    addNode: (parentNode, dataParent, dataChild, depth=0) ->
        name = dataChild.name + ' ' + Math.round(dataChild.count*100/dataParent.count).toFixed(0) + '%'
        childNode = parentNode.add(name, if depth < 0 then true else false)
        if dataChild.children?
            for item in dataChild.children
                @addNode childNode, dataChild, item, depth+1
        else
            childNode.key = dataChild.key
    
    toggle: =>
        if @expanded
            @collapse()
        else
            @expand()

    expand: (instant=false) ->
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
