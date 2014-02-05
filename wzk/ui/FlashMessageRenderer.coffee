goog.provide 'wzk.ui.FlashMessageRenderer'

goog.require 'wzk.ui.ComponentRenderer'

class wzk.ui.FlashMessageRenderer extends wzk.ui.ComponentRenderer

  ###*
    @constructor
    @extends {wzk.ui.ComponentRenderer}
  ###
  constructor: ->
    super()
    @tag = 'li'

  ###*
    @override
  ###
  createDom: (flash) ->
    dom = flash.getDomHelper()
    el = super flash
    txt = dom.el 'span', 'msg-text', el
    dom.setTextContent txt, flash.msg
    el

goog.addSingletonGetter wzk.ui.FlashMessageRenderer
