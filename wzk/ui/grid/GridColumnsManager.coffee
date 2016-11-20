goog.require 'goog.events'
goog.require 'goog.json'
goog.require 'goog.object'
goog.require 'goog.style'

goog.require 'wzk.obj'
goog.require 'wzk.stor.LocalStorage'


class wzk.ui.grid.GridColumnsManager extends wzk.ui.Component

  ###*
    @const {string} local storage key
  ###
  @STORAGE_KEY: 'columns_storage'

  ###*
    @const {string} leaf id prefix
  ###
  @LEAF_ID_PREFIX: 'manage-'

  ###*
    @enum {string} used classes
  ###
  @CLS:
    LEAF: 'managed-col'
    IS_FILTERED: 'is-filtered'
    LIST: 'managed-columns'
    COLUMNS_FILTERING_TEXT: 'columns-filtering-text'

  ###*
    @enum {string} data attrs
  ###
  @DATA:
    GRID_DATA: 'columnsManager'

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.ui.grid.FilterWatcher} filterWatcher
    @param {wzk.ui.grid.Grid} grid
  ###
  constructor:(@dom, @filterWatcher, @grid) ->
    super()
    @headers = []
    @cols = {}
    @filterStates = {}
    @checkboxes = []
    @verboseCols = []
    @allCols = @grid.cols
    @storageKey = @composeStorageKey()
    @filteringText = ''
    @filteringTextEl = null
    @storage = new wzk.stor.LocalStorage @dom.getWindow()['localStorage']

  ###*
    @param {Element} el
  ###
  decorate: (@el) =>
    unless @grid.table.id or @grid.table.id is ''
      @dom.getWindow().console.warn('Missing table id attribute for ' + @grid.table.className)
      return

    super(@el)
    @headers = @dom.all('thead > tr > th', @grid.table)
    @verboseCols = @getVerboseColNames()
    @cols = @getOrCreateState()

    @filterStates = @getInitialFilterStates()
    @filteringTextEl = @dom.getElement([wzk.ui.grid.GridColumnsManager.CLS.COLUMNS_FILTERING_TEXT, @grid.table.id].join('-'))
    unless @filteringTextEl
      @dom.getWindow().console.warn('Missing filtering text element for #' + @el.id)
      return

    @filteringText = @filteringTextEl.innerHTML
    @dom.hide(@filteringTextEl)
    goog.events.listen(@filteringTextEl, goog.events.EventType.CLICK, @deleteFilters)
    goog.events.listen(@grid, wzk.ui.grid.Grid.EventType.LOADED, @handleGridLoaded)
    goog.events.listen(@filterWatcher, wzk.ui.grid.FilterWatcher.EventType.CHANGED, @filterChanged)

    @render()

  ###*
    @protected
  ###
  handleGridLoaded: =>
    @show(@getVisibleCols())

  ###*
    @protected
    @param {string} prefix
    @param {string} column
    @return {string}
  ###
  composeCheckboxId: (prefix, column) ->
    [@grid.table.id, prefix, column].join('')

  ###*
    @protected
    @param {string} checkboxId
    @param {string} column
    @param {Element} parent
    @return {Element}
  ###
  buildLabel: (checkboxId, column, parent) ->
    label = @dom.el(
      'label',
      {
        'class': if @filterStates[column] then wzk.ui.grid.GridColumnsManager.CLS.IS_FILTERED else ''
        'for': checkboxId
      },
      @verboseCols[column],
    )
    @dom.append(parent, label)
    return label

  ###*
    @protected
    @param {string} id
    @param {string} column
    @param {Element} parent
    @return {Element}
  ###
  buildCheckbox: (id, column, parent) ->
    return @dom.el(
      'input',
      {
        type: 'checkbox',
        name: column,
        checked: (if @cols[column]? then @cols[column] else true),
        id: id
      },
      parent
    )

  ###*
    @protected
    @param {string} col
    @param {Element} columnList
    @return {Element}
  ###
  buildColumnItem: (col, columnList) ->
    colItem = @dom.el('li', wzk.ui.grid.GridColumnsManager.CLS.LEAF)
    checkboxId = @composeCheckboxId(wzk.ui.grid.GridColumnsManager.LEAF_ID_PREFIX, col)
    checkbox = @buildCheckbox(checkboxId, col, colItem)
    @buildLabel(checkboxId, col, colItem)
    goog.events.listen(checkbox, goog.events.EventType.CLICK, @handleChange)
    @dom.append(columnList, colItem)
    return checkbox

  ###*
    @protected
  ###
  render: =>
    columnList = @dom.el('ul', wzk.ui.grid.GridColumnsManager.CLS.LIST)

    @checkboxes = (@buildColumnItem(col, columnList) for col, _ in @allCols)
    @saveState(@getVisibleCols())

    @removeOld()
    @dom.append(@el, columnList)

  ###
    @protected
  ###
  removeOld: =>
    @dom.removeNode(@dom.cls wzk.ui.grid.GridColumnsManager.CLS.LIST, @el)

  ###*
    @protected
  ###
  composeStorageKey: ->
    [wzk.ui.grid.GridColumnsManager.STORAGE_KEY, @grid.table.id].join('-')

  ###*
    @protected
    @return {Object}
  ###
  getOrCreateState: =>
    cols = (`/** @type Object */`) @storage.get(@storageKey)
    if not cols
      cols = {}
      for col in @allCols
        cols[col] = true
      @storage.set(@storageKey, cols)

    cols

  ###*
    @protected
  ###
  getInitialFilterStates: =>
    return wzk.obj.dict(@filterWatcher.getFields(), (filter, _) -> [filter.getName(), filter.getValue() isnt ''])

  ###*
    @protected
    @return {Object}
  ###
  getVerboseColNames: =>
    return wzk.obj.dict(@dom.all('th > span', @grid.table), (span, i) => [@allCols[i], @dom.getTextContent(span)])

  ###*
    @protected
  ###
  handleChange: =>
    @cols = @getVisibleCols()
    @show(@cols)
    @saveState(@cols)

  ###*
    @protected
  ###
  filterChanged: =>
    @setFilterStates(@filterWatcher.getQuery())
    @render()

  ###*
    @protected
    @param {wzk.resource.Query} query
  ###
  setFilterStates: (query) =>
    for name, isFiltered of @filterStates
      @filterStates[name] = query.filters[name]?

  ###*
    @protected
    @param {Object} state
  ###
  saveState: (state) =>
    @updateFilteringText state
    @storage.set(@storageKey, state)

  ###*
    @return {Object}
  ###
  getVisibleCols: =>
    wzk.obj.dict(@checkboxes, (checkbox, _) -> [checkbox.name, checkbox['checked']? and checkbox['checked']])

  ###*
    @protected
    @param {Object} state
  ###
  updateFilteringText: (state) =>
    hiddenFiltered = (@verboseCols[colName].toLowerCase() for colName, isVisible of state when not isVisible and @filterWatcher.getQuery().hasFilter(colName))

    if hiddenFiltered.length > 0
      @filteringTextEl.innerHTML = @filteringText.replace('%(columns)s', hiddenFiltered.join(', '))
      @dom.show(@filteringTextEl)
    else
      @dom.hide(@filteringTextEl)

  ###*
    @protected
  ###
  showOrHideHeader: =>
    (goog.style.setElementShown(@headers[i], @cols[checkbox['name']]) for checkbox, i in @checkboxes when @headers[i]?)

  ###*
    @protected
  ###
  deleteFilters: =>
    @filterWatcher.resetFiltering()

  ###*
    @protected
    @param {Object} cols
  ###
  show: (cols) =>
    arrCols = @toArray(cols)
    @grid.setColumns(arrCols)
    @grid.rowBuilder.setColumns(arrCols)
    @showOrHideHeader()

  ###*
    @protected
    @param {Object} cols
    @return {Array}
  ###
  toArray: (cols) =>
    (col for col in @allCols when cols[col])
