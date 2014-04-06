goog.require 'wzk.dom.Dom'

###*
  A base component renderer. By default renders a component as DIV.
###
class wzk.ui.ComponentRenderer

  ###*
    @constructor
  ###
  constructor: ->
    @tag = 'div'
    @classes = []

  ###*
    @param {wzk.ui.Component} component
    @return {Element}
  ###
  createDom: (component) ->
    component.getDomHelper().el @tag, @buildAttrs(component), component.getCaption()

  ###*
    @param {wzk.ui.Component} component
    @return {Array.<string>}
  ###
  getClassNames: (component) ->
    @classes.concat component.cssClasses

  ###*
    @param {wzk.ui.Component} component
    @return {string}
  ###
  getClassesAsString: (component) ->
    @getClassNames(component).join ' '

  ###*
    @protected
    @param {wzk.ui.Component} component
    @return {Object}
  ###
  buildAttrs: (component) ->
    'id': component.getId()
    'class': @getClassesAsString(component)

goog.addSingletonGetter wzk.ui.ComponentRenderer
