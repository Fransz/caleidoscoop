caleidoscoop = caleidoscoop || {}

class caleidoscoop.Bead
    constructor: (@def, options) ->
        @elm = @def.use()
        @grp = drawing.group()
        @grp.add(@elm)

        @positionX = options.positionX || 0
        @positionY = options.positionY || 0
        @grp.transform("t #{@positionX}, #{@positionY}")

        # @tString = options.transform || ""
        # @elm.attr({transform: @tString})
        @tMatrix = options.transform || Snap.matrix()
        @elm.transform(@tMatrix)

        @color = options.color || ""
        @elm.attr({fill: @color})
        

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

    addTo: (grp) ->
        grp.add(@grp)

    getHexColor: () ->
        Snap.color(@color).hex

    remove: () ->
        @grp.remove()

    rotate: (deg) ->
        @tMatrix.add(Snap.matrix().rotate(deg, 0, 0))
        @elm.transform(@tMatrix)

    flipHorizontal: () ->
        @tMatrix = Snap.matrix().scale(-1, 1).add(@tMatrix)
        @elm.transform(@tMatrix)
