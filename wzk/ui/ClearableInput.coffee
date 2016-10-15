goog.require 'wzk.ui.Input'
goog.require 'wzk.ui.CloseIcon'
goog.require 'wzk.testing.events'

class wzk.ui.ClearableInput extends wzk.ui.Input

  ###*
    @enum {string}
  ###
  @EventType:
    CLEAR: 'clear'

  ###*
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@dom) ->
    super(null, null, @dom)

    @clrBtn = new wzk.ui.CloseIcon dom: @dom
    @clrBtn.listen goog.ui.Component.EventType.ACTION, @handleClean

  ###*
    @override
  ###
  render: (@container) ->
    super @container
    @clrBtn.render @container
    @hideClearButton()

    @setElementInternal @getElement()

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleClean: (e) =>
    @setValue ''
    @hideClearButton()
    wzk.testing.events.fireBrowserEvent new wzk.testing.events.Event(goog.events.EventType.CHANGE, @getElement())
    @dispatchEvent new goog.events.Event(wzk.ui.ClearableInput.EventType.CLEAR, @)

  hideClearButton: ->
    goog.style.setElementShown @clrBtn.getElement(), false

  showClearButton: ->
    unless @getElement().getAttribute("readonly")
      goog.style.setElementShown @clrBtn.getElement(), true

  ###*
    @override
  ###
  handleInputChange: (e) ->
    super(e)
    text = @getValue()

    if text
      @showClearButton()
    else
      @dispatchEvent new goog.events.Event(wzk.ui.ClearableInput.EventType.CLEAR, @)
      @hideClearButton()
