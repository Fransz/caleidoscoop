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

editButton.click(editHandler)




class Caleidoscoop
    beadDefinitions: []

    transformations: []

    center: {x: 300, y: 300}

    beadsGroup: drawing.group().attr({id: "eads"}).toDefs()

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

        this.addBead(bead) for bead in @beadDefinitions
        this.addBead(bead) for bead in @beadDefinitions

        @transformedBeads = (@beadsGroup.use().transform(t) for t in @transformations)
        @animationTransforms = ({transform: t + "r360,0,0"} for t in @transformations)

        this.drawGroup(@transformedBeads[n], @transformations[n]) for n in  [0...6]
        this.animateGroup(@transformedBeads[n], @transformations[n]) for n in  [0...6]

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
    # @return                   void
    addBead: (beadDefinition) ->
        rotation = "r" + Math.round(360 * Math.random()) + ",0,0"

        centers = []
        centers.push { x: Math.round(x * Math.random() * @center.x), y: Math.round(y * Math.random() * @center.y) } for y in [-1, 1] for x in [-1, 1]

        bbox = beadDefinition.getBBox()
        translatex = (x) -> x - bbox.x
        translatey = (y) -> y - bbox.y
        transforms = ("t#{translatex(c.x)},#{translatey(c.y)}" + rotation for c in centers)

        hsb = "hsb(".concat(Math.random(), ",.75", ", .75)")

        @beadsGroup.add(beadDefinition.use().attr(fill: hsb, transform: t)) for t in transforms


    # Draws a bead group with a transformed clipping cone
    #
    # @param beadGroup          The group of beads to add.
    # @param beadTransform      The corresponding clipping path transformation.
    # @return                   void
    drawGroup: (beadGroup, beadTransform) ->
        chamber = drawing.group().transform("t #{@center.x}, #{@center.y}")
        chamber.add(beadGroup)
        chamber.attr({ clipPath: @clipCone.use().transform(beadTransform)})



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




theBeads = [circleForm, triangleForm, squareForm, diamondForm, starForm, wingForm]
theMirrors = [0, Math.PI / 3, -Math.PI / 3 ]

caleidoscoop = new Caleidoscoop theBeads, theMirrors, theCone
