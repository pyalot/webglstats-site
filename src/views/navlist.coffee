behavior = sys.import 'behavior'

exports.index = class NavlistExpand
    constructor: (id, @prefix, entries) ->
        behavior.activatable @
        behavior.collapsable @
        @parent = $(id)
        @link = @parent.find('a')

        @list = $('<ul></ul>')
            .appendTo(@parent)

        @entries = {}
        for entry in entries
            @add(entry)

        @list.css('display', 'block')
        @height = @list[0].getBoundingClientRect().height
        @list[0].style.height = '0px'
        @link.on 'click', @toggle

        @expanded = false

    add: (name) ->
        if typeof(name) == 'string'
            label = name
            tags = []
        else
            label = name.label
            tags = name.tags
            name = name.name

        li = $('<li></li>').appendTo(@list)
        $('<a></a>')
            .appendTo(li)
            .text(label)
            .attr('href', "/#{@prefix}/#{name}")

        @entries[name] = li

    toggle: =>
        if @expanded
            @collapse()
        else
            @expand()

    expand: (instant=false) ->
        behavior.collapse(@)
        @parent.addClass('expanded')

        @expanded = true
        if instant
            @list.addClass('notransition')
        @list[0].style.height = @height + 'px'
        if instant
            @list[0].getBoundingClientRect()
            @list.removeClass('notransition')

    collapse: (instant=false) ->
        @parent.removeClass('expanded')
        @expanded = false
        if instant
            @list.addClass('notransition')
        @list[0].style.height = '0px'
        if instant
            @list[0].getBoundingClientRect()
            @list.removeClass('notransition')

    deactivate: ->
        for name, entry of @entries
            entry.removeClass('active')

    activate: (name, instant=false) ->
        behavior.deactivate()
        @entries[name].addClass('active')
        @expand(instant)
