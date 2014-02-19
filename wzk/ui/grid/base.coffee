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

###*
  @param {Element} table
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} factory
  @return {wzk.ui.grid.Grid}
###
wzk.ui.grid.build = (table, dom, factory) ->
  wzk.ui.grid.buildGrid table, dom, factory, wzk.ui.grid.Grid

###*
  @param {Element} table
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
  @param {Function} ctor
  @return {wzk.ui.grid.Grid}
###
wzk.ui.grid.buildGrid = (table, dom, xhrFac, ctor) ->
  parser = new wzk.resource.AttrParser()
  ctx = parser.parseContext table
  client = new wzk.resource.Client xhrFac, ctx
  extractor = new wzk.ui.grid.ArgsExtractor table
  repo = new wzk.ui.grid.Repository client
  query = new wzk.resource.Query parser.parseResource(table)

  dialog = new wzk.ui.dialog.ConfirmDialog undefined, undefined, dom
  dialog.setConfirm extractor.parseConfirm()
  dialog.setTitle extractor.parseTitle()
  dialog.setYesNoCaptions goog.dom.dataset.get(table, 'btnYes'), goog.dom.dataset.get(table, 'btnNo')

  grid = new ctor dom, repo, extractor.parseColumns(), extractor.parseActions(), dialog, query

  msgr = new wzk.ui.grid.Messenger grid
  msgr.decorate dom.getParentElement(table)

  grid.decorate table

  watcher = new wzk.ui.grid.FilterWatcher grid, query
  watcher.watchOn table
  grid
