goog.require 'goog.dom.dataset'
goog.require 'goog.dom.forms'
goog.require 'wzk.events.lst'

class wzk.ui.grid.FilterWatcher

  ###*
    @enum {string}
  ###
  @DATA:
    FILTER: 'filter'

  ###*
    @param {wzk.ui.grid.Grid} grid
    @param {wzk.resource.Query} query
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@grid, @query, @dom) ->
    @fields = []
    @initialCheck = false

  ###*
    @param {Element} table
  ###
  watchOn: (table) ->
    for field in table.querySelectorAll 'thead *[data-filter]'
      @fields.push field
      @listen field

    @grid.listen wzk.ui.grid.Grid.EventType.LOADED, @handleLoad

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleLoad: (e) =>
    unless @initialCheck
      for field in @fields
        @filter field
      @initialCheck = true

  ###*
    @protected
    @param {Element} field
  ###
  listen: (field) ->
    wzk.events.lst.onChangeOrKeyUp field, (e) =>
      el = (`/** @type {Element} */`) e.target
      @filter el

  ###*
    @protected
    @param {Element} el
  ###
  filter: (el) ->
    D = wzk.ui.grid.FilterWatcher.DATA
    name = String goog.dom.dataset.get(el, D.FILTER)
    val = goog.dom.forms.getValue(el)
    if @query.isChanged name, val
      @query.filter name, val
      @grid.setQuery @query
      @grid.refresh()
