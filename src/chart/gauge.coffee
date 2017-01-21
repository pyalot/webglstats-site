mix = (a, b, f) ->
    return Math.round(a*(1-f) + b*f).toFixed(0)

colorStops = [
    [255,70,21]
    [21,216,255]
    [106,255,21]
]

exports.index = class Gauge
    constructor: ({size,label}) ->
        size ?= 'small'

        step = (start, end, value) =>
            if isNaN(value)
                value = 0

            percent.textContent = "#{value.toFixed(0)}%"

            f = value / 100

            c0 = Math.min(Math.floor(f*2), 1)
            c1 = c0+1
            f = (f%0.5)*2
            c0 = colorStops[c0]
            c1 = colorStops[c1]

            r = mix(c0[0], c1[0], f)
            g = mix(c0[1], c1[1], f)
            b = mix(c0[2], c1[2], f)

            @chart.options.barColor = "rgb(#{r},#{g},#{b})"

        @elem = $('<div class="gauge"></div>')
            .addClass(size)
            .easyPieChart
                animate: 1000
                onStart: =>
                    step(null, null, 0)
                onStep: step
                onStop: =>
                    step(null, null, 100)

                lineWidth: 8
                #barColor: '#15ecff'
                #barColor: 'rgb(106,255,21)' #good
                #barColor: 'rgb(21,216,255)' #meh
                barColor: 'rgb(255,70,21)' #bad
                trackColor: 'rgba(255,255,255,0.05)'
                scaleColor: 'rgba(255,255,255,0.2)'
                size: if size=='small' then 80 else 160
                lineCap: 'butt'
    
        percent = $('<div class="percent">0%</div>').appendTo(@elem)[0]

        if label?
            @label = $('<label></label>')
                .text(label)
                .appendTo(@elem)

        @chart = @elem.data('easyPieChart')

    setLabel: (text) ->
        if @label?
            @label.text(text)

    update: (value) ->
        if isNaN(value)
            value = 0
        @chart.update(value)
