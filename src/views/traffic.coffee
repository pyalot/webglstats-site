db = sys.import 'db'
util = sys.import '/util'
behavior = sys.import 'behavior'
{Gauge, Series, Donut, StackedPercentage} = sys.import '/chart'

exports.index = class Traffic
    constructor: (@filter, search) ->
        null

    show: ->
        behavior.deactivate()
        behavior.collapse(@)
      
        ## first row ##
        mainRow = $('<div></div>')
            .addClass('row')
            .addClass('responsive')
            .appendTo('main')
        
        col = $('<div></div>')
            .appendTo(mainRow)
        widget = $('<div class="box"></div>')
            .appendTo(col)
        $('<h1>Visits</h1>')
            .appendTo(widget)
        @series().appendTo(widget)
        
        col = $('<div></div>')
            .appendTo(mainRow)
        widget = $('<div class="box"></div>')
            .appendTo(col)
        $('<h1>Platform (30 days)</h1>')
            .appendTo(widget)
        @donut('useragent.device').appendTo(widget)


        ## second row ##
        mainRow = $('<div></div>')
            .addClass('row')
            .addClass('responsive')
            .appendTo('main')
        
        col = $('<div></div>')
            .appendTo(mainRow)
        
        widget = $('<div class="box"></div>')
            .appendTo(col)
        
        $('<h1>Operating System (30 days)</h1>')
            .appendTo(widget)
        
        @donut('useragent.os').appendTo(widget)

        col = $('<div></div>')
            .appendTo(mainRow)
        
        widget = $('<div class="box"></div>')
            .appendTo(col)
        
        $('<h1>Browser (30 days)</h1>')
            .appendTo(widget)

        @donut('useragent.family').appendTo(widget)

        ## platform time series ##
        full = $('<div class="full box"></div>')
            .appendTo('main')
        
        $('<h1>Platform</h1>')
            .appendTo(full)

        @stackedPercentage('useragent.device').appendTo(full)
        
        ## os time series ##
        full = $('<div class="full box"></div>')
            .appendTo('main')
        
        $('<h1>Operating System</h1>')
            .appendTo(full)

        @stackedPercentage('useragent.os').appendTo(full)
        
        ## browser time series ##
        full = $('<div class="full box"></div>')
            .appendTo('main')
        
        $('<h1>Browser</h1>')
            .appendTo(full)

        @stackedPercentage('useragent.family').appendTo(full)

    donut: (bucketBy) ->
        chart = new Donut()

        @filter.onChange chart.elem, =>
            chart.elem.addClass('spinner')
            query =
                filterBy: {}
                bucketBy: bucketBy
                start: -30

            if @filter.platforms?
                query.filterBy.platform = @filter.platforms

            db.execute
                query: query
                success: (result) ->
                    chart.elem.removeClass('spinner')

                    values = for label, n in result.keys
                        value = result.values[n]
                        {
                            label: (
                                util.capitalize(label.replace(/_/g, ' ')) +
                                " #{((value*100/result.total).toFixed(1))}% (#{util.formatNumber(value)})"
                            )
                            value:result.values[n]
                        }
                        
                    chart.update(values)

        return $(chart.elem)

    series: (name) ->
        chart = new Series()
        @filter.onChange chart.elem, =>
            query =
                filterBy: {}
                series: 'daily'

            if @filter.platforms?
                query.filterBy.platform = @filter.platforms

            db.execute
                query: query
                success: (result) ->
                    chart.update(result.values)

        return chart.elem

    stackedPercentage: (bucketBy) ->
        chart = new StackedPercentage()

        @filter.onChange chart.elem, =>
            query =
                filterBy: {}
                bucketBy: bucketBy
                series: 'daily'

            if @filter.platforms?
                query.filterBy.platform = @filter.platforms

            db.execute
                query: query
                success: (result) ->
                    keys = result.keys
                    xLabels = []
                    data = []
                    
                    if keys[0] == null
                        valueStart = 1
                        keys.shift()
                    else
                        valueStart = 0

                    for item in result.values
                        xLabels.push(item.name)
                        values = []

                        for value in item.values[valueStart...]
                            if item.total == 0
                                values.push(0)
                            else
                                values.push(value/item.total)

                        data.push(values)

                    chart.update
                        areaLabels: keys
                        xLabels: xLabels
                        data: data
                        type: 'rel'

        return $(chart.elem)
