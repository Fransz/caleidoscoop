caleidoscoop = caleidoscoop || {}

class caleidoscoop.BeadsColorPicker
    constructor: () ->
        @elm = document.getElementById('colorpicker')
        @slider = document.getElementById('slider')
        @picker = document.getElementById('picker')
        preview = document.getElementById('preview')

        ok = document.getElementById('ok')
        @_addHtmlEventListener(ok, 'click', @_colorPickerOkHandler)
        cancel = document.getElementById('cancel')
        @_addHtmlEventListener(cancel, 'click', @_colorPickerCancelHandler)

        @colorPicker = new ColorPicker(@slider, @picker,
            (hex, hsv, rgb) =>
                preview.style.backgroundColor = hex
                @newColor = hex
        )


    enable: (@bead, @colorIcon) ->
        @elm.style.display = 'block'
        @colorPicker.setHex(@bead.getHexColor())


    disable: () ->
        @elm.style.display = 'none'
        @bead.disableColorBead(@colorIcon) if @bead


    _addHtmlEventListener: (element, event, listener) ->
        if (element.attachEvent)
            element.attachEvent('on' + event, listener)
        else if (element.addEventListener)
            element.addEventListener(event, listener, false)


    _colorPickerOkHandler: (evt) =>
        @bead.setColor(@newColor)
        @disable()
         
    _colorPickerCancelHandler: (evt) =>
        @disable()
