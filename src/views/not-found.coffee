exports.index = ->
    widget = $('<div class="full box"></div>')
        .appendTo('main')
        
    $('<h1>Page Not Found</h1>')
        .appendTo(widget)
        
    $('''<p>
        The page you requested could not be found.
    </p>''').appendTo(widget)
