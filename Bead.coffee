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

# Factory method for creating a bead  with a use element from a bead with a definition element
#
# @param def  The svg def element
# @param transform  The initial transform
# @param color  The initial color.
#
# @return the new bead.
caleidoscoop.Bead.fromDefinition = (def, tString, color) ->
    b = new Bead(def)
    b.use()
    b.setTransform(tString)
    b.setColor(color)

    return b

# Factory method for creating a new bead  with a use element from another bead with a use element.
#
# @param bead  The other bead.
#
# @return the new bead.
caleidoscoop.Bead.fromBead = (bead) ->
    b = new Bead(bead.def)
    b.use()
    b.setTransform(bead.getTransform)
    b.setColor(bead.getColor)

    return b

