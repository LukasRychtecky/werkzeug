goog.provide 'wzk.ui.dropup'

goog.require 'wzk.ui.dropup.Dropup'

###*
  @param {Element} el
  @param {wzk.dom.Dom} dom
  @param {number=} duration affects speed of sliding
###
wzk.ui.dropup.build = (el, dom, duration)->
  dropup = new wzk.ui.dropup.Dropup dom, duration
  dropup.decorate el
