goog.require 'goog.string'
goog.require 'wzk.ui.inlineform.FieldExpert'
goog.require 'wzk.ui.inlineform.RowBuilder'
goog.require 'goog.events'
goog.require 'goog.events.EventType'
goog.require 'wzk.ui.inlineform.ConfigHandler'


class wzk.ui.inlineform.DynamicForm

  ###*
    @enum {string}
  ###
  @SELECTORS:
    FILE_INPUT: "input[type=file]"

  ###*
    @constructor
    @param {wzk.dom.Dom} dom
    @param {wzk.app.Register} reg
  ###
  constructor: (@dom, @reg) ->
    @formNum = 0
    @MAX_FORMS = 1000
    @config = null
    @builder = null
    @listener = null

  ###*
    Allow dynamic adding table rows. A fieldset argument is HTMLFieldSetElement (but should works with basic Element) which contains a table and a trigger button.
    The button must have a 'dynamic' CSS class. First from from tbody is use for cloning.

    @param {Element} fieldset
    @param {boolean=} enabled
  ###
  dynamic: (fieldset, enabled = true) ->
    @btn = @dom.cls('dynamic', fieldset)
    # If a fieldset has no dynamic button, it's not a dynamic form
    return unless @btn?

    @initInputs(fieldset)
    expert = new wzk.ui.inlineform.FieldExpert(parseInt(@formNum, 10))

    rows = @findRows fieldset
    row = rows[rows.length - 1] # prototype row, intended to be cloned
    @builder = new wzk.ui.inlineform.RowBuilder(row, expert, @reg, @dom)

    if rows.length > 1
      for rowIndex in [0..rows.length - 2]
        @builder.decorateRow(rows[rowIndex], false)

    if enabled
      @listener = goog.events.listen @btn, goog.events.EventType.CLICK, @handleClick

      @builder.listen wzk.ui.inlineform.RowBuilder.EventType.DELETE, @handleRowDelete
    else
      @builder.setEnabled false

    @removeInputsForCloning row

    goog.style.setElementShown @btn, enabled

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleRowDelete: (e) =>
    el = (`/** @type {Element} */`) e.target
    for fileInput in @dom.all wzk.ui.inlineform.DynamicForm.SELECTORS.FILE_INPUT, el
      @dom.removeNode fileInput
    goog.style.setElementShown el, false
    @removeDutyFromHiddenInputs el

  ###*
    @protected
  ###
  handleClick: =>
    row = @builder.addRow()
    @formNum++
    @config.store @formNum
    if @formNum is @MAX_FORMS
      goog.dom.classes.add(@btn, 'disabled')
      goog.events.unlistenByKey(@listener)

    if @dom.all('input[type=file]', row).length == 1
      @openFileDialog(row)

  ###*
    @protected
    @param {Element} row
  ###
  openFileDialog: (row) ->
    input = @dom.one 'input[type=file]', row
    input.click() if input

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
    @return {NodeList.<Element>}
  ###
  findRows: (fieldset) ->
    return (`/** @type {NodeList.<Element>} */`) @dom.clss('inline-line', fieldset)

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
    for input in @dom.all 'input, select', row
      input.removeAttribute 'required'
