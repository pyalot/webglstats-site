util = sys.import '/util'

smooth = (size, src) ->
    values = src[..size]
    for i in [size...src.length]
        sum = 0
        for j in [0...size]
            sum += src[i-j]
        sum/=size
        values.push(sum)
    return values

exports.index = class Series
    constructor: ->
        @elem = $('<div class="series"></div>')

    update: (items) ->
        values = for item in items
            if item.total > 0
                item.values[1]/item.total
            else
                0

        #values = smooth(30, values)

        @elem.sparkline values,
            type:'line'
            chartRangeMin:0
            chartRangeMax:1
            spotColor: false
            minSpotColor: false
            maxSpotColor: false
            highlightLineColor: 'rgb(255,70,21)'
            spotRadius: 0
            lineColor: 'rgba(255,255,255,0.5)'
            fillColor: '#348CFF'
            height:300
            width:'100%'
            tooltipFormatter: (sparkline, options, fields) ->
                x = fields.x
                item = items[x]
                if item.total > 0
                    value = (item.values[1]/item.total)*100
                else
                    value = 0
                return "<span>#{item.name} - #{value.toFixed(0)}%<br/>(#{util.formatNumber(item.total)} samples)</span>"
