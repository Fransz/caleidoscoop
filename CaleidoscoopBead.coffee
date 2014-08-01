caleidoscoop = caleidoscoop || {}

class caleidoscoop.CaleidoscoopBead extends caleidoscoop.Bead
    constructor: (bead, tString, hsb) ->
        super(bead.def)
        @setColor(hsb)
        @setTransform(tString)
