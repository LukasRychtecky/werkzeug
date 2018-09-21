goog.require 'goog.dom.classes'
goog.require 'goog.array'
goog.require 'goog.events'
goog.require 'goog.style'
goog.require 'goog.events.KeyCodes'
goog.require 'goog.dom.classes'
goog.require 'goog.dom.dataset'
goog.require 'goog.string'

goog.require 'wzk.ui.CloseIcon'
goog.require 'wzk.ui.inlineform.FieldExpert'
goog.require 'wzk.ui.inlineform.RowDecorator'

###*
  A dynamic builder of table rows for Django's inline forms
###
class wzk.ui.inlineform.RowBuilder extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @CLS =
    EVEN: 'even'
    ODD: 'odd'

  ###*
    @enum {string}
  ###
  @EventType =
    DELETE: 'delete'

  ###*
    @type {string}
  ###
  @CHECKBOX_SELECTOR = 'input[type=checkbox]'

  ###*
    @param {Element} row
    @param {wzk.ui.inlineform.FieldExpert} expert
    @param {wzk.app.Register} reg
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@row, @expert, @reg, @dom) ->
    super()
    @parent = @dom.getParentElement(@row)
    @clone = @prepareClone()
    @rowDecorator = new wzk.ui.inlineform.RowDecorator({dom: @dom})
    CLS = wzk.ui.inlineform.RowBuilder.CLS
    @prevClass = CLS.ODD
    @nextClass = CLS.EVEN
    goog.dom.classes.remove @clone, CLS.EVEN, CLS.ODD

  ###*
    Adds new row as a sibling of a initial row. Returns a created row.

    @return {Element}
  ###
  addRow: ->
    cloned = @clone.cloneNode(true)
    @decorateRow(cloned, true)

    @cycle(cloned)
    @fixIdsAndNames(cloned)
    @parent.appendChild(cloned)
    @expert.next()
    cloned

  ###*
    Remove empty row and fixes indexes of lower rows.

    @param {Element} row
  ###
  removeRow: (row) ->
    @expert.prev()

    nextRow = row
    while nextRow = @dom.getNextElementSibling(nextRow)
      goog.dom.classes.toggle(nextRow, @nextClass)
      goog.dom.classes.toggle(nextRow, @prevClass)

      for field in @dom.all 'input, select, textarea', nextRow
        for attr in ['name', 'id', 'data-for']
          if field[attr]?
            splitAttr = field[attr].split('-')
            splitAttr[splitAttr.length - 2] = parseInt(splitAttr[splitAttr.length - 2], 10) - 1
            field[attr] = splitAttr.join('-')
    @dom.removeNode(row)
    @rotateClasses()

  ###*
    @param {Element} row
    @param {boolean} processElements
  ###
  decorateRow: (row, processElements) ->
    removeIcon = @rowDecorator.addRemoveIcon(row)
    if removeIcon?
      removeIcon.listen(goog.ui.Component.EventType.ACTION, @handleIconAction)
    if processElements
      @reg.process(row)

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleIconAction: (e) =>
    removeIcon = e.target
    removed = removeIcon.getRemoved()
    checkbox = wzk.ui.inlineform.getRemoveCheckboxOrNull(@dom, removed)
    if checkbox?
      checkbox.checked = true
      @dispatchEvent new goog.events.Event(wzk.ui.inlineform.RowBuilder.EventType.DELETE, removeIcon.getRemoved())

  ###*
    Cycles CSS classes on a row

    @protected
    @param {Element} row
  ###
  cycle: (row) ->
    goog.dom.classes.add(row, @nextClass)
    @rotateClasses()

  ###*
    @protected
  ###
  rotateClasses: ->
    [@nextClass, @prevClass] = [@prevClass, @nextClass]

  ###*
    Fixes ids and names of inputs in new row

    @protected
    @param {Element} row
  ###
  fixIdsAndNames: (row) ->
    for field in @dom.all 'input, select, textarea', row
      for attr in ['name', 'id', 'data-for']
        if field[attr]?
          field[attr] = @expert.process(field[attr])

    for el in @dom.all 'div[data-for]', row
      value = goog.dom.dataset.get el, 'for'
      if value?
        goog.dom.dataset.set el, 'for', @expert.process value

  ###*
    Prepares a row for cloning

    @protected
    @return {Element}
  ###
  prepareClone: ->
    clone = @row.cloneNode(true)
    goog.dom.classes.remove(clone, @prevClass)
    clone

  ###*
    @param {boolean} enabled
  ###
  setEnabled: (enabled) ->
    for row in @dom.getChildren @parent
      goog.style.setElementShown @dom.getLastElementChild(row), enabled
