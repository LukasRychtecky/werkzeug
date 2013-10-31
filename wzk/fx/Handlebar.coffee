goog.provide 'wzk.fx.Handlebar'

goog.require 'wzk.ui.Component'
goog.require 'wzk.fx.HandlebarRenderer'

class wzk.fx.Handlebar extends wzk.ui.Component

  ###*
    @constructor
    @extends {wzk.ui.Component}
    @param {Object} params
  ###
  constructor: (params) ->
    params.renderer ?= wzk.fx.HandlebarRenderer.getInstance()
    super params
