###
colorStops = [
    [147,255,14]
    [0,47,232]
    [246,52,0]
]

colorStops = [
    [14,230,255]
    [232,0,203]
    [173,246,0]
]
###

colorStops = [
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

mix = (a, b, f) ->
    return Math.round(a*(1-f) + b*f).toFixed(0)

interpolateColors = (f, stops) ->
    c0 = Math.min(Math.floor(f*2), 1)
    c1 = c0+1
    f = (f%0.5)*2
    c0 = stops[c0]
    c1 = stops[c1]

    r = mix(c0[0], c1[0], f)
    g = mix(c0[1], c1[1], f)
    b = mix(c0[2], c1[2], f)

    return [r,g,b]

class Table
    constructor: (parent) ->
        @table = $('<table class="data-table"></table>')
            .appendTo(parent)
        thead = $('<thead><tr><td/><td>Value</td><td colspan="2">%</td></thead>')
            .appendTo(@table)
        @tbody = $('<tbody></tbody>')
            .appendTo(@table)

    fill: (values) ->
        @tbody.remove()
        @tbody = $('<tbody></tbody>')
            .appendTo(@table)

        @rows = []

        for value, n in values
            [r,g,b] = colorStops[n%colorStops.length]
            color = "rgb(#{r},#{g},#{b})"
            row = $('<tr></tr>')
                .appendTo(@tbody)
            connector = $('<td></td>')
                .css('background-color', color)
                .appendTo(row)[0]
            $('<td></td>')
                .text(value)
                .appendTo(row)

            percent = $('<td class="percent"></td>')
                .appendTo(row)[0]

            bar = $('<td class="bar"><div></div></td>')
                .appendTo(row)
                .find('div')

            @rows.push(connector:connector, percent:percent, bar:bar)

class Chart
    constructor: (parent) ->
        @canvas = $('<canvas class="plot"></canvas>')
            .appendTo(parent)[0]

        @canvas.width = 500
        @canvas.height = 450
        @ctx = @canvas.getContext('2d')

        @paddingLeft = 50
        @paddingRight = 0
        @paddingTop = 20
        @paddingBottom = 50

        requestAnimationFrame(@check)

    check: =>
        if document.body.contains(@canvas)
            if @canvas.width != @canvas.clientWidth or @canvas.height != @canvas.clientHeight
                @canvas.width = @canvas.clientWidth
                @canvas.height = @canvas.clientHeight
                @draw()
            requestAnimationFrame(@check)

    pruneData: (areaLabels, areas) ->
        resultLabels = []
        resultAreas = []
        for i in [0...areaLabels.length]
            max = 0
            for item in areas[i]
                max = Math.max(max, item.rel)

            if max > 1.0/100
                resultLabels.push areaLabels[i]
                resultAreas.push areas[i]

        #return [areaLabels, areas]
        return [resultLabels, resultAreas]

    update: ({areaLabels, @xLabels, data, @type}) ->
        @type ?= 'abs'
        width = @canvas.width
        height = @canvas.height
        ctx = @ctx

        ctx.clearRect(0,0,width,height)

        stacked = []
        for item in data
            values = []
            sum = 1
            for value in item
                values.push(abs:sum, rel:value)
                sum -= value
            stacked.push(values)

        areas = []
        for i in [0...areaLabels.length]
            series = []
            for item in stacked
                series.push(item[i])
            areas.push series

        [@areaLabels, @areas] = @pruneData(areaLabels, areas)

        @count = data.length
        @draw()

    xToPos: (x) ->
        f = x/(@count-1)
        width = @canvas.width - @paddingLeft - @paddingRight
        return @paddingLeft + f*width

    yToPos: (y) ->
        height = @canvas.height - @paddingTop - @paddingBottom
        return @paddingTop + height-y*height

    drawYAxis: ->
        ctx = @ctx

        height = 12
        ctx.fillStyle = 'rgba(255,255,255,0.5)'
        ctx.font = "#{height}px 'Source Sans Pro'"
        ctx.textBaseline = 'middle'
        ctx.textAlign = 'end'

        for i in [0...5]
            percent = (100-(i/4)*100).toFixed(0) + '%'
            y = @yToPos(1-(i/4))
            x = @paddingLeft - 10
            ctx.fillText(percent, x, y)

    drawXAxisMonths: ->
        labels = @xLabels
        currentMonth = null
        days = null
        months = []

        for label, x in labels
            month = label.split('-')[1]
            if month != currentMonth
                if days?
                    months.push(days)
                days = []
                currentMonth = month

            days.push(day:label, x:x)

        if days?
            months.push(days)


        monthNames = [null,'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        ctx = @ctx
        ctx.strokeStyle = 'rgba(0,0,0,0.3)'

        height = 12
        ctx.fillStyle = 'rgba(255,255,255,0.5)'
        ctx.font = "#{height}px 'Source Sans Pro'"
        ctx.textBaseline = 'alphabetic'
        ctx.textAlign = 'center'

        for month in months
            x = month[0].x
            num = parseInt(month[0].day.split('-')[1], 10)
            name = monthNames[num]

            ctx.beginPath()
            ctx.moveTo(@xToPos(x), @yToPos(0))
            ctx.lineTo(@xToPos(x), @yToPos(1))
            ctx.stroke()

            labelX = Math.floor((@xToPos(month[0].x) + @xToPos(month[month.length-1].x))/2)
            labelY = Math.floor(@yToPos(0)) + height + 5
            ctx.fillText(name, labelX, labelY)
    
    drawXAxisYears: ->
        labels = @xLabels
        currentYear = null
        days = null
        years = []

        for label, x in labels
            year = label.split('-')[0]
            if year != currentYear
                if days?
                    years.push(days:days, name:currentYear)
                days = []
                currentYear = year

            days.push(day:label, x:x)

        if days?
            years.push(days:days, name:year)

        ctx = @ctx
        ctx.strokeStyle = 'rgba(0,0,0,0.3)'

        height = 12
        ctx.fillStyle = 'rgba(255,255,255,0.5)'
        ctx.font = "#{height}px 'Source Sans Pro'"
        ctx.textBaseline = 'alphabetic'
        ctx.textAlign = 'center'

        for year in years
            x = year.days[0].x
            name = year.name

            ctx.beginPath()
            ctx.moveTo(@xToPos(x), @yToPos(0))
            ctx.lineTo(@xToPos(x), @yToPos(1))
            ctx.stroke()

            labelX = Math.floor((@xToPos(year.days[0].x) + @xToPos(year.days[year.days.length-1].x))/2)
            labelY = Math.floor(@yToPos(0)) + height + 5
            ctx.fillText(name, labelX, labelY)

    draw: ->
        if not @areas?
            return

        areas = @areas
        ctx = @ctx

        for area, n in areas
            [r,g,b] = colorStops[n%colorStops.length]

            ctx.fillStyle = "rgb(#{r},#{g},#{b})"

            ctx.beginPath()
            ctx.moveTo(@xToPos(0),@yToPos(0))
            ctx.lineTo(@xToPos(0), @yToPos(area[0].abs))
            for x in [1...area.length]
                ctx.lineTo(@xToPos(x), @yToPos(area[x].abs))
            ctx.lineTo(@xToPos(@count-1), @yToPos(0))
            ctx.closePath()
            ctx.fill()
           
        ctx.strokeStyle = "rgba(0,0,0,0.5)"
        for area in areas
            ctx.beginPath()
            ctx.moveTo(@xToPos(0), @yToPos(area[0].abs))
            for x in [1...area.length]
                ctx.lineTo(@xToPos(x), @yToPos(area[x].abs))
            ctx.stroke()

        @drawYAxis()
        @drawXAxisYears()

    getSlice: (f) ->
        if @type == 'abs'
            i = Math.round(f*(@count-1))
            for area in @areas
                {abs: area[i].abs, display: area[i].abs}
        else if @type == 'rel'
            i = Math.round(f*(@count-1))
            for area in @areas
                {abs: area[i].abs, display: area[i].rel}

class Overlay
    constructor: (parent, @chart, @table) ->
        @canvas = $('<canvas class="overlay"></canvas>')
            .appendTo(parent)[0]

        @ctx = @canvas.getContext('2d')

        $(@chart.canvas)
            .hover(@mouseenter, @mouseleave)
            .mousemove(@mousemove)

        requestAnimationFrame(@check)

    check: =>
        if document.body.contains(@canvas)
            if @canvas.width != @canvas.clientWidth or @canvas.height != @canvas.clientHeight
                @canvas.width = @canvas.clientWidth
                @canvas.height = @canvas.clientHeight
                @draw()
            requestAnimationFrame(@check)
    
    mouseenter: =>
        @hover = true

    mouseleave: =>
        @hover = false
        @ctx.clearRect(0, 0, @canvas.width, @canvas.height)

    mousemove: ({originalEvent}) =>
        @draw(originalEvent)

    draw: (event) ->
        ctx = @ctx
        ctx.clearRect(0, 0, @canvas.width, @canvas.height)

        if not @hover
            return

        rect = @canvas.getBoundingClientRect()
        chartRect = @chart.canvas.getBoundingClientRect()

        chartLeft = chartRect.left - rect.left + @chart.paddingLeft
        chartTop = chartRect.top - rect.top + @chart.paddingTop
        chartRight = chartRect.right - rect.left - @chart.paddingRight
        chartBottom = chartRect.bottom - rect.top - @chart.paddingBottom
        width = chartRight - chartLeft
        height = chartBottom - chartTop
        
        x = event.clientX - rect.left
        y = event.clientY - rect.top


        f = (x-chartLeft)/width

        if f >= 0 and f <= 1
            ctx.strokeStyle = 'rgba(0,0,0,0.3)'
            ctx.beginPath()
            ctx.moveTo(x, chartTop)
            ctx.lineTo(x, chartBottom)
            ctx.stroke()

            slice = @chart.getSlice(f)

            for value, n in slice
                [r,g,b] = colorStops[n%colorStops.length]
                color = "rgb(#{r},#{g},#{b})"
                y = chartTop + (1-value.abs)*height
                
                #@table.rows[n].percent.textContent = (value*100).toFixed(1)
                #@table.rows[n].bar.css('width', value*100)
                
                #dots on the line
                ctx.fillStyle = color
                ctx.beginPath()
                ctx.arc(x,y,3,0,Math.PI*2)
                ctx.fill()
                ctx.strokeStyle = "rgba(0,0,0,0.4)"
                ctx.arc(x,y,3,0,Math.PI*2)
                ctx.stroke()
               
                # labels

            @drawLabels(slice, x, chartTop, height)
            @updateTable(f)

    updateTable: (f) ->
        slice = @chart.getSlice(f)
        for value, n in slice
            @table.rows[n].percent.textContent = (value.display*100).toFixed(1)
            @table.rows[n].bar.css('width', value.display*100)


    drawLabels: (slice, x, chartTop, height) ->
        fontSize = 14
        @ctx.font = "#{fontSize}px 'Source Sans Pro'"
        @ctx.textBaseline = 'middle'

        labels = []
        for value, i in slice
            y = chartTop + (1-value.abs)*height
            label = @chart.areaLabels[i] + ' ='
            percent = (value.display*100).toFixed(1) + '%'
            [r,g,b] = colorStops[i%colorStops.length]
            r = Math.round(r*0.75+255*0.25)
            g = Math.round(g*0.75+255*0.25)
            b = Math.round(b*0.75+255*0.25)
            color = "rgb(#{r},#{g},#{b})"
            labelWidth = @ctx.measureText(label).width
            percentWidth = @ctx.measureText(percent).width

            labels.push
                label: label
                labelWidth: labelWidth
                percent: percent
                percentWidth: percentWidth
                width: labelWidth + percentWidth + 5
                color: color
                y: y

        left = []
        right = []
        for label, i in labels
            if i % 2 == 0
                right.push(label)
            else
                left.push(label)

        bevel = Math.round(fontSize/2 + 2)

        @ctx.textAlign = 'left'
        l = Math.round(x+6)
        for item in right
            y = Math.round(item.y)
            t = y - bevel
            b = y + bevel
            r = l + item.width + bevel + 6
            
            @ctx.fillStyle = 'black'
            @ctx.beginPath()
            @ctx.moveTo(l,y)
            @ctx.lineTo(l+bevel, t)
            @ctx.lineTo(r, t)
            @ctx.lineTo(r,b)
            @ctx.lineTo(l+bevel, b)
            @ctx.closePath()
            @ctx.fill()

            @ctx.strokeStyle = 'white'
            @ctx.beginPath()
            @ctx.moveTo(l,y)
            @ctx.lineTo(l+bevel, t)
            @ctx.lineTo(r, t)
            @ctx.lineTo(r,b)
            @ctx.lineTo(l+bevel, b)
            @ctx.closePath()
            @ctx.stroke()
            
            @ctx.fillStyle = item.color
            @ctx.fillText(item.label, l+bevel+1, y)
            
            @ctx.fillStyle = 'white'
            @ctx.fillText(item.percent, l+bevel+1+item.labelWidth + 5, y)
        
        @ctx.textAlign = 'left'
        r = x - 6
        for item in left
            y = Math.round(item.y)
            t = y - bevel
            b = y + bevel
            l = r - item.width - bevel - 6
            
            @ctx.fillStyle = 'black'
            @ctx.beginPath()
            @ctx.moveTo(r,y)
            @ctx.lineTo(r-bevel, b)
            @ctx.lineTo(l, b)
            @ctx.lineTo(l,t)
            @ctx.lineTo(r-bevel, t)
            @ctx.closePath()
            @ctx.fill()

            @ctx.fillStyle = 'white'
            @ctx.beginPath()
            @ctx.moveTo(r,y)
            @ctx.lineTo(r-bevel, b)
            @ctx.lineTo(l, b)
            @ctx.lineTo(l,t)
            @ctx.lineTo(r-bevel, t)
            @ctx.closePath()
            @ctx.stroke()
            
            @ctx.fillStyle = item.color
            @ctx.fillText(item.label, l+5, y)
            
            @ctx.fillStyle = 'white'
            @ctx.fillText(item.percent, l+5+item.labelWidth + 5, y)

exports.index = class StackedPercentage
    constructor: ->
        @elem = $('<div class="stacked-percentage"></div>')
        @chart = new Chart(@elem)
        @table = new Table(@elem)
        @overlay = new Overlay(@elem, @chart, @table)

    update: (params) ->
        @chart.update(params)
        @table.fill(@chart.areaLabels, params)
        @overlay.updateTable(1)
