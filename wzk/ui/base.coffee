goog.provide 'wzk.ui'

goog.require 'wzk.dom.Dom'
goog.require 'wzk.ui.Flash'
goog.require 'goog.dom.classes'
goog.require 'goog.dom.dataset'
goog.require 'wzk.net.XhrConfig'

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
    xhrFac.build(new wzk.net.XhrConfig()).send url, 'GET', '', {}

###*
  @param {Element} el
  @param {wzk.dom.Dom} dom
###
wzk.ui.navbarToggle = (el, dom) ->
  goog.events.listen el, goog.events.EventType.CLICK, ->
    goog.dom.classes.toggle el, 'collapsed'

    target = goog.dom.dataset.get el, 'target'
    menu = dom.cls String target
    goog.dom.classes.toggle menu, 'in'
