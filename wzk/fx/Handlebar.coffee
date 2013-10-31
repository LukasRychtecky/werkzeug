goog.provide 'wzk.fx.Handlebar'

goog.require 'wzk.ui.Control'
goog.require 'wzk.fx.HandlebarRenderer'

class wzk.fx.Handlebar extends wzk.ui.Control

  ###*
    @constructor
    @extends {wzk.ui.Control}
    @param {Object} params
  ###
  constructor: (params) ->
    params.renderer ?= wzk.fx.HandlebarRenderer.getInstance()
    super params
