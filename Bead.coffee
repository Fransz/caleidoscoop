caleidoscoop = caleidoscoop || {}

class caleidoscoop.Bead
    def: null                       # The beads defining element.
    elm: null                       # The beads use element.
    tString: ""                     # The beads transformation string
    color: 0                         # The beads color, a hsb value.

    # Construct a Bead from a svg definition element
    #
    # @param def  The svg definition element.
    constructor: (def) ->
        @def = def

    use: () ->
        @elm = @def.use()

    getDefinition: () ->
        @def

    getElement: () ->
        @elm

    getBBox: () ->
        @def.getBBox()

    setTransform: (tString) ->
        @tString = tString
        @elm.transform(tString)

    getTransform: (tString) ->
        @tString

    setColor: (color) ->
        @color = color
        @elm.attr({fill: color})

    getColor: (color) ->
        @color
