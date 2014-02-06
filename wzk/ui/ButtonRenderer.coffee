goog.provide 'wzk.ui.ButtonRenderer'

goog.require 'goog.ui.NativeButtonRenderer'
goog.require 'goog.dom.classes'

class wzk.ui.ButtonRenderer extends goog.ui.NativeButtonRenderer

  ###*
    @constructor
    @extends {goog.ui.NativeButtonRenderer}
  ###
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
    goog.dom.classes.add el, 'btn'
    el

goog.addSingletonGetter wzk.ui.ButtonRenderer
