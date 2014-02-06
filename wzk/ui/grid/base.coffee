goog.provide 'wzk.ui.grid'

goog.require 'wzk.resource.Client'
goog.require 'wzk.ui.grid.Grid'
goog.require 'wzk.ui.grid.ArgsExtractor'
goog.require 'wzk.ui.grid.Repository'
goog.require 'goog.dom.dataset'
goog.require 'wzk.ui.Dialog'
goog.require 'wzk.resource.AttrParser'

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
  repo = new wzk.ui.grid.Repository client, parser.parseResource(table)

  dialog = new wzk.ui.Dialog undefined, undefined, dom
  dialog.confirm = extractor.parseConfirm()
  dialog.setYesNoCaptions goog.dom.dataset.get(table, 'btnYes'), goog.dom.dataset.get(table, 'btnNo')

  grid = new ctor dom, repo, extractor.parseColumns(), extractor.parseActions(), dialog

  grid.decorate table
  grid
