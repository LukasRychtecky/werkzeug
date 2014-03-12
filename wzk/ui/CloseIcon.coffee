goog.provide 'wzk.ui.CloseIcon'

goog.require 'wzk.ui.Component'
goog.require 'wzk.ui.CloseIconRenderer'
goog.require 'goog.dom.classes'

class wzk.ui.CloseIcon extends wzk.ui.Component

  ###*
    @enum {string}
  ###
  @CLASSES:
    ICON: 'goog-icon-remove'

  ###*
    @constructor
    @extends {wzk.ui.Component}
    @param {Object=} params
      renderer: {@link wzk.ui.CloseIconRenderer}
  ###
  constructor: (params = {}) ->
    params.renderer ?= wzk.ui.CloseIconRenderer.getInstance()
    super params
    @addClass wzk.ui.CloseIcon.CLASSES.ICON

  ###*
    @override
  ###
  afterRendering: ->
    goog.events.listen @getElement(), goog.events.EventType.CLICK, =>
      @dispatchEvent goog.ui.Component.EventType.ACTION
    undefined # because of CoffeeScript

  ###*
    @override
  ###
  canDecorate: (el) ->
    el? and goog.dom.classes.has el, wzk.ui.CloseIcon.CLASSES.ICON

  ###*
    @override
  ###
  decorateInternal: (el) ->
    @setElementInternal el
