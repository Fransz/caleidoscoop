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
        # cp = document.getElementById('colorpicker')
        # slider = document.getElementById('slider')
        # picker = document.getElementById('picker')
        # ok = document.getElementById('ok')
        # cancel = document.getElementById('cancel')

        # for n in @slider.childNodes
            # do (n) =>
                # n && @slider.removeChild(n)
        # for n in @picker.childNodes
            # do (n) =>
                # n && picker.removeChild(n)

        # # @Todo how to correct remove the event,
        # ok.removeEventListener('click', @_colorPickerOkHandler, false)
        # cancel.removeEventListener('click', @_colorPickerCancelHandler, false)
        # ok.onclick = null
        # cancel.onclick = null
        # @_addHtmlEventListener(ok, 'click', (evt) -> )
        # @_addHtmlEventListener(cancel, 'click', (evt) -> )

        @elm.style.display = 'none'


    _addHtmlEventListener: (element, event, listener) ->
        if (element.attachEvent)
            element.attachEvent('on' + event, listener)
        else if (element.addEventListener)
            element.addEventListener(event, listener, false)


    _colorPickerOkHandler: (evt) =>
        @bead.setColor(@newColor)
        @disable()
        @colorIcon.click(@bead.colorHandler)
         
    _colorPickerCancelHandler: (evt) =>
        @disable()
        @colorIcon.click(@bead.colorHandler)
