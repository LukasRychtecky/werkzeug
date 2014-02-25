class wzk.ui.tab.TabsRenderer extends wzk.ui.ComponentRenderer

  constructor: ->
    super()
    @classes = ['goog-tabs']

  ###*
    @param {wzk.ui.Component} tabs
    @param {Element} element
  ###
  decorate: (tabs, element) ->
    tabs.setId(element.id) if element.id?

goog.addSingletonGetter wzk.ui.tab.TabsRenderer
