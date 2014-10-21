goog.require 'goog.dom.dataset'
goog.require 'goog.dom.forms'
goog.require 'wzk.events.lst'

class wzk.ui.grid.FilterWatcher extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGED: 'filter-changed'

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
    super()
    @fields = {}
    @initialCheck = true

  ###*
    @param {Element} table
  ###
  watchOn: (table) ->
    for field in @dom.all 'thead *[data-filter]', table
      @fields[field.name.split('__').pop()] = field
      @watchField field

    @grid.listen wzk.ui.grid.Grid.EventType.LOADED, @handleLoad

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleLoad: (e) =>
    if @initialCheck
      @query.each (k, v) =>
        if @fields[k]?
          goog.dom.forms.setValue @fields[k], v[0]
    else
      for k, field of @fields
        @filter field
    @initialCheck = false

  ###*
    @protected
    @param {Element} field
  ###
  watchField: (field) ->
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
      @query.offset = 0
      @grid.setQuery @query
      @grid.refresh()
      @dispatchChanged()

  ###*
    @protected
  ###
  dispatchChanged: ->
    @dispatchEvent new goog.events.Event(wzk.ui.grid.FilterWatcher.EventType.CHANGED, {})

  ###*
    @return {wzk.resource.Query}
  ###
  getQuery: ->
    @query
