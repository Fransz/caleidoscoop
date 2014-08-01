caleidoscoop = caleidoscoop || {}

class caleidoscoop.Bead
    def: null                       # The beads defining element.
    elm: null                       # The beads use element.
    tString: ""                     # The beads transformation string
    color: ""                       # The beads color, a string.

    constructor: (@def, options) ->
        @elm = @def.use()

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
