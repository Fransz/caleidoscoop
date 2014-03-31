#
# For the reflection matrices see:
# @see http://math.stackexchange.com/questions/525082/reflection-across-a-line
drawing = Snap("#drawing")

center = {x: 300, y: 300}

rect = drawing.rect(0, 0, 600, 600).attr({fill: "black", stroke: "green"})
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

coneRadius = 300
coneAngle = Math.PI / 3
# coneStart = {x: coneRadius * Math.cos(coneAngle / 2), y: -coneRadius * Math.sin(coneAngle / 2)}
# coneEnd = {x: coneRadius * Math.cos(coneAngle / 2), y: coneRadius * Math.sin(coneAngle / 2)}
coneStart = {x: coneRadius, y: 0}
coneEnd = {x: coneRadius * Math.cos(coneAngle), y: coneRadius * Math.sin(coneAngle)}

# cone = drawing.path().L(coneEnd).A(coneRadius, coneRadius, 0, 0, 0, coneStart).fill("yellow")
coneString = "M 0 0 L #{coneEnd.x} #{coneEnd.y} A #{coneRadius} #{coneRadius} 0 0 0 #{coneStart.x} #{coneStart.y}"
cone = drawing.path(coneString).attr({id: "cone", fill: "yellow"})
# cone.toDefs()
# cone.translate(coneCenter.x, coneCenter.y)

makeMirror = (k) ->
    mirror = (k) ->
        f = 1 / (k * k + 1)
        new Snap.Matrix(f * (1 - k * k),  f * 2 * k,  f * 2 * k,  f * (k * k - 1),  0,  0)
        
    t = new Snap.Matrix()
    # t.translate(center.x, center.y).add(mirror(k))
    t.add(mirror(k))

# mirrors = (makeMirror k for k in [-Math.sqrt(3), 0])
mirrors = (makeMirror k for k in [-Math.sqrt(3), Math.sqrt(3), 0])


tt = (x, y, g) -> g.add( drawing.use().attr("xlink:href": "#reference").transform("t#{x},#{y}") )
addBeads = (g) -> tt(x * 40, y * 40, g) for y in [0..1] for x in [0..1]

# addBeads = (g) -> g.add( drawing.use().attr("xlink:href": "#reference"))


beadsGroup = drawing.group()
addBeads(beadsGroup)
# beadsGroup.attr({clipPath: cone})
# console.log drawing.toString()

# chamber1 = drawing.group()
# beads1 = beadsGroup.clone().transform("t #{center.x}, #{center.y}")
# chamber1.add(beads1)
# clip1 = cone.clone().transform("t #{center.x}, #{center.y}")
# chamber1.attr({clipPath: clip1})
# animate1 = "t300,300 r360,0,0"

# chamber4 = drawing.group()
# beads4 = beadsGroup.clone().transform("t #{center.x}, #{center.y} r180,0,0")
# chamber4.add(beads4)
# clip4 = cone.clone().transform("t #{center.x}, #{center.y} r180,0,0")
# chamber4.attr({clipPath: clip4})
# animate4 = "t300,300 r540,0,0"

# chamber2 = drawing.group()
# beads2 = beadsGroup.clone().transform(mirrors[0].toTransformString())
# chamber2.add(beads2)
# clip2 = cone.clone().transform(mirrors[0].toTransformString())
# chamber2.attr({clipPath: clip2})
# animate2 = mirrors[0].toTransformString() + "r360,0,0"

# mirror_5 = mirrors[0]
# mirror_5.scale(-1,-1)
# chamber5 = drawing.group()
# beads5 = beadsGroup.clone().transform(mirror_5.toTransformString())
# chamber5.add(beads5)
# clip5 = cone.clone().transform(mirror_5.toTransformString())
# chamber5.attr({clipPath: clip5})
# animate5 = mirror_5.toTransformString() + "r360,0,0"

# chamber3 = drawing.group()
# beads3 = beadsGroup.clone().transform(mirrors[1].toTransformString())
# chamber3.add(beads3)
# clip3 = cone.clone().transform(mirrors[1].toTransformString())
# chamber3.attr({clipPath: clip3})
# animate3 = mirrors[1].toTransformString() + "r360,0,0"

# mirror_6 = mirrors[1]
# mirror_6.scale(-1,-1)
# chamber6 = drawing.group()
# beads6 = beadsGroup.clone().transform(mirror_6.toTransformString())
# chamber6.add(beads6)
# clip6 = cone.clone().transform(mirror_6.toTransformString())
# chamber6.attr({clipPath: clip6})
# animate6 = mirror_6.toTransformString() + "r360,0,0"


chamber1 = drawing.group()
chamber1.transform("t #{center.x}, #{center.y}")
beads1 = beadsGroup.clone()
chamber1.add(beads1)
clip1 = cone.clone()
chamber1.attr({clipPath: clip1})
animate1 = "r360,0,0"

chamber2 = drawing.group()
chamber2.transform("t #{center.x}, #{center.y}")
mirror_2 = mirrors[0].clone()
beads2 = beadsGroup.clone().transform(mirror_2.toTransformString())
chamber2.add(beads2)
clip2 = cone.clone().transform(mirrors[0].toTransformString())
chamber2.attr({clipPath: clip2})
animate2 = mirrors[0].toTransformString() + "r360,0,0"

chamber3 = drawing.group()
mirror_3 = mirror_2.add(mirrors[1])
chamber3.transform("t #{center.x}, #{center.y}")
beads3 = beadsGroup.clone().transform(mirror_3.toTransformString())
chamber3.add(beads3)
clip3 = cone.clone().transform(mirror_3.toTransformString())
chamber3.attr({clipPath: clip3})
animate3 = mirror_3.toTransformString() + "r360,0,0"

chamber4 = drawing.group()
mirror_4 = mirror_3.add(mirrors[2])
chamber4.transform("t #{center.x}, #{center.y}")
beads4 = beadsGroup.clone().transform(mirror_4.toTransformString())
chamber4.add(beads4)
clip4 = cone.clone().transform(mirror_4.toTransformString())
chamber4.attr({clipPath: clip4})
animate4 = mirror_4.toTransformString() + "r360,0,0"

chamber5 = drawing.group()
mirror_5 = mirror_4.add(mirrors[0])
chamber5.transform("t #{center.x}, #{center.y}")
beads5 = beadsGroup.clone().transform(mirror_5.toTransformString())
chamber5.add(beads5)
clip5 = cone.clone().transform(mirror_5.toTransformString())
chamber5.attr({clipPath: clip5})
animate5 = mirror_5.toTransformString() + "r360,0,0"

chamber6 = drawing.group()
mirror_6 = mirror_5.add(mirrors[1])
chamber6.transform("t #{center.x}, #{center.y}")
beads6 = beadsGroup.clone().transform(mirror_6.toTransformString())
chamber6.add(beads6)
clip6 = cone.clone().transform(mirror_6.toTransformString())
chamber6.attr({clipPath: clip6})
animate6 = mirror_6.toTransformString() + "r360,0,0"

beads1.animate({ transform: animate1}, 4000, mina.lineair)
beads2.animate({ transform: animate2}, 4000, mina.lineair)
beads3.animate({ transform: animate3}, 4000, mina.lineair)
beads4.animate({ transform: animate4}, 4000, mina.lineair)
beads5.animate({ transform: animate5}, 4000, mina.lineair)
beads6.animate({ transform: animate6}, 4000, mina.lineair)
