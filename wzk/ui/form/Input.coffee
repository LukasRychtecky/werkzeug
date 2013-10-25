goog.provide 'wzk.ui.form.Input'

goog.require 'goog.ui.Control'
goog.require 'wzk.ui.form.InputRenderer'
goog.require 'goog.dom.TagName'
goog.require 'goog.dom.DomHelper'

class wzk.ui.form.Input extends goog.ui.Control

  ###*
    @constructor
    @extends {goog.ui.Control}
    @param {Object} param
      content: Text caption or DOM structure to display as the content of the control
      renderer: Renderer used to render or decorate the component, defaults to {@link wzk.ui.form.InputRenderer}
      dom: DomHelper
      type: A type of an input, defaults text
  ###
  constructor: (params = {}) ->
    {content, renderer, dom, @type} = params
    @type = 'text' unless @type?
    renderer = wzk.ui.form.InputRenderer.getInstance() unless renderer?
    super(content, renderer, dom)
    @setHandleMouseEvents(false)
    @setAllowTextSelection(true)
    @setContentInternal('') unless content?

  ###*
    @param {*} val
  ###
  setValue: (val) ->
    @setContent(String(val))

  ###*
    @returns {string}
  ###
  getValue: ->
    @getElement().value

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
    el.tagName is goog.dom.TagName.INPUT

  ###*
    @param {boolean} required
  ###
  makeRequired: (required = true) ->
    @getElement().required = if required then 'required' else undefined
