caleidoscoop = caleidoscoop || {}

class caleidoscoop.TemplateBead extends caleidoscoop.Bead
    editor = null

    # Constructor for a template bead.
    # We create the template bead from a definition, give it the correct position, and assign a click handler.
    constructor: (defElement, options) ->
        @editor = options.editor || null
        super(defElement, options)
        this.bindHandler('click', @copyBead)


    copyBead: (evt) =>
        eBead = theEditableBeadFactory.copyBeadFromTemplateBead(this, @editor)
        @editor.addBead(eBead)
        eBead.setColor("green")
        return eBead




