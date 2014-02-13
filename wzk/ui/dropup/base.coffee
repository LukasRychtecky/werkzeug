goog.provide 'wzk.ui.dropup'

###*
  @param {Element} el
  @param {wzk.dom.Dom} dom
###
wzk.ui.dropup.build = (el, dom)->
  dropup = new wzk.ui.dropup.Dropup dom
  dropup.decorate el
