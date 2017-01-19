navLists = []
Views = sys.import 'views'
db = sys.import 'views/db'
util = sys.import 'util'
Scroll = sys.import 'scroll'

$ ->
    views = new Views()

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


    db.execute
        query:
            series: 'daily'
            start: -2
        success: (result) ->
            date = result.values[1].name
            [year, month, day] = date.split('-')
            $('header > span.updated').text('Last update: ' + util.formatDate(year, month, day))
