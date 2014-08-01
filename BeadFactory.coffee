caleidoscoop = caleidoscoop || {}

# Factory class for copying a existing bead.
#
class caleidoscoop.BeadFactory
    copyBead: (b) ->
        new Bead(b.getDefinition(), {})

    createBead: (d) ->
        new Bead(d, {})

caleidoscoop.theBeadFactory = new caleidoscoop.BeadFactory()


class caleidoscoop.CaleidoscoopBeadFactory
    copyBead: (b, transform, color) ->
        options = {transform: transform, color: color}
        new CaleidoscoopBead(b.getDefinition(), options)

caleidoscoop.theCaleidoscoopBeadFactory = new caleidoscoop.CaleidoscoopBeadFactory()


class caleidoscoop.TemplateBeadFactory
    copyBead: (b, editor) ->
        options = {color: "red", transform: "", editor: editor}
        _b = new TemplateBead(b.getDefinition(), options)
        
        # TODO: this should go to setClick/EventHandler.
        _b.elm.click(_b.clickHandler)

        return _b

caleidoscoop.theTemplateBeadFactory = new caleidoscoop.TemplateBeadFactory()


class caleidoscoop.EditorBeadFactory
    _copyBead: (b, editor) ->
        options = {color: b.getColor(), transform: b.getTransform(), editor: editor}
        _b = new EditableBead(b.getDefinition(), options)


        # @Todo do we need this?
        matrix = _b.elm.transform().localMatrix
        _b.startE = matrix.e
        _b.startF = matrix.f

        _b.setPickupHandler(_b.pickupBead)
        _b.setDragHandler(_b.dragBead)
        _b.setReleaseHandler(_b.releaseBead)
        _b.setEditHandler(_b.editBead)

        editor.addBead(_b)

        return _b

    copyBeadFromTemplateBead: (b, editor) ->
        _b = @_copyBead(b, editor)
        _b.elm.mousemove(_b.dragHandler)
        _b.elm.click(_b.releaseHandler)
        _b.elm.dblclick(_b.editHandler)

        return _b

    copyBeadFromCaleidoscoopBead: (b, editor) ->
        _b = @_copyBead(b, editor)
        _b.elm.click(_b.pickupHandler)
        _b.elm.dblclick(_b.editHandler)

        return _b

caleidoscoop.theEditableBeadFactory = new caleidoscoop.EditorBeadFactory()

