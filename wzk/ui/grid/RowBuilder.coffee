goog.require 'wzk.ui.grid.Row'
goog.require 'wzk.ui.form.Checkbox'


class wzk.ui.grid.RowBuilder extends wzk.ui.Component

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.ui.grid.Body} rows
    @param {Array.<string>} cols
    @param {wzk.ui.grid.CellFormatter} formatter
    @param {wzk.ui.dialog.ConfirmDialog} confirm
    @param {boolean} selectable
  ###
  constructor: (@dom, @rows, @cols, @formatter, @confirm, @selectable = false) ->
    super()
    @ACTION_MAP =
      'rest': @buildRestAction
      'web': @buildWebAction

  ###*
    @param {Array.<string>} cols
  ###
  setColumns: (@cols) ->

  ###*
    @param {Object} model
    @param {boolean=} showActions
  ###
  build: (model, showActions = true) ->
    row = new wzk.ui.grid.Row(dom: @dom, confirm: @confirm)
    row.setModel(model)
    @rows.addChild(row, false)

    if @selectable
      @buildSelectCell(row)

    for col in @cols
      @buildCell(model, col, row)

    if model['_class_names']?
      row.addClassName(cls) for cls in model['_class_names']

    if (goog.isArray(model['_actions']) and not goog.array.isEmpty(model['_actions'])) and showActions
      @buildActionsCell row, model

    row

  ###*
    @param {Object} model
  ###
  replaceRowByModel: (model) ->
    for id in @rows.getChildIds()
      row = (`/** @type {wzk.ui.grid.Row} */`) @rows.getChild(id)
      if row.getModel().id is model.id
        @replaceRow(model, row)
        break

  ###*
    @protected
    @param {Object} model
    @param {wzk.ui.grid.Row} row
  ###
  replaceRow: (model, row) ->
    row.setModel model
    @dom.clearElement row.getElement()
    row.removeChildren()

    rowElement = row.getElement()
    for col in @cols
      @buildCell(model, col, row).render rowElement

    if goog.isArray(model['_actions']) and not goog.array.isEmpty(model['_actions'])
      @buildActionsCell(row, model).render rowElement
    else
      row.addCell('').render()

  ###*
    @protected
    @param {Object} model
    @param {string} col
    @param {wzk.ui.grid.Row} row
  ###
  buildCell: (model, col, row) ->
    cell = new wzk.ui.grid.Cell(dom: @dom)
    if model['_default_action']
      link = new wzk.ui.Link(
        dom: @dom,
        href: model['_web_links'][model['_default_action']],
        htmlCaption: @formatter.format(model, col)
      )
      cell.addChild link
    else
      cell.setCaption(@formatter.format(model, col))
    cell.addClass(col)
    row.addChild(cell)
    cell

  ###*
    @protected
    @param {wzk.ui.grid.Row} row
    @return {wzk.ui.grid.Cell}
  ###
  buildSelectCell: (row) ->
    cell = new wzk.ui.grid.Cell(dom: @dom)
    checkbox = new wzk.ui.form.Checkbox(dom: @dom)
    cell.addChild(checkbox)
    cell.addClass('select-row')
    row.addChild(cell)
    row.setSelectable(checkbox)
    cell

  ###*
    @protected
    @param {wzk.ui.grid.Row} row
    @param {Object} model
  ###
  buildActionsCell: (row, model) ->
    cell = row.addCell('')
    cell.addClass('actions')
    @buildAction(action, model, cell, row) for action in model['_actions']
    row.addChild(cell)
    cell

    ###*
    @param {Object} action
    @param {Object} model
    @param {wzk.ui.grid.Cell} cell
    @param {wzk.ui.grid.Row} row
  ###
  buildAction: (action, model, cell, row) ->
    if @ACTION_MAP[action['type']]?
      @ACTION_MAP[action['type']](action, model, cell, row)
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
  buildRestAction: (action, model, cell, row) =>
    @buildRemoteButton(action, model, row, cell)

  ###*
    @protected
    @param {Object} action
    @param {Object} model
    @param {wzk.ui.grid.Cell} cell
    @param {wzk.ui.grid.Row} row
  ###
  buildWebAction: (action, model, cell, row) =>
    link = new wzk.ui.Link(
      dom: @dom,
      href: model['_web_links'][action['name']],
      caption: action['verbose_name'],
      target: action['target']
    )
    link.addClass(@getClass(action))
    cell.addChild(link)

  ###*
    @protected
    @param {Object} action
    return {string}
  ###
  getClass: (action) ->
    (action['class_name'] or action['name']) or ''

  ###*
    @protected
    @param {Object} action
    @param {Object} model
    @param {wzk.ui.grid.Cell} cell
    @param {wzk.ui.grid.Row} row
    @return {wzk.ui.form.RemoteButton}
  ###
  buildRemoteButton: (action, model, row, cell) ->
    btn = new wzk.ui.form.ActionButton(content: action['verbose_name'], dom: @dom)
    btnData =
      model: model
      action: action
    @setupButton(btnData, action['verbose_name'], @getClass(action), btn)
    cell.addChild(btn)
    btn.listen(goog.ui.Component.EventType.ACTION, row.handleRemoteButton)
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
    Temporary a model wrapper, connects a table row and its data

    @private
    @param {goog.ui.Button} btn
    @param {wzk.ui.grid.Row} row
    @param {Object} model
  ###
  buildButtonModel: (btn, row, model) ->
    btn.setModel(row: row, model: model)
