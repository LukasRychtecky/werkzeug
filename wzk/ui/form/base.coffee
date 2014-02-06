goog.provide 'wzk.ui.form'

goog.require 'goog.dom.dataset'
goog.require 'wzk.ui.form.RestForm'
goog.require 'wzk.ui.form.ModalForm'
goog.require 'goog.dom.forms'
goog.require 'wzk.resource.Client'

###*
  @param {Element} form
  @return {Object}
###
wzk.ui.form.form2Json = (form) ->
  map = goog.dom.forms.getFormDataMap((`/** @type {HTMLFormElement} */`) form)
  json = {}
  for k in map.getKeys()
    v = map.get k
    json[k] = if goog.isArray(v) then v.pop() else v
  json

###*
  @param {Element} parent
  @param {boolean=} skipCsrf
  @param {RegExp=} filterByName
  @return {Object}
###
wzk.ui.form.formFields2Json = (parent, skipCsrf = true, filterByName = /INITIAL_FORMS|TOTAL_FORMS|MAX_NUM_FORMS$/) ->
  json = {}
  for el in parent.querySelectorAll 'input, textarea, select'
    continue if el.name is 'csrfmiddlewaretoken' and skipCsrf
    continue if filterByName and filterByName.test el.name
    json[el.name] = goog.dom.forms.getValue el
  json

###*
  @param {Element} form
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
###
wzk.ui.form.ajaxifyForm = (form, dom, xhrFac) ->
  client = new wzk.resource.Client xhrFac
  new wzk.ui.form.RestForm(client, dom).decorate form

###*
  @param {Element} el
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
  @param {wzk.wzk.App} appInstance
###
wzk.ui.form.openFormInModal = (el, dom, xhrFac, appInstance) ->
  url = goog.dom.dataset.get el, 'modal'
  client = new wzk.resource.Client xhrFac
  modal = new wzk.ui.form.ModalForm dom, client, String(url), appInstance
  modal.setTitle el.title if el.title

  goog.events.listen el, goog.events.EventType.CLICK, ->
    modal.open()
