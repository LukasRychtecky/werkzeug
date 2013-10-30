goog.provide 'wzk.ui.Control'

goog.require 'goog.ui.Control'

class wzk.ui.Control extends goog.ui.Control

  ###*
    @constructor
    @extends {goog.ui.Control}
    @param {Object} params
      content: Text caption or DOM structure to display as the content of the control
      renderer: Renderer used to render or decorate the component, defaults to {@link wzk.ui.form.InputRenderer}
      dom: DomHelper
      type: A type of an input, defaults text
  ###
  constructor: (params = {}) ->
    {content, renderer, dom} = params
    super(content, renderer, dom)
