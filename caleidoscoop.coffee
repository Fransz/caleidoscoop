#
# For the reflection matrices see:
# @see http://math.stackexchange.com/questions/525082/reflection-across-a-line
drawing = Snap("#drawing")


#
# reference forms, for testing
tree = drawing.group()
tree.add(drawing.line(-Math.sqrt(2) * 15, -Math.sqrt(2) * 15, 0, 0).attr({"stroke": "red", "stroke-width": "2px"}))
tree.add(drawing.line(0, 0, -15, 0).attr({"stroke": "yellow", "stroke-width": "2px"}))
tree.add(drawing.line(0, 0, 0, -15).attr({"stroke": "green", "stroke-width": "2px"}))

bunch = drawing.group()
bunch.add(drawing.circle(20, 20, 20)).attr({fill: "red", stroke: "blue"})
bunch.add(drawing.rect(40, 40, 20, 20)).attr({fill: "green"})

reference = drawing.group().attr({id: "reference"})
reference.add(bunch)
reference.toDefs()

# Use a reference defenition element in a group, on given coordinates
addReference = (x, y, g) -> g.add( drawing.use().attr("xlink:href": "#reference").transform("t#{x},#{y}") )




# center of our drawing.
center = {x: 300, y: 300}

# our viewport
rect = drawing.rect(0, 0, 600, 600).attr({fill: "black", stroke: "green"})


# clipping cone.
coneRadius = 300
coneAngle = Math.PI / 3
coneStart = {x: coneRadius, y: 0}
coneEnd = {x: coneRadius * Math.cos(coneAngle), y: coneRadius * Math.sin(coneAngle)}
coneString = "M 0 0 L #{coneEnd.x} #{coneEnd.y} A #{coneRadius} #{coneRadius} 0 0 0 #{coneStart.x} #{coneStart.y}"
cone = drawing.path(coneString).attr({id: "cone", fill: "yellow"})
cone.toDefs()


# Function for making mirrors under an angle.
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
addBeads = (g) -> addReference(x * 40, y * 40, g) for y in [0..1] for x in [0..1]
addBeads(beadsGroup)


# 6 transformed bead views, 6 animations
transformedBeads = (beadsGroup.clone().transform(t) for t in beadTransforms)
beadsAnimations = ({transform: t + "r360,0,0"} for t in beadTransforms)


# 6 chambers.
chamber0 = drawing.group().transform("t #{center.x}, #{center.y}")
chamber0.add(transformedBeads[0])
chamber0.attr({clipPath: cone.clone()})
transformedBeads[0].animate(beadsAnimations[0], 4000, mina.lineair)

chamber1 = drawing.group().transform("t #{center.x}, #{center.y}")
chamber1.add(transformedBeads[1])
chamber1.attr({clipPath: cone.clone().transform(beadTransforms[1])})
transformedBeads[1].animate(beadsAnimations[1], 4000, mina.lineair)

chamber2 = drawing.group().transform("t #{center.x}, #{center.y}")
chamber2.add(transformedBeads[2])
chamber2.attr({clipPath: cone.clone().transform(beadTransforms[2])})
transformedBeads[2].animate(beadsAnimations[2], 4000, mina.lineair)

chamber3 = drawing.group().transform("t #{center.x}, #{center.y}")
chamber3.add(transformedBeads[3])
chamber3.attr({clipPath: cone.clone().transform(beadTransforms[3])})
transformedBeads[3].animate(beadsAnimations[3], 4000, mina.lineair)

chamber4 = drawing.group().transform("t #{center.x}, #{center.y}")
chamber4.add(transformedBeads[4])
chamber4.attr({clipPath: cone.clone().transform(beadTransforms[4])})
transformedBeads[4].animate(beadsAnimations[4], 4000, mina.lineair)

chamber5 = drawing.group().transform("t #{center.x}, #{center.y}")
chamber5.add(transformedBeads[5])
chamber5.attr({clipPath: cone.clone().transform(beadTransforms[5])})
transformedBeads[5].animate(beadsAnimations[5], 4000, mina.lineair)
