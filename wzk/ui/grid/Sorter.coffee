goog.require 'goog.events'
goog.require 'goog.object'
goog.require 'wzk.ui.grid.THeader'

class wzk.ui.grid.Sorter extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @EVENTS:
    SORT: 'sort'

  ###*
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@dom) ->
    super()
    @table = null
    @headers = []

  ###*
    @param {Element} table
  ###
  decorate: (@table) ->
    for th in @dom.clss('sortable', table)
      header = new wzk.ui.grid.THeader(@dom, th)
      goog.events.listen header, goog.object.getValues(wzk.ui.grid.THeader.EVENTS), @handleSort
      @headers.push header

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSort: (e) =>
    @dispatchEvent new goog.events.Event(wzk.ui.grid.Sorter.EVENTS.SORT, e.target)
