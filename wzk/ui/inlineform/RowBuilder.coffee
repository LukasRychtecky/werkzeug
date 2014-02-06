goog.provide 'wzk.ui.inlineform.RowBuilder'
goog.provide 'wzk.ui.inlineform.RowBuilder.EventType'

goog.require 'goog.dom.classes'
goog.require 'goog.array'
goog.require 'wzk.ui.inlineform.FieldExpert'
goog.require 'goog.events'
goog.require 'goog.events.EventTarget'
goog.require 'goog.style'
goog.require 'goog.events.KeyCodes'
goog.require 'goog.dom.classes'

###*
  A dynamic builder of table rows for Django's inline forms
###
class wzk.ui.inlineform.RowBuilder extends goog.events.EventTarget

  ###*
    @constructor
    @extends {goog.events.EventTarget}
    @param {Element} row
    @param {wzk.ui.inlineform.FieldExpert} expert
    @param {goog.dom.DomHelper} dom
  ###
  constructor: (@row, @expert, @dom) ->
    super()
    @parent = @dom.getParentElement(@row)
    @clone = @prepareClone()
    @prevClass = 'odd'
    @nextClass = 'even'
    @rotateClasses() if goog.dom.classes.has @clone, 'even'
    goog.dom.classes.remove @clone, 'even', 'odd'

  ###*
    Adds new row as a sibling of a initial row. Returns a created row.

    @return {Element}
  ###
  addRow: ->
    cloned = @clone.cloneNode(true)
    @cycle(cloned)
    @fixIdsAndNames(cloned)
    @parent.appendChild(cloned)
    @hangDeleteListener cloned
    @expert.next()

  ###*
    @param {Element} row
  ###
  hangDeleteListener: (row) ->
    E = goog.events.EventType
    goog.events.listen row.querySelector('td:last-child input[type=checkbox]'), [E.CLICK, E.KEYUP], (e) =>
      if e.type is E.CLICK or e.keyCode is goog.events.KeyCodes.SPACE
        @dispatchEvent new goog.events.Event(wzk.ui.inlineform.RowBuilder.EventType.DELETE, row)

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

###*
  @enum {string}
###
wzk.ui.inlineform.RowBuilder.EventType =
  DELETE: 'delete'
