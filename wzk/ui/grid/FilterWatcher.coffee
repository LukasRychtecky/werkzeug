goog.require 'wzk.ui.grid.Filter'
goog.require 'wzk.ui.grid.FilterExtended'
goog.require 'wzk.dom.classes'

class wzk.ui.grid.FilterWatcher extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGED: 'filter-changed'

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
    extFiltersEnabled = goog.dom.classes.has table, wzk.ui.grid.FilterExtended.CLS.ENABLED_FILTERS
    for field in @dom.all 'thead *[data-filter]', table
      filter = @buildFilter field, extFiltersEnabled
      @fields[filter.getName()] = filter
      @watchField filter

    @grid.listen wzk.ui.grid.Grid.EventType.LOADED, @handleLoad

  ###*
    @protected
    @param {Element} field
    @param {boolean} extFiltersEnabled
    @return {wzk.ui.grid.Filter}
  ###
  buildFilter: (field, extFiltersEnabled) ->
    if extFiltersEnabled and @isFilterAllowed(field)
      return new wzk.ui.grid.FilterExtended @dom, field
    new wzk.ui.grid.Filter @dom, field

  ###*
    @protected
    @param {Element} field
    @return {boolean}
  ###
  isFilterAllowed: (field) ->
    wzk.dom.classes.hasAny(field, ['date', 'datetime']) or field.type in ['number', 'date', 'datetime']

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleLoad: (e) =>
    if @initialCheck
      @query.each (k, v) =>
        if @fields[k]?
          @fields[k].setValue v[0]
    else
      for k, field of @fields
        @filter field
    @initialCheck = false

  ###*
    @protected
    @param {wzk.ui.grid.Filter} filter
  ###
  watchField: (filter) ->
    goog.events.listen filter, wzk.ui.grid.Filter.EVENTS.CHANGE, @handleChange

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleChange: (e) =>
    filter = (`/** @type {wzk.ui.grid.Filter} */`) e.currentTarget
    @filter filter

  ###*
    @protected
    @param {wzk.ui.grid.Filter} filter
  ###
  filter: (filter) ->
    if filter.apply @query
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
