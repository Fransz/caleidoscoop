caleidoscoop = caleidoscoop || {}

class caleidoscoop.CaleidoscoopBead extends caleidoscoop.Bead
    constructor: (bead, tString, hsb) ->
        super(bead.def)
        @use()
        @setColor(hsb)
        @setTransform(tString)
