goog.provide 'wzk.ui.ac'

goog.require 'wzk.ui.ac.SelectAutoComplete'
goog.require 'goog.dom.dataset'
goog.require 'wzk.resource.Query'
goog.require 'wzk.ui.ac.Renderer'
goog.require 'wzk.ui.ac.PictureCustomRenderer'
goog.require 'wzk.ui.ac.ExtSelectbox'
goog.require 'wzk.ui.ac.ExtSelectboxStorage'
goog.require 'wzk.ui.ac.ExtSelectboxStorageHandler'
goog.require 'wzk.ui.ac.NativeDataProvider'
goog.require 'wzk.ui.ac.RestDataProvider'
goog.require 'wzk.ui.ac.InputAutoComplete'


###*
  @param {HTMLSelectElement} select
  @param {wzk.dom.Dom} dom
  @return {wzk.ui.ac.SelectAutoComplete}
###
wzk.ui.ac.buildSelectAutoCompleteNative = (select, dom) ->
  ac = wzk.ui.ac.buildSelectAutocompleteInternal select, dom
  dataProvider = new wzk.ui.ac.NativeDataProvider()
  dataProvider.load select, dom, (data) ->
    ac.load(data)
  ac

###*
  @param {Element} el
  @param {wzk.dom.Dom} dom
###
wzk.ui.ac.buildSelectAutoCompleteRest = (el, dom, api, tokenName, limit, tokenMinLength) ->
  el = (`/** @type {HTMLSelectElement} */`) el
  ac = new wzk.ui.ac.InputAutoComplete(
    dom,
    new wzk.ui.ac.Renderer(dom, null, wzk.ui.ac.buildCustomRenderer(el, dom)),
    api,
    tokenName,
    limit,
    tokenMinLength,
  )
  ac.decorate(el)
  ac

###*
  @param {HTMLSelectElement} select
  @param {wzk.dom.Dom} dom
###
wzk.ui.ac.buildExtSelectboxFromSelectNative = (select, dom) ->
  selectbox = wzk.ui.ac.buildExtSelectboxFromSelectInternal select, dom

  dataProvider = new wzk.ui.ac.NativeDataProvider()
  dataProvider.load select, dom, (data) ->
    selectbox.decorate(select, data)

###*
  @param {HTMLSelectElement} select
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
###
wzk.ui.ac.buildExtSelectboxFromSelectRest = (select, dom, xhrFac) ->
  selectbox = wzk.ui.ac.buildExtSelectboxFromSelectInternal select, dom
  wzk.ui.ac.buildRestDataProvider select, xhrFac, (data) ->
    selectbox.decorate(select, data)

###*
  @param {HTMLSelectElement} select
  @param {wzk.net.XhrFactory} xhrFac
  @param {function(Object)} onLoad
###
wzk.ui.ac.buildRestDataProvider = (select, xhrFac, onLoad) ->
  dataProvider = new wzk.ui.ac.RestDataProvider()
  wzk.ui.ac.addFields(dataProvider, select)
  dataProvider.load select, xhrFac, (data) ->
    onLoad(data)

###*
  @param {HTMLSelectElement} select
  @param {wzk.dom.Dom} dom
  @return {wzk.ui.ac.SelectAutoComplete}
###
wzk.ui.ac.buildSelectAutocompleteInternal = (select, dom) ->
  customRenderer = wzk.ui.ac.buildCustomRenderer(select, dom)
  renderer = new wzk.ui.ac.Renderer(dom, null, customRenderer)
  ac = new wzk.ui.ac.SelectAutoComplete dom, renderer
  ac.decorate select
  ac

###*
  @param {HTMLSelectElement} select
  @param {wzk.dom.Dom} dom
###
wzk.ui.ac.buildExtSelectboxFromSelectInternal = (select, dom) ->
  return unless select?

  customRenderer = wzk.ui.ac.buildCustomRenderer(select, dom)
  renderer = new wzk.ui.ac.Renderer(dom, null, customRenderer)
  storage = new wzk.ui.ac.ExtSelectboxStorage(dom, select)
  selectbox = new wzk.ui.ac.ExtSelectbox(dom, renderer, customRenderer, new wzk.ui.ac.ExtSelectboxStorageHandler(select, storage))
  selectbox

###*
  Builds renderer only if select has data-image attribute
  @protected
  @param {HTMLSelectElement} select
  @param {wzk.dom.Dom} dom
###
wzk.ui.ac.buildCustomRenderer = (select, dom) ->
  customRenderer = null
  # if any option has 'data-image' attribute, use custom renderer
  if select.querySelector("option[data-image]")?
    customRenderer = new wzk.ui.ac.PictureCustomRenderer(dom)
  customRenderer

###*
  @param {wzk.ui.ac.RestDataProvider} dataProvider
  @param {Element} el
###
wzk.ui.ac.addFields = (dataProvider, el) ->
  dataProvider.addField('_autocomplete_value')
  dataProvider.addField('_obj_name')
  dataProvider.addField('photo')
  fields = wzk.ui.ac.extractFieldNames(el)
  if fields.length > 0
    for field in fields
      dataProvider.addField(field)

###*
  @param {Element} el
  @return {Array.<string>}
###
wzk.ui.ac.extractFieldNames = (el) ->
  fieldsValue = goog.dom.dataset.get(el, 'fields')
  return if fieldsValue? then (v.split('__')[0] for k, v of goog.json.parse(fieldsValue)) else []
