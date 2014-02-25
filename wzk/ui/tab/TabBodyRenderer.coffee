class wzk.ui.tab.TabBodyRenderer extends wzk.ui.ComponentRenderer

  constructor: ->
    super()

  ###*
    @param {Element} element
  ###
  canDecorate: (element) ->
    true

  ###*
    @param {wzk.ui.Component} component
    @param {Element} element
  ###
  decorate: (component, element) ->
    component.setId element.id if element.id?

goog.addSingletonGetter wzk.ui.tab.TabBodyRenderer
