goog.provide 'wzk.ui.form.BackgroundForm'

goog.require 'goog.events.EventTarget'
goog.require 'goog.ui.Button'
goog.require 'goog.dom.forms'

class wzk.ui.form.BackgroundForm extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @EventType:
    SAVED: 'saved'
    ERROR: 'error'

  ###*
    @constructor
    @extends {goog.events.EventTarget}
    @param {wzk.resource.Client} client
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@client, @dom) ->
    super()
    @btns = []
    @clean = false

  ###*
    @param {Element} form
  ###
  decorate: (form) ->
    return unless form?

    dispatchers = @dom.all '.btn-save', form
    return unless dispatchers

    @btns = []
    for dispatcher in dispatchers
      btn = new goog.ui.Button()
      btn.decorate dispatcher
      @btns.push btn

    @hangListener form
    @removeDefaultBehaviour form

  ###*
    @protected
    @param {Element} form
  ###
  removeDefaultBehaviour: (form) ->
    goog.events.listen form, 'submit', (e) ->
      e.preventDefault()

  ###*
    @protected
    @param {Element} form
  ###
  hangListener: (form) ->
    for btn in @btns
      btn.listen goog.ui.Component.EventType.ACTION, (event) =>
        btn = event.target
        btn.setEnabled false

        name = btn.getElement().getAttribute 'name'
        value = btn.getElement().getAttribute 'value'

        if name?
          hidden = @dom.createDom  'input', {type: 'hidden', name: name, value: value}
          @dom.appendChild form, hidden

        @send form

  ###*
    @param {Element} form
  ###
  send: (@form) ->

  ###*
    @param {boolean} clean
  ###
  cleanAfterSubmit: (@clean) ->

  ###*
    @protected
    @param {Object} data
  ###
  onSuccess: (data) =>
    if @clean
      for field in @dom.all 'input[type=text], textarea', @form
        goog.dom.forms.setValue field, ''

  ###*
    @protected
    @param {*} res
  ###
  onError: (res) ->

  ###*
    @param {boolean} enable
  ###
  setButtonsEnabled: (enable) ->
    for btn in @btns
      btn.setEnabled enable
