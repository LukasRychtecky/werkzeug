goog.provide 'wzk.fx.HandlebarRenderer'

goog.require 'goog.ui.ControlRenderer'

class wzk.fx.HandlebarRenderer extends goog.ui.ControlRenderer

  ###*
    @constructor
    @extends {goog.ui.ControlRenderer}
  ###
  constructor: ->
    super

  ###*
    @override
  ###
  createDom: (control) ->
    el = super control
    el.appendChild @buildHandler(control)
    el

  ###*
    @protected
    @param {goog.ui.Control} control
  ###
  buildHandler: (control) ->
    control.getDomHelper().createDom 'span', 'icon-handle'

goog.addSingletonGetter wzk.fx.HandlebarRenderer
