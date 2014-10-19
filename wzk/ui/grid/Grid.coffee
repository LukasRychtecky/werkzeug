goog.provide 'wzk.ui.grid.Grid'

goog.require 'goog.dom.DomHelper'
goog.require 'goog.object'
goog.require 'goog.ui.Dialog'
goog.require 'goog.ui.Button'
goog.require 'goog.ui.Component.EventType'
goog.require 'goog.ui.Dialog'
goog.require 'goog.ui.Dialog.EventType'
goog.require 'goog.ui.Dialog.DefaultButtonKeys'
goog.require 'goog.events'
goog.require 'goog.events.Event'
goog.require 'goog.string.format'
goog.require 'wzk.ui.grid.Paginator'
goog.require 'wzk.ui.grid.Sorter'
goog.require 'wzk.ui.ButtonRenderer'
goog.require 'wzk.ui.Link'
goog.require 'wzk.ui.grid.CellFormatter'
goog.require 'wzk.ui.grid.Body'
goog.require 'wzk.ui.grid.Row'
goog.require 'goog.object'
goog.require 'goog.array'
goog.require 'wzk.ui.form.RemoteButton'
goog.require 'wzk.ui.form.ActionButton'
goog.require 'wzk.ui.grid.RowBuilder'

class wzk.ui.grid.Grid extends wzk.ui.Component

  ###*
    @enum {string}
  ###
  @EventType:
    DELETE_ITEM: 'delete-item'
    LOADED: 'loaded'
    SELECTED_ITEM: 'selected-item'

  ###*
    @enum {string}
  ###
  @DATA:
    SHOW_ACTIONS: 'showActions'

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.ui.grid.Repository} repo
    @param {Array.<string>} cols
    @param {wzk.ui.dialog.ConfirmDialog} confirm
    @param {wzk.resource.Query} query
    @param {wzk.ui.grid.Paginator} paginator
  ###
  constructor: (@dom, @repo, @cols, @confirm, @query, @paginator) ->
    super()
    @table = null
    @tbody = null
    @sorter = null
    @lastQuery = {}
    @rows = new wzk.ui.grid.Body dom: @dom
    @rowBuilder = new wzk.ui.grid.RowBuilder(@dom, @rows, @cols, new wzk.ui.grid.CellFormatter(), @confirm)
    @showActions = true

  ###*
    @param {Element} table
  ###
  decorate: (@table) ->
    if goog.dom.dataset.has @table, wzk.ui.grid.Grid.DATA.SHOW_ACTIONS
      if goog.dom.dataset.get(@table, wzk.ui.grid.Grid.DATA.SHOW_ACTIONS) is 'false'
        @showActions = false

    @removeBody()
    paginatorEl = @dom.getParentElement(@table)?.querySelector '.paginator'
    if paginatorEl?
      @paginator.loadData paginatorEl
      paging = {offset: (@paginator.page - 1) * @paginator.base}
    else
      @paginator = null

    @buildBody @buildQuery(paging), (result) =>
      @decorateWithSorting()

      if @paginator?
        @paginator.init(result.total, result.count)
        @buildPaginator paginatorEl

      @dispatchLoaded result
      @listen wzk.ui.grid.Grid.EventType.DELETE_ITEM, @handleDeleteItem

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleDeleteItem: (e) =>
    @repo.delete e.target, =>
      @buildBody @buildQuery(), (result) =>
        if @paginator?
          @paginator.refresh result

  ###*
    @protected
    @param {Object|null=} opts
    @return {wzk.resource.Query}
  ###
  buildQuery: (opts = {}) ->
    @query.order = opts.column if opts.column?
    @query.direction = opts.direction if opts.direction?
    @query.base = opts.base ? @paginator?.base
    @query.offset = if opts.offset? then opts.offset else @paginator?.offset
    @query

  ###*
    @protected
    @param {Element|undefined} el
  ###
  buildPaginator: (el) ->
    if el?
      @paginator.decorate el
    else
      @paginator.renderBefore @table

    @paginator.listen wzk.ui.grid.Paginator.EventType.GO_TO, (e) =>
      @buildBody @buildQuery(e.target), (result) =>
        @paginator.refresh result

    @renderBottomPaginator()

  refresh: ->
    @buildBody @buildQuery({offset: @query.offset}), (result) =>
      result.offset = @query.offset
      @paginator?.refresh result

  ###*
    @protected
  ###
  renderBottomPaginator: ->
    clone = @paginator.createClone()
    @dom.insertSiblingAfter clone, @table

  ###*
    @protected
    @param {wzk.resource.Query} query
    @param {function(Object)|null=} doAfter
  ###
  buildBody: (query, doAfter = null) ->
    @doAfter = doAfter if doAfter?
    @repo.load query, @handleData

  ###*
    Allows to re-render grid without reloading from repository
    @protected
    @param {Array.<Object>} data
    @param {Object} result
  ###
  handleData: (data, result) =>
    if @rows.isInDocument()
      @rows.destroyChildren()

    for model in data
      row = @rowBuilder.build model, @showActions
      row.listen wzk.ui.grid.Row.EventType.DELETE_BUTTON, @handleDeleteBtn
      row.listen wzk.ui.grid.Row.EventType.REMOTE_BUTTON, @handleRemoteButton

    unless @rows.isInDocument()
      @rows.render @table
    @rows.listen goog.ui.Component.EventType.ACTION, @handleSelectedItem

    result.count = data.length
    @doAfter result if @doAfter?
    data

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSelectedItem: (e) =>
    e.target.setState goog.ui.Component.State.SELECTED, true
    @dispatchSelectedItem e.target.getModel()

  ###*
    @protected
  ###
  removeBody: ->
    body = @table.querySelector 'tbody'
    if body?
      @dom.removeNode body

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleRemoteButton: (e) =>
    btn = e.target
    model = btn.getModel().model
    action = btn.getModel().action
    btn.call @repo.getClient(), model['_rest_links'][action['name']]['url'], action['method'], action['data'], (response) =>
      @rowBuilder.replaceRowByModel(response)

  ###*
    @protected
  ###
  decorateWithSorting: ->
    @sorter = new wzk.ui.grid.Sorter @dom
    @sorter.decorate @table

    @sorter.listen wzk.ui.grid.Sorter.EventType.SORT, (e) =>
      @buildBody @buildQuery(e.target), (result) =>
        @paginator.refresh result

  ###*
    @protected
    @param {goog.ui.Button} btn
  ###
  dispatchDeleteItem: (btn) ->
    @dispatchEvent(new goog.events.Event(wzk.ui.grid.Grid.EventType.DELETE_ITEM, btn.getModel().model))

  ###*
    @protected
    @param {Object} result
  ###
  dispatchLoaded: (result) ->
    @dispatchEvent new goog.events.Event(wzk.ui.grid.Grid.EventType.LOADED, result)

  ###*
    @protected
    @param {Object} model
  ###
  dispatchSelectedItem: (model) ->
    @dispatchEvent new goog.events.Event(wzk.ui.grid.Grid.EventType.SELECTED_ITEM, model)

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleDeleteBtn: (e) =>
    btn = (`/** @type {goog.ui.Button} */`) e.target
    @dispatchDeleteItem btn
    @silentlyRemoveRow btn

  ###*
    A little bit dirty, but enough for now.

    @private
    @param {goog.ui.Button} btn
  ###
  silentlyRemoveRow: (btn) ->
    @dom.removeNode btn.getModel().row

  ###*
    @param {wzk.resource.Query} query
  ###
  setQuery: (@query) ->

  ###*
    @param {Object} model
  ###
  selectIfContains: (model) ->
    @rows.selectIfContains model
