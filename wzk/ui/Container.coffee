goog.provide 'wzk.ui.Container'

goog.require 'wzk.ui.Component'

class wzk.ui.Container extends wzk.ui.Component

  ###*
    @constructor
    @extends {wzk.ui.Component}
    @param {Object} params
  ###
  constructor: (params) ->
    super params

  ###*
    Replaces a child in the container

    @param {wzk.ui.Component} old
    @param {wzk.ui.Component} newChild
    @param {boolean=} render
  ###
  replace: (old, newChild, render = true) ->
    index = @indexOfChild old
    @removeChild old, render
    @addChildAt newChild, index, render
