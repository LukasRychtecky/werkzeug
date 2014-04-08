goog.require 'goog.dom.classes'
goog.require 'wzk.ui.Component'
goog.require 'wzk.ui.IconRenderer'

###*
    Descendants must implement getClass() method, that returns
    icon class.
###
class wzk.ui.IconComponent extends wzk.ui.Component

  ###*
    @param {Object} params
      dom: {@link wzk.dom.Dom}
      renderer: a renderer for the component, defaults {@link wzk.ui.ComponentRenderer}
      caption: {string}
      classname: {string}
  ###
  constructor: (params = {}) ->
    params.renderer ?= new wzk.ui.IconRenderer params.classname
    super params

    @addClass params.classname

  ###*
    @override
  ###
  afterRendering: ->
    goog.events.listen @getElement(), goog.events.EventType.CLICK, (e) =>
      e.preventDefault()
      @dispatchEvent goog.ui.Component.EventType.ACTION
    undefined # because of CoffeeScript

  ###*
    @override
  ###
  canDecorate: (el) ->
    el? and goog.dom.classes.has el, @classname

  ###*
    @override
  ###
  decorateInternal: (el) ->
    @setElementInternal el
