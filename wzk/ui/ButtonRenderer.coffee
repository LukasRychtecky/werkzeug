goog.require 'goog.dom.classes'

class wzk.ui.ButtonRenderer extends goog.ui.ButtonRenderer

  ###*
    @enum {string}
  ###
  @CLASSES:
    BUTTON: 'btn'

  constructor: ->
    super()

  ###*
    @override
  ###
  createDom: (btn) ->
    el = super btn
    dom = btn.getDomHelper()
    dom.setTextContent el, ''
    span = dom.el 'span', {}, el
    dom.setTextContent span, btn.getCaption()
    goog.dom.classes.add el, wzk.ui.ButtonRenderer.CLASSES.BUTTON
    el

goog.addSingletonGetter wzk.ui.ButtonRenderer
