goog.provide 'wzk.ui.inlineform.DynamicForm'

goog.require 'goog.string'
goog.require 'wzk.ui.inlineform.FieldExpert'
goog.require 'wzk.ui.inlineform.RowBuilder'
goog.require 'goog.events'
goog.require 'goog.events.EventType'
goog.require 'wzk.ui.inlineform.ConfigHandler'

class wzk.ui.inlineform.DynamicForm

  ###*
    @constructor
    @param {goog.dom.DomHelper} dom
  ###
  constructor: (@dom) ->
    @formNum = 0
    @MAX_FORMS = 1000
    @config = null

  ###*
    Allow dynamic adding table rows. A fieldset argument is HTMLFieldSetElement (but should works with basic Element) which contains a table and a trigger button.
    The button must have a 'dynamic' CSS class. First from from tbody is use for cloning.

    @param {Element} fieldset
    @param {boolean=} enabled
  ###
  dynamic: (fieldset, enabled = true) ->
    btn = fieldset.querySelector('.dynamic')
    # If a fieldset has no dynamic button, it's not a dynamic form
    return unless btn?

    @initInputs(fieldset)
    expert = new wzk.ui.inlineform.FieldExpert(parseInt(@formNum, 10))
    row = @findRow fieldset
    builder = new wzk.ui.inlineform.RowBuilder(row, expert, @dom)

    if enabled
      @hangAddRowListener builder, btn
      @hangRemoveRowHandler builder, fieldset
    else
      builder.setEnabled false

    @removeInputsForCloning row

    goog.style.setElementShown btn, enabled

  ###*
    @protected
    @param {wzk.ui.inlineform.RowBuilder} builder
    @param {Element} btn
  ###
  hangAddRowListener: (builder, btn) ->
    listener = goog.events.listen btn, goog.events.EventType.CLICK, =>
      builder.addRow()
      @formNum++
      @config.store @formNum
      if @formNum is @MAX_FORMS
        goog.dom.classes.add(btn, 'disabled')
        goog.events.unlistenByKey(listener)

  ###*
    Loads Django's InlineForms config data

    @protected
    @param {Element} fieldset
  ###
  initInputs: (fieldset) ->
    @config = new wzk.ui.inlineform.ConfigHandler fieldset
    @config.load()

    @formNum = @config.formNum

    @MAX_FORMS = @config.MAX_FORMS

  ###*
    @protected
    @param {Element} fieldset
    @return {Element}
  ###
  findRow: (fieldset) ->
    el = fieldset.querySelector('table tbody')
    @dom.lastChildOfType el, 'tr'

  ###*
    @protected
    @param {Element} row
  ###
  removeInputsForCloning: (row) ->
    @dom.removeNode row

  ###*
    @protected
    @param {Element} row
  ###
  removeDutyFromHiddenInputs: (row) ->
    for input in row.querySelectorAll 'input, select'
      input.removeAttribute 'required'

  ###*
    @protected
    @param {wzk.ui.inlineform.RowBuilder} builder
    @param {Element} fieldset
  ###
  hangRemoveRowHandler: (builder, fieldset) ->
    builder.hangDeleteListener row for row in fieldset.querySelectorAll 'table tbody tr'

    goog.events.listen builder, wzk.ui.inlineform.RowBuilder.EventType.DELETE, (e) =>
      goog.style.setElementShown e.target, false
      @removeDutyFromHiddenInputs e.target
