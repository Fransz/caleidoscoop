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
    console.log 'Edit'
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


    constructor : (beads, mirrors, clipCone) ->
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

    constructor: (beadDefinitions, beadGroup) ->
        @beadsDefinitions = beadDefinitions
        @beadsGroup = beadGroup

        drawing.rect(0, 0, @center.x * 2, @center.y *2).attr({stroke: "red", "stroke-width": "1px"})
        drawing.circle(@center.x, @center.y, 2).attr({fill: "white"})

        # clear editor button
        clearEditButton = drawing.group().attr({display: "inline"})
        clearEditButton.add(drawing.rect(610, 550, 50, 30).attr({ id: "edit", fill: "green" , "pointer-events": "all"}))
        clearEditButton.add(drawing.text(620, 570, "clear").attr({ fill: "white", "pointer-events": "all"}))

        clearEditButton.click((evt) =>
            @beadsGroup.remove()
            @beadsGroup = drawing.group()
        )

        this._addDefinitions(beadDefinitions)
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

    # Add a single bead to the definitions panel
    # A use element is made from the bead, and added to the panel. 
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

            clickHandler = (evt, x, y) ->
                coordXY = (evt) ->
                    console.log evt
                    containerX = document.getElementById('canvas').offsetLeft
                    containerY = document.getElementById('canvas').offsetTop

                    coord={ X: null, Y: null }
                    isTouchSupported = 'ontouchstart' in window

                    if(isTouchSupported)
                        coord.X = evt.clientX-containerX
                        coord.Y = evt.clientY-containerY
                        coord

                    else if(evt.offsetX || evt.offsetX == 0)
                        coord.X = evt.offsetX
                        coord.Y = evt.offsetY
                        coord

                    else if(evt.layerX || evt.layerX == 0)
                        coord.X = evt.layerX
                        coord.Y = evt.layerY
                        coord

                console.log "coordXY"
                console.log coordXY
                # create another use element, with the sme transformation.
                newElement = beadDefinition.use().transform(transformString).attr({fill: "green", stroke: "yellow", "stroke-width": "2px"})
                drawing.add(newElement)

                matrix = newElement.transform().localMatrix
                newElement.startE = matrix.e
                newElement.startF = matrix.f

                pickupHandler = (evt, x, y) ->
                    matrix = newElement.transform().localMatrix
                    newElement.startE = matrix.e
                    newElement.startF = matrix.f
                    newElement.mousemove(moveHandler)
                    newElement.unclick(pickupHandler)
                    newElement.click(releaseHandler)

                moveHandler = (evt, dx, dy) ->
                    console.log "move to" + dx + " " + dy

                    coord = coordXY(evt)
                    console.log coord

                    matrix = newElement.transform().localMatrix
                    matrix.e = coord.X
                    matrix.f = coord.Y
                    newElement.transform(matrix)

                releaseHandler = (evt, x, y) ->
                    newElement.unmousemove(moveHandler)
                    newElement.unclick(releaseHandler)
                    newElement.click(pickupHandler)
                
                newElement.mousemove(moveHandler)
                newElement.unclick(clickHandler)
                newElement.click(releaseHandler)


            drgStart = (x, y, evt) ->
                matrix = useElement.transform().localMatrix
                useElement.startE = matrix.e
                useElement.startF = matrix.f

            drgMove = (dx, dy, x, y) ->
                matrix = useElement.transform().localMatrix
                matrix.e = useElement.startE + dx
                matrix.f = useElement.startF + dy
                useElement.transform(matrix)

            # useElement.drag(drgMove, drgStart)
            templateElement.click(clickHandler)

            [_xOff, _yOff]





theBeads = [circleForm, triangleForm, squareForm, diamondForm, starForm, wingForm]
theMirrors = [0, Math.PI / 3, -Math.PI / 3 ]

caleidoscoop = new Caleidoscoop theBeads, theMirrors, theCone
