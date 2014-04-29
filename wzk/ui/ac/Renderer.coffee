goog.require 'wzk.ui.Input'
goog.require 'wzk.ui.OpenIcon'
goog.require 'wzk.ui.ClearableInput'
goog.require 'goog.style'

class wzk.ui.ac.Renderer extends goog.ui.ac.Renderer

  ###*
    @enum {string}
  ###
  @TAGS:
    ITEM: 'span'
    CONTAINER: 'ul'
    ROW: 'li'
    ITEMS_CONTAINER: 'div'

  ###*
    @enum {string}
  ###
  @CLS:
    CONTAINER: 'ac dropdown-menu'
    ROW: 'ac-row'
    ACTIVE: 'active'
    ITEM: 'ac-item ac-buttons'
    IMG: 'ac-image'
    WITH_IMAGE: 'with-image'

  ###*
    @enum {string}
  ###
  @EventType:
    CLEAN: 'clean'
    OPEN: 'open'

  ###*
    Class for rendering the results of an auto-complete in a drop down list.

    @param {wzk.dom.Dom} dom
    @param {?({renderRow}|{render})=} customRenderer Custom full renderer to
        render each row. Should be something with a renderRow or render method.
    @param {boolean=} rightAlign Determines if the autocomplete will always
        be right aligned. False by default.
    @param {boolean=} useStandardHighlighting Determines if standard
        highlighting should be applied to each row of data. Standard highlighting
        bolds every matching substring for a given token in each row. True by
        default.
  ###
  constructor: (@dom, @imagePlaceholder, @customRenderer, rightAlign, useStandardHighlighting) ->
    super(null, customRenderer, rightAlign, useStandardHighlighting)

    @className = wzk.ui.ac.Renderer.CLS.CONTAINER
    @rowClassName = wzk.ui.ac.Renderer.CLS.ROW
    @activeClassName = wzk.ui.ac.Renderer.CLS.ACTIVE
    @imgOrPlaceholder = null
    @input = null

  ###*
    @param {Element} select element to be decorated
  ###
  decorate: (@select) ->
    goog.style.setElementShown @select, false
    @readonly = @select.hasAttribute('readonly')

    # create input element and attach it to dom
    @container = @dom.createDom wzk.ui.ac.Renderer.TAGS.ITEM, wzk.ui.ac.Renderer.CLS.ITEM

    if @customRenderer?
      @imgOrPlaceholder = @customRenderer.createImageOrPlaceholder()
      @dom.appendChild @container, @imgOrPlaceholder

    # parent of select element is cosidered to be container
    selectParent = @dom.getParentElement @select
    @dom.appendChild selectParent, @container

    @buildInput()
    @items = @dom.createDom wzk.ui.ac.Renderer.TAGS.ITEMS_CONTAINER

    if @customRenderer?
      goog.dom.classes.add @input.getElement(), wzk.ui.ac.Renderer.CLS.WITH_IMAGE

    if @readonly
      @input.getElement().setAttribute 'readonly', 'true'
    else
      @openBtn = new wzk.ui.OpenIcon()
      @openBtn.listen goog.ui.Component.EventType.ACTION, @handleOpen
      @openBtn.render @container

  ###*
    @protected
  ###
  buildInput: ->
    @input = new wzk.ui.ClearableInput @dom
    @input.listen wzk.ui.Input.EventType.VALUE_CHANGE, @handleInputValueChange
    @input.render @container

    if @select.hasAttribute 'placeholder' and (not @readonly)
      @input.getElement().setAttribute 'placeholder', @select.getAttribute 'placeholder'

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleOpen: (e) =>
    @dispatchEvent new goog.events.Event(wzk.ui.ac.Renderer.EventType.OPEN)

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleInputValueChange: (e) =>
    unless @readonly
      if e.target.getContent()
        goog.style.setElementShown @openBtn.getElement(), false
      else
        goog.style.setElementShown @openBtn.getElement(), true
        @clearImage()
        @dispatchClean()

  ###*
    Dispatches clean signal
  ###
  dispatchClean: ->
    @dispatchEvent new goog.events.Event(wzk.ui.ac.Renderer.EventType.CLEAN)

  ###*
    @return {wzk.ui.Input}
  ###
  getInput: ->
    @input

  ###*
    @param {Element} container
  ###
  setContainer: (@container) ->

  ###*
    @param {Object|null|undefined=} data
  ###
  updateImage: (data = null) ->
    if @imgOrPlaceholder?
      newImg = @customRenderer.createImageOrPlaceholder data
      @dom.replaceNode newImg, @imgOrPlaceholder
      @imgOrPlaceholder = newImg

  clearImage: ->
    if @customRenderer?
      placeholder = @customRenderer.createImagePlaceholder()
      @dom.replaceNode placeholder, @imgOrPlaceholder
      @imgOrPlaceholder = placeholder

  ###*
    If the main HTML element hasn't been made yet, creates it and appends it
    to the parent.

    @override
    @suppress {visibility}
  ###
  maybeCreateElement_: ->
    unless @element_
      # Make element and add it to the parent
      el = @dom.createDom(wzk.ui.ac.Renderer.TAGS.CONTAINER, {style: 'display:none'})
      if @showScrollbarsIfTooLarge_
        # Make sure that the dropdown will get scrollbars if it isn't large
        # enough to show all rows.
        goog.style.setStyle el, 'overflow-y', 'auto'

      @element_ = el
      @setMenuClasses_ el
      goog.a11y.aria.setRole el, goog.a11y.aria.Role.LISTBOX

      el.id = goog.ui.IdGenerator.getInstance().getNextUniqueId()

      @dom.appendChild @container, el

      # Add this object as an event handler
      goog.events.listen el, goog.events.EventType.CLICK, @handleClick_, false, @
      goog.events.listen el, goog.events.EventType.MOUSEDOWN, @handleMouseDown_, false, @
      goog.events.listen el, goog.events.EventType.MOUSEOVER, @handleMouseOver_, false, @
      undefined # Coffee & Closure

  ###*
    Render a row by creating a div and then calling row rendering callback or
    default row handler

    @override
    @suppress {visibility}
    @param {Object} row Object representing row.
    @param {string} token Token to highlight.
    @return {Element} An element with the rendered HTML.
  ###
  renderRowHtml: (row, token) ->
    # unique id
    id = goog.ui.IdGenerator.getInstance().getNextUniqueId()

    # create and return the node
    node = @dom.createDom wzk.ui.ac.Renderer.TAGS.ROW, {className: wzk.ui.ac.Renderer.CLS.ROW, id: id}

    goog.a11y.aria.setRole node, goog.a11y.aria.Role.OPTION

    if @customRenderer_ and @customRenderer_.renderRow
      @customRenderer_.renderRow row, token, node
    else
      @renderRowContents_ row, token, node

    if token and @useStandardHighlighting_
      @hiliteMatchingText_(node, token)

    goog.dom.classes.add node, @rowClassName
    @rowDivs_.push node
    node
