goog.require 'wzk.ui.grid.Grid'
goog.require 'goog.style'

class wzk.ui.grid.Messenger

  ###*
    @enum {string}
  ###
  @CSS:
    SELECTOR: '.table-empty'

  ###*
    @param {wzk.ui.grid.Grid} grid
  ###
  constructor: (@grid) ->
    @grid.listen wzk.ui.grid.Grid.EventType.LOADED, @handleLoaded

  ###*
    @param {Element} parent
  ###
  decorate: (parent) ->
    @msgEl = parent.querySelector wzk.ui.grid.Messenger.CSS.SELECTOR

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleLoaded: (e) =>
    isEmpty = e.target.count is 0
    @grid.paginator.show not isEmpty
    goog.style.setElementShown @msgEl, isEmpty if @msgEl
