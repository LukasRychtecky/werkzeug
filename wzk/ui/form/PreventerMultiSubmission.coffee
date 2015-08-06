goog.require 'goog.dom.classes'
goog.require 'goog.events'

class wzk.ui.form.PreventerMultiSubmission

  ###*
    @const
  ###
  @BUTTONS = '.form-btns button.btn'

  ###*
    @const
  ###
  @CLS_AJAX = 'ajax'


  ###*
    @const
  ###
  @SPINNER_CLS = 'btn-spinner'

  ###*
    @param {Element} form
  ###
  @enableButtonsInForm: (form) ->
    btn.removeAttribute 'disabled' for btn in form.querySelectorAll(wzk.ui.form.PreventerMultiSubmission.BUTTONS)
    spinner = form.querySelector(wzk.ui.form.PreventerMultiSubmission.BUTTONS + ' .' +
        wzk.ui.form.PreventerMultiSubmission.SPINNER_CLS)
    goog.dom.removeNode(spinner) if spinner?

  ###*
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@dom) ->

  ###*
    @param {Element} form
  ###
  prevent: (form) ->
    return if goog.dom.classes.has form, wzk.ui.form.PreventerMultiSubmission.CLS_AJAX

    @btns = @dom.all wzk.ui.form.PreventerMultiSubmission.BUTTONS, form

    for btn in @btns
      goog.events.listen btn, [goog.events.EventType.CLICK, goog.events.EventType.KEYUP], @handleButton

    goog.events.listen form, goog.events.EventType.SUBMIT, @handleSubmit

  ###*
    @protected
  ###
  handleSubmit: =>
    btn.setAttribute 'disabled', 'true' for btn in @btns

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleButton: (e) =>
    btn = (`/** @type {Element} */`) e.currentTarget
    if not @dom.cls wzk.ui.form.PreventerMultiSubmission.SPINNER_CLS, btn
      spinner = @dom.el 'i', 'fa fa-refresh fa-spin ' + wzk.ui.form.PreventerMultiSubmission.SPINNER_CLS
      @dom.appendChild btn, spinner

    if e.target.name?
      hidden = @dom.el 'input', {type: 'hidden', name: e.target.name, value: e.target.value}
      @dom.appendChild e.target.parentNode, hidden
