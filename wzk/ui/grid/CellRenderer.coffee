class wzk.ui.grid.CellRenderer extends wzk.ui.ComponentRenderer

  constructor: ->
    super()
    @tag = 'td'

  ###*
    @override
  ###
  createDom: (component) ->
    dom = component.getDomHelper()
    td = dom.el @tag, @buildAttrs(component)
    wrapper = dom.el 'span', 'cell-content', component.getCaption()
    td.appendChild wrapper
    td

goog.addSingletonGetter wzk.ui.grid.CellRenderer
