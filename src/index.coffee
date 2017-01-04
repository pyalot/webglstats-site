navLists = []
Views = sys.import 'views'

$ ->
    views = new Views()

    document.addEventListener 'click', (event) ->
        target = event.target ? event.srcElement
        if target.tagName == 'A'
            href = target.getAttribute('href')
            if href? and href.startsWith('/')
                event.preventDefault()
                history.pushState(null, null, href)
                views.handle(href)

    $('nav > div.content').slimScroll(height:'auto')

    window.addEventListener 'popstate', ->
        views.handle(document.location.pathname)

    path = document.location.pathname
    views.handle(path, true)

    $('.navtoggle').click ->
        $('body').toggleClass('sidebar')
