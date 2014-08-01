caleidoscoop = caleidoscoop || {}

class caleidoscoop.TemplateBead extends caleidoscoop.Bead
    editor = null

    # Constructor for a template bead.
    # We create the template bead from a definition, give it the correct position, and assign a click handler.
    constructor: (defElement, options) ->
        @editor = options.editor || null
        super(defElement, options)

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

    clickHandler: (evt) =>
        eBead = theEditableBeadFactory.copyBeadFromTemplateBead(this, @editor)
        eBead.setColor("green")
        return eBead




