caleidoscoop = caleidoscoop || {}

class editableBead
    bead = null
    pickupHandler = null
    dragHandler = null
    releaseHandler = null


    # Constructor for the editable bead. We create it from a template bead, copy its transformation and assign
    # eventhandlers
    #
    # @param templateBead   The template from which to create this editable bead.
    constructor: (templateBead) ->
        bead = templateBead.bead

        tString = templateBead.bead.transform().string
        matrix = templateBead.bead.transform().localMatrix
        @bead = templateBead.definition.use().transform(tString).attr({fill: "green"})

        # Store the initial transformations
        @bead.startE = matrix.e
        @bead.startF = matrix.f

        this.setPickupHandler()
        this.setDragHandler()
        this.setReleaseHandler()

        @bead.mousemove(@dragHandler)
        @bead.click(@releaseHandler)
        drawing.add(@bead)
        theEditor.addBead(@bead)

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
            coord

        else if(evt.offsetX || evt.offsetX == 0)
            coord.x = evt.offsetX - 300
            coord.y = evt.offsetY - 300
            coord

        else if(evt.layerX || evt.layerX == 0)
            coord.x = evt.layerX - 300
            coord.y = evt.layerY - 300
            coord

    # Eventhandler for clicking on the new bead again.
    #
    # @param evt The click event.
    # @return void
    setPickupHandler: () ->
        self = this
        @pickupHandler = (evt) ->
            matrix = self.bead.transform().localMatrix
            self.bead.startE = matrix.e
            self.bead.startF = matrix.f

            self.bead.unclick(@pickupHandler)
            self.bead.click(@releaseHandler)
            self.bead.mousemove(@dragHandler)


    # Event handler for moving the new bead.
    #
    # @param evt The move event
    setDragHandler: () ->
        self = this
        @dragHandler = (evt) ->
            coord = self.coordXY(evt)

            matrix = self.bead.transform().localMatrix
            matrix.e = coord.x
            matrix.f = coord.y
            self.bead.transform(matrix)

    # Event handler for releasing the bead.
    #
    # @param evt The click event.
    setReleaseHandler: (evt) ->
        self = this

        @releaseHandler = (evt) ->
            self.bead.unclick(self.releaseHandler)
            self.bead.click(self.pickupHandler)
            self.bead.unmousemove(self.dragHandler)
