caleidoscoop = caleidoscoop || {}

class caleidoscoop.Bead
    constructor: (@def, options) ->
        @elm = @def.use()
        @grp = drawing.group()
        @grp.add(@elm)

        @positionX = options.positionX || 0
        @positionY = options.positionY || 0
        @grp.transform("t #{@positionX}, #{@positionY}")

        @tMatrix = options.transform || Snap.matrix()
        @elm.transform(@tMatrix)

        @color = options.color || ""
        @elm.attr({fill: @color})

        @boundEvents = []
        

    setPositionX: (positionX) ->
        @positionX = positionX
        @grp.transform("t #{@positionX}, #{@positionY}")

    setPositionY: (positionY) ->
        @positionY = positionY
        @grp.transform("t #{@positionX}, #{@positionY}")

    setTransform: (tMatrix) ->
        @tMatrix = tMatrix
        @elm.transform(@tMatrix)

    setColor: (color) ->
        @color = color
        @elm.attr({fill: color})


    getBBox: () ->
        @def.getBBox()

    getHexColor: () ->
        Snap.color(@color).hex


    addTo: (grp) ->
        grp.add(@grp)

    remove: () ->
        @grp.remove()


    rotate: (deg) ->
        @tMatrix.add(Snap.matrix().rotate(deg, 0, 0))
        @elm.transform(@tMatrix)

    flipHorizontal: () ->
        @tMatrix = Snap.matrix().scale(-1, 1).add(@tMatrix)
        @elm.transform(@tMatrix)

    bindHandler: (evtName, fn, args) ->
        args = args || Array()

        handler = (evt) =>
            args.unshift(evt)
            fn.apply(this, args)

        Snap[evtName].call(@elm, handler)
        @boundEvents[evtName] = handler

    unBindHandler: (evtName) ->
        Snap["un" + evtName].call(@elm, handler)
        @boundEvents[evtName] = null
