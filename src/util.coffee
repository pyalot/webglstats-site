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

exports.formatNumber = (n) ->
    if n < 1e3
        return n.toFixed(0)
    else if n >= 1e3 and n < 1e6
        return (n/1e3).toFixed(1) + 'k'
    else if n >= 1e6 and n < 1e9
        return (n/1e6).toFixed(1) + 'M'
    else if n >= 1e9 and n < 1e12
        return (n/1e9).toFixed(1) + 'G'
    else
        return (n/1e12).toFixed(1) + 'T'

exports.capitalize = (s) ->
    return s[0].toUpperCase() + s[1...]

exports.versionPath = (webglVersion) ->
    ({webgl1:'webgl', webgl2:'webgl2'})[webglVersion]

exports.versionLabel = (webglVersion) ->
    ({webgl1:'WebGL 1', webgl2:'WebGL 2'})[webglVersion]

monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr',
    'May', 'Jun', 'Jul', 'Aug',
    'Sep', 'Oct', 'Nov', 'Dec',
]
exports.formatDate = (year, month, day) ->
    month = parseInt(month, 10)-1
    return "#{day} #{monthNames[month]}. #{year}"

exports.getJSON = ({url, success, error}) ->
    xhr = new XMLHttpRequest()
    xhr.open('GET', url)
    xhr.onload = ->
        data = JSON.parse(xhr.response)
        success(data)
    xhr.onerror = ->
        error()
    xhr.send()

exports.iter2list = (iterator) ->
    result = []
    while 1
        item = iterator.next()
        if item?
            if item.done
                break
            else
                result.push item.value
        else
            break
    return result
