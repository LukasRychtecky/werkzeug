goog.provide 'wzk.ui.LinkRenderer'

class wzk.ui.LinkRenderer extends wzk.ui.ComponentRenderer

  constructor: ->
    super()
    @tag = 'a'
    @classes = ['btn', 'btn-link']

  ###*
    @override
  ###
  createDom: (component) ->
    a = super component
    a.href = component.getHref()
    span = component.getDomHelper().el 'span', {}, component.getCaption()
    a.appendChild span
    a

goog.addSingletonGetter wzk.ui.LinkRenderer
