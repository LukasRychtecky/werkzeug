goog.require 'wzk.ui.grid.Filter'
goog.require 'wzk.ui.grid.FilterExtended'
goog.require 'wzk.resource.FilterValue'
goog.require 'wzk.dom.classes'
goog.require 'goog.object'

class wzk.ui.grid.FilterWatcher extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGED: 'filter-changed'
    RESET_PAGINATOR: 'reset-paginator'

  ###*
    @param {wzk.ui.grid.Grid} grid
    @param {wzk.resource.Query} query
    @param {wzk.stor.StateStorage} ss
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@grid, @query, @ss, @dom) ->
    super()
    @fields = {}
    @initialCheck = true
    @ssKeys = {}
    @defaultFilters = {}

  ###*
    @param {Element} table
    @return {wzk.resource.Query}
  ###
  watchOn: (table) ->
    extFiltersEnabled = goog.dom.classes.has table, wzk.ui.grid.FilterExtended.CLS.ENABLED_FILTERS
    for field in @dom.all 'thead *[data-filter]', table
      filter = @buildFilter(field, extFiltersEnabled)
      if goog.object.containsKey(@fields, filter.getFilter())
        @dom.getWindow().console.warn(
          "Table ##{table.id} contains duplicated columns with name '#{filter.getFilter()}'.")
      else
        @fields[filter.getFilter()] = filter
        @watchField(filter)

    @updateInitialState()
    @query

  updateInitialState: ->
    @ssKeys = @adjustURIFilters(@ss.getAllKeys())
    @defaultFilters = @query.getDefaultFilters()
    @fillFiltersFromDefaults()
    @fillFiltersFromUri()
    @applyAllFilters()

  ###*
    @protected
  ###
  fillFiltersFromUri: ->
    for fieldName, field of @fields
      for paramKey, uriParam of @ssKeys
        if field.isValidFilterFormat(paramKey)
          field.fillFromUri(uriParam['operator'], uriParam['value'])

  ###*
    @protected
  ###
  fillFiltersFromDefaults: ->
    for key, value of @defaultFilters
      if @fields[key]? then @fields[key].setValue value else @query.filter new wzk.resource.FilterValue(key, '', value)

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
    @param {Object} namesWithOperators
    @return {Object}
  ###
  adjustURIFilters: (namesWithOperators) ->
    adjustedFilters = {}
    for nameWithOperator in namesWithOperators
      nameWithoutOperator = @getBareFilterName nameWithOperator
      adjustedFilters[nameWithOperator] =
        'operator': @getOperatorFromName(nameWithOperator, nameWithoutOperator)
        'value': @ss.get(nameWithOperator)
        'name': nameWithOperator

    adjustedFilters

  ###*
    @protected
    @param {string} nameWithOperator
    @return {string}
  ###
  getBareFilterName: (nameWithOperator) ->
    splittedName = nameWithOperator.split wzk.ui.grid.Filter.SEPARATOR
    if splittedName[splittedName.length - 2]? then @joinFilterName splittedName else splittedName[0]

  ###*
    @protected
    @param {Array} splittedFilterName
    @return {string}
  ###
  joinFilterName: (splittedFilterName) ->
    nameParts = (splittedFilterName[i] for i in [0..splittedFilterName.length - 2])
    nameParts.join wzk.ui.grid.Filter.SEPARATOR

  ###*
    @protected
    @param {string} nameWithOperator
    @param {string} nameWithoutOperator
    @return {string}
  ###
  getOperatorFromName: (nameWithOperator, nameWithoutOperator) ->
    nameWithOperator.replace(nameWithoutOperator, '').replace wzk.ui.grid.Filter.SEPARATOR, ''

  ###*
    @protected
    @param {Element} field
    @return {boolean}
  ###
  isFilterAllowed: (field) ->
    wzk.dom.classes.hasAny(field, ['date', 'datetime']) or field.type in ['number', 'date', 'datetime']

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
    @param {wzk.ui.grid.Filter} triggeredFilter
  ###
  filter: (triggeredFilter) ->
    if triggeredFilter.apply(@query)
      for filterName, filter of @fields
        if goog.string.startsWith(filterName, triggeredFilter.getName())
          filter.apply(@query)
      @dispatchEvent new goog.events.Event wzk.ui.grid.FilterWatcher.EventType.RESET_PAGINATOR, {}
      @dispatchChanged()

  ###*
    @protected
  ###
  dispatchChanged: ->
    @dispatchEvent new goog.events.Event wzk.ui.grid.FilterWatcher.EventType.CHANGED, {}

  ###*
    @protected
  ###
  applyAllFilters: ->
    for filterName, filter of @fields
      filter.apply @query

  resetFilters: ->
    for filterName, filter of @fields
      filter.reset()
      filter.apply @query

  resetFiltering: ->
    @resetFilters()
    @dispatchChanged()

  ###*
    @return {wzk.resource.Query}
  ###
  getQuery: ->
    @query


  ###*
    @protected
    @return {boolean}
  ###
  hasValueChanged: (filter, value) ->
    (@defaultFilters[filter.getName()]? and value is '') or value isnt ''

  ###*
    @return {Object}
  ###
  getParams: ->
    params = {}
    for filterName, filter of @fields
      value = filter.getValue()
      if @hasValueChanged(filter, value)
        params[filter.getParamName()] = value
    params

  ###*
    @return {Array}
  ###
  getFiltersNames: ->
    (filterName for filterName, filter of @fields)

  ###*
    @return {wzk.ui.grid.Grid}
  ###
  getGrid: ->
    @grid

  ###*
    @return {Object}
  ###
  getFields: ->
    @fields
