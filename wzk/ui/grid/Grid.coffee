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
goog.require 'goog.object'
goog.require 'goog.array'

goog.require 'wzk.events.lst'
goog.require 'wzk.ui.grid.BasePaginator'
goog.require 'wzk.ui.grid.Sorter'
goog.require 'wzk.ui.ButtonRenderer'
goog.require 'wzk.ui.Link'
goog.require 'wzk.ui.grid.CellFormatter'
goog.require 'wzk.ui.grid.Body'
goog.require 'wzk.ui.grid.Row'
goog.require 'wzk.ui.form.RemoteButton'
goog.require 'wzk.ui.form.ActionButton'
goog.require 'wzk.ui.form.Checkbox'
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
  @CLS:
    ACTIONS: 'actions'

  ###*
    @enum {string}
  ###
  @SELECTORS:
    EXPORT_BUTTONS: '.export-buttons'

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.ui.grid.Repository} repo
    @param {Array.<string>} cols
    @param {wzk.ui.grid.StateHolder} stateHolder
    @param {wzk.ui.dialog.ConfirmDialog} confirm
    @param {wzk.resource.Query} query
    @param {wzk.ui.grid.BasePaginator} paginator
    @param {wzk.ui.Flash} flash
    @param {boolean=} rowSelectable default is `false`
  ###
  constructor: (@dom, @repo, @cols, @stateHolder, @confirm, @query, @paginator, @flash, @rowSelectable = false) ->
    super()
    @table = null
    @tbody = null
    @sorter = null
    @lastQuery = {}
    @rows = new wzk.ui.grid.Body dom: @dom
    @rowBuilder = null
    @showActions = true
    @data = []

  ###*
    @protected
    @return {Element|null}
  ###
  findPaginator: ->
    @dom.getParentElement(@table)?.querySelector('.paginator')

  ###*
    @protected
    @param {Element} paginatorEl
    @return {Object|null}
  ###
  setupPaginator: (paginatorEl) ->
    if paginatorEl?
      @paginator.loadData(paginatorEl)
    else
      @paginator = null

  ###*
    @param {Element} table
  ###
  decorate: (@table) ->
    @rowBuilder = new wzk.ui.grid.RowBuilder(@dom, @rows, @cols, new wzk.ui.grid.CellFormatter(), @confirm, @rowSelectable)
    @stateHolder.listen wzk.ui.grid.StateHolder.EventType.CHANGED, @refresh

    unless @dom.cls(wzk.ui.grid.Grid.CLS.ACTIONS, @table)
      @showActions = false
    @removeBody()

    paginatorEl = @findPaginator()
    @setupPaginator(paginatorEl)
    @buildBody(@buildQuery(), (result) =>
      @decorateWithSorting()

      if @paginator?
        @paginator.init(result)
        @buildPaginator(paginatorEl)

      @dispatchLoaded(result)
      @listen(wzk.ui.grid.Grid.EventType.DELETE_ITEM, @handleDeleteItem)
    )

    for el in [@table, paginatorEl]
      wzk.events.lst.onClickOrEnter(
        el,
        (e) => @dispatchEvent(new goog.events.Event(goog.ui.Component.EventType.ACTION, e))
      )

    selectAllEl = @dom.one('input.select-all', @table)
    if selectAllEl?
      selectAll = new wzk.ui.form.Checkbox(dom: @dom)
      selectAll.decorate(selectAllEl)
      selectAll.listen(wzk.ui.form.Field.EVENTS.CHANGE, @handleSelectAll)

    undefined

  ###*
    @return {wzk.resource.Query}
  ###
  getQuery: ->
    @stateHolder.getQuery()

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleDeleteItem: (e) =>
    if @paginator.reloadWithDelete()
      @repo.delete(e.target, =>
        @buildBody(@buildQuery(), (result) =>
          if @paginator?
            @paginator.refresh result
        )
      )
    else
      @data = @data.filter (x) -> x != e.target
      @rerender()

  ###*
    @protected
    @return {wzk.resource.Query}
  ###
  buildQuery: ->
    if @paginator?
      @paginator.buildQuery(@query)
    @query

  ###*
    @protected
    @param {Element|undefined} el
  ###
  buildPaginator: (el) ->
    if el?
      @paginator.decorate(el)
    else
      @paginator.renderBefore(@table)

    @renderBottomPaginator()

  refresh: =>
    @query = @getQuery()
    @buildBody(@buildQuery(), (result) =>
      @paginator?.refresh(result)
    )

  ###*
    @protected
  ###
  renderBottomPaginator: ->
    clone = @paginator.createClone()
    @dom.insertSiblingAfter(clone, @table)

  ###*
    @protected
    @param {wzk.resource.Query} query
    @param {function(Object)|null=} doAfter
  ###
  buildBody: (query, doAfter = null) ->
    @doAfter = doAfter if doAfter?
    @repo.load(query, @handleData)

  ###*
    Rerenders the grid by its `data`
    @protected
  ###
  rerender: ->
    if @rows.isInDocument()
      @rows.destroyChildren()

    for model in @data
      row = @rowBuilder.build(model, @showActions)
      row.listen(wzk.ui.grid.Row.EventType.DELETE_BUTTON, @handleDeleteBtn)
      row.listen(wzk.ui.grid.Row.EventType.REMOTE_BUTTON, @handleRemoteButton)
      row.listen(wzk.ui.grid.Row.EventType.SELECTION_CHANGE, @handleSelectionChange)

    unless @rows.isInDocument()
      @rows.render(@table)
    @rows.listen(goog.ui.Component.EventType.ACTION, @handleSelectedItem)

  ###*
    Changes shown grid's columns by given `cols`. The grid will be rerendered.
    @param {Array.<string>} cols
  ###
  changeColumns: (cols) ->
    @setColumns(cols)
    @rowBuilder.setColumns(cols)
    @rerender()

  ###*
    Allows to re-render grid without reloading from repository
    @protected
    @param {Array.<Object>} data
    @param {Object} result
  ###
  handleData: (data, result) =>
    if @paginator.clearData()
      @data = data
    else
      @data = @data.concat data
    @rerender()
    result.count = data.length
    @doAfter result if @doAfter?
    @data

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
      @flash.success action['success_text']
      @rowBuilder.replaceRowByModel(response)

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSelectionChange: (e) =>
    @dispatchEvent(e)

  ###*
    @protected
  ###
  decorateWithSorting: ->
    @sorter = new wzk.ui.grid.Sorter @dom
    @sorter.decorate @table

    @sorter.listen(wzk.ui.grid.Sorter.EVENTS.SORT, @handleSort)

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSort: (e) =>
    header = (`/** @type {wzk.ui.grid.THeader} */`) e.target
    @query.sort(header.getName(), header.getDirection())

    if @paginator.resetWithSort()
      @paginator.reset(@query)

    @buildBody @buildQuery(), (result) =>
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
  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleDeleteBtn: (e) =>
    btn = (`/** @type {goog.ui.Button} */`) e.target
    @dispatchDeleteItem(btn)
    @silentlyRemoveRow(btn)

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

  ###*
    @return {Array.<string>}
  ###
  getColumns: ->
    @cols

  ###*
    @param {Array.<string>} cols
  ###
  setColumns: (@cols) ->

  ###*
    @return {Array|NodeList}
  ###
  getSelectedRows: ->
    return if @rowSelectable then (row for row in @rows.getChildren() when row.isSelected()) else []

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSelectAll: (e) =>
    for row in @rows.getChildren()
      if row.selectable?
        row.selectable.setValue(e.currentTarget.getValue())
