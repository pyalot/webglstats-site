instances = []

exports.index = class Navigatable
    constructor: ->
        instances.push @

    deactivateAll: ->
        for instance in instances
            instance.deactivate()
