goog.require 'wzk.ui.Input'
goog.require 'wzk.ui.OpenIcon'
goog.require 'wzk.ui.ClearableInput'
goog.require 'goog.style'
goog.require 'wzk.num'
goog.require 'goog.dom.dataset'

class wzk.ui.ac.Renderer extends goog.ui.ac.Renderer

  ###*
    @enum {string}
  ###
  @TAGS:
    ITEM: 'span'
    CONTAINER: 'ul'
    GROUP: 'ul'
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
    @enum {string}
  ###
  @DATA:
    ITEM_VALUE: 'value'

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
    @param {boolean=} renderOpenButton default `false`
    @suppress {accessControls}
  ###
  constructor: (@dom, @imagePlaceholder, @customRenderer, rightAlign, useStandardHighlighting, @renderOpenButton = false) ->
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
    @container = @dom.el wzk.ui.ac.Renderer.TAGS.ITEM, wzk.ui.ac.Renderer.CLS.ITEM

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
      @openBtn = new wzk.ui.OpenIcon dom: @dom
      @openBtn.listen goog.ui.Component.EventType.ACTION, @handleOpen
      @openBtn.render @container

  ###*
    @param {wzk.ui.TagContainer} tagContainer
  ###
  setTagContainer: (@tagContainer) =>

  ###*
    @param {Array} initialData
  ###
  setInitialData: (@initialData) =>

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
    @return {Object}
  ###
  getSelectedRows: =>
    return {} if not @tagContainer?
    @tagContainer.getTags()

  ###*
    @override
    @suppress {accessControls}
  ###
  redraw: =>
    @maybeCreateElement_()

    if @topAlign_
      @element_.style.visibility = 'hidden'

    if @widthProvider_
      width = @widthProvider_.clientWidth + 'px'
      @element_.style.minWidth = width

    @rowDivs_.length = 0
    @dom_.removeChildren(@element_)

    if @customRenderer_ and @customRenderer_.render
      @customRenderer_.render(this, @element_, @rows_, @token_)
    else
      curRow = null
      groupedRows = @createNestedRows @rows_
      @renderNestedRows groupedRows, curRow

    if @rows_.length is 0
      @dismiss()
      return
    else
      @show()

    @reposition()
    goog.style.setUnselectable(@element_, true)

  ###*
    @protected
    @param {Array|Object} rows
    @param {Element|null} curRow
    @suppress {accessControls}
  ###
  renderNestedRows: (rows, curRow) =>
    for row in rows
      if row instanceof Array
        groupLi = @buildGroupLi @getGroupName row
        groupUl = @dom.el wzk.ui.ac.Renderer.TAGS.GROUP
        groupLi.appendChild groupUl
        for subrow in row
          groupUl.appendChild @renderRowHtml(subrow, @token_)
        @appendRow groupLi, curRow
        curRow = groupLi
      else
        row = @renderRowHtml(row, @token_)
        @appendRow row, curRow
        curRow = row

  ###*
    @protected
    @param {Array} groupRows
    @return {string}
  ###
  getGroupName: (groupRows) ->
    return  if groupRows[0] then groupRows[0]['group'] else ''

  ###*
    @protected
    @param {Element} row
    @param {Element} curRow
    @suppress {accessControls}
  ###
  appendRow: (row, curRow) =>
    if @topAlign_
      @element_.insertBefore(row, curRow)
    else
      @dom_.appendChild(@element_, row)

  ###*
    @protected
    @return {Element}
  ###
  buildGroupLi: (groupName) =>
    return @dom.el wzk.ui.ac.Renderer.TAGS.ROW, '', groupName

  ###*
    @protected
    @param {Array} rows
    @return {Object}
  ###
  createNestedRows: (rows) ->
    groupsDict = {}
    output = []
    counter = 0
    for row in rows
      if row['group']?
        if groupsDict[row['group']]?
          output[groupsDict[row['group']]].push row
        else
          groupsDict[row['group']] = counter
          output[groupsDict[row['group']]] = [row]
          counter++
      else
        output.push row
        counter++
    output

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

    goog.dom.dataset.set node, 'value', row['data']['id']

    if @customRenderer and @customRenderer.renderRow
      @customRenderer.renderRow row, token, node
    else
      @renderRowContents_ row, token, node

    if token and @useStandardHighlighting_
      @hiliteMatchingText_(node, token)

    goog.dom.classes.add node, @rowClassName
    @rowDivs_.push node
    node
