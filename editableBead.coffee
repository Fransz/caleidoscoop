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
        this.setDoubleClickHandler()

        if(bead instanceof TemplateBead)
            @elm.mousemove(@dragHandler)
            @elm.click(@releaseHandler)
        if(bead instanceof CaleidoscoopBead)
            @elm.click(@pickupHandler)
        @elm.dblclick(@doubleClickHandler)

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
        @pickupHandler = (evt) =>
            matrix = @elm.transform().localMatrix
            @startE = matrix.e
            @startF = matrix.f

            @elm.unclick(@pickupHandler)
            @elm.click(@releaseHandler)
            @elm.mousemove(@dragHandler)


    # Event handler for moving the new bead.
    #
    # @param evt The move event
    setDragHandler: () ->
        @dragHandler = (evt) =>
            coord = @coordXY(evt)

            matrix = @elm.transform().localMatrix
            matrix.e = coord.x
            matrix.f = coord.y
            @setTransform(matrix.toTransformString())

    # Event handler for releasing the bead.
    #
    # @param evt The click event.
    setReleaseHandler: (evt) ->
        @releaseHandler = (evt) =>
            @elm.unclick(@releaseHandler)
            @elm.click(@pickupHandler)
            @elm.unmousemove(@dragHandler)


    setDoubleClickHandler: (evt) ->
        @doubleClickHandler = (evt) =>
            this.elm.attr({fill: "orange"})
