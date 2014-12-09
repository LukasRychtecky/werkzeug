goog.provide 'wzk.dom.classes'

goog.require 'goog.dom.classes'

###*
  Returns true if the given element has any of given classes, otherwise false

  @param {Element} el
  @param {Array.<string>} classes
###
wzk.dom.classes.hasAny = (el, classes) ->
  for cls in classes
    return true if goog.dom.classes.has el, cls
  false
