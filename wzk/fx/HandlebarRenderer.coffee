class wzk.fx.HandlebarRenderer extends wzk.ui.ComponentRenderer

  constructor: ->
    super()

  ###*
    @override
  ###
  createDom: (component) ->
    el = super component
    el.appendChild @buildHandler(component)
    el

  ###*
    @protected
    @param {wzk.ui.Component} component
    @return {Element}
  ###
  buildHandler: (component) ->
    component.getDomHelper().createDom 'span', 'icon-handle'

goog.addSingletonGetter wzk.fx.HandlebarRenderer
