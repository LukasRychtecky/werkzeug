goog.require 'wzk.ui.grid.RowRenderer'
goog.require 'wzk.ui.grid.Cell'

class wzk.ui.grid.Row extends wzk.ui.Control

  ###*
    @enum {string}
  ###
  @EventType:
    REMOTE_BUTTON: 'RemoteButton'
    DELETE_BUTTON: 'DeleteButton'
    SELECTION_CHANGE: 'selection-change'

  constructor: (params = {}) ->
    params.renderer ?= wzk.ui.grid.RowRenderer.getInstance()
    super params
    @confirm = params.confirm
    @cells = []
    @selectable = null

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
    @param {wzk.ui.form.Field} selectable
  ###
  setSelectable: (@selectable) ->
    @selectable.listen(wzk.ui.form.Field.EVENTS.CHANGE, @handleSelected)

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSelected: (e) ->
    @dispatchEvent(new goog.events.Event(wzk.ui.grid.Row.EventType.SELECTION_CHANGE, e))

  ###*
    @return {boolean}
  ###
  isSelected: ->
    return @selectable? and Boolean(@selectable.getValue())

  ###*
    @param {goog.events.Event} e
  ###
  handleRemoteButton: (e) =>
    action = e.target.getModel()['action']
    confirm = action['confirm']
    btn = e.target

    if confirm
      @confirm.setContent confirm['text']
      @confirm.setTitle confirm['title']
      @confirm.setYesNoCaptions confirm['true_label'], confirm['false_label']
      @confirm.open()
      @confirm.focus()
      goog.events.listenOnce @confirm, goog.ui.Dialog.EventType.SELECT, (e) =>
        if e.key is goog.ui.Dialog.DefaultButtonKeys.YES
          if action['method'] is 'DELETE'
            @dispatchEvent new goog.events.Event(wzk.ui.grid.Row.EventType.DELETE_BUTTON, btn)
          else
            @dispatchEvent new goog.events.Event(wzk.ui.grid.Row.EventType.REMOTE_BUTTON, btn)
    else
      @dispatchEvent new goog.events.Event(wzk.ui.grid.Row.EventType.REMOTE_BUTTON, e.target)

  ###*
    @param {goog.events.Event} e
  ###
  handleDeleteBtn: (e) ->
    @dispatchEvent new goog.events.Event(wzk.ui.grid.Row.EventType.DELETE_BUTTON, e.target)
