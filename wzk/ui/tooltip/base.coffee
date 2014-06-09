goog.provide 'wzk.ui.tooltip'

goog.require 'goog.dom.dataset'
goog.require 'goog.ui.Tooltip'

wzk.ui.tooltip.tooltipy = (el, dom) ->
  title = goog.dom.dataset.get el, 'title'
  new goog.ui.Tooltip el, title, dom
