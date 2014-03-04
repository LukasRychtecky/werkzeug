goog.require 'goog.dom.classes'

class wzk.ui.ButtonRenderer extends goog.ui.NativeButtonRenderer

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

  ###*
    Allows decorating any element.
    @override
    @param {Element} el
  ###
  canDecorate: (el) ->
    if el.tagName is 'DIV' or el.tagName is 'SPAN'
      return true
    else
      return super el

goog.addSingletonGetter wzk.ui.ButtonRenderer
