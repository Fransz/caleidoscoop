drawing = Snap("#drawing")

# Form definitions.
circleForm = drawing.circle(0, 0, 30)
circleForm.toDefs()

triangleForm = drawing.polyline([[0, -30], [30, 30], [-30, 30]])
triangleForm.toDefs()

squareForm = drawing.rect(-30, -30, 60, 60)
squareForm.toDefs()

diamondForm = drawing.polyline([[-30,0], [-20, -20], [20, -20], [30, 0], [0, 40]])
diamondForm.toDefs()

starForm = drawing.group()
starForm.toDefs()
starForm.add(drawing.polyline([[0, -30], [30, 16], [-30, 16]]))
starForm.add(drawing.polyline([[0, 30], [30, -16], [-30, -16]]))

wingForm = drawing.group()
wingForm.toDefs()
wingForm.add(drawing.ellipse(0, 0, 16, 30))
wingForm.add(drawing.ellipse(0, 0, 30, 16))


# clipping cone.
coneRadius = 300
coneAngle = Math.PI / 3
coneStart = { x: coneRadius, y: 0 }
coneEnd = { x: coneRadius * Math.cos(coneAngle), y: coneRadius * Math.sin(coneAngle) }
coneString = "M 0 0 L #{coneEnd.x} #{coneEnd.y} A #{coneRadius} #{coneRadius} 0 0 0 #{coneStart.x} #{coneStart.y}"
theCone = drawing.path(coneString).attr({id: "cone"})
theCone.toDefs()

# background rectangle.
theRect = drawing.rect(0, 0, 600, 600).attr({fill: "black", "pointer-events": "all"})


# edit button
editButton = drawing.group().attr({display: "inline"})
editButton.add(drawing.rect(560, 570, 40, 30).attr({ id: "edit", fill: "green" , "pointer-events": "all"}))
editButton.add(drawing.text(570, 590, "edit").attr({ fill: "white", "pointer-events": "all"}))

editHandler = (evt) ->
    caleidoscoop.stopAnimation()
    caleidoscoop.clear()

    editor = new Editor(caleidoscoop.beadDefinitions, caleidoscoop.beadsGroup)

editButton.click(editHandler)



class Caleidoscoop
    center: {x: 300, y: 300}

    beadDefinitions: []                                         # all known beads

    transformations: []                                         # all transformations, from the given mirrors.

    beadsGroup: drawing.group().attr({id: "beads"}).toDefs()    # all beads drawn in chamber 0.

    transformedGroups: []                                       # group of beads in chamber 0 transformed, animated.

    chambers: []                                                # group of transformed beads, clipped.



    clipCone: null


    constructor: (beads, mirrors, clipCone) ->
        @clipCone = clipCone

        @beadDefinitions.push(b) for b in beads

        # @TODO make all transformations from all mirrors
        m = (this.makeMirror k for k in mirrors)
        @transformations = [
            new Snap.Matrix(1, 0, 0, 1, 0, 0).toTransformString(),
            m[0].clone().toTransformString(),
            m[0].clone().add(m[1]).toTransformString(),
            m[0].clone().add(m[1]).add(m[2]).toTransformString(),
            m[0].clone().add(m[1]).add(m[2]).add(m[0]).toTransformString(),
            m[0].clone().add(m[1]).add(m[2]).add(m[0]).add(m[1]).toTransformString()
        ]

        this.addBead(bead, @beadsGroup) for bead in @beadDefinitions

        @transformedGroups = (@beadsGroup.use().transform(t) for t in @transformations)

        this.drawChamber(@transformedGroups[n], @transformations[n]) for n in  [0...6]



    # Function for making mirrors under an angle.
    # @see http://math.stackexchange.com/questions/525082/reflection-across-a-line
    #
    # @param a  angle of the mirror with x-axis.
    # @return   Snap.Matrix
    makeMirror: (a) ->

        mirror = (k) ->
            f = 1 / (k * k + 1)
            new Snap.Matrix(f * (1 - k * k),  f * 2 * k,  f * 2 * k,  f * (k * k - 1),  0,  0)
            
        t = new Snap.Matrix()
        t.add(mirror(Math.tan(a)))



    # Add a beads to the beadsGroup.
    # The beads are added on a random point, and with a random rotation
    # The beads are added four times, around our center point
    # 
    # @param beadDefinition     definition of the bead to add.
    # @param group              group to add to.
    # @return                   void
    addBead: (beadDefinition, group) ->
        rotation = "r" + Math.round(360 * Math.random()) + ",0,0"

        centers = []
        centers.push { x: Math.round(x * Math.random() * @center.x), y: Math.round(y * Math.random() * @center.y) } for y in [-1, 1] for x in [-1, 1]

        bbox = beadDefinition.getBBox()
        translatex = (x) -> x - bbox.x
        translatey = (y) -> y - bbox.y
        transforms = ("t#{translatex(c.x)},#{translatey(c.y)}" + rotation for c in centers)

        hsb = "hsb(".concat(Math.random(), ",.75", ", .75)")

        group.add(beadDefinition.use().attr(fill: hsb, transform: t)) for t in transforms



    # Draws a bead group with a clipping cone, animates the beadsgroup.
    # The chamber itself (i.e. beadsbroup + clippingCone) is not animated.
    # We keep track of all chambers.
    #
    # @param beadGroup          The group of beads to add.
    # @param beadTransform      The corresponding clipping path transformation.
    # @return                   void
    drawChamber: (beadGroup, beadTransform) ->
        this.animateGroup(beadGroup, beadTransform)

        chamber = drawing.group().transform("t #{@center.x}, #{@center.y}")
        chamber.add(beadGroup)
        chamber.attr({ clipPath: @clipCone.use().transform(beadTransform)})

        @chambers.push(chamber)



    # Animates a bead group
    # The already applied transformation to the beadgroup is expanded with rotations
    #
    # @param beadGroup          The group of beads to transform.
    # @param beadTransform      The base transform of the group.
    # @return                   void
    animateGroup: (beadGroup, beadTransform) ->
        animateGroupCnt = (bg, bt, n) ->
            animateAgain = () ->
                animateGroupCnt(bg, bt, n + 1)

            a = 360 * n
            beadGroup.animate({ transform: beadTransform + "r#{a},0,0" }, 8000, mina.lineair, animateAgain)

        animateGroupCnt(beadGroup, beadTransform, 1)



     # Stops all beadGroups from animating.
     #
     # @return  void
     stopAnimation: () ->
        beadGroup.stop() for beadGroup in @transformedGroups



     # removes all chambers
     #
     # @return void.
    clear: () ->
        chamber.remove() for chamber in @chambers



class Editor
    beadDefinitions: []

    center: {x: 300, y: 300}

    beadsGroup: null


    # constructor for our editor.
    # Draws all defined beads so we can add them; draws all beads in the caleidoscoop; adds a clear button.
    #
    # @param beadDefinitions  An array with all beadsDefinitions.
    # @param beadGroup An array with all beads drawn in the caleidoscoop.
    constructor: (beadDefinitions, beadGroup) ->
        @beadsDefinitions = beadDefinitions
        @beadsGroup = beadGroup

        editArea = drawing.rect(0, 0, @center.x * 2, @center.y *2).attr({stroke: "red", "stroke-width": "1px"})
        editDot = drawing.circle(@center.x, @center.y, 2).attr({fill: "white"})

        # Create group with templates to drag and drop from.
        defGroup = this._addDefinitions(beadDefinitions)

        # clear editor button, with an event handler
        clearEditButton = drawing.group().attr({display: "inline"})
        clearEditButton.add(drawing.rect(610, 500, 50, 30).attr({ id: "clear", fill: "green" , "pointer-events": "all"}))
        clearEditButton.add(drawing.text(620, 520, "clear").attr({ fill: "white", "pointer-events": "all"}))
        clearEditButton.click((evt) =>
            @beadsGroup.remove()
            @beadsGroup = drawing.group()
        )

        # play button, with an event handler
        playButton = drawing.group().attr({display: "inline"})
        playButton.add(drawing.rect(610, 550, 50, 30).attr({ id: "play", fill: "green" , "pointer-events": "all"}))
        playButton.add(drawing.text(620, 570, "play").attr({ fill: "white", "pointer-events": "all"}))
        playButton.click((evt) =>
            editArea.remove()
            editDot.remove()
            defGroup.remove()
            playButton.remove()
            clearButton.remove()
        )

        chamber = drawing.group().transform("t #{@center.x}, #{@center.y}")
        chamber.add(beadGroup)


    # Adds all beads to a definition panel.
    #
    # @param beads The definitions of our beads
    # @return void
    _addDefinitions: (beadDefinitions) ->
        defPanelHeight = @center.y * 2
        defPanelWidth = 100

        defGroup = drawing.group()

        # Add all definitons to our panel on the correct coordinates.
        n = 0
        xOffset = @center.x * 2 + 100
        yOffset = 40
        while n < beadDefinitions.length
            [_xOff, _yOff] = this._addDefinition(beadDefinitions[n], defGroup, xOffset, yOffset)
            yOffset += _yOff + 20
            n += 1

        defGroup


    # Add a single bead to the definitions panel
    # A use element is made from the beadDefinition, and added to the panel. 
    # A click handler for selecting the bead is added to the use element
    #
    # @param bead the definition element of the bead to add.
    # @param defGroup The group to add the bead to.
    # @param xOffset Where on our paper to put the definition.
    # @param yOffset Where on our paper to put the definition.
    #
    # @return A tuple with the x- and yOffset of the added use element.
    _addDefinition: (beadDefinition, defGroup, xOffset, yOffset) ->
            bbox = beadDefinition.getBBox()
            _xOff = xOffset + bbox.width / 2
            _yOff = bbox.height
            transformString = "t #{_xOff}, #{yOffset}"

            templateElement = beadDefinition.use()
            defGroup.add(templateElement.transform(transformString).attr({fill: "red"}))

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
                # @param x
                # @param y
                releaseHandler = (evt) ->
                    newElement.unmousemove(moveHandler)
                    newElement.unclick(releaseHandler)
                    newElement.click(pickupHandler)
                
                # Assign event handlers.
                newElement.mousemove(moveHandler)
                newElement.unclick(clickHandler)
                newElement.click(releaseHandler)


            templateElement.click(clickHandler)

            [_xOff, _yOff]


# Globals for all beads, and all mirrors.
theBeads = [circleForm, triangleForm, squareForm, diamondForm, starForm, wingForm]
theMirrors = [0, Math.PI / 3, -Math.PI / 3 ]

caleidoscoop = new Caleidoscoop theBeads, theMirrors, theCone
