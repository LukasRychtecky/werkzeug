class wzk.ui.InputRenderer extends goog.ui.ControlRenderer

  constructor: ->
    super()

  ###*
    @override
  ###
  decorate: (input, element) ->
    super(input, element)
    input.setContent(element.value)
    element

  ###*
    @override
  ###
  canDecorate: (element) ->
    element.tagName is goog.dom.TagName.INPUT

  ###*
    @override
  ###
  createDom: (input) ->
    input.getDomHelper().el('input',
      'type': 'text'
      'class': @getClassNames(input).join(' ')
    )

goog.addSingletonGetter wzk.ui.InputRenderer
