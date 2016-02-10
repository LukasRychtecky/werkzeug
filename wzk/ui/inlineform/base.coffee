goog.provide 'wzk.ui.inlineform'

goog.require 'goog.dom.classes'
goog.require 'goog.string'

goog.require 'wzk.ui.inlineform.DynamicForm'

###*
  @param {Element} fieldset
  @param {wzk.dom.Dom} dom
###
wzk.ui.inlineform.buildDynamicButton = (fieldset, dom, register) ->
  form = new wzk.ui.inlineform.DynamicForm dom, register
  form.dynamic fieldset, not goog.dom.classes.has(fieldset, 'disabled')


###*
  @param {wzk.dom.Dom} dom
  @param {Element} row
  @return {Element|null}
###
wzk.ui.inlineform.getRemoveCheckboxOrNull = (dom, row) ->
  checkboxes = (checkbox for checkbox in dom.all('input[type=checkbox]', row) when goog.string.endsWith(checkbox.id, 'DELETE'))
  return if checkboxes.length then checkboxes[0] else null
