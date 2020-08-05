goog.provide 'wzk.ui.grid'
goog.provide 'wzk.ui.grid.Params'

goog.require 'goog.Timer'

goog.require 'wzk.resource.Client'
goog.require 'wzk.ui.grid.Grid'
goog.require 'wzk.ui.grid.ArgsExtractor'
goog.require 'wzk.ui.grid.Repository'
goog.require 'wzk.ui.dialog.ConfirmDialog'
goog.require 'wzk.resource.AttrParser'
goog.require 'wzk.ui.grid.Messenger'
goog.require 'wzk.resource.Query'
goog.require 'wzk.ui.grid.FilterWatcher'
goog.require 'wzk.uri'
goog.require 'wzk.num'
goog.require 'wzk.ui.grid.PaneMode'
goog.require 'wzk.ui.grid.StateHolder'
goog.require 'wzk.ui.grid.Updater'
goog.require 'wzk.net.XhrConfig'
goog.require 'wzk.ui.grid.ExportLink'
goog.require 'wzk.ui.grid.GridColumnsManager'
goog.require 'wzk.ui.grid.BulkChange'
goog.require 'wzk.ui.grid.OffsetBasedPaginator'
goog.require 'wzk.ui.grid.CursorBasedPaginator'

###*
  @constructor
  @struct
  @param {Object=} params
###
wzk.ui.grid.Params = (params = {}) ->
  {@exportButtonsEl} = params

###*
  @param {Element} table
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} factory
  @param {wzk.app.Register} reg
  @param {wzk.stor.StateStorage} ss
  @param {wzk.ui.Flash} flash
  @param {wzk.ui.grid.Params=} params
  @return {wzk.ui.grid.Grid}
###
wzk.ui.grid.build = (table, dom, factory, reg, ss, flash, params = new wzk.ui.grid.Params()) ->
  wzk.ui.grid.buildGrid table, dom, factory, reg, ss, wzk.ui.grid.Grid, flash, params

###*
  @param {Element} table
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
  @param {wzk.app.Register} reg
  @param {wzk.stor.StateStorage} ss
  @param {Function} ctor
  @param {wzk.ui.Flash} flash
  @param {wzk.ui.grid.Params=} params
  @return {wzk.ui.grid.Grid}
###
wzk.ui.grid.buildGrid = (table, dom, xhrFac, reg, ss, ctor, flash, params = new wzk.ui.grid.Params()) ->
  parser = new wzk.resource.AttrParser()
  ctx = parser.parseContext table
  client = new wzk.resource.Client xhrFac, ctx
  extractor = new wzk.ui.grid.ArgsExtractor table
  repo = new wzk.ui.grid.Repository client
  query = new wzk.resource.Query parser.parseResource(table)

  for field in extractor.parseRestFields()
    query.addField field

  client.setDefaultFields query
  client.setDefaultHeader wzk.resource.Client.X_HEADERS.SERIALIZATION_FORMAT, query.verbose()
  client.setDefaultHeader wzk.resource.Client.X_HEADERS.FIELDS, query.composeFields()

  stateHolder = new wzk.ui.grid.StateHolder(ss, table.id)

  if dom.getParentElement(table)?.querySelector('.paginator.cursor-based-paginator')?
    paginator = new wzk.ui.grid.CursorBasedPaginator(stateHolder: stateHolder)
  else
    paginator = new wzk.ui.grid.OffsetBasedPaginator(stateHolder: stateHolder)

  dialog = new wzk.ui.dialog.ConfirmDialog undefined, undefined, dom

  grid = new ctor(
    dom, repo, extractor.parseColumns(), stateHolder, dialog, query, paginator, flash, extractor.parseRowSelectable())

  watcher = new wzk.ui.grid.FilterWatcher grid, query, ss, dom
  grid.setQuery watcher.watchOn(table)

  grid.decorate table

  columnsManagerCls = parser.getAttr(table, wzk.ui.grid.GridColumnsManager.DATA.GRID_DATA)
  if columnsManagerCls
    columnsManagerEl = dom.getElement(columnsManagerCls)
    if columnsManagerEl
      manager = new wzk.ui.grid.GridColumnsManager(dom, watcher, grid)
      manager.decorate(columnsManagerEl)

  stateHolder.handle paginator, watcher
  stateHolder.setBase paginator.getBase()

  msgr = new wzk.ui.grid.Messenger grid
  msgr.decorate dom.getParentElement table

  if wzk.ui.grid.PaneMode.usePane table
    query.removeField '_default_action'
    mode = new wzk.ui.grid.PaneMode client, dom, reg, ss, query
    mode.watchOn grid

  if goog.dom.dataset.has table, wzk.ui.grid.Updater.DATA.URL
    url = String goog.dom.dataset.get table, wzk.ui.grid.Updater.DATA.URL
    interval = wzk.num.parseDec String(goog.dom.dataset.get(table, wzk.ui.grid.Updater.DATA.INTERVAL)), wzk.ui.grid.Updater.REFRESH_INTERVAL
    xhrConfig = new wzk.net.XhrConfig loading: false
    updater = new wzk.ui.grid.Updater grid, new wzk.resource.Client(xhrFac, '', xhrConfig), url, interval
    updater.start()
  else if goog.dom.dataset.has(table, 'interval')
    wzk.ui.grid.autoRefresh(grid)


  {exportButtonsEl} = params
  exportButtonsEl ?= dom.one wzk.ui.grid.Grid.SELECTORS.EXPORT_BUTTONS
  exportButtonsEl ?= dom.getParentElement(table)
  exportElements = dom.clss wzk.ui.grid.ExportLink.CLS, exportButtonsEl
  for el in exportElements
    exportBtn = new wzk.ui.grid.ExportLink dom: dom, watcher: watcher, client: new wzk.resource.Client(xhrFac)
    exportBtn.decorate el

  if goog.dom.dataset.has(table, 'bulkChange')
    bulkChangeEl = dom.getElement(String(goog.dom.dataset.get(table, 'bulkChange')))
    if bulkChangeEl?
      bulkChange = new wzk.ui.grid.BulkChange(dom, new wzk.resource.Client(xhrFac), grid, reg, flash)
      bulkChange.decorate(bulkChangeEl)

  grid


###*
  @param {wzk.ui.grid.Grid} grid
###
wzk.ui.grid.autoRefresh = (grid) ->
  interval = wzk.num.parseDec(String(goog.dom.dataset.get(grid.table, 'interval')), 0)
  if interval > 1
    timer = new goog.Timer(interval)
    timer.listen(goog.Timer.TICK, -> grid.refresh())
    timer.start()
