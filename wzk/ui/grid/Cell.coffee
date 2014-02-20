goog.require 'wzk.ui.grid.CellRenderer'

class wzk.ui.grid.Cell extends wzk.ui.Component

  constructor: (params) ->
    params.renderer ?= wzk.ui.grid.CellRenderer.getInstance()
    super params
