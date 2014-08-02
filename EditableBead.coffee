caleidoscoop = caleidoscoop || {}

class caleidoscoop.EditableBead extends caleidoscoop.Bead
    pickupHandler = null
    dragHandler = null
    releaseHandler = null

    # Copy Constructor for an editable bead. 
    # We create it from a template bead or a template bead
    #
    # @param templateBead   The template from which to create this editable bead.
    constructor: (defElement, options) ->
        super(defElement, options)
        @editor = options.editor || null


    # Eventhandler for clicking on the new bead again.
    #
    # @param evt The click event.
    # @return void
    setPickupHandler: (fn) ->
        @pickupHandler = (evt) =>
            fn.apply(this)


    # Event handler for moving the new bead.
    #
    # @param evt The move event
    setDragHandler: (fn) ->
        @dragHandler = (evt) =>
            fn.call(this, evt)

    # Event handler for releasing the bead.
    #
    # @param evt The click event.
    setReleaseHandler: (fn) ->
        @releaseHandler = (evt) =>
            fn.apply(this)


    setEditHandler: (fn) ->
        @editHandler = (evt) =>
            fn.apply(this)


    setDeleteHandler: (fn) ->
        @deleteHandler = (evt) =>
            fn.apply(this)


    setRotateHandler: (fn) ->
        @rotateHandler = (evt) =>
            fn.apply(this)


    setMirrorHandler: (fn) ->
        @mirrorHandler = (evt) =>
            fn.apply(this)


    setColorHandler: (fn, arg) ->
        @colorHandler = (evt) =>
            fn.call(this, arg)

    setColorPickerCancelHandler: (fn) ->
        @colorPickerCancelHandler = (evt) =>
            fn.apply(this)


    setColorPickerOkHandler: (fn) ->
        @colorPickerOkHandler = (evt) =>
            fn.apply(this)


    # picksup the bead
    #
    # @return void
    pickupBead: () ->
        @elm.unclick(@pickupHandler)
        @elm.click(@releaseHandler)
        @elm.mousemove(@dragHandler)


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
    releaseBead: () =>
        @elm.unclick(@releaseHandler)
        @elm.click(@pickupHandler)
        @elm.unmousemove(@dragHandler)


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

        # set event handlers for the bead.
        @elm.unclick(@pickupHandler)
        @elm.unmousemove(@dragHandler)

        for b in @editor.allBeads
            do (b) =>
                b.elm.undblclick(b.editHandler)

        @setEditHandler(@disableEditBead)
        @elm.dblclick(@editHandler)


    # hodes and unset event handlers for the bead icons.
    #
    # @return void
    disableEditBead: () ->
        @editArea.remove()

        @elm.click(@pickupHandler)

        for b in @editor.allBeads
            do (b) =>
                b.elm.dblclick(b.editHandler)

        @setEditHandler(@editBead)
        @elm.dblclick(@editHandler)

        @disableColorBead(null)


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
        @setDeleteHandler(@deleteBead)
        deleteIcon.click(@deleteHandler)
        @editArea.add(deleteIcon)

        rotateIconX = editBarBB.x + barIconsDeltaX + 3
        rotateIconY = editBarBB.y + 17
        rotateIcon = drawing.text(rotateIconX, rotateIconY, "R").attr({id: "rotateIcon",  fill: "white"})
        @setRotateHandler(@rotateBead)
        rotateIcon.click(@rotateHandler)
        @editArea.add(rotateIcon)

        mirrorIconX = editBarBB.x + barIconsDeltaX * 2 + 3
        mirrorIconY = editBarBB.y + 17
        mirrorIcon = drawing.text(mirrorIconX, mirrorIconY, "M").attr({id: "mirrorIcon",  fill: "white"})
        @setMirrorHandler(@mirrorBead)
        mirrorIcon.click(@mirrorHandler)
        @editArea.add(mirrorIcon)

        colorIconX = editBarBB.x + barIconsDeltaX * 3 + 3
        colorIconY = editBarBB.y + 17
        colorIcon = drawing.text(colorIconX, colorIconY, "C").attr({id: "colorIcon",  fill: "white"})
        @setColorHandler(@colorBead, colorIcon)
        colorIcon.click(@colorHandler)
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
    colorBead: (colorIcon) ->
        cp = document.getElementById('colorpicker')
        slider = document.getElementById('slider')
        picker = document.getElementById('picker')
        preview = document.getElementById('preview')
        ok = document.getElementById('ok')
        cancel = document.getElementById('cancel')

        cp.style.display = 'block'

        c = new ColorPicker(slider, picker,
                (hex, hsv, rgb) ->
                    preview.style.backgroundColor = hex
                    this.newColor = hex
            )
        @setColorPickerOkHandler((evt) ->
            @setColor(c.newColor)
            @disableColorBead()
            colorIcon.click(@colorHandler)
        )
        @setColorPickerCancelHandler((evt) ->
            @setColor(c.originalColor)
            @disableColorBead()
            colorIcon.click(@colorHandler)
        )

        _addEventListener = (element, event, listener) ->
            if (element.attachEvent)
                element.attachEvent('on' + event, listener)
            else if (element.addEventListener)
                element.addEventListener(event, listener, false)

        _addEventListener(ok, 'click', @colorPickerOkHandler)
        _addEventListener(cancel, 'click', @colorPickerCancelHandler)

        c.originalColor = @getHexColor()
        c.setHex(@getHexColor())

        colorIcon.unclick(@colorHandler)


    # Event handler for the disabling the colorpicker
    #
    # @return void
    disableColorBead: (evt) ->
        cp = document.getElementById('colorpicker')
        slider = document.getElementById('slider')
        picker = document.getElementById('picker')
        ok = document.getElementById('ok')
        cancel = document.getElementById('cancel')

        for n in slider.childNodes
            do (n) =>
                n && slider.removeChild(n)
        for n in picker.childNodes
            do (n) =>
                n && picker.removeChild(n)

        # @Todo how to correct remove the event,
        ok.removeEventListener('click', @colorPickerOkHandler, false)
        cancel.removeEventListener('click', @colorPickerCancelHandler, false)
        ok.onclick = null
        cancel.onclick = null
        @setColorPickerCancelHandler((evt) -> )
        @setColorPickerOkHandler((evt) -> )

        cp.style.display = 'none'


