goog.require 'goog.dom.classes'

class wzk.ui.tab.TabBarRenderer extends goog.ui.TabBarRenderer

  ###*
    @type {string}
  ###
  @CLASS = 'goog-tab-bar'

  constructor: ->
    super()

  ###*
    @override
  ###
  canDecorate: (el) ->
    goog.dom.classes.has el, wzk.ui.tab.TabBarRenderer.CLASS

goog.addSingletonGetter wzk.ui.tab.TabBarRenderer
