caleidoscoop = caleidoscoop || {}

class caleidoscoop.Editor
    center: {x: 300, y: 300}

    editorGroup: null                                      # A group for all editor components

    beadGroup: null                                        # A group for all beads.
    allBeads: []                                           # An array for all beads.

    templateGroup: null                                    # A group for the templates from the bead definitions.
    templateBeads: []                                      # An array for all templateBeads.

    # constructor for our editor.
    # Draws all defined beads so we can add them; draws all beads in the caleidoscoop; adds a clear button.
    #
    # @param beadDefinitions  An array with all beadsDefinitions.
    # @param beadGroup An array with all beads drawn in the caleidoscoop.
    constructor: (beadDefinitions) ->
        @editorGroup = drawing.group().attr({id: "editor", display: "none"})
        this._initPlayButton()
        this._initClearButton()
        this._initBorders()

        @templateGroup = drawing.group().attr({id: "templates"})
        @templateGroup.transform("t #{@center.x}, #{@center.y}")
        @editorGroup.add(@templateGroup)

        @beadGroup = drawing.group().attr({id: "beads"})
        @beadGroup.transform("t #{@center.x}, #{@center.y}")
        @editorGroup.add(@beadGroup)

        this._initTemplateBeads(beadDefinitions, @templateBeads)
        this.displayTemplateBeads(@templateGroup)


    # init the template beads while constructing the object.
    #
    # @param beadDefinitions Definitions for the template beads.
    # @return void
    _initTemplateBeads: (beadDefinitions, templateBeads) ->
        for bDef in beadDefinitions
            do (bDef) ->
                templateBeads.push(new TemplateBead(bDef))


    # displays the template area and the template beads.
    #
    # @return void.
    displayTemplateBeads: (templateGroup) ->
        offsetX = 400
        offsetY = -260

        for tBead in @templateBeads
            do (tBead) ->
                offsetY += tBead.display(offsetX, offsetY, templateGroup)


    # addBead adds an use element to the allBeads area, and displays it.
    #
    # @param bead the bead to add.
    # @return void
    addBead: (bead) ->
        @beadGroup.add(bead.getElement())
        @allBeads.push(bead)

    # shows the edit bead icons for a given bead.
    #
    # @param bead
    # @retun void
    # @todo: find a good way for drawing the edit box; while defining forms? creating editable beads?
    enableBeadEdit: (bead) ->
        _drawEditIcons = (editArea, editBox, editBar) ->
            editBoxBB = editBox.getBBox()
            editBarBB = editBar.getBBox()
            barIconsDeltaX = (editBarBB.width) / 4 

            closeIconX = editBoxBB.x + editBoxBB.width - 20
            closeIconY = editBoxBB.y + 17
            closeIcon = drawing.text(closeIconX, closeIconY, "X").attr({ fill: "white"})
            editArea.add(closeIcon)

            deleteIconX = editBarBB.x + 3
            deleteIconY = editBarBB.y + 17
            deleteIcon = drawing.text(deleteIconX, deleteIconY, "D").attr({ fill: "white"})
            editArea.add(deleteIcon)

            rotateIconX = editBarBB.x + barIconsDeltaX + 3
            rotateIconY = editBarBB.y + 17
            rotateIcon = drawing.text(rotateIconX, rotateIconY, "R").attr({ fill: "white"})
            editArea.add(rotateIcon)

            mirrorIconX = editBarBB.x + barIconsDeltaX * 2 + 3
            mirrorIconY = editBarBB.y + 17
            mirrorIcon = drawing.text(mirrorIconX, mirrorIconY, "M").attr({ fill: "white"})
            editArea.add(mirrorIcon)

            colorIconX = editBarBB.x + barIconsDeltaX * 3 + 3
            colorIconY = editBarBB.y + 17
            colorIcon = drawing.text(colorIconX, colorIconY, "C").attr({ fill: "white"})
            editArea.add(colorIcon)


        bbox= bead.getBBox()
        c = drawing.circle(bbox.cx, bbox.cy, bbox.r0)
        bbox = c.getBBox()

        beadTransform = bead.getTransformMatrix()
        beadTransform.a = beadTransform.d = 1
        beadTransform.b = beadTransform.c = 0

        editArea = drawing.group().transform(beadTransform)

        editBox = drawing.rect(bbox.x, bbox.y, bbox.width, bbox.height).attr(stroke: "orange", "stroke-width": "1px", fill: "none")
        editArea.add(editBox)

        # the edit bar
        editBar = drawing.rect(bbox.x, bbox.y + bbox.height, bbox.width, bbox.height / 4).attr(stroke: "orange", "stroke-width": "1px", fill: "none")
        editArea.add(editBar)

        # The edit icons
        _drawEditIcons(editArea, editBox, editBar)

        @beadGroup.add(editArea)


    # Shows the editor
    #
    # @return void
    show: () ->
        @editorGroup.attr({display: "block"})


    # Hides the editor
    #
    # @return void
    hide: () ->
        @editorGroup.attr({display: "none"})

    # init the editors play button
    #
    # @return void
    _initClearButton: () ->
        clearButton = drawing.group().attr({id: "clearbutton", display: "inline"})
        clearButton.add(drawing.rect(610, 500, 50, 30).attr({ fill: "green" , "pointer-events": "all"}))
        clearButton.add(drawing.text(620, 520, "clear").attr({ fill: "white", "pointer-events": "all"}))
        @editorGroup.add(clearButton)

        clearButton.click((evt) =>
            bead.elm.remove() for bead in @allBeads
            @allBeads = []
        )


    # init the editors clear button
    #
    # @return void
    _initPlayButton: () ->
        playButton = drawing.group().attr({id: "playbutton", display: "inline"})
        playButton.add(drawing.rect(610, 550, 50, 30).attr({ fill: "green" , "pointer-events": "all"}))
        playButton.add(drawing.text(620, 570, "play").attr({ fill: "white", "pointer-events": "all"}))
        @editorGroup.add(playButton)

        playButton.click((evt) =>
            this.hide()

            for bead in @allBeads
                do (bead) ->
                    theCaleidoscoop.addBead(new CaleidoscoopBead(bead, bead.getTransform(), bead.getColor()))
            # theCaleidoscoop.addBeadToMasterGroup(bead) for bead in @allBeads
            theCaleidoscoop.makeTransformedGroups()
            theCaleidoscoop.drawChambers()

            @allBeads = []
        )


    # init the editors borders
    #
    # @return void
    _initBorders: () ->
        editArea = drawing.rect(0, 0, @center.x * 2, @center.y *2).attr({stroke: "red", "stroke-width": "1px"})
        @editorGroup.add(editArea)
        editCircle = drawing.circle(@center.x, @center.y, 300).attr({stroke: "blue", "stroke-width": "1px"})
        @editorGroup.add(editCircle)
        editDot = drawing.circle(@center.x, @center.y, 2).attr({fill: "white"})
        @editorGroup.add(editDot)
