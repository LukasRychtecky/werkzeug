goog.provide 'wzk.ui'

goog.require 'wzk.dom.Dom'
goog.require 'wzk.ui.Flash'

###*
  @param {Document} doc
  @return {wzk.ui.Flash}
###
wzk.ui.buildFlash = (doc) ->
  new wzk.ui.Flash dom: new wzk.dom.Dom(doc)
