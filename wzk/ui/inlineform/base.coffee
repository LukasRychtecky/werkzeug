goog.provide 'wzk.ui.inlineform'

goog.require 'wzk.ui.inlineform.DynamicForm'
goog.require 'goog.dom.classes'

###*
  @param {Element} fieldset
  @param {goog.dom.DomHelper} dom
###
wzk.ui.inlineform.buildDynamicButton = (fieldset, dom) ->
  form = new wzk.ui.inlineform.DynamicForm dom
  form.dynamic fieldset, not goog.dom.classes.has(fieldset, 'disabled')
