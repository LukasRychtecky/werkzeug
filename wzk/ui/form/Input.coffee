goog.provide 'wzk.ui.form.Input'

goog.require 'wzk.ui.form.Field'
goog.require 'wzk.ui.form.InputRenderer'
goog.require 'goog.dom.TagName'
goog.require 'goog.dom.DomHelper'

class wzk.ui.form.Input extends wzk.ui.form.Field

  ###*
    @constructor
    @extends {wzk.ui.form.Field}
    @param {Object} params
      content: Text caption or DOM structure to display as the content of the control
      renderer: Renderer used to render or decorate the component, defaults to {@link wzk.ui.form.InputRenderer}
      dom: DomHelper
      type: A type of an input, defaults text
  ###
  constructor: (params = {}) ->
    params.renderer = wzk.ui.form.InputRenderer.getInstance() unless params?.renderer?

    super(params)
    {@type} = params
    @type ?= 'text'

  ###*
    Clears an input's value
  ###
  clear: ->
    @getElement().value = ''

  ###*
    @override
  ###
  render: (parent) ->
    super(parent)
    @fixInternalElement()

  ###*
    @override
  ###
  renderBefore: (subling) ->
    super(subling)
    @fixInternalElement()

  ###*
    @protected
    An internal element should not be always Input (see wzk.ui.form.InputSearchRenderer)
    Finds an appropriate input and sets as the internal element if it's necessary
  ###
  fixInternalElement: ->
    return if @isInput(@getElement())

    @setElementInternal(@dom_.getChildren(@getElement())[0])

  ###*
    @protected
    @param {Element} el
    @return {boolean}
  ###
  isInput: (el) ->
    el.tagName is String(goog.dom.TagName.INPUT)

  ###*
    @param {boolean} required
  ###
  makeRequired: (required = true) ->
    @getElement().required = if required then 'required' else undefined
