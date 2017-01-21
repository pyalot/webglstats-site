exports.index = (items) ->
    items = items[...]
    items.unshift ['Home', '/']

    ol = $('<ol class="breadcrumbs"></ol>')
        .attr('vocab', 'http://schema.org/')
        .attr('typeof', 'BreadcrumbList')
        .appendTo('main')

    itemList = []
    structuredData =
        '@context': 'http://schema.org',
        '@type': 'BreadcrumbList',
        itemListElement: itemList

    i = 1
    for item in items
        li = $('<li></li>')
            .appendTo(ol)

        if typeof(item) == 'string'
            li.text(item)
        else
            $('<a></a>')
                .attr('href', item[1])
                .text(item[0])
                .appendTo(li)

            itemList.push
                '@type': 'ListItem'
                position: i
                item:
                    '@id': "//webglstats.com#{item[1]}"
                    name: item[0]

            i += 1

    $('<script type="application/ld+json"></script>')
        .text(JSON.stringify(structuredData))
        .appendTo('main')
