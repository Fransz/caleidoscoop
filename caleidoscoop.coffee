#
# For the reflection matrices see:
# @see http://math.stackexchange.com/questions/525082/reflection-across-a-line
drawing = Snap("#drawing")


# Use a reference defenition element in a group, on given coordinates
addReference = (x, y, g) -> g.add( drawing.use().attr("xlink:href": "#reference").transform("t#{x},#{y}") )


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

beads = [circleForm, triangleForm, squareForm, diamondForm, starForm, wingForm]


# center of our drawing.
theCenter = {x: 300, y: 300}

# our viewport
rect = drawing.rect(0, 0, 600, 600).attr({fill: "black"})


# clipping cone.
coneRadius = 300
coneAngle = Math.PI / 3
coneStart = { x: coneRadius, y: 0 }
coneEnd = { x: coneRadius * Math.cos(coneAngle), y: coneRadius * Math.sin(coneAngle) }
coneString = "M 0 0 L #{coneEnd.x} #{coneEnd.y} A #{coneRadius} #{coneRadius} 0 0 0 #{coneStart.x} #{coneStart.y}"
cone = drawing.path(coneString).attr({id: "cone"})
cone.toDefs()


# Function for making mirrors under an angle.
# @see http://math.stackexchange.com/questions/525082/reflection-across-a-line
#
# @param k  slope of the mirror (tangens of angle with x-axis).
# @return   Snap.Matrix
makeMirror = (k) ->

    mirror = (k) ->
        f = 1 / (k * k + 1)
        new Snap.Matrix(f * (1 - k * k),  f * 2 * k,  f * 2 * k,  f * (k * k - 1),  0,  0)
        
    t = new Snap.Matrix()
    t.add(mirror(k))

mirrors = (makeMirror k for k in [-Math.sqrt(3), Math.sqrt(3), 0])

# transformation strings for the caleidoscope chambers, from the three mirrors
beadTransforms = [
            new Snap.Matrix(1, 0, 0, 1, 0, 0).toTransformString(),
            mirrors[0].clone().toTransformString(),
            mirrors[0].clone().add(mirrors[1]).toTransformString(),
            mirrors[0].clone().add(mirrors[1]).add(mirrors[2]).toTransformString(),
            mirrors[0].clone().add(mirrors[1]).add(mirrors[2]).add(mirrors[0]).toTransformString(),
            mirrors[0].clone().add(mirrors[1]).add(mirrors[2]).add(mirrors[0]).add(mirrors[1]).toTransformString()
]


# Our bead view.
beadsGroup = drawing.group().attr({id: "beads"})
beadsGroup.toDefs()

# addBeads = () -> addReference(x * 40, y * 40, beadsGroup) for y in [0..1] for x in [0..1]
addBeads = (cnt) ->
    addBead(bead) for bead in beads for n in [0..cnt]


# Add all beads.
# All beads are added on a random point, and with a random rotation
# All beads are added four times, around our center point
# 
# @param beadDefinition     definition of the bead to add.
# @return                   void
addBead = (beadDefinition) ->
    rotation = "r" + Math.round(360 * Math.random()) + ",0,0"

    centers = []
    centers.push { x: Math.round(x * Math.random() * theCenter.x), y: Math.round(y * Math.random() * theCenter.y) } for y in [-1, 1] for x in [-1, 1]

    bbox = beadDefinition.getBBox()
    translatex = (x) -> x - bbox.x
    translatey = (y) -> y - bbox.y
    transforms = ("t#{translatex(c.x)},#{translatey(c.y)}" + rotation for c in centers)

    hsb = "hsb(".concat(Math.random(), ",.75", ", .75)")

    beadsGroup.add(beadDefinition.use().attr(fill: hsb, transform: t)) for t in transforms

addBeads(1)


# 6 transformed bead views, 6 animations
transformedBeads = (beadsGroup.use().transform(t) for t in beadTransforms)
beadsAnimations = ({transform: t + "r360,0,0"} for t in beadTransforms)


# Draws a bead group with a transformed clipping cone
#
# @param beadGroup          The group of beads to add.
# @param beadTransform      The corresponding clipping path transformation.
# @return                   void
drawGroup = (beadGroup, beadTransform) ->
    chamber = drawing.group().transform("t #{theCenter.x}, #{theCenter.y}")
    chamber.add(beadGroup)
    chamber.attr({ clipPath: cone.use().transform(beadTransform )})

drawGroup(transformedBeads[n], beadTransforms[n]) for n in  [0...6]

# Animates a bead group
# The already applied transformation to the beadgroup is expanded with rotations
#
# @param beadGroup          The group of beads to transform.
# @param beadTransform      The base transform of the group.
# @return                   void
animateGroup = (beadGroup, beadTransform) ->
    animateGroupCnt = (bg, bt, n) ->
        animateAgain = () ->
            animateGroupCnt(bg, bt, n + 1)

        a = 360 * n
        transform = { transform: beadTransform + "r#{a},0,0" }
        console.log transform.transform
        beadGroup.animate(transform, 8000, mina.lineair, animateAgain)

    animateGroupCnt(beadGroup, beadTransform, 1)


animateGroup(transformedBeads[n], beadTransforms[n]) for n in  [0...6]
