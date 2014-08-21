goog.require 'wzk.ui.ButtonRenderer'

class wzk.ui.Button extends goog.ui.Button

  ###*
    @param {Object} params
      content {goog.ui.ControlContent=}
      renderer {goog.ui.ButtonRenderer=}
      dom {goog.dom.DomHelper=}
  ###
  constructor: (params = {}) ->
    params.renderer ?= wzk.ui.ButtonRenderer.getInstance()
    super params.content, params.renderer, params.dom
    @dom = params.dom
