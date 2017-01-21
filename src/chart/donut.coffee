colors = [
    [160,0,65]
    [94,76,164]
    [44,135,191]
    [98,195,165]
    [170,222,162]
    [230,246,147]
    [255,255,188]
    [255,255,133]
    [255,175,89]
    [246,109,58]
]

exports.index = class Donut
    constructor: (options={}) ->
        @width = options.width ? 160
        @height = options.height ? 160

        @elem = $('<div class="donut"></div>')

        canvas = $('<canvas></canvas>').appendTo(@elem)[0]
        canvas.width = @width
        canvas.height = @height
        @ctx = canvas.getContext('2d')
        
        @legend = $('<div></div>')
            .appendTo(@elem)

    update: (values) ->
        values.sort (a, b) -> b.label - a.label
        values = values.filter (entry) -> entry.value > 0

        @legend.empty()
        @ctx.clearRect(0, 0, @width, @height)

        total = 0
        for entry in values
            total += entry.value

        start = 0
        for entry, n in values

            [r,g,b] = colors[n%colors.length]
            color = "rgb(#{r},#{g},#{b})"
            end = start + entry.value/total

            $('<div></div>')
                .appendTo(@legend)
                .text(entry.label)
                .css('border-color', color)

            @segment(start, end, color)
            @separator(end)
            start = end

    separator: (pos) ->
        r2 = Math.min(@width, @height)/2
        r1 = r2*0.8

        a = Math.PI*2*pos - Math.PI/2

        cx = @width/2
        cy = @height/2

        x1 = cx + Math.cos(a)*r1
        y1 = cy + Math.sin(a)*r1
        x2 = cx + Math.cos(a)*r2
        y2 = cy + Math.sin(a)*r2

        @ctx.beginPath()
        @ctx.moveTo(x1,y1)
        @ctx.lineTo(x2,y2)
        @ctx.stroke()

    segment: (start, end, color) ->
        start = Math.PI*2*start - Math.PI/2
        end = Math.PI*2*end - Math.PI/2
        @ctx.fillStyle = color
        r2 = Math.min(@width, @height)/2
        r1 = r2*0.8
        @ctx.beginPath()
        @ctx.arc(@width/2, @height/2, r2, start, end, false)
        @ctx.arc(@width/2, @height/2, r1, end, start, true)
        @ctx.fill()
