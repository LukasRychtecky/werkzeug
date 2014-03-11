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
    @param {wzk.dom.Dom} dom
    @param {wzk.ui.grid.Repository} repo
    @param {Array.<string>} cols
    @param {wzk.ui.dialog.ConfirmDialog} dialog
    @param {wzk.resource.Query} query
    @param {wzk.ui.grid.Paginator} paginator
  ###
  constructor: (@dom, @repo, @cols, @dialog, @query, @paginator) ->
    super()
    @table = null
    @tbody = null
    @sorter = null
    @lastQuery = {}
    @rows = new wzk.ui.grid.Body dom: @dom
    @rowBuilder = new wzk.ui.grid.RowBuilder(@dom, @rows, @cols, new wzk.ui.grid.CellFormatter())

  ###*
    @param {Element} table
  ###
  decorate: (@table) ->
    @removeBody()
    paginatorEl = @dom.getParentElement(@table)?.querySelector '.paginator'
    @paginator.loadData paginatorEl

    @buildBody @buildQuery({offset: (@paginator.page - 1) * @paginator.base}), (result) =>
      @decorateWithSorting()

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
        @paginator.refresh result

  ###*
    @protected
    @param {Object|null=} opts
    @return {wzk.resource.Query}
  ###
  buildQuery: (opts = {}) ->
    @query.order = opts.column if opts.column?
    @query.direction = opts.direction if opts.direction?
    @query.base = opts.base ? @paginator.base
    @query.offset = if opts.offset? then opts.offset else @paginator.offset
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
    @buildBody @buildQuery(), (result) =>
      @paginator.refresh result

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
    if @rows.isInDocument()
      @rows.destroyChildren()

    @repo.load query, (data, result) =>
      for model in data
        row = @rowBuilder.build model
        row.listen wzk.ui.grid.Row.EventType.DELETE_BUTTON, @handleDeleteBtn
        row.listen wzk.ui.grid.Row.EventType.REMOTE_BUTTON, @handleRemoteButton

      unless @rows.isInDocument()
        @rows.render @table
      @rows.listen goog.ui.Component.EventType.ACTION, @handleSelectedItem

      result.count = data.length
      doAfter result if doAfter?

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
    @param {string} txt
  ###
  setDialogText: (txt) ->
    @dialog.formatContent txt

  ###*
    @protected
    @param {goog.ui.Button} btn
  ###
  showDialog: (btn) ->
    @dialog.open()
    @dialog.focus()
    goog.events.listenOnce @dialog, goog.ui.Dialog.EventType.SELECT, (e) =>
      if e.key is goog.ui.Dialog.DefaultButtonKeys.YES
        @dispatchDeleteItem btn
        @silentlyRemoveRow btn

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
    @setDialogText btn.getModel().model.toString()
    @showDialog btn

  ###*
    A little bit dirty, but enough for now.

    @private
    @param {goog.ui.Button} btn
  ###
  silentlyRemoveRow: (btn) ->
    @dom.removeNode btn.getModel().row
