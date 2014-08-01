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

        templateGroupOffsetX = 450
        templateGroupOffsetY = -260
        templateGroupTransform = "t #{@center.x + templateGroupOffsetX}, #{@center.y + templateGroupOffsetY}"
        @templateGroup = drawing.group().attr({id: "templates"})
        @templateGroup.transform(templateGroupTransform)
        @editorGroup.add(@templateGroup)

        @beadGroup = drawing.group().attr({id: "beads"})
        @beadGroup.transform("t #{@center.x}, #{@center.y}")

        @editorGroup.add(@beadGroup)

        this._initTemplateBeads(beadDefinitions, @templateBeads)
        # this.displayTemplateBeads(@templateGroup)


    # init the template beads while constructing the object.
    #
    # @param beadDefinitions Definitions for the template beads.
    # @return void
    _initTemplateBeads: (beadDefinitions, templateBeads) ->
        deltaY = 0
        for b in beadDefinitions
            do (b) =>
                _b = theTemplateBeadFactory.copyBead(b, 0, deltaY, this)
                templateBeads.push(_b)
                _b.addTo(@templateGroup)
                deltaY += _b.getBBox().height + 20
        


    # displays the template area and the template beads.
    #
    # @return void.
    displayTemplateBeads: (templateGroup) ->
        for tBead in @templateBeads
            do (tBead) ->
                offsetY += tBead.display(offsetX, offsetY, templateGroup)

        bbox = this.getBBox()
        beadX = offsetX + bbox.x / 2
        group.add(this.setTransform("t #{beadX}, #{offsetY}"))
        bbox.height + 20


    # addBead adds an use element to the allBeads area, and displays it.
    #
    # @param bead the bead to add.
    # @return void
    addBead: (bead) ->
        @beadGroup.add(bead.getElement())
        @allBeads.push(bead)



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
                    bead.elm.remove()
                    bead.disableColorBead(null)

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
