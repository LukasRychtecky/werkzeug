goog.provide 'wzk.ui.tab'

goog.require 'wzk.ui.tab.Tabs'

###*
  @param {Element} el
  @param {wzk.dom.Dom} dom
###
wzk.ui.tab.decorate = (el, dom) ->
  tabs = new wzk.ui.tab.Tabs dom: dom
  tabs.decorate el
