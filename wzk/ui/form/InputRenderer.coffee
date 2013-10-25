goog.provide 'wzk.ui.form.InputRenderer'

goog.require 'goog.ui.ControlRenderer'

class wzk.ui.form.InputRenderer extends goog.ui.ControlRenderer

  ###*
    @constructor
    @extends {goog.ui.ControlRenderer}
  ###
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
    input.getDomHelper().createDom('input',
      'type': input.type
      'class': @getClassNames(input).join(' ')
    )

goog.addSingletonGetter wzk.ui.form.InputRenderer
