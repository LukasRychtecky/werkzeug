goog.provide 'wzk.ui.popup'
goog.require 'wzk.ui.popup.Popup'

###*
  @param {Element} el
  @param {wzk.dom.Dom} dom
###
wzk.ui.popup.dropdown = (el, dom) ->
  new wzk.ui.popup.Popup({dom:dom}).decorate(el)
