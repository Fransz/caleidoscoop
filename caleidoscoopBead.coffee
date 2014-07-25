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
