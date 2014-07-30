caleidoscoop = caleidoscoop || {}

class caleidoscoop.EditableBead extends caleidoscoop.Bead
    pickupHandler = null
    dragHandler = null
    releaseHandler = null

    # Copy Constructor for an editable bead. 
    # We create it from a template bead or a template bead
    #
    # @param templateBead   The template from which to create this editable bead.
    constructor: (bead, editor) ->
        super(bead.def)                     # create a new bead with the beads definition.
        @setColor(bead.getColor())

        @editor = editor

        tString = bead.getTransform()
        this.setTransform(tString)

        matrix = @elm.transform().localMatrix

        # Store the initial transformations
        @startE = matrix.e
        @startF = matrix.f

        this.setPickupHandler()
        this.setDragHandler()
        this.setReleaseHandler()
        this.setEditHandler(@enableBeadEdit)

        if(bead instanceof TemplateBead)
            @elm.mousemove(@dragHandler)
            @elm.click(@releaseHandler)
        if(bead instanceof CaleidoscoopBead)
            @elm.click(@pickupHandler)
        @elm.dblclick(@editHandler)

        @editor.addBead(this)

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


    setEditHandler: (fn) ->
        @editHandler = (evt) =>
            fn.apply(this)


    # shows and set event handlers for the bead icons.
    #
    # @return void
    enableBeadEdit: () ->
        @showBeadEdit()

        # set event handlers for the bead.
        @elm.unclick(@pickupHandler)
        @elm.unmousemove(@dragHandler)

        @elm.undblclick(@editHandler)
        @setEditHandler(@disableBeadEdit)
        @elm.dblclick(@editHandler)


    # hodes and unset event handlers for the bead icons.
    #
    # @return void
    disableBeadEdit: () ->
        @editArea.remove()

        # set event handlers for the bead.
        @elm.click(@pickupHandler)
        @elm.undblclick(@disableBeadEdit)
        @elm.dblclick(@enableBeadEdit)

    # _shows the edit bead icons for a given bead.
    #
    # @param bead
    # @retun void
    # @todo: find a good way for drawing the edit box; while defining forms? creating editable beads?
    showBeadEdit: (bead) ->

        # get a bunding box big enough.
        bbox= @getBBox()
        c = drawing.circle(bbox.cx, bbox.cy, bbox.r0)
        bbox = c.getBBox()
        c.remove()

        beadTransform = @getTransformMatrix()
        beadTransform.a = beadTransform.d = 1
        beadTransform.b = beadTransform.c = 0

        @editArea = drawing.group().transform(beadTransform)

        # the editBox
        editBox = drawing.rect(bbox.x, bbox.y, bbox.width, bbox.height).attr(stroke: "orange", "stroke-width": "1px", fill: "none")
        @editArea.add(editBox)

        # the edit bar
        editBar = drawing.rect(bbox.x, bbox.y + bbox.height, bbox.width, bbox.height / 4).attr(stroke: "orange", "stroke-width": "1px", fill: "none")
        @editArea.add(editBar)

        # The edit icons
        @_drawEditIcons(editBox, editBar)

        @editor.beadGroup.add(@editArea)


    # internal function for showing the icons while enabeling beadEdit
    #
    # @param editBox  the rect around the bead
    # @param editBar  the bar under the bead
    # @return void
    _drawEditIcons: (editBox, editBar) ->
        editBoxBB = editBox.getBBox()
        editBarBB = editBar.getBBox()
        barIconsDeltaX = (editBarBB.width) / 4 

        closeIconX = editBoxBB.x + editBoxBB.width - 20
        closeIconY = editBoxBB.y + 17
        closeIcon = drawing.text(closeIconX, closeIconY, "X").attr({ fill: "white"})
        @editArea.add(closeIcon)

        deleteIconX = editBarBB.x + 3
        deleteIconY = editBarBB.y + 17
        deleteIcon = drawing.text(deleteIconX, deleteIconY, "D").attr({ fill: "white"})
        @editArea.add(deleteIcon)

        rotateIconX = editBarBB.x + barIconsDeltaX + 3
        rotateIconY = editBarBB.y + 17
        rotateIcon = drawing.text(rotateIconX, rotateIconY, "R").attr({ fill: "white"})
        @editArea.add(rotateIcon)

        mirrorIconX = editBarBB.x + barIconsDeltaX * 2 + 3
        mirrorIconY = editBarBB.y + 17
        mirrorIcon = drawing.text(mirrorIconX, mirrorIconY, "M").attr({ fill: "white"})
        @editArea.add(mirrorIcon)

        colorIconX = editBarBB.x + barIconsDeltaX * 3 + 3
        colorIconY = editBarBB.y + 17
        colorIcon = drawing.text(colorIconX, colorIconY, "C").attr({ fill: "white"})
        @editArea.add(colorIcon)


