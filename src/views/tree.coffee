exports.index = class Node
    constructor: ({name, @container, @parent, @checkChange, @expanded}) ->
        @checkChange ?= ->
        @expanded ?= true

        if name?
            @item = $('<div></div>')
                .text(name)
                .appendTo(@container)
                .click(@toggleExpand)

            @checkbox = $('<span class="checkbox"></span>')
                .appendTo(@item)
                .click(@toggleCheck)

        @children = []
        @setStatus 'checked'

    toggleExpand: =>
        if @expanded
            @collapse()
        else
            @expand()

    collapse: ->
        @expanded = false
        if @item?
            @item.removeClass('expanded').addClass('collapsed')
        if @list?
            @list.hide()

    expand: ->
        @expanded = true
        if @item?
            @item.removeClass('collapsed').addClass('expanded')
        if @list?
            @list.show()

    toggleCheck: (event) =>
        event.preventDefault()
        event.stopPropagation()

        if @status == 'checked'
            @uncheck()
        else
            @check()

        if @parent?
            @parent.updateCheck()
        else
            @checkChange()
        
    check: ->
        @setStatus 'checked'

        for child in @children
            child.check()

    uncheck: ->
        @setStatus 'unchecked'

        for child in @children
            child.uncheck()

    updateCheck: ->
        allChecked = true
        noneChecked = true

        for child in @children
            if child.status == 'checked' or child.status == 'semichecked'
                noneChecked = false

            if child.status != 'checked'
                allChecked = false

        if allChecked
            @setStatus 'checked'
        else if noneChecked
            @setStatus 'unchecked'
        else
            @setStatus 'semichecked'

        if @parent?
            @parent.updateCheck()

        @checkChange()

    updateStatus: ->
        if @children? and @children.length > 0
            allChecked = true
            noneChecked = true

            for child in @children
                status = child.updateStatus()
                if status == 'checked' or child.status == 'semichecked'
                    noneChecked = false

                if status != 'checked'
                    allChecked = false

            if allChecked
                @setStatus 'checked'
            else if noneChecked
                @setStatus 'unchecked'
            else
                @setStatus 'semichecked'

        return @status

    setStatus: (@status) ->
        if @checkbox?
            @checkbox
                .removeClass('unchecked')
                .removeClass('semichecked')
                .removeClass('checked')
                .addClass(@status)

    add: (name, expanded=true) ->
        if not @list?
            @list = $('<ul></ul>')
                .appendTo(@container)

            if @expanded
                if @item?
                    @item.addClass('expanded')
            else
                if @item?
                    @item.addClass('collapsed')
                @list.hide()
            
            $('<span class="arrow"></span>')
                .prependTo(@item)

        container = $('<li></li>').appendTo(@list)
        node = new Node(name:name, container:container, parent:@, expanded:expanded)
        @children.push node
        return node

    isActive: ->
        return @status == 'checked' or @status == 'semichecked'

    visitActive: (fun) ->
        if @isActive()
            fun(@)
            for child in @children
                child.visitActive(fun)

    visit: (fun) ->
        fun(@)
        for child in @children
            child.visit(fun)
