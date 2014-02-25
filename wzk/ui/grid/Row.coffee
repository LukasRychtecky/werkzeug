goog.require 'wzk.ui.grid.RowRenderer'
goog.require 'wzk.ui.grid.Cell'

class wzk.ui.grid.Row extends wzk.ui.Control

  constructor: (params = {}) ->
    params.renderer ?= wzk.ui.grid.RowRenderer.getInstance()
    super params
    @cells = []

  ###*
    @param {string} text
    @return {wzk.ui.grid.Cell}
  ###
  addCell: (text) ->
    cell = new wzk.ui.grid.Cell dom: @dom, caption: text
    @addChild cell
    cell
