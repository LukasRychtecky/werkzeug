goog.provide 'wzk.ui.Container'

goog.require 'wzk.ui.Control'

class wzk.ui.Container extends wzk.ui.Control

  ###*
    @constructor
    @extends {wzk.ui.Control}
    @param {Object} params
      dom: {@link wzk.dom.Dom}
      renderer: {@link goog.ui.ControlRenderer}
      orientation: {@link goog.ui.Container.Orientation}
  ###
  constructor: (params) ->
    super params.orientation, params.renderer, params.dom

  ###*
    Replaces a child in the container

    @param {goog.ui.Control} old
    @param {goog.ui.Control} newChild
    @param {boolean} render
  ###
  replace: (old, newChild, render = true) ->
    index = @indexOfChild old
    @removeChild old, render
    @addChildAt newChild, index, render
