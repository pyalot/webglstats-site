normalize = (labels, values) ->

    total = 0
    for value in values
        total += value

    newValues = []
    cum = 1
    for value, i in values
        label = labels[i]
        abs = value/total
        newValues.push(abs:abs, cum:cum)
        cum -= abs

    values = newValues
    newValues = []
    newLabels = []
    for value, i in values
        label = labels[i]
        if value.abs > 0.0001
            newValues.push(value)
            newLabels.push(label)

    return [newLabels, newValues]

exports.index = class Bar
    constructor: ->
        @elem = @table = $('<table class="data-table"></table>')

        $('<thead><tr><td>Value</td><td colspan="2">Abs.</td><td colspan="2">Cum.</td></thead>')
            .appendTo(@table)

        @tbody = $('<tbody></tbody>')
            .appendTo(@table)

    update: (labels, values) ->
        [labels,values] = normalize(labels, values)

        @tbody.remove()
        @tbody = $('<tbody></tbody>')
            .appendTo(@table)

        @rows = []

        for value, i in values
            label = labels[i]
            
            row = $('<tr></tr>')
                .appendTo(@tbody)
            
            $('<td></td>')
                .text(label)
                .appendTo(row)

            $('<td class="percent"></td>')
                .text((value.abs*100).toFixed(1) + '%')
                .appendTo(row)

            $('<td class="bar"><div></div></td>')
                .appendTo(row)
                .find('div')
                .css('width', value.abs*100)
            
            $('<td class="percent"></td>')
                .text((value.cum*100).toFixed(1) + '%')
                .appendTo(row)
            
            $('<td class="bar"><div></div></td>')
                .appendTo(row)
                .find('div')
                .css('width', value.cum*100)
