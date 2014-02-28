goog.require 'wzk.ui.grid.RowRenderer'
goog.require 'wzk.ui.grid.Cell'

class wzk.ui.grid.Row extends wzk.ui.Control

  ###*
    @enum {string}
  ###
  @EventType:
    REMOTE_BUTTON: 'RemoteButton'
    DELETE_BUTTON: 'DeleteButton'

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

  ###*
    @override
  ###
  isAllowTextSelection: ->
    return true

  ###*
    @param {goog.events.Event} e
  ###
  handleRemoteButton: (e)->
    @dispatchEvent new goog.events.Event(wzk.ui.grid.Row.EventType.REMOTE_BUTTON, e.target)

  ###*
    @param {goog.events.Event} e
  ###
  handleDeleteBtn: (e) ->
    @dispatchEvent new goog.events.Event(wzk.ui.grid.Row.EventType.DELETE_BUTTON, e.target)
