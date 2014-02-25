class wzk.ui.ControlRenderer extends goog.ui.ControlRenderer

  constructor: ->
    super()
    @tag = 'div'

  ###*
    @override
  ###
  createDom: (control) ->
    el = control.getDomHelper().el @tag, @getClassNames(control).join(' '), control.getContent()
    @setAriaStates control, el
    el

goog.addSingletonGetter wzk.ui.ControlRenderer
