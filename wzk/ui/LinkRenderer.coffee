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
    a.innerHTML = ''
    a.href = component.getHref()
    a.title = component.getTitle()
    span = component.getDomHelper().el 'span', {}, component.getCaption()
    a.appendChild span
    a

goog.addSingletonGetter wzk.ui.LinkRenderer
