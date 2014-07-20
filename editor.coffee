caleidoscoop = caleidoscoop || {}

class caleidoscoop.Editor
    center: {x: 300, y: 300}

    editorGroup: null                                                           # A group for all beads.

    templateGroup: null                                                         # A group for the templates from the bead definitions.

    allBeads: []                                                                # An array for all beads.

    # constructor for our editor.
    # Draws all defined beads so we can add them; draws all beads in the caleidoscoop; adds a clear button.
    #
    # @param beadDefinitions  An array with all beadsDefinitions.
    # @param beadGroup An array with all beads drawn in the caleidoscoop.
    constructor: (beadDefinitions, beadsArray) ->
        editArea = drawing.rect(0, 0, @center.x * 2, @center.y *2).attr({stroke: "red", "stroke-width": "1px"})
        editCircle = drawing.circle(@center.x, @center.y, 300).attr({stroke: "blue", "stroke-width": "1px"})
        editDot = drawing.circle(@center.x, @center.y, 2).attr({fill: "white"})
        @editorGroup = drawing.group().attr({id: "editbeads"})

        @templateGroup = drawing.group()

        # Create group with templates to drag and drop from.
        this._addDefinitions(beadDefinitions)

        # clear editor button, with an event handler
        clearEditButton = drawing.group().attr({display: "inline"})
        clearEditButton.add(drawing.rect(610, 500, 50, 30).attr({ id: "clear", fill: "green" , "pointer-events": "all"}))
        clearEditButton.add(drawing.text(620, 520, "clear").attr({ fill: "white", "pointer-events": "all"}))
        clearEditButton.click((evt) =>
            @editorGroup.remove()
            @editorGroup = drawing.group().attr({id: "editbeads"})
        )

        # play button, with an event handler
        playButton = drawing.group().attr({display: "inline"})
        playButton.add(drawing.rect(610, 550, 50, 30).attr({ id: "play", fill: "green" , "pointer-events": "all"}))
        playButton.add(drawing.text(620, 570, "play").attr({ fill: "white", "pointer-events": "all"}))
        playButton.click((evt) =>
            editArea.remove()
            editDot.remove()
            @templateGroup.remove()
            @editorGroup.remove()
            playButton.remove()
            clearEditButton.remove()

            theCaleidoscoop.allBeads = @allBeads
            theCaleidoscoop.addBeadToMasterGroup(bead) for bead in @allBeads
            theCaleidoscoop.makeTransformedGroups()
            theCaleidoscoop.drawChambers()
        )

        @editorGroup.add(bead) for bead in beadsArray
        @editorGroup.transform("t #{@center.x}, #{@center.y}")


    # Adds a use element from all beads definitions to the template group.
    #
    # @param beads The definitions of our beads
    # @return void
    _addDefinitions: (beadDefinitions) ->
        defPanelHeight = @center.y * 2
        defPanelWidth = 100

        # Add all definitons to our panel on the correct coordinates.
        n = 0
        xOffset = @center.x * 2 + 100
        yOffset = 40
        while n < beadDefinitions.length
            [_xOff, _yOff] = this._addDefinition(beadDefinitions[n], xOffset, yOffset)
            yOffset += _yOff + 20
            n += 1


    # Add a use element from a bead definition to the template group
    # A click handler for selecting the bead is added to the use element
    #
    # @param bead the definition element of the bead to add.
    # @param templateGroup The group to add the bead to.
    # @param xOffset Where on our paper to put the definition.
    # @param yOffset Where on our paper to put the definition.
    #
    # @return A tuple with the x- and yOffset of the added use element.
    _addDefinition: (beadDefinition, xOffset, yOffset) ->
            bbox = beadDefinition.getBBox()
            _xOff = xOffset + bbox.width / 2
            _yOff = bbox.height
            transformString = "t #{_xOff}, #{yOffset}"

            templateElement = beadDefinition.use()
            @templateGroup.add(templateElement.transform(transformString).attr({fill: "red"}))

            self = this

            # The clickhandler for the beads in the panel.
            clickHandler = (evt) ->
                
                # Helper function for calculating new coordinates while dragging
                #
                # @param evt  The event.
                # @return object  An object with the new x and y coordinate.
                coordXY = (evt) ->
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

                # create another use element, with the same transformation as the bead in the panel.
                newElement = beadDefinition.use().transform(transformString).attr({fill: "green"})
                drawing.add(newElement)
                # self.editorGroup.add(newElement)

                # Store the initial transformation
                matrix = newElement.transform().localMatrix
                newElement.startE = matrix.e
                newElement.startF = matrix.f

                # Eventhandler for clicking on the new bead again.
                #
                # @param evt The click event.
                # @param x
                # @param y
                pickupHandler = (evt) ->
                    matrix = newElement.transform().localMatrix
                    newElement.startE = matrix.e
                    newElement.startF = matrix.f
                    newElement.mousemove(moveHandler)
                    newElement.unclick(pickupHandler)
                    newElement.click(releaseHandler)

                # Event handler for moving the new bead.
                #
                # @param evt The move event
                # @param dx
                # @param dy
                moveHandler = (evt) ->

                    coord = coordXY(evt)

                    matrix = newElement.transform().localMatrix
                    matrix.e = coord.x
                    matrix.f = coord.y
                    newElement.transform(matrix)

                # Event handler for releasing the new bead.
                # Here we reassign eventhandlers on the new bead.
                #
                # @param evt The click event.
                # XXX We dont need to push or add the bead again after picking up again.
                releaseHandler = (evt) ->
                    newBead = beadDefinition.use().attr({fill: "green"})
                    initialTransform = newElement.transform().localMatrix
                    initialTransform.e -= 300
                    initialTransform.f -= 300
                    newBead.transform(initialTransform)
                    self.editorGroup.add(newBead)
                    self.allBeads.push(newBead)

                    newElement.unmousemove(moveHandler)
                    newElement.unclick(releaseHandler)
                    newElement.click(pickupHandler)
                
                # Assign event handlers.
                newElement.mousemove(moveHandler)
                newElement.unclick(clickHandler)
                newElement.click(releaseHandler)


            templateElement.click(clickHandler)

            [_xOff, _yOff]

