_.extend(window, caleidoscoop)

drawing = Snap("#drawing")

#
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

theBeads = [circleForm, triangleForm, squareForm, diamondForm, starForm, wingForm]


#
# clipping cone.
coneRadius = 300
coneAngle = Math.PI / 3
coneStart = { x: coneRadius, y: 0 }
coneEnd = { x: coneRadius * Math.cos(coneAngle), y: coneRadius * Math.sin(coneAngle) }
coneString = "M 0 0 L #{coneEnd.x} #{coneEnd.y} A #{coneRadius} #{coneRadius} 0 0 0 #{coneStart.x} #{coneStart.y}"

theCone = drawing.path(coneString).attr({id: "cone"}).toDefs()



# background rectangle.
theRect = drawing.rect(0, 0, 600, 600).attr({fill: "black", "pointer-events": "all"})



# Angles for the mirros.
theAngles = [0, Math.PI / 3, -Math.PI / 3 ]




# edit button
editButton = drawing.group().attr({display: "inline"})
editButton.add(drawing.rect(560, 570, 40, 30).attr({ id: "edit", fill: "green" , "pointer-events": "all"}))
editButton.add(drawing.text(570, 590, "edit").attr({ fill: "white", "pointer-events": "all"}))

editHandler = (evt) ->
    theCaleidoscoop.stopAnimation()
    theCaleidoscoop.clear()

    window.theEditor = new Editor(theBeads, theCaleidoscoop.allBeads)

editButton.click(editHandler)








# Globals for all beads, and all mirrors.

theCaleidoscoop = new caleidoscoop.Caleidoscoop theBeads, theAngles, theCone
window.theEditor = null
