goog.provide 'wzk.ui.grid.Sorter'

goog.require 'goog.events'
goog.require 'goog.events.EventType'
goog.require 'goog.dom.classes'
goog.require 'goog.events.EventTarget'
goog.require 'goog.dom.dataset'

class wzk.ui.grid.Sorter extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @EventType:
    SORT: 'sort'

  ###*
    @enum {string}
  ###
  @DIRECTION:
    ASC: 'ASC'
    DESC: 'DESC'

  ###*
    @enum {string}
  ###
  @CLASSES:
    ASC: 'goog-tablesorter-sorted'
    DESC: 'goog-tablesorter-sorted-reverse'

  ###*
    @constructor
    @extends {goog.events.EventTarget}
    @param {goog.dom.DomHelper} dom
  ###
  constructor: (@dom) ->
    super()
    @table = null

  ###*
    @param {Element} table
  ###
  decorate: (@table) ->
    for th in table.querySelectorAll '.sortable'
      @hangListener th
      @createColNameIfMissing th

  ###*
    @protected
    @param {Element} th
  ###
  hangListener: (th) ->
    goog.events.listen th, goog.events.EventType.CLICK, (e) =>
      dir = wzk.ui.grid.Sorter.DIRECTION.ASC
      col = @getKey th
      C = wzk.ui.grid.Sorter.CLASSES

      if goog.dom.classes.has th, C.ASC
        @applyDesc th
        dir = wzk.ui.grid.Sorter.DIRECTION.DESC
      else if goog.dom.classes.has th, C.DESC
        @applyNoSort th
      else
        @applyAsc th

      @applyNoSortForOthers th

      @dispatchSort col, dir

  ###*
    @protected
    @param {Element} th
  ###
  applyNoSort: (th) ->
    goog.dom.classes.remove th, wzk.ui.grid.Sorter.CLASSES.ASC
    goog.dom.classes.remove th, wzk.ui.grid.Sorter.CLASSES.DESC

  ###*
    @protected
    @param {Element} th
  ###
  applyAsc: (th) ->
    goog.dom.classes.add th, wzk.ui.grid.Sorter.CLASSES.ASC
    goog.dom.classes.remove th, wzk.ui.grid.Sorter.CLASSES.DESC

  ###*
    @protected
    @param {Element} th
  ###
  applyDesc: (th) ->
    goog.dom.classes.remove th, wzk.ui.grid.Sorter.CLASSES.ASC
    goog.dom.classes.add th, wzk.ui.grid.Sorter.CLASSES.DESC

  ###*
    @protected
    @param {Element} sortedBy
  ###
  applyNoSortForOthers: (sortedBy) ->
    key = @getKey sortedBy
    for th in @table.querySelectorAll '.sortable'
      @applyNoSort(th) if @getKey(th) isnt key

  ###*
    @protected
    @param {Element} th
  ###
  getKey: (th) ->
    goog.dom.dataset.get th, 'col'

  ###*
    @protected
    @param {string} col
    @param {string} dir
  ###
  dispatchSort: (col, dir) ->
    @dispatchEvent new goog.events.Event(wzk.ui.grid.Sorter.EventType.SORT, {column: col, direction: dir})

  ###*
    @protected
    @param {Element} th
  ###
  createColNameIfMissing: (th) ->
    unless goog.dom.dataset.has th, 'col'
      col = @dom.getTextContent th
      goog.dom.dataset.set th, 'col', col.toLowerCase()
