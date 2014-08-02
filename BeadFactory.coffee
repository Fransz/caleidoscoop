caleidoscoop = caleidoscoop || {}

class caleidoscoop.BeadFactory
    copyBead: (b) ->
        new Bead(b.getDefinition(), {})

    createBead: (d) ->
        new Bead(d, {})

caleidoscoop.theBeadFactory = new caleidoscoop.BeadFactory()



class caleidoscoop.CaleidoscoopBeadFactory
    copyBead: (b, transform, color, positionX, positionY) ->
        options = {
            transform: transform, color: color,
            positionX: positionX, positionY: positionY
        }
        new CaleidoscoopBead(b.getDefinition(), options)


    copyBeadFromEditorBead: (bead) ->
        @copyBead(bead, bead.tMatrix, bead.color, bead.positionX, bead.positionY)

caleidoscoop.theCaleidoscoopBeadFactory = new caleidoscoop.CaleidoscoopBeadFactory()



class caleidoscoop.TemplateBeadFactory
    copyBead: (b, positionX, positionY, editor) ->
        options = {
            color: "red", transform: "", editor: editor
            positionX: positionX, positionY: positionY, 
        }
        _b = new TemplateBead(b.getDefinition(), options)
        
        # TODO: this should go to setClick/EventHandler.
        _b.elm.click(_b.clickHandler)

        return _b

caleidoscoop.theTemplateBeadFactory = new caleidoscoop.TemplateBeadFactory()



class caleidoscoop.EditorBeadFactory
    _copyBead: (b, positionX, positionY, editor) ->
        options = {
            color: b.getColor(), transform: b.tMatrix, editor: editor
            positionX: positionX, positionY: positionY
        }
        _b = new EditableBead(b.getDefinition(), options)


        _b.setPickupHandler(_b.pickupBead)
        _b.setDragHandler(_b.dragBead)
        _b.setReleaseHandler(_b.releaseBead)
        _b.setEditHandler(_b.editBead)

        return _b

    copyBeadFromTemplateBead: (b, editor) ->
        templateGroupPosition = editor.templateGroupPosition
        _b = @_copyBead(b, templateGroupPosition.x + b.positionX, templateGroupPosition.y + b.positionY, editor)
        _b.elm.mousemove(_b.dragHandler)
        _b.elm.click(_b.releaseHandler)
        _b.elm.dblclick(_b.editHandler)

        return _b

    copyBeadFromCaleidoscoopBead: (b, editor) ->
        _b = @_copyBead(b, b.positionX, b.positionY, editor)
        _b.elm.click(_b.pickupHandler)
        _b.elm.dblclick(_b.editHandler)

        return _b

caleidoscoop.theEditableBeadFactory = new caleidoscoop.EditorBeadFactory()

