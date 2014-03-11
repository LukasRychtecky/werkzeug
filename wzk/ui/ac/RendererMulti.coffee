class wzk.ui.ac.RendererMulti extends wzk.ui.ac.Renderer

  @EventType:
    REMOVE: 'remove'

  @TAGS:
    ITEM: 'div'

  ###*
    Class for rendering the results of an auto-complete in a drop down list.

    @param {wzk.dom.Dom} dom
    @param {Element=} parentNode optional reference to the parent element
        that will hold the autocomplete elements. goog.dom.getDocument().body
        will be used if this is null.
    @param {?({renderRow}|{render})=} customRenderer Custom full renderer to
        render each row. Should be something with a renderRow or render method.
    @param {boolean=} rightAlign Determines if the autocomplete will always
        be right aligned. False by default.
    @param {boolean=} useStandardHighlighting Determines if standard
        highlighting should be applied to each row of data. Standard highlighting
        bolds every matching substring for a given token in each row. True by
        default.
  ###
  constructor: (@dom, @imagePlaceholder, parentNode, @customRenderer, rightAlign, useStandardHighlighting) ->
    super(@dom, @imagePlaceholder, parentNode, customRenderer, rightAlign, useStandardHighlighting)

  ###*
    Re-renders selected items with remove buttons above input
    @param {Array.<wzk.resource.Model>} models
  ###
  update: (models) ->
    @dom.removeChildren @items
    for model in models
      item = @dom.createDom wzk.ui.ac.RendererMulti.TAGS.ITEM
      @customRenderer.renderRow model, undefined, item
      @dom.appendChild item, @buildRemoveControl model
      @dom.appendChild @items, item

  ###*
    @protected
    @param {wzk.resource.Model} model
  ###
  buildRemoveControl: (model) ->
    removeControl = @dom.createDom 'input', {type: 'checkbox', checked: 'on'}
    goog.events.listen removeControl, goog.events.EventType.CLICK, @handleRemove
    removeControl.model = model
    removeControl

  ###*
    @protected
    @param {goog.events.Event} event
  ###
  handleRemove: (event) =>
    @dispatchEvent new goog.events.Event wzk.ui.ac.RendererMulti.EventType.REMOVE, event.target.model
