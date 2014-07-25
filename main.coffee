_.extend(window, caleidoscoop)

drawing = Snap("#drawing")

#
# Form definitions.
circleForm = drawing.circle(0, 0, 30)
circle = new Bead(circleForm.toDefs())

triangleForm = drawing.polyline([[0, -30], [30, 30], [-30, 30]])
triangle = new Bead(triangleForm.toDefs())

squareForm = drawing.rect(-30, -30, 60, 60)
square = new Bead(squareForm.toDefs())

diamondForm = drawing.polyline([[-30,0], [-20, -20], [20, -20], [30, 0], [0, 40]])
diamond = new Bead(diamondForm.toDefs())

starForm = drawing.group()
starForm.add(drawing.polyline([[0, -30], [30, 16], [-30, 16]]))
starForm.add(drawing.polyline([[0, 30], [30, -16], [-30, -16]]))
star = new Bead(starForm.toDefs())

wingForm = drawing.group()
wingForm.toDefs()
wingForm.add(drawing.ellipse(0, 0, 16, 30))
wingForm.add(drawing.ellipse(0, 0, 30, 16))
wing = new Bead(wingForm.toDefs())

theBeads = [circle, triangle, square, diamond, star, wing]


#
# clipping cone.
coneRadius = 300
coneAngle = Math.PI / 3
coneStart = { x: coneRadius, y: 0 }
coneEnd = { x: coneRadius * Math.cos(coneAngle), y: coneRadius * Math.sin(coneAngle) }
coneString = "M 0 0 L #{coneEnd.x} #{coneEnd.y} A #{coneRadius} #{coneRadius} 0 0 0 #{coneStart.x} #{coneStart.y}"

theCone = drawing.path(coneString).attr({id: "cone"}).toDefs()



# Angles for the mirros.
theAngles = [0, Math.PI / 3, -Math.PI / 3 ]




# edit button
editButton = drawing.group().attr({display: "inline"})
editButton.add(drawing.rect(560, 570, 40, 30).attr({ id: "edit", fill: "green" , "pointer-events": "all"}))
editButton.add(drawing.text(570, 590, "edit").attr({ fill: "white", "pointer-events": "all"}))

editHandler = (evt) ->
    theCaleidoscoop.stopAnimation()
    theCaleidoscoop.clear()

    for bead in theCaleidoscoop.allBeads
        do (bead) ->
            new EditableBead(bead, bead.getColor())

    theCaleidoscoop.allBeads = []
    theEditor.show()


editButton.click(editHandler)








# Globals for all beads, and all mirrors.

theCaleidoscoop = new caleidoscoop.Caleidoscoop theBeads, theAngles, theCone
theEditor = new Editor theBeads, theCaleidoscoop.allBeads 
