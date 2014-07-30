caleidoscoop = caleidoscoop || {}

class caleidoscoop.TemplateBead extends caleidoscoop.Bead
    # Constructor for a template bead.
    # We create the template bead from a definition, give it the correct position, and assign a click handler.
    constructor: (bead) ->
        super(bead.def)
        @use()
        @setColor('red')

        this.setClickHandler()
        @elm.click(@clickHandler)



    # displays the teplateBead in the given grouo, on the given coordinates.
    #
    # @param offsetX
    # @param offsetY
    # @param group  the group to add to.
    # @return int deltaY
    display: (offsetX, offsetY, group) ->
        bbox = this.getBBox()
        beadX = offsetX + bbox.x / 2
        group.add(this.setTransform("t #{beadX}, #{offsetY}"))
        bbox.height + 20


    # Set the event handler for clicking the bead. In the eventhandler we create a new editable bead.
    #
    # @param evt The click event.
    setClickHandler: () ->
        self = this

        @clickHandler = (evt) ->
            eBead = new EditableBead(self, "green")


