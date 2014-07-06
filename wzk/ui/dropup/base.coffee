goog.provide 'wzk.ui.dropup'

goog.require 'wzk.ui.dropup.Dropup'
goog.require 'wzk.num'
goog.require 'goog.dom.dataset'

###*
  @param {Element} el
  @param {wzk.dom.Dom} dom
  @param {number|undefined=} duration affects speed of sliding
###
wzk.ui.dropup.build = (el, dom, duration = undefined) ->
  duration ?= wzk.num.parseDec String(goog.dom.dataset.get(el, 'duration')), 250
  dropup = new wzk.ui.dropup.Dropup dom, duration
  dropup.decorate el
