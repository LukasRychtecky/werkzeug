goog.provide 'wzk.ui.FlashRenderer'

goog.require 'wzk.ui.ComponentRenderer'

class wzk.ui.FlashRenderer extends wzk.ui.ComponentRenderer

  ###*
    @constructor
    @extends {wzk.ui.ComponentRenderer}
  ###
  constructor: ->
    super()
    @tag = 'ul'

  ###*
    @override
  ###
  createDom: (flash) ->
    el = super flash
    el

goog.addSingletonGetter wzk.ui.FlashRenderer
