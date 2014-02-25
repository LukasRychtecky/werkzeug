class wzk.ui.ac.Renderer extends goog.ui.ac.Renderer

  ###*
    @enum {string}
  ###
  @TAGS:
    ITEM: 'span'
    CONTAINER: 'ul'
    ROW: 'li'

  ###*
    @enum {string}
  ###
  @STYLE:
    CONTAINER_CLASSNAME: 'dropdown-menu'
    ROW_CLASSNAME: 'ac-row'
    ACTIVE_CLASS_NAME: 'active'
    ITEM_CLASS: 'ac-item'
    IMAGE_CLASS: 'ac-image'

  ###*
    Class for rendering the results of an auto-complete in a drop down list.

    @constructor
    @param {wzk.ui.dom.Dom} dom
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
    @extends {goog.events.EventTarget}
  ###
  constructor: (@dom, parentNode, customRenderer, rightAlign, useStandardHighlighting) ->
    super(parentNode, customRenderer, rightAlign, useStandardHighlighting)
    @TAGS = wzk.ui.ac.Renderer.TAGS
    @STYLE = wzk.ui.ac.Renderer.STYLE

    @className = @STYLE.CONTAINER_CLASSNAME
    @rowClassName = @STYLE.ROW_CLASSNAME
    @activeClassName = @STYLE.ACTIVE_CLASS_NAME

  decorate: (@select) ->
    # create input element and attach it to dom
    @item = @dom.createDom @TAGS.ITEM, @STYLE.ITEM_CLASS
    @image = @dom.createDom 'img', {src: @STYLE.PLACEHOLDER_IMAGE, class: @STYLE.IMAGE_CLASS}
    @input = @dom.createDom 'input', {type: 'text'}

    # parent of select element is cosidered to be container
    selectParent = @dom.getParentElement @select

    @dom.appendChild selectParent, @item
    @dom.appendChild @item, @image
    @dom.appendChild @item, @input

  getInput: ->
    @input

  setImage: (imageUrl) ->
    @image.setAttribute('src', imageUrl)

  ###*
    If the main HTML element hasn't been made yet, creates it and appends it
    to the parent.
    @private
  ###
  maybeCreateElement_: ->
    unless @element_
      # Make element and add it to the parent
      el = @dom_.createDom(@TAGS.CONTAINER, {style: 'display:none'})
      @element_ = el
      @setMenuClasses_(el)
      goog.a11y.aria.setRole(el, goog.a11y.aria.Role.LISTBOX)

      el.id = goog.ui.IdGenerator.getInstance().getNextUniqueId()

      @dom_.appendChild(this.parent_, el)

      # Add this object as an event handler
      goog.events.listen(el, goog.events.EventType.CLICK,
                         @handleClick_, false, this)
      goog.events.listen(el, goog.events.EventType.MOUSEDOWN,
                         @handleMouseDown_, false, this)
      goog.events.listen(el, goog.events.EventType.MOUSEOVER,
                         @handleMouseOver_, false, this)

  ###*
    Render a row by creating a div and then calling row rendering callback or
    default row handler

    @override
    @param {Object} row Object representing row.
    @param {string} token Token to highlight.
    @return {Element} An element with the rendered HTML.
  ###
  renderRowHtml: (row, token) ->
    # unique id
    id = goog.ui.IdGenerator.getInstance().getNextUniqueId()

    # create and return the node
    node = @dom_.createDom @TAGS.ROW, {className: @STYLE.ROW_CLASSNAME, id: id}

    goog.a11y.aria.setRole(node, goog.a11y.aria.Role.OPTION)

    if (@customRenderer_ and @customRenderer_.renderRow)
      @customRenderer_.renderRow(row, token, node)
    else
      @renderRowContents_(row, token, node)

    if (token and @useStandardHighlighting_)
      @hiliteMatchingText_(node, token)

    goog.dom.classes.add(node, @rowClassName)
    @rowDivs_.push(node)
    node
