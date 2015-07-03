goog.provide 'wzk.ui.dialog'

goog.require 'goog.events'
goog.require 'goog.events.EventType'

goog.require 'wzk.resource.Client'
goog.require 'wzk.ui.dialog.SnippetModal'

###*
  @param {Element} el an element that triggers a modal
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
  @param {wzk.app.Register} register
###
wzk.ui.dialog.buildSnippetModal = (el, dom, xhrFac, register) ->
  url = String(goog.dom.dataset.get(el, 'url'))
  snippet = String(goog.dom.dataset.get(el, 'snippetName'))
  modal = new wzk.ui.dialog.SnippetModal dom, new wzk.resource.Client(xhrFac), url, snippet, register
  goog.events.listen el, goog.events.EventType.CLICK, (e) ->
    e.preventDefault()
    modal.open()
