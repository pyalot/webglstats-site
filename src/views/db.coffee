progress = null

exports.init = ->
    progress = $('<div class="progress"></div>')
        .appendTo('header')

requested = 0
completed = 0
visible = false
fadeOuttimeout = null

fadeOut = ->
    visible = false
    progress.hide()

updateProgress = ->
    f = completed/requested
    progress.width((100-f*100).toFixed(0) + '%')

startRequest = ->
    if not visible
        progress.show()
        visible = true
        requested = 0
        completed = 0

    requested += 1
    updateProgress()

    if fadeOutTimeout?
        clearTimeout(fadeOutTimeout)
        fadeOutTimeout = null

completeRequest = ->
    completed += 1
    updateProgress()

    if completed == requested
        if fadeOutTimeout?
            clearTimeout(fadeOutTimeout)
        fadeOutTimeout = setTimeout(fadeOut, 1000)

exports.execute = ({query, success}) ->
    startRequest()
    $.post
        url: 'https://data.webglstats.com/webgl1',
        data: JSON.stringify(query)
        dataType: 'json'
        success: (result) =>
            completeRequest()
            success(result)
