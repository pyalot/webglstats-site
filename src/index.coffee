navLists = []
Views = sys.import 'views'
db = sys.import 'views/db'
util = sys.import 'util'
Scroll = sys.import 'scroll'
Location = sys.import 'location'

app = null

class Application
    constructor: ->
        @dbmeta = document.webglstats.meta
        @location = new Location(@)
        @views = new Views(@)
        @updateDate()
        @setupNavigation()
        @navigate(true)

    backendError: ->
        widget = $('<div class="full box"></div>')
            .appendTo('main')

        $('<h1>Data Backend Maintenance</h1>')
            .appendTo(widget)

        $('<p>The data backend is under maintenance, please try later.</p>')
            .appendTo(widget)

    updateDate: ->
        date = document.webglstats.meta.webgl1.lastChunk
        [year, month, day] = date.split('-')
        $('header > span.updated').text('Last update: ' + util.formatDate(year, month, day))

    setupNavigation: ->
        $('.navtoggle').click ->
            $('body').toggleClass('sidebar')

        $('div.overlay').click ->
            $('body').removeClass('sidebar')
        
        @scroll = new Scroll($('nav > div.scroller')[0])
    
    navigate: (pageload=false) ->
        @views.handle(@location, pageload)

load = ->
    app = new Application()

if document.webglstats.domready and document.webglstats.meta?
    document.webglstats.loaded = true
    load()
else
    document.webglstats.load = load
