caleidoscoop = caleidoscoop || {}

class caleidoscoop.EditableBead extends caleidoscoop.Bead
    constructor: (defElement, options) ->
        super(defElement, options)

        @editor = options.editor || null


    # Eventhandler for clicking on the new bead again.
    #
    # @param evt The click event.
    # @return void
    # setPickupHandler: (fn) ->
        # @pickupHandler = (evt) =>
            # fn.apply(this)


    # Event handler for moving the new bead.
    #
    # @param evt The move event
    # setDragHandler: (fn) ->
        # @dragHandler = (evt) =>
            # fn.call(this, evt)

    # Event handler for releasing the bead.
    #
    # @param evt The click event.
    # setReleaseHandler: (fn) ->
        # @releaseHandler = (evt) =>
            # fn.apply(this)


    # setEditHandler: (fn) ->
        # @editHandler = (evt) =>
            # fn.apply(this)


    # setDeleteHandler: (fn) ->
        # @deleteHandler = (evt) =>
            # fn.apply(this)


    # setRotateHandler: (fn) ->
        # @rotateHandler = (evt) =>
            # fn.apply(this)


    # setMirrorHandler: (fn) ->
        # @mirrorHandler = (evt) =>
            # fn.apply(this)


    # setColorHandler: (fn, arg) ->
        # @colorHandler = (evt) =>
            # fn.call(this, arg)

    # setColorPickerCancelHandler: (fn) ->
        # @colorPickerCancelHandler = (evt) =>
            # fn.apply(this)


    # setColorPickerOkHandler: (fn) ->
        # @colorPickerOkHandler = (evt) =>
            # fn.apply(this)


    # picksup the bead
    #
    # @return void
    pickupBead: (evt) ->
        @unBindHandler('dblclick')
        @unBindHandler('click')
        @bindHandler('click', @releaseBead)
        @bindHandler('mousemove', @dragBead)


    # drags the bead
    #
    # @param evt the move event
    # @return void
    dragBead: (evt) ->
        coord = @_coordHelper(evt)

        @positionX = coord.x
        @positionY = coord.y
        @grp.transform("t #{@positionX}, #{@positionY}")


    # releases the bead
    #
    # @return void
    releaseBead: (evt) ->
        @unBindHandler('click')
        @unBindHandler('mousemove')
        @bindHandler('click', @pickupBead)
        @bindHandler('dblclick', @editBead)


    # Helper function for calculating new coordinates while dragging
    #
    # @param evt  The event.
    # @return object  An object with the new x and y coordinate.
    _coordHelper: (evt) ->
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



    # shows and set event handlers for the bead icons.
    #
    # @return void
    editBead: () ->
        @showBeadEdit()

        for b in @editor.allBeads
            do (b) ->
                b.unBindHandler('dblclick')
                b.unBindHandler('click')
        for b in @editor.templateBeads
            do (b) ->
                b.unBindHandler('dblclick')
                b.unBindHandler('click')

        @unBindHandler('click')
        @unBindHandler('mousemove')

        @unBindHandler('dblclick')
        @bindHandler('dblclick', @disableEditBead)


    # hodes and unset event handlers for the bead icons.
    #
    # @return void
    disableEditBead: () ->
        @editArea.remove()

        for b in @editor.allBeads
            do (b) =>
                b.bindHandler('dblclick', b.editBead)
                b.bindHandler('click', b.pickupBead)
        for b in @editor.templateBeads
            do (b) =>
                b.bindHandler('click', b.copyBead)

        @unBindHandler('click')
        @bindHandler('click', @pickupBead)

        @unBindHandler('dblclick')
        @bindHandler('dblclick', @editBead)


    # _shows the edit bead icons for a given bead.
    #
    # @param bead
    # @retun void
    # @todo: find a good way for drawing the edit box; while defining forms? creating editable beads?
    showBeadEdit: (bead) ->
        # get a bounding box big enough.
        bbox= @getBBox()
        c = drawing.circle(bbox.cx, bbox.cy, bbox.r0)
        bbox = c.getBBox()
        c.remove()

        # @todo: We have no more translations on the beads element.
        @editArea = drawing.group()
        @grp.add(@editArea)

        editBox = drawing.rect(bbox.x, bbox.y, bbox.width, bbox.height).attr(stroke: "orange", "stroke-width": "1px", fill: "none")
        @editArea.add(editBox)

        editBar = drawing.rect(bbox.x, bbox.y + bbox.height, bbox.width, bbox.height / 4).attr(stroke: "orange", "stroke-width": "1px", fill: "none")
        @editArea.add(editBar)

        @_drawEditIcons(editBar)


    # internal function for showing the icons while enabeling beadEdit
    #
    # @param editBox  the rect around the bead
    # @param editBar  the bar under the bead
    # @return void
    _drawEditIcons: (editBar) ->
        editBarBB = editBar.getBBox()
        barIconsDeltaX = (editBarBB.width) / 4

        deleteIconX = editBarBB.x + 3
        deleteIconY = editBarBB.y + 17
        deleteIcon = drawing.text(deleteIconX, deleteIconY, "D").attr({id: "deleteIcon",  fill: "white"})
        @bindHandler('click', @deleteBead, [], deleteIcon)
        @editArea.add(deleteIcon)

        rotateIconX = editBarBB.x + barIconsDeltaX + 3
        rotateIconY = editBarBB.y + 17
        rotateIcon = drawing.text(rotateIconX, rotateIconY, "R").attr({id: "rotateIcon",  fill: "white"})
        @bindHandler('click', @rotateBead, [], rotateIcon)
        @editArea.add(rotateIcon)

        mirrorIconX = editBarBB.x + barIconsDeltaX * 2 + 3
        mirrorIconY = editBarBB.y + 17
        mirrorIcon = drawing.text(mirrorIconX, mirrorIconY, "M").attr({id: "mirrorIcon",  fill: "white"})
        @bindHandler('click', @mirrorBead, [], mirrorIcon)
        @editArea.add(mirrorIcon)

        colorIconX = editBarBB.x + barIconsDeltaX * 3 + 3
        colorIconY = editBarBB.y + 17
        colorIcon = drawing.text(colorIconX, colorIconY, "C").attr({id: "colorIcon",  fill: "white"})
        @bindHandler('click', @colorBead, [colorIcon], colorIcon)
        @editArea.add(colorIcon)



    # Event handler for the delete icon
    #
    # @return void
    deleteBead: () ->
        @disableEditBead()
        @editor.removeBead(this)

    # Event handler for the rotate icon
    #
    # @return void
    rotateBead: () ->
        @rotate(30)


    # Event handler for the mirror icon
    #
    # @return void
    mirrorBead: () ->
        @flipHorizontal()


    # Event handler for the color icon
    #
    # @return void
    colorBead: (evt, colorIcon) ->
        @editor.colorPicker.enable(this, colorIcon)

        colorIcon.unclick(@colorHandler)
