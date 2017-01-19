exports.index = class Scroll
    constructor: (@scroller) ->
        @scroller.addEventListener 'touchstart', @onTouch
        @scroller.addEventListener 'touchend', @onTouch
        @scroller.addEventListener 'touchcancel', @onTouch
        @scrollbar = document.createElement('div')
        @style = @scrollbar.style
        @style.position = 'absolute'
        @style.opacity = '0'
        #@style.visibility = 'hidden'
        @style.transform = 'translateY(0px)'
        @style.transition = 'opacity 0.25s'
        @style.top = '0px'
        @style.right = '3px'
        @style.height = '100%'
        @style.backgroundColor = 'rgba(0,0,0,0.5)'
        @style.width = '4px'
        @style.borderRadius = '5px'
        @style.pointerEvents = 'none'

        @scroller.parentElement.appendChild(@scrollbar)
        @paddingTop = getComputedStyle(@scroller.parentElement).paddingTop
        @paddingTop = parseInt(@paddingTop[...@paddingTop.length-2], 10)

        @lastScrollTop = @scroller.scrollTop
        @lastScrolled = performance.now()
        @visible = false
        @touching = false
        @update()

    onTouch: (event) =>
        if event.touches.length > 0
            @touching = true
        else
            @touching = false

    update: =>
        scrollTop = @scroller.scrollTop
        if scrollTop == @lastScrollTop
            if @visible and (not @touching)
                if performance.now() - @lastScrolled > 200
                    @visible = false
                    @style.opacity = '0'
        else
            if not @visible
                @visible = true
                @style.opacity = '1'

            @lastScrolled = performance.now()
            scrollHeight = @scroller.scrollHeight
            height = @scroller.clientHeight
            possibleScroll = scrollHeight-height
            overflow = Math.max(
                Math.max(0, scrollTop) - scrollTop,
                Math.max(0, scrollTop - possibleScroll)
            )*2.2; # aesthetic scale factor

            scale = (height-overflow)/scrollHeight
            scroll = Math.min(1, Math.max(0, scrollTop/possibleScroll))
            offset = (1-scale)*scroll

            scale = scale*(height-6) # padding and to px
            offset = offset*(height-6)+3 # padding and to px

            @style.height = scale.toFixed(1)+'px' # height to preserve rounded top/bottom
            #@style.top = offset.toFixed(1)+'px'
            @style.transform = 'translateY(' + (offset+@paddingTop).toFixed(1) + 'px)'
            @lastScrollTop = scrollTop
        requestAnimationFrame @update
