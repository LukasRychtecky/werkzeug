goog.provide 'wzk.ui'

goog.require 'wzk.dom.Dom'
goog.require 'wzk.ui.Flash'
goog.require 'goog.dom.dataset'

###*
  @param {Document} doc
  @return {wzk.ui.Flash}
###
wzk.ui.buildFlash = (doc) ->
  new wzk.ui.Flash dom: new wzk.dom.Dom(doc)

###*
  @param {Element} el
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
###
wzk.ui.loadSnippet = (el, dom, xhrFac) ->
  url = String goog.dom.dataset.get el, 'snippetOnload'
  if url
    xhrFac.build().send url, 'GET', '', {}
