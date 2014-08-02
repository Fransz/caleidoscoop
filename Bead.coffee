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
        

    getDefinition: () ->
        @def

    getElement: () ->
        @elm

    getBBox: () ->
        @def.getBBox()

    getGrp: () ->
        @grp

    addTo: (grp) ->
        grp.add(@grp)

    setColor: (color) ->
        @color = color
        @elm.attr({fill: color})

    getColor: () ->
        @color

    getHexColor: () ->
        Snap.color(@color).hex

    remove: () ->
        @grp.remove()

    rotate: (deg) ->
        @tMatrix.add(Snap.matrix().rotate(deg, 0, 0))
        @elm.transform(@tMatrix)

    # @TODO: the scale has to be after the rotate transformations of the bead.
    flipHorizontal: () ->
        @tMatrix = Snap.matrix().scale(-1, 1).add(@tMatrix)
        # @tMatrix = @tMatrix.add(Snap.matrix().scale(-1, 1))
        @elm.transform(@tMatrix)
