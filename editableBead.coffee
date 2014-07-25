caleidoscoop = caleidoscoop || {}

class caleidoscoop.EditableBead extends caleidoscoop.Bead
    pickupHandler = null
    dragHandler = null
    releaseHandler = null

    # Constructor for the editable bead. We create it from a template bead, copy its transformation and assign
    # eventhandlers
    #
    # @param templateBead   The template from which to create this editable bead.
    constructor: (bead, fill) ->
        super(bead.def)
        @use()
        @setColor(fill)

        tString = bead.getTransform()
        this.setTransform(tString)

        matrix = @elm.transform().localMatrix

        # Store the initial transformations
        @startE = matrix.e
        @startF = matrix.f

        this.setPickupHandler()
        this.setDragHandler()
        this.setReleaseHandler()

        if(bead instanceof TemplateBead)
            @elm.mousemove(@dragHandler)
            @elm.click(@releaseHandler)
        if(bead instanceof CaleidoscoopBead)
            @elm.click(@pickupHandler)

        theEditor.addBead(this)

    # Helper function for calculating new coordinates while dragging
    #
    # @param evt  The event.
    # @return object  An object with the new x and y coordinate.
    coordXY: (evt) ->
        containerX = document.getElementById('canvas').offsetLeft
        containerY = document.getElementById('canvas').offsetTop

        coord = { x: null, y: null }
        isTouchSupported = 'ontouchstart' in window

        if(isTouchSupported)
            coord.x = evt.clientX - containerX - 300
            coord.y = evt.clientY - containerY - 300
            return coord

        else if(evt.offsetX || evt.offsetX == 0)
            coord.x = evt.offsetX - 300
            coord.y = evt.offsetY - 300
            return coord

        else if(evt.layerX || evt.layerX == 0)
            coord.x = evt.layerX - 300
            coord.y = evt.layerY - 300
            return coord

    # Eventhandler for clicking on the new bead again.
    #
    # @param evt The click event.
    # @return void
    setPickupHandler: () ->
        self = this
        @pickupHandler = (evt) ->
            matrix = self.elm.transform().localMatrix
            self.startE = matrix.e
            self.startF = matrix.f

            self.elm.unclick(self.pickupHandler)
            self.elm.click(self.releaseHandler)
            self.elm.mousemove(self.dragHandler)


    # Event handler for moving the new bead.
    #
    # @param evt The move event
    setDragHandler: () ->
        self = this
        @dragHandler = (evt) ->
            coord = self.coordXY(evt)

            matrix = self.elm.transform().localMatrix
            matrix.e = coord.x
            matrix.f = coord.y
            self.setTransform(matrix.toTransformString())

    # Event handler for releasing the bead.
    #
    # @param evt The click event.
    setReleaseHandler: (evt) ->
        self = this

        @releaseHandler = (evt) ->
            self.elm.unclick(self.releaseHandler)
            self.elm.click(self.pickupHandler)
            self.elm.unmousemove(self.dragHandler)
