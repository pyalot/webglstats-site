activatables = []
collapsables = []

exports.activatable = (instance) ->
    activatables.push instance

exports.collapsable = (instance) ->
    collapsables.push instance

exports.collapse = (origin) ->
    for instance in collapsables
        if origin isnt instance
            instance.collapse()

exports.deactivate = ->
    for instance in activatables
        instance.deactivate()
