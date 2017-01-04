Navigatable = sys.import 'navigatable'

exports.index = class NavlistExpand extends Navigatable
    constructor: (id, @prefix, entries) ->
        super()
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
        li = $('<li></li>').appendTo(@list)
        $('<a></a>')
            .appendTo(li)
            .text(name)
            .attr('href', "/webgl/#{@prefix}/#{name}") #FIXME for webgl2

        @entries[name] = li

    toggle: =>
        if @expanded
            @collapse()
        else
            @expand()

    expand: (instant=false) ->
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
        @deactivateAll()
        @entries[name].addClass('active')
        @expand(instant)
