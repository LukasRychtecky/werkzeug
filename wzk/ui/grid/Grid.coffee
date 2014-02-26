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
    @base = 10
    @tbody = null
    @sorter = null
    @formatter = new wzk.ui.grid.CellFormatter()
    @lastQuery = {}
    @rows = new wzk.ui.grid.Body dom: @dom

  ###*
    @param {Element} table
  ###
  decorate: (@table) ->
    @removeBody()
    paginatorEl = @dom.getParentElement(@table)?.querySelector '.paginator'
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
    @query.base = opts.base if opts.base?
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
        @buildRow model

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
    @param {Object} model
  ###
  buildRow: (model) ->
    row = new wzk.ui.grid.Row dom: @dom
    row.setModel model
    @rows.addChild row, true
    for col in @cols
      @buildCell(model, col, row)

    row.addClassName cls for cls in model['_class_names']

    if goog.array.isEmpty model['_actions']
      row.addCell ''
    else
      @buildActionsCell row, model

  ###*
    @protected
    @param {Object} model
    @param {string} col
    @param {wzk.ui.grid.Row} row
  ###
  buildCell: (model, col, row) ->
    row.addCell @formatter.format(model, col)

  ###*
    @protected
    @param {wzk.ui.grid.Row} row
    @param {Object} model
  ###
  buildActionsCell: (row, model) ->
    cell = row.addCell ''
    cell.addClass 'actions'
    @buildAction action, model, cell, row for action in model['_actions']
    row.addChild cell

  ###*
    @protected
    @param {Object} action
    @param {Object} model
    @param {wzk.ui.grid.Cell} cell
    @param {wzk.ui.grid.Row} row
  ###
  buildAction: (action, model, cell, row) ->
    if action['type'] is 'rest'
      @buildRestAction action, model, cell, row
    else if action['type'] is 'web'
      @buildWebAction action, model, cell
    else
      # TODO: use google closure logger
      @dom.getWindow().console.warn('Non-existent action type: ' + action['type'])

  ###*
    @protected
    @param {Object} action
    @param {Object} model
    @param {wzk.ui.grid.Cell} cell
    @param {wzk.ui.grid.Row} row
  ###
  buildRestAction: (action, model, cell, row) ->
    if action['method'] is 'DELETE'
      btn = @buildButton action['verbose_name'], action['name'], model, cell, row
      btn.listen goog.ui.Component.EventType.ACTION, @handleDeleteBtn
    else
      @buildRemoteButton action, model, cell

  ###*
    @protected
    @param {Object} action
    @param {Object} model
    @param {wzk.ui.grid.Cell} cell
    @return {wzk.ui.form.RemoteButton}
  ###
  buildRemoteButton: (action, model, cell) ->
    btn = new wzk.ui.form.RemoteButton action['verbose_name'], undefined, @dom
    btnData =
      model: model
      action: action
    @setupButton btnData, action['verbose_name'], action['class_name'], btn
    cell.addChild btn
    btn.listen goog.ui.Component.EventType.ACTION, @handleRemoteButton
    btn

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleRemoteButton: (e) =>
    btn = e.target
    model = btn.getModel().model
    action = btn.getModel().action
    btn.call @repo.getClient(), model['_rest_links'][action['name']]['url'], action['method'], action['data'], =>
      # dirty remove by row replace, when REST API will be fixed
      @buildBody @buildQuery(), (result) =>
        @paginator.refresh result

  ###*
    @protected
    @param {Object} action
    @param {Object} model
    @param {wzk.ui.grid.Cell} cell
  ###
  buildWebAction: (action, model, cell) ->
    link = new wzk.ui.Link dom: @dom, href: model['_web_links'][action['name']], caption: action['verbose_name']
    link.addClass(action['class_name'] or action['name'])
    cell.addChild link

  ###*
    @protected
    @param {string} caption
    @param {string} className
    @param {Object} model
    @param {wzk.ui.grid.Cell} cell
    @param {wzk.ui.grid.Row} row
    @return {goog.ui.Button}
  ###
  buildButton: (caption, className, model, cell, row) ->
    btn = new goog.ui.Button caption, wzk.ui.ButtonRenderer.getInstance(), @dom
    btn.addClassName 'btn-danger'
    @setupButton model, caption, className, btn
    cell.addChild btn
    @buildButtonModel btn, row, model
    btn

  ###*
    @protected
    @param {Object} model
    @param {string} caption
    @param {string} className
    @param {goog.ui.Button} btn
  ###
  setupButton: (model, caption, className, btn) ->
    btn.addClassName className
    btn.setModel model
    btn.setTooltip caption

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
    @dialog.setVisible true
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

  ###*
    Temporary a model wrapper, connects a table row and its data

    @private
    @param {goog.ui.Button} btn
    @param {wzk.ui.grid.Row} row
    @param {Object} model
  ###
  buildButtonModel: (btn, row, model) ->
    btn.setModel row: row, model: model
