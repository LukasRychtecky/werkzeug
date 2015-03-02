goog.require 'goog.events'
goog.require 'goog.json'
goog.require 'goog.style'
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
  ###
  constructor:(@dom, @filterWatcher) ->
    super()
    @headers = []
    @grid = @filterWatcher.getGrid()
    @cols = {}
    @filterStates = {}
    @checkbs = []
    @verboseCols = []
    @allCols = @grid.cols
    @sKey = @getStorageKey()
    @table = @grid.getElement()
    @filteringText = ''
    @filteringTextEl = null
    @lStorage = new app.stor.LocalStorage @dom.getWindow()['localStorage']

    @createStorage()

  ###*
    @param {Element} el
  ###
  decorate: (@el) =>
    super @el
    @headers = @dom.all 'thead > tr > th', @table
    @verboseCols = @getVerboseColNames()
    @cols = @getOrCreateState()
    @filterStates = @getInitialFilterStates()
    @filteringTextEl = @dom.cls wzk.ui.grid.GridColumnsManager.CLS.COLUMNS_FILTERING_TEXT
    if @filteringTextEl
      @filteringText = @filteringTextEl.innerHTML
      @dom.hide @filteringTextEl
      goog.events.listen @filteringTextEl, goog.events.EventType.CLICK, @deleteFilters

    goog.events.listen @grid, wzk.ui.grid.Grid.EventType.LOADED, =>
      @show @getVisibleCols()

    goog.events.listen @filterWatcher, wzk.ui.grid.FilterWatcher.EventType.CHANGED, @filterChanged

    @render()

  ###*
    @protected
  ###
  render: =>
    list = @dom.el 'ul', wzk.ui.grid.GridColumnsManager.CLS.LIST
    idPrefix = wzk.ui.grid.GridColumnsManager.LEAF_ID_PREFIX

    for col, i in @allCols
      leaf = @dom.el 'li', wzk.ui.grid.GridColumnsManager.CLS.LEAF
      label = @dom.el 'label', (if @filterStates[col] then wzk.ui.grid.GridColumnsManager.CLS.IS_FILTERED else ''), @verboseCols[col]
      label.htmlFor = idPrefix + col
      checkb = @dom.el 'input', type: 'checkbox', name: col, checked: (if @cols[col]? then @cols[col] else true), id: idPrefix + col

      @checkbs.push checkb
      goog.events.listen checkb, goog.events.EventType.CLICK, @handleChange

      leaf.appendChild checkb
      leaf.appendChild label

      list.appendChild leaf

    @saveState @getVisibleCols()

    @removeOld()
    @el.appendChild list

  ###
    @protected
  ###
  removeOld: =>
    @dom.removeNode @dom.cls wzk.ui.grid.GridColumnsManager.CLS.LIST, @el

  ###*
    @protected
  ###
  getStorageKey: =>
    wzk.ui.grid.GridColumnsManager.STORAGE_KEY

  ###*
    @protected
  ###
  getOrCreateState: =>
    cols = (`/** @type Object */`) @lStorage.get @sKey
    if @cols.length is 0
      for col in @allCols
        cols[col] = true
      @saveState cols

    cols

  ###*
    @protected
  ###
  getInitialFilterStates: =>
    states = {}
    for col in @allCols
      states[col] = false
    states

  ###*
    @protected
  ###
  createStorage: =>
    @lStorage.set @sKey, {} if @lStorage.get(@sKey) is null

  ###*
    @protected
    @return {Object}
  ###
  getVerboseColNames: =>
    verboseNames = {}
    for span, i in @dom.all 'th > span', @table
      verboseNames[@allCols[i]] = @dom.getTextContent span
    verboseNames

  ###*
    @protected
  ###
  handleChange: =>
    @cols = @getVisibleCols()
    @show @cols
    @saveState @cols

  ###*
    @protected
  ###
  filterChanged: =>
    @setFilterStates @filterWatcher.getQuery()
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
    @lStorage.set @sKey, state

  ###*
    @return {Object}
  ###
  getVisibleCols: =>
    cols = {}
    for checkb, i in @checkbs
      cols[checkb.name] = checkb['checked']? and checkb['checked']
    cols

  ###*
    @protected
    @param {Object} state
  ###
  updateFilteringText: (state) =>
    hiddenFiltered = (@verboseCols[colName].toLowerCase() for colName, isVisible of state when not isVisible and @filterWatcher.getQuery().hasFilter(colName))
    if hiddenFiltered.length > 0
      @filteringTextEl.innerHTML = @filteringText.replace('%(columns)s', hiddenFiltered.join(', '))
      @dom.show @filteringTextEl
    else
      @dom.hide @filteringTextEl

  ###*
    @protected
  ###
  showOrHideHeader: =>
    goog.style.setElementShown @headers[i], @cols[checkb['name']] for checkb, i in @checkbs when @headers[i]?

  ###*
    @protected
  ###
  deleteFilters: =>
    @filterWatcher.reset()

  ###*
    @protected
    @param {Object} cols
  ###
  show: (cols) =>
    arrCols = @toArray cols
    @grid.setColumns arrCols
    @grid.rowBuilder.setColumns arrCols
    @showOrHideHeader()
    @grid.refresh()

  ###*
    @protected
    @param {Object} cols
    @return {Array}
  ###
  toArray: (cols) =>
    (col for col in @allCols when cols[col])
