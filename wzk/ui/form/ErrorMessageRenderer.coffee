goog.provide 'wzk.ui.form.ErrorMessageRenderer'

goog.require 'wzk.ui.ComponentRenderer'

###*
  A renderer for field validation errors. Renders errors as UL.
###
class wzk.ui.form.ErrorMessageRenderer extends wzk.ui.ComponentRenderer

  ###*
    @constructor
    @extends {wzk.ui.ComponentRenderer}
  ###
  constructor: ->

  createDom: (error) ->
    error.getDomHelper().createDom 'ul'

  ###*
    @param {wzk.dom.Dom} dom
    @param {string} msg
    @return {Element}
  ###
  buildMessage: (dom, msg) ->
    dom.el 'li', {}, msg

goog.addSingletonGetter wzk.ui.form.ErrorMessageRenderer
