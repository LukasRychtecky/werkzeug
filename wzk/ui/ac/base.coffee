goog.provide 'wzk.ui.ac'

goog.require 'wzk.ui.ac.SelectAutoComplete'
goog.require 'goog.dom.dataset'
goog.require 'wzk.resource.Query'
goog.require 'wzk.ui.ac.Renderer'
goog.require 'wzk.ui.ac.PictureCustomRenderer'

###*
  @param {Element} select
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
###
wzk.ui.ac.buildSelectAutoComplete = (select, dom, xhrFac) ->
  url = goog.dom.dataset.get select, 'resource'

  renderer = new wzk.ui.ac.Renderer(dom, null, null, new wzk.ui.ac.PictureCustomRenderer(dom))
  ac = new wzk.ui.ac.SelectAutoComplete dom, renderer
  ac.decorate select

  client = new wzk.resource.Client(xhrFac)
  query = new wzk.resource.Query()
  query.addExtraField '_obj_name'
  client.setDefaultExtraFields query
  client.find url, (data) ->
    ac.load data
