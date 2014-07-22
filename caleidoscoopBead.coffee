caleidoscoop = caleidoscoop || {}

class caleidoscoop.CaleidoscoopBead
    bead = null
    hsb = null

    # Constructor for a caleidoscoop bead.
    # We create the caleidoscoop bead from a definition.
    constructor: (beadDefinition, hsb, transform) ->
        @definition = beadDefinition
        @bead = beadDefinition.use().attr(fill: hsb, transform: transform)
        @hsb = hsb



    # displays the teplateBead in the given grouo, on the given coordinates.
    #
    # @param offsetX
    # @param offsetY
    # @param group  the group to add to.
    # @return int deltaY
    display: (offsetX, offsetY, group) ->
        bbox = @bead.getBBox()
        beadX = offsetX + bbox.x / 2
        group.add(@bead.transform("t #{beadX}, #{offsetY}"))
        bbox.height + 20
