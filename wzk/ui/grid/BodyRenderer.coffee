class wzk.ui.grid.BodyRenderer extends goog.ui.ContainerRenderer

  constructor: ->
    super()
    @tag = 'tbody'

  ###*
    @param {goog.ui.Container} container
    @return {Element}
  ###
  createDom: (container) ->
    container.getDomHelper().el @tag, @getClassNames(container).join(' ')

goog.addSingletonGetter wzk.ui.grid.BodyRenderer
