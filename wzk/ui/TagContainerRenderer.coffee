goog.provide 'wzk.ui.TagContainerRenderer'

goog.require 'goog.ui.ControlRenderer'

class wzk.ui.TagContainerRenderer extends goog.ui.ControlRenderer

  ###*
    @constructor
    @extends {goog.ui.ControlRenderer}
  ###
  constructor: ->
    super()

  getCssClass: ->
    "tag-container"

goog.addSingletonGetter wzk.ui.TagContainerRenderer
