goog.provide 'wzk.ui.FlashRenderer'

goog.require 'wzk.ui.ComponentRenderer'

class wzk.ui.FlashRenderer extends wzk.ui.ComponentRenderer

  ###*
    @enum {string}
  ###
  @CLASSES:
    FLASH: 'flash'

  ###*
    @constructor
    @extends {wzk.ui.ComponentRenderer}
  ###
  constructor: ->
    super()
    @classes.push wzk.ui.FlashRenderer.CLASSES.FLASH

goog.addSingletonGetter wzk.ui.FlashRenderer
