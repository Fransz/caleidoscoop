caleidoscoop = caleidoscoop || {}

class caleidoscoop.Editor
    center: {x: 300, y: 300}
    templateGroupPosition: {x: 450, y: -260}

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

        templateGroupTransform = "t #{@center.x + @templateGroupPosition.x}, #{@center.y + @templateGroupPosition.y}"
        @templateGroup = drawing.group().attr({id: "templates"})
        @templateGroup.transform(templateGroupTransform)
        @editorGroup.add(@templateGroup)

        @beadGroup = drawing.group().attr({id: "beads"})
        @beadGroup.transform("t #{@center.x}, #{@center.y}")
        @editorGroup.add(@beadGroup)

        @colorPicker = new BeadsColorPicker

        this._initTemplateBeads(beadDefinitions, @templateBeads)



    # init the template beads while constructing the object.
    #
    # @param beadDefinitions Definitions for the template beads.
    # @return void
    _initTemplateBeads: (beadDefinitions, templateBeads) ->
        deltaY = 0
        for b in beadDefinitions
            do (b) =>
                _b = theTemplateBeadFactory.copyBead(b, 0, deltaY, this)
                # @todo: this should go to editor.
                templateBeads.push(_b)
                _b.addTo(@templateGroup)
                deltaY += _b.getBBox().height + 20
        

    enableAllBeads: () ->
        for b in @allBeads
            do (b) =>
                b.bindHandler('dblclick', b.editBead)
                b.bindHandler('click', b.pickupBead)
        for b in @templateBeads
            do (b) =>
                b.bindHandler('click', b.copyBead)

    disableAllBeads: () ->
        for b in @allBeads
            do (b) ->
                b.unBindHandler('dblclick')
                b.unBindHandler('click')
        for b in @templateBeads
            do (b) ->
                b.unBindHandler('dblclick')
                b.unBindHandler('click')


    # addBead adds an use element to the allBeads area, and displays it.
    #
    # @param bead the bead to add.
    # @return void
    addBead: (bead) ->
        bead.addTo(@beadGroup)
        @allBeads.push(bead)


    removeBead: (bead) ->
        bead.remove()
        @allBeads.splice(_.indexOf(@allBeads, bead), 1)


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
        @colorPicker.disable()

    # init the editors play button
    #
    # @return void
    _initClearButton: () ->
        clearButton = drawing.group().attr({id: "clearbutton", display: "inline"})
        clearButton.add(drawing.rect(610, 500, 50, 30).attr({ fill: "green" , "pointer-events": "all"}))
        clearButton.add(drawing.text(620, 520, "clear").attr({ fill: "white", "pointer-events": "all"}))
        @editorGroup.add(clearButton)

        clearButton.click((evt) =>
            bead.remove() for bead in @allBeads
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
            for bead in @allBeads
                do (bead) ->
                    theCaleidoscoop.addBead(
                        theCaleidoscoopBeadFactory.copyBeadFromEditorBead(bead)
                    )
                    bead.remove()

            theCaleidoscoop.makeTransformedGroups()
            theCaleidoscoop.drawChambers()

            @allBeads = []
            this.hide()
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
