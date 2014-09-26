caleidoscoop = caleidoscoop || {}

class caleidoscoop.BeadFactory
    copyBead: (b) ->
        new Bead(b.def, {})

    createBead: (d) ->
        new Bead(d, {})

caleidoscoop.theBeadFactory = new caleidoscoop.BeadFactory()



class caleidoscoop.CaleidoscoopBeadFactory
    copyBead: (b, transform, color, positionX, positionY) ->
        options = {
            transform: transform, color: color,
            positionX: positionX, positionY: positionY
        }
        new CaleidoscoopBead(b.def, options)


    copyBeadFromEditorBead: (bead) ->
        @copyBead(bead, bead.tMatrix, bead.color, bead.positionX, bead.positionY)

caleidoscoop.theCaleidoscoopBeadFactory = new caleidoscoop.CaleidoscoopBeadFactory()



class caleidoscoop.TemplateBeadFactory
    copyBead: (b, positionX, positionY, editor) ->
        options = {
            color: "red", transform: "", editor: editor
            positionX: positionX, positionY: positionY, 
        }
        new TemplateBead(b.def, options)

caleidoscoop.theTemplateBeadFactory = new caleidoscoop.TemplateBeadFactory()



class caleidoscoop.EditorBeadFactory
    _copyBead: (b, positionX, positionY, editor) ->
        options = {
            color: b.color, transform: b.tMatrix, editor: editor
            positionX: positionX, positionY: positionY
        }
        new EditableBead(b.def, options)


    copyBeadFromTemplateBead: (b, editor) ->
        templateGroupPosition = editor.templateGroupPosition
        _b = @_copyBead(b, templateGroupPosition.x + b.positionX, templateGroupPosition.y + b.positionY, editor)
        editor.disableAllBeads()
        _b.bindHandler('mousemove', _b.dragBead)
        _b.bindHandler('click', _b.releaseBead)

        return _b


    copyBeadFromCaleidoscoopBead: (b, editor) ->
        _b = @_copyBead(b, b.positionX, b.positionY, editor)
        _b.bindHandler('click', _b.pickupBead)
        _b.bindHandler('dblclick', _b.editBead)

        return _b

caleidoscoop.theEditableBeadFactory = new caleidoscoop.EditorBeadFactory()

