exports.measureHeight = (elem) ->
    style = elem.style

    origTransition = style.transition
    origHeight = style.height

    style.transition = 'none !important'
    style.height = 'auto'
    height = elem.getBoundingClientRect().height

    style.height = origHeight
    style.transition = origTransition

    return height

exports.after = (timeout, fun) ->
    setTimeout(fun, timeout*1000)

exports.nextFrame = (fun) ->
    requestAnimationFrame(fun)

