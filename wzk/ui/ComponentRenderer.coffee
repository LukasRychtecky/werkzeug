goog.provide 'wzk.ui.ComponentRenderer'

###*
  A base component renderer. By default renders a component as DIV.
###
class wzk.ui.ComponentRenderer

  ###*
    @constructor
  ###
  constructor: ->

  ###*
    @param {wzk.ui.Component}
    @return {Element}
  ###
  createDom: (component) ->
    component.getDomHelper().createDom 'div'

  ###*
    @param {wzk.ui.Component} component
    @return {Array.<string>}
  ###
  getClassNames: (component) ->
    component.cssClasses

goog.addSingletonGetter wzk.ui.ComponentRenderer
