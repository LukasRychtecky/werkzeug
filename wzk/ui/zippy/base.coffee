goog.provide 'wzk.ui.zippy'

goog.require 'wzk.ui.zippy.Zippy'
goog.require 'wzk.ui.zippy.CollapsableList'

###*
  Element must have 1:N messege classes
  each message class must have childs with classes: head, text and message-preview
  head is always displayed, text is expanded on click on head
  message-preview is hidden on expand, shown on collapse

  @param {Element} messages
  @param {wzk.dom.Dom} dom
###
wzk.ui.zippy.buildZippy = (messages, dom) ->
  zippy = new wzk.ui.zippy.Zippy dom
  zippy.decorate messages

###*
  @param {Element} el
  @param {wzk.dom.Dom} dom
###
wzk.ui.zippy.buildCollapsableList = (el, dom) ->
  collapsable = new wzk.ui.zippy.CollapsableList {dom: dom}
  collapsable.decorate el
