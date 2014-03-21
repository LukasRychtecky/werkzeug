goog.require 'wzk.ui.grid.Row'

class wzk.ui.grid.RowBuilder extends wzk.ui.Component

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.ui.grid.Body} rows
    @param {Array.<string>} cols
    @param {wzk.ui.grid.CellFormatter} formatter
  ###
  constructor: (@dom, @rows, @cols, @formatter) ->
    super()

  ###*
    @param {Object} model
  ###
  build: (model) ->
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
    row.getElement().innerHTML = ''
    row.removeChildren()

    rowElement = row.getElement()
    for col in @cols
      @buildCell(model, col, row).render rowElement

    if goog.array.isEmpty model['_actions']
      row.addCell('').render()
    else
      @buildActionsCell(row, model).render rowElement

  ###*
    @protected
    @param {Object} model
    @param {string} col
    @param {wzk.ui.grid.Row} row
  ###
  buildCell: (model, col, row) ->
    cell = row.addCell @formatter.format(model, col)
    cell.addClass col
    cell

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
    cell

    ###*
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
      btn.listen goog.ui.Component.EventType.ACTION, row.handleDeleteBtn
    else
      @buildRemoteButton action, model, row, cell

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
    @param {Object} action
    @param {Object} model
    @param {wzk.ui.grid.Cell} cell
    @param {wzk.ui.grid.Row} row
    @return {wzk.ui.form.RemoteButton}
  ###
  buildRemoteButton: (action, model, row, cell) ->
    btn = new wzk.ui.form.ActionButton action['verbose_name'], undefined, @dom
    btnData =
      model: model
      action: action
    @setupButton btnData, action['verbose_name'], action['class_name'], btn
    cell.addChild btn
    btn.listen goog.ui.Component.EventType.ACTION, row.handleRemoteButton
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
    btn.setModel row: row, model: model
