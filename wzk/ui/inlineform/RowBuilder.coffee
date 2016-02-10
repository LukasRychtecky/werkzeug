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
    @decorateRow cloned

    @cycle(cloned)
    @fixIdsAndNames(cloned)
    @parent.appendChild(cloned)
    @expert.next()
    cloned

  ###*
    @param {Element} row
  ###
  decorateRow: (row) ->
    removeIcon = @rowDecorator.addRemoveIcon(row)
    return unless removeIcon?
    removeIcon.listen goog.ui.Component.EventType.ACTION, @handleIconAction
    @reg.process row

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
    @removeValues(clone)
    clone

  ###*
    Cleans inputs in a row for cloning

    @protected
  ###
  removeValues: (row) ->
    for field in row.querySelectorAll('input')
      field.value = field.getAttribute('value') if field.type isnt 'hidden'

  ###*
    @param {boolean} enabled
  ###
  setEnabled: (enabled) ->
    for row in @dom.getChildren @parent
      goog.style.setElementShown @dom.getLastElementChild(row), enabled
