caleidoscoop = caleidoscoop || {}

class caleidoscoop.Caleidoscoop
    center: {x: 300, y: 300}

    allBeads: []                                                # all known beads.

    transformations: []                                         # all transformations, from the given mirrors.

    masterGroup: null                                           # all beads not transformed, not animated.

    transformedGroups: []                                       # groups of all beads, transformed, animated.

    chambers: []                                                # group of transformed beads and clipping cone.

    clipCone: null

    transformedClipCones: []

    constructor: (defBeads, angles, @clipCone) ->
        @masterGroup = drawing.group().attr({id: "beadsMaster"}).toDefs()
        @transformations = this.makeTransformations(angles)

        randomBeads = _.flatten(@generateBeads(defBead) for defBead in defBeads)
        @addBead(randomBead) for randomBead in randomBeads

        @makeTransformedGroups()
        @drawChambers()


    # Make all transformation matrices from the mirrors made by the given angels.
    #
    # @param angles An array with angles under which we find the mirrors.
    # @return An array with transformation matrices for each mirror
    #
    # @TODO solve this properly.
    makeTransformations: (angles) ->
        mirrors = (this.makeMirror a for a in angles)
        transformations = [
            new Snap.Matrix(1, 0, 0, 1, 0, 0).toTransformString(),
            mirrors[0].clone().toTransformString(),
            mirrors[0].clone().add(mirrors[1]).toTransformString(),
            mirrors[0].clone().add(mirrors[1]).add(mirrors[2]).toTransformString(),
            mirrors[0].clone().add(mirrors[1]).add(mirrors[2]).add(mirrors[0]).toTransformString(),
            mirrors[0].clone().add(mirrors[1]).add(mirrors[2]).add(mirrors[0]).add(mirrors[1]).toTransformString()
        ]


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


    # Transform the beads group with the given transformation
    #
    # @return An array with the transformed beadsgroup for each mirror
    makeTransformedGroups: () ->
        @transformedGroups = (@masterGroup.use().transform(t) for t in @transformations)


    # Generate four new beads with a position, a rotation and a hue from a bead definition.
    # The beads are added to the allBeads array.
    #
    # @param beadDef  The definition of the bead.
    # @return void
    generateBeads: (bead) ->
        _positionX = (x) -> x - bead.getBBox().x / 2
        _positionY = (y) -> y - bead.getBBox().y / 2

        rotation = Snap.matrix().rotate(Math.round(360 * Math.random()) , 0, 0)
        hsb = "hsb(".concat(Math.random(), ",.75", ", .75)")

        centers = []
        centers.push { x: Math.round(x * Math.random() * @center.x), y: Math.round(y * Math.random() * @center.y) } for y in [-1, 1] for x in [-1, 1]

        theCaleidoscoopBeadFactory.copyBead(bead, rotation.clone(), hsb, _positionX(c.x), _positionY(c.y)) for c in centers



    # Adds a single bead to the allBeads array
    #
    # @param bead  The bead.
    # @return void
    addBead: (bead) ->
        @allBeads.push(bead)
        bead.addTo(@masterGroup)



    # Draw all chambers
    #
    # @return void
    drawChambers: () ->
        this.drawChamber(@transformedGroups[n], @transformations[n]) for n in  [0...6]



    # Draws a bead group with a clipping cone, animates the beadsgroup.
    # We need the transform from the already transformed group again for the animation.
    # The chamber itself (i.e. beadsbroup + clippingCone) is not animated, only translated to the @center.
    # We keep track of all chambers.
    #
    # @param beadGroup          The group of beads to add.
    # @param beadTransform      The corresponding clipping path transformation.
    # @return                   void
    drawChamber: (beadGroup, beadTransform) ->
        this.animateGroup(beadGroup, beadTransform)

        chamber = drawing.group().transform("t #{@center.x}, #{@center.y}")
        chamber.add(beadGroup)
        clipCone = @clipCone.use().transform(beadTransform)
        @transformedClipCones.push(clipCone)
        chamber.attr({ clipPath: clipCone})

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
        @allBeads = []

        @masterGroup.remove()
        @masterGroup = drawing.group().attr({id: "beads"}).toDefs()

        chamber.remove() for chamber in @chambers
        @chambers = []

        clipCone.parent().remove() for clipCone in @transformedClipCones
        @transformedClipCones = []


