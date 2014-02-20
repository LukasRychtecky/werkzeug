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
goog.require 'wzk.hist'

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

  win = dom.getWindow()
  {base, page} = wzk.ui.grid.parseFragment(win.location.hash)
  paginator = new wzk.ui.grid.Paginator base: base, page: page

  grid = new ctor dom, repo, extractor.parseColumns(), extractor.parseActions(), dialog, query, paginator
  grid.decorate table

  watcher = new wzk.ui.grid.FilterWatcher grid, query
  watcher.watchOn table

  msgr = new wzk.ui.grid.Messenger grid
  msgr.decorate dom.getParentElement(table)

  # propagate change of page to hash fragment of url
  paginator.listen wzk.ui.grid.Paginator.EventType.GO_TO, (event) ->
    if event.target.page is 1 and event.target.base is 10
      win.location.hash = ''
    else
      frag = wzk.uri.addFragmentParam('page', event.target.page)
      frag = [frag, '&', wzk.uri.addFragmentParam('base', event.target.base)].join('')
      win.location.hash = frag
    undefined #because of Coffee vs. Closure Compiler

  # setup history handling
  wzk.hist.historyHandler (historyEvent)->
    {base, page} = wzk.ui.grid.parseFragment(historyEvent.token)
    paginator.goToPage(base, page)

  grid

###*
  @param {string} fragment
  @return {Object}
###
wzk.ui.grid.parseFragment = (fragment) ->
  page = wzk.num.parseDec wzk.uri.getFragmentParam('page', fragment), 1
  base = wzk.num.parseDec wzk.uri.getFragmentParam('base', fragment), 10

  {base: base, page: page}
