navLists = []
Views = sys.import 'views'
db = sys.import 'views/db'
util = sys.import 'util'
Scroll = sys.import 'scroll'

backendError = ->
    widget = $('<div class="full box"></div>')
        .appendTo('main')

    $('<h1>Data Backend Maintenance</h1>')
        .appendTo(widget)

    $('<p>The data backend is under maintenance, please try later.</p>')
        .appendTo(widget)

load = ->
    if document.webglstats.meta == 'error'
        backendError()
        return

    views = new Views(document.webglstats.meta)

    document.addEventListener 'click', (event) ->
        if event.ctrlKey or event.shiftKey or event.metaKey or event.altKey
            return

        target = event.target ? event.srcElement
        anchor = $(target).closest('a')[0]
        if anchor?
            href = anchor.getAttribute('href')
            if href? and href.startsWith('/')
                event.preventDefault()
                history.pushState(null, null, href)
                views.handle(href)

    #$('nav > div.content').slimScroll(height:'auto')
    scroll = new Scroll($('nav > div.scroller')[0])

    window.addEventListener 'popstate', ->
        query = new URLSearchParams(document.location.search)
        views.handle(document.location.pathname, query)

    path = document.location.pathname
    query = new URLSearchParams(document.location.search)
    views.handle(path, query, true)

    $('.navtoggle').click ->
        $('body').toggleClass('sidebar')

    $('div.overlay').click ->
        $('body').removeClass('sidebar')

    $('form.search').submit (event) ->
        term = $(@).find('input[type=text]').val()
        query = "?query=#{term}"
        history.pushState(null, null, "/search#{query}")
        query = new URLSearchParams(query)
        views.handle('/search', query)
        event.preventDefault()
        event.stopPropagation()

    date = document.webglstats.meta.webgl1.lastChunk
    [year, month, day] = date.split('-')
    $('header > span.updated').text('Last update: ' + util.formatDate(year, month, day))

if document.webglstats.domready and document.webglstats.meta?
    document.webglstats.loaded = true
    load()
else
    document.webglstats.load = load
