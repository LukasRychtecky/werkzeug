goog.provide 'wzk.ui.grid'

goog.require 'wzk.resource.Client'
goog.require 'wzk.ui.grid.Grid'
goog.require 'wzk.ui.grid.ArgsExtractor'
goog.require 'wzk.ui.grid.Repository'
goog.require 'goog.dom.dataset'
goog.require 'wzk.ui.dialog.ConfirmDialog'
goog.require 'wzk.resource.AttrParser'
goog.require 'wzk.ui.grid.Messenger'
goog.require 'wzk.resource.Query'
goog.require 'wzk.ui.grid.FilterWatcher'
goog.require 'wzk.uri'
goog.require 'wzk.num'
goog.require 'wzk.ui.grid.PaneMode'
goog.require 'wzk.ui.grid.PaginatorHandler'

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
  query.verbose()

  client.setDefaultExtraFields query

  dialog = new wzk.ui.dialog.ConfirmDialog undefined, undefined, dom
  dialog.setConfirm extractor.parseConfirm()
  dialog.setTitle extractor.parseTitle()
  dialog.setYesNoCaptions goog.dom.dataset.get(table, 'btnYes'), goog.dom.dataset.get(table, 'btnNo')

  pagHandler = new wzk.ui.grid.PaginatorHandler ss

  paginator = new wzk.ui.grid.Paginator base: pagHandler.getBase(), page: pagHandler.getPage()

  pagHandler.handle paginator

  grid = new ctor dom, repo, extractor.parseColumns(), dialog, query, paginator
  grid.decorate table

  pagHandler.setBase paginator.getBase()

  watcher = new wzk.ui.grid.FilterWatcher grid, query
  watcher.watchOn table

  msgr = new wzk.ui.grid.Messenger grid
  msgr.decorate dom.getParentElement table

  if wzk.ui.grid.PaneMode.usePane table
    mode = new wzk.ui.grid.PaneMode client, dom, reg, ss, query
    mode.watchOn grid

  grid
