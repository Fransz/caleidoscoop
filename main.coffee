_.extend(window, caleidoscoop)

drawing = Snap("#drawing")


formGroup = drawing.group().attr({id: "formGroup"}).toDefs()
theBeadGroup = drawing.group().attr(id: "theBeadGroup").toDefs()

circleForm = drawing.circle(0, 0, 30).attr({id: "circleForm"})
formGroup.add(circleForm)

circle = theBeadFactory.createBead(circleForm)
circle.addTo(theBeadGroup)


triangleForm = drawing.polyline([[0, -30], [30, 30], [-30, 30]]).attr({id: "triangleForm"})
formGroup.add(triangleForm)

triangle = theBeadFactory.createBead(triangleForm)
triangle.addTo(theBeadGroup)


squareForm = drawing.rect(-30, -30, 60, 60).attr({id: "squareForm"})
formGroup.add(squareForm)

square = theBeadFactory.createBead(squareForm)
square.addTo(theBeadGroup)


diamondForm = drawing.polyline([[-30,0], [-20, -20], [20, -20], [30, 0], [0, 40]]).attr({id: "diamondForm"})
formGroup.add(diamondForm)

diamond = theBeadFactory.createBead(diamondForm)
diamond.addTo(theBeadGroup)


starForm = drawing.group().attr({id: "starForm"})
starForm.add(drawing.polyline([[0, -30], [30, 16], [-30, 16]]))
starForm.add(drawing.polyline([[0, 30], [30, -16], [-30, -16]]))
formGroup.add(starForm)

star = theBeadFactory.createBead(starForm)
star.addTo(theBeadGroup)


wingForm = drawing.group().attr({id: "wingForm"})
wingForm.add(drawing.ellipse(0, 0, 16, 30))
wingForm.add(drawing.ellipse(0, 0, 30, 16))
formGroup.add(wingForm)

wing = theBeadFactory.createBead(wingForm)
wing.addTo(theBeadGroup)


ellForm = drawing.group().attr({id: "ell"})
ellForm.add(drawing.rect(-20, -20, 10, 40))
ellForm.add(drawing.rect(-20, 20, 40, 10))
ellForm.add(drawing.circle(0, 0, 5))
formGroup.add(ellForm)

ell = theBeadFactory.createBead(ellForm)
ell.addTo(theBeadGroup)


theBeads = [circle, triangle, square, diamond, star, wing]


#
# clipping cone.
coneRadius = 300
coneAngle = Math.PI / 3
coneStart = { x: coneRadius, y: 0 }
coneEnd = { x: coneRadius * Math.cos(coneAngle), y: coneRadius * Math.sin(coneAngle) }
coneString = "M 0 0 L #{coneEnd.x} #{coneEnd.y} A #{coneRadius} #{coneRadius} 0 0 0 #{coneStart.x} #{coneStart.y}"

theCone = drawing.path(coneString).attr({id: "clippingConeMaster"}).toDefs()



# Angles for the mirros.
theAngles = [0, Math.PI / 3, -Math.PI / 3 ]




# edit button
editButton = drawing.group().attr({display: "inline"})
editButton.add(drawing.rect(560, 570, 40, 30).attr({ id: "edit", fill: "green" , "pointer-events": "all"}))
editButton.add(drawing.text(570, 590, "edit").attr({ fill: "white", "pointer-events": "all"}))

editHandler = (evt) ->
    theCaleidoscoop.stopAnimation()

    for bead in theCaleidoscoop.allBeads
        do (bead) ->
            theEditor.addBead(theEditableBeadFactory.copyBeadFromCaleidoscoopBead(bead, theEditor))


    theCaleidoscoop.clear()
    theEditor.show()


editButton.click(editHandler)




# Globals for all beads, and all mirrors.

theCaleidoscoop = new caleidoscoop.Caleidoscoop theBeads, theAngles, theCone
theEditor = new Editor theBeads
