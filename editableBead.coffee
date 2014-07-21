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
            coord.x = evt.clientX - containerX
            coord.y = evt.clientY - containerY
            coord

        else if(evt.offsetX || evt.offsetX == 0)
            coord.x = evt.offsetX
            coord.y = evt.offsetY
            coord

        else if(evt.layerX || evt.layerX == 0)
            coord.x = evt.layerX
            coord.y = evt.layerY
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
            newBead = beadDefinition.use().attr({fill: "green"})
            initialTransform = newElement.transform().localMatrix
            initialTransform.e -= 300
            initialTransform.f -= 300
            newBead.transform(initialTransform)
            self.editorGroup.add(newBead)
            self.allBeads.push(newBead)

            self.bead.unclick(@releaseHandler)
            self.bead.click(@pickupHandler)
            self.bead.mouseunmove(@dragHandler)
