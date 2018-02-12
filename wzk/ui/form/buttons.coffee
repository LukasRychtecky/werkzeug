goog.provide 'wzk.ui.form.buttons'

goog.require 'goog.dom.classes'

goog.require 'wzk.events.lst'


###*
  @type {string}
###
wzk.ui.form.buttons.BUTTON_SELECTOR = '.form-btns button.btn'

###*
  @type {string}
###
wzk.ui.form.buttons.SPINNER_CLS = 'btn-spinner'


###*
  @param {Element} btn
  @param {wzk.dom.DomHelper} dom
###
wzk.ui.form.buttons.enable = (btn, dom) ->
  btn.removeAttribute('disabled')
  spinner = dom.cls(wzk.ui.form.buttons.SPINNER_CLS, btn)
  if spinner?
    dom.removeNode(spinner)


###*
  Enables buttons in a given `form`. Removes spinners and disable attributes from buttons.
  @param {Element} form
  @param {wzk.dom.DomHelper} dom
###
wzk.ui.form.buttons.enableInForm = (form, dom) ->
  for btn in dom.one(wzk.ui.form.buttons.BUTTON_SELECTOR, form)
    wzk.ui.form.buttons.enable(btn)


###*
  @private
  @param {wzk.dom.DomHelper} dom
  @return {Element}
###
wzk.ui.form.buildSpinner = (dom) ->
  dom.el('i', 'fa fa-refresh fa-spin ' + wzk.ui.form.buttons.SPINNER_CLS)


###*
  Prevents multi form submission by disabling buttons and adding a spinner into a submitter
  @param {Element} form
  @param {wzk.dom.DomHelper} dom
###
wzk.ui.form.buttons.preventMultiSubmission = (form, dom) ->
  return if goog.dom.classes.has(form, wzk.ui.form.buttons.AJAX_CLS)

  btns = dom.all(wzk.ui.form.buttons.BUTTON_SELECTOR, form)

  handleClick = (e) ->
    btn = (`/** @type {Element} */`) e.currentTarget
    if not dom.cls(wzk.ui.form.buttons.SPINNER_CLS, btn)
      dom.appendChild(btn, wzk.ui.form.buildSpinner(dom))

    if e.target.name?
      dom.appendChild(
        e.target.parentNode,
        dom.el('input', {type: 'hidden', name: e.target.name, value: e.target.value})
      )

  for btn in btns
    wzk.events.lst.onClickOrEnter(btn, handleClick)

  handleSubmit = ->
    for btn in btns
      btn.setAttribute('disabled', true)

  goog.events.listen(form, goog.events.EventType.SUBMIT, handleSubmit)
