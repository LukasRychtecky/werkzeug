goog.require 'goog.dom.classes'
goog.require 'goog.array'
goog.require 'wzk.ui.inlineform.FieldExpert'
goog.require 'goog.events'
goog.require 'goog.style'
goog.require 'goog.events.KeyCodes'
goog.require 'goog.dom.classes'

###*
  A dynamic builder of table rows for Django's inline forms
###
class wzk.ui.inlineform.RowBuilder extends goog.events.EventTarget

  ###*
    @type {string}
  ###
  @ICON_SELECTOR = 'td:last-child input[type=checkbox]'

  ###*
    @enum {string}
  ###
  @CLS =
    EVEN: 'EVEN'
    ODD: 'odd'

  ###*
    @enum {string}
  ###
  @EventType =
    DELETE: 'delete'

  ###*
    @param {Element} row
    @param {wzk.ui.inlineform.FieldExpert} expert
    @param {goog.dom.DomHelper} dom
  ###
  constructor: (@row, @expert, @dom) ->
    super()
    @parent = @dom.getParentElement(@row)
    @clone = @prepareClone()
    CLS = wzk.ui.inlineform.RowBuilder.CLS
    @prevClass = CLS.ODD
    @nextClass = CLS.EVEN
    @rotateClasses() if goog.dom.classes.has @clone, CLS.EVEN
    goog.dom.classes.remove @clone, CLS.EVEN, CLS.ODD

  ###*
    Adds new row as a sibling of a initial row. Returns a created row.

    @return {Element}
  ###
  addRow: ->
    cloned = @clone.cloneNode(true)
    removeIcon = @addRemoveIcon(cloned)

    @cycle(cloned)
    @fixIdsAndNames(cloned)
    @parent.appendChild(cloned)
    removeIcon.listen goog.ui.Component.EventType.ACTION, @handleIconAction
    @expert.next()

  ###*
    @param {Element} row
  ###
  addRemoveIcon: (row) ->
    checkbox = @dom.one wzk.ui.inlineform.RowBuilder.ICON_SELECTOR, row
    goog.style.setElementShown checkbox, false

    removeIcon = new wzk.ui.CloseIcon dom: @dom, removed: row
    removeIcon.render row
    removeIcon

  ###*
    @param {Element} row
  ###
  hangDeleteListener: (row) ->
    E = goog.events.EventType
    goog.events.listen @dom.one(wzk.ui.inlineform.RowBuilder.ICON_SELECTOR, row), [E.CLICK, E.KEYUP], (e) =>
      if e.type is E.CLICK or e.keyCode is goog.events.KeyCodes.SPACE
        @dispatchEvent new goog.events.Event(wzk.ui.inlineform.RowBuilder.EventType.DELETE, row)

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleIconAction: (e) =>
    removeIcon = e.target
    removed = removeIcon.getRemoved()
    checkbox = @dom.one 'input[type=checkbox]', removed
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
    for field in row.querySelectorAll('input, select')
      for attr in ['name', 'id']
        if field[attr]?
          field[attr] = @expert.process(field[attr])

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
      field.value = '' if field.type isnt 'hidden'

  ###*
    @param {boolean} enabled
  ###
  setEnabled: (enabled) ->
    for row in @dom.getChildren @parent
      goog.style.setElementShown @dom.getLastElementChild(row), enabled
