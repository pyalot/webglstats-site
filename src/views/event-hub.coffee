exports.index = class EventHub
    constructor: ->
        @listeners = []

    bind: (handler) ->
        if handler not in @listeners
            @listeners.push(handler)
        return @

    unbind: (handler) ->
        idx = @listeners.indexOf(handler)
        if idx >= 0
            @listeners[idx] = null

    trigger: (data) ->
        listeners = []
        for handler in @listeners
            if handler?
                handler(data)
                listeners.push(handler)
        @listeners = listeners
        return @
