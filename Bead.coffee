caleidoscoop = caleidoscoop || {}

class caleidoscoop.Bead
    constructor: (@def, options) ->
        @elm = @def.use()
        @grp = drawing.group()
        @grp.add(@elm)

        @positionX = options.positionX || 0
        @positionY = options.positionY || 0
        @grp.transform("t #{@positionX}, #{@positionY}")

        @tString = options.transform || ""
        @elm.attr({transform: @tString})

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

    setTransform: (tString) ->
        @tString = tString
        @elm.transform(tString)

    getTransform: () ->
        @tString

    getTransformMatrix: () ->
        @elm.transform().localMatrix

    setColor: (color) ->
        @color = color
        @elm.attr({fill: color})

    getColor: () ->
        @color

    getHexColor: () ->
        Snap.color(@color).hex

    rotate: (deg) ->
        m = @getTransformMatrix().add(Snap.matrix().rotate(deg, 0, 0))
        @tString = m.toTransformString()
        @elm.transform(@tString)

    # @TODO: the scale has to be after the rotate transformations of the bead.
    flipHorizontal: () ->
        m = @getTransformMatrix()
        m.add(Snap.matrix().scale(-1, 1))
        @tString = m.toTransformString()
        @elm.transform(@tString)
