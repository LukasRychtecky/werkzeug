goog.provide 'wzk.ui.grid'

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

###*
  @param {Element} table
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} factory
  @param {wzk.app.Register} reg
  @param {wzk.stor.StateStorage} ss
  @return {wzk.ui.grid.Grid}
###
wzk.ui.grid.build = (table, dom, factory, reg, ss) ->
  wzk.ui.grid.buildGrid table, dom, factory, reg, ss, wzk.ui.grid.Grid

###*
  @param {Element} table
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
  @param {wzk.app.Register} reg
  @param {wzk.stor.StateStorage} ss
  @param {Function} ctor
  @return {wzk.ui.grid.Grid}
###
wzk.ui.grid.buildGrid = (table, dom, xhrFac, reg, ss, ctor) ->
  parser = new wzk.resource.AttrParser()
  ctx = parser.parseContext table
  client = new wzk.resource.Client xhrFac, ctx
  extractor = new wzk.ui.grid.ArgsExtractor table
  repo = new wzk.ui.grid.Repository client
  query = new wzk.resource.Query parser.parseResource(table)
  query.putDefaultExtraFields()

  client.setDefaultExtraFields query
  client.setDefaultHeader wzk.resource.Client.X_HEADERS.SERIALIZATION_FORMAT, query.verbose()
  client.setDefaultHeader wzk.resource.Client.X_HEADERS.EXTRA_FIELDS, query.composeExtraFields()

  stateHolder = new wzk.ui.grid.StateHolder ss

  paginator = new wzk.ui.grid.Paginator base: stateHolder.getBase(), page: stateHolder.getPage()

  dialog = new wzk.ui.dialog.ConfirmDialog undefined, undefined, dom

  grid = new ctor dom, repo, extractor.parseColumns(), dialog, query, paginator
  grid.decorate table

  watcher = new wzk.ui.grid.FilterWatcher grid, query, dom
  watcher.watchOn table

  stateHolder.handle paginator, watcher
  stateHolder.setBase paginator.getBase()

  msgr = new wzk.ui.grid.Messenger grid
  msgr.decorate dom.getParentElement table

  if wzk.ui.grid.PaneMode.usePane table
    query.removeExtraField '_default_action'
    mode = new wzk.ui.grid.PaneMode client, dom, reg, ss, query
    mode.watchOn grid

  if goog.dom.dataset.has table, wzk.ui.grid.Updater.DATA.URL
    url = String(goog.dom.dataset.get table, wzk.ui.grid.Updater.DATA.URL)
    interval = wzk.num.parseDec String(goog.dom.dataset.get(table, wzk.ui.grid.Updater.DATA.INTERVAL)), wzk.ui.grid.Updater.REFRESH_INTERVAL
    xhrConfig = new wzk.net.XhrConfig loading: false
    updater = new wzk.ui.grid.Updater grid, new wzk.resource.Client(xhrFac, '', xhrConfig), url, interval
    updater.start()

  exportElements = dom.clss wzk.ui.grid.ExportLink.CLS, dom.getParentElement(table)
  for el in exportElements
    exportBtn = new wzk.ui.grid.ExportLink dom: dom, watcher: watcher, client: new wzk.resource.Client(xhrFac)
    exportBtn.decorate el

  grid
