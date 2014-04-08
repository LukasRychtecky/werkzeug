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

###*
  Default selectAutoComplete builder; ensures backwards compatibility
  @param {Element} select
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
###
wzk.ui.ac.buildSelectAutoComplete = (select, dom, xhrFac) ->
  select = (`/** @type {HTMLSelectElement} */`) select
  wzk.ui.ac.buildSelectAutoCompleteRest select, dom, xhrFac

###*
  @param {HTMLSelectElement} select
  @param {wzk.dom.Dom} dom
###
wzk.ui.ac.buildSelectAutoCompleteNative = (select, dom) ->
  ac = wzk.ui.ac.buildSelectAutocompleteInternal select, dom
  dataProvider = new wzk.ui.ac.NativeDataProvider()
  dataProvider.load select, dom, (data) ->
    ac.load data

###*
  @param {HTMLSelectElement} select
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
###
wzk.ui.ac.buildSelectAutoCompleteRest = (select, dom, xhrFac) ->
  ac = wzk.ui.ac.buildSelectAutocompleteInternal select, dom
  dataProvider = new wzk.ui.ac.RestDataProvider()
  wzk.ui.ac.addExtraFields dataProvider
  dataProvider.load select, xhrFac, (data) ->
    ac.load data

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
  wzk.ui.ac.addExtraFields dataProvider
  dataProvider.load select, xhrFac, (data) ->
    onLoad(data)

###*
  @param {HTMLSelectElement} select
  @param {wzk.dom.Dom} dom
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
  # if any option has 'data-image' attribute, use custom renderer
  if select.querySelector("option[data-image]")?
    customRenderer = new wzk.ui.ac.PictureCustomRenderer(dom)
  else
    customRenderer = null
  customRenderer

###*
  @protected
  @param {wzk.ui.ac.RestDataProvider} dataProvider
###
wzk.ui.ac.addExtraFields = (dataProvider) ->
  dataProvider.addExtraField '_obj_name'
  dataProvider.addExtraField 'photo'
