goog.require 'goog.array'
goog.require 'goog.dom.classes'
goog.require 'goog.dom.forms'
goog.require 'goog.functions'
goog.require 'goog.string'
goog.require 'goog.style'

goog.require 'wzk.dom.dataset'
goog.require 'wzk.json'
goog.require 'wzk.num'
goog.require 'wzk.ui.menu.Menu'
goog.require 'wzk.ui.menu.MenuItemRenderer'
goog.require 'wzk.ui.menu.MenuRenderer'

class wzk.ui.grid.CursorBasedPaginatorRenderer extends wzk.ui.ComponentRenderer

  ###*
    @enum {string}
  ###
  @CLASSES:
    ACTIVE: 'active'
    INACTIVE: 'disabled'
    NEXT: 'next'
    RESULT: 'result'
    RESULT_DISPLAYED: 'result-displayed'
    PAGING: 'paging'
    PAGINATION: 'pagination'
    PAGE_ITEM: 'page-item'
    BASE_SWITCHER: 'base-switcher'
    PAGINATOR: 'paginator'

  ###*
    @enum {string}
  ###
  @DATA:
    CURSOR: 'c'
    PAGING: 'paging'
    BASE_TYPE: 'baseType'
    BASE_RANGE: 'baseRange'
    CUSTOM_BASE_LABEL: 'customBaseLabel'
    CUSTOM_BASE_ERROR_MESSAGE: 'customBaseErrorMessage'

  ###*
    @enum {string}
  ###
  @PAGING_STYLE:
    SIMPLE: 'simple'
    FULL: 'full' # default

  ###*
    @enum {string}
  ###
  @BASE_TYPES:
    NONE: 'none' # default
    CUSTOM: 'custom'

  ###*
    @type {Array.<number>}
  ###
  @BASE_RANGE_DEFAULT: [1, 1000]

  ###*
    @type {string}
  ###
  @CUSTOM_BASE_LABEL: 'Display number of rows'

  ###*
    @type {string}
  ###
  @CUSTOM_BASE_ERROR_MESSAGE: 'Row number has to be between %s and %s'

  constructor: ->
    super()
    @classes.push 'paginator'
    @switcher = null
    @switcherSelect = null
    @switcherPattern = '%d per page'
    @itemTag = 'LI'
    @itemInnerTag = 'SPAN'
    @pagingStyle = wzk.ui.grid.CursorBasedPaginatorRenderer.PAGING_STYLE.SIMPLE
    @baseRange = wzk.ui.grid.CursorBasedPaginatorRenderer.BASE_RANGE_DEFAULT
    @customBaseLabel = wzk.ui.grid.CursorBasedPaginatorRenderer.CUSTOM_BASE_LABEL
    @customBaseErrorMessage = wzk.ui.grid.CursorBasedPaginatorRenderer.CUSTOM_BASE_ERROR_MESSAGE

  ###*
    @override
  ###
  createDom: (paginator) ->
    el = super paginator
    dom = paginator.getDomHelper()
    @attachSwitcher paginator, el, dom
    el

  ###*
    @protected
    @param {goog.dom.DomHelper} dom
    @param {Element} el
  ###
  deleteErrorMessageIfExists: (dom, el) ->
    errorMessageEl = dom.cls('paginator__error-message', el)
    dom.removeNode(errorMessageEl) if errorMessageEl?

  ###*
    @protected
    @param {goog.dom.DomHelper} dom
    @param {Element} el
  ###
  createErrorMessage: (dom, el) ->
    [min, max] = @baseRange
    errorMessageEl = dom.el(
      'div',
      'paginator__error-message',
      [dom.el('div', 'alert alert-danger', goog.string.format(@customBaseErrorMessage, min, max))])
    dom.appendChild(el, errorMessageEl)

  ###*
    @param {wzk.ui.Component} paginator
    @param {Element} el
  ###
  hangCustomerBaseInputListeners: (paginator, el) ->
    wzk.events.lst.onEnter(
      el,
      (_) =>
        dom = paginator.getDomHelper()
        inputEl = dom.cls('paginator__custom-base-input', el)
        return unless inputEl?

        parent = dom.getParentElement(el)
        newBase = wzk.num.parseDec((`/** @type {string} */`) goog.dom.forms.getValue(inputEl))
        if wzk.num.inRange(@baseRange, newBase)
          @deleteErrorMessageIfExists(dom, parent)
          paginator.setBase(newBase)
        else
          @createErrorMessage(dom, parent))

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} paginatorEl
    @return {?Element}
  ###
  createCustomBaseEl: (paginator, paginatorEl) ->
    dom = paginator.getDomHelper()
    resultDisplayedEl = dom.cls(wzk.ui.grid.CursorBasedPaginatorRenderer.CLASSES.RESULT_DISPLAYED, paginatorEl)
    return null unless resultDisplayedEl?

    parent = dom.getParentElement(resultDisplayedEl)
    customBaseEl = dom.el('span', 'paginator__custom-base-wrapper')
    dom.prependChild(parent, customBaseEl)
    dom.appendChild(customBaseEl, dom.el('span', 'paginator__custom-base-label', @customBaseLabel))
    [min, max] = @baseRange
    customBaseInputEl =
      dom.el(
        'input',
        {
          'type': 'number',
          'value': paginator.getBase(),
          'class': 'paginator__custom-base-input',
          'min': min,
          'max': max})
    dom.appendChild(customBaseEl, customBaseInputEl)
    @hangCustomerBaseInputListeners(paginator, customBaseInputEl)

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} paginatorEl
  ###
  deleteCustomerBaseElementIfExists: (paginator, paginatorEl) ->
    dom = paginator.getDomHelper()
    customerBaseWrapperEl = dom.cls('paginator__custom-base-wrapper', paginatorEl)
    dom.removeNode(customerBaseWrapperEl) if customerBaseWrapperEl?

  ###*
    @protected
    @param {Object} value
    @return {Array.<number>}
  ###
  baseRangeOrDefault: (value) ->
    if goog.isArray(value) and value.length is 2 and goog.array.every(value, wzk.num.isPos)
      value
    else
      goog.global['console']['warn'](
        'Paginator "data-base-rage" contains invalid value. A tuple with two positive number was expected.')
      wzk.ui.grid.CursorBasedPaginatorRenderer.BASE_RANGE_DEFAULT

  ###*
    @param {wzk.ui.Component} paginator
    @param {Element} el
  ###
  decorate: (paginator, el) ->
    dom = (`/** @type {wzk.dom.Dom} */`) paginator.getDomHelper()
    C = wzk.ui.grid.CursorBasedPaginatorRenderer.CLASSES

    D = wzk.ui.grid.CursorBasedPaginatorRenderer.DATA

    @pagingStyle = wzk.dom.dataset.get(
      el,
      D.PAGING,
      String,
      wzk.ui.grid.CursorBasedPaginatorRenderer.PAGING_STYLE.SIMPLE)

    pagination = dom.cls(C.PAGINATION, el) ? el

    @decoratePagination(paginator, pagination, dom)

    @customBaseLabel = wzk.dom.dataset.get(
      el, D.CUSTOM_BASE_LABEL, String, wzk.ui.grid.CursorBasedPaginatorRenderer.CUSTOM_BASE_LABEL)
    @customBaseErrorMessage = wzk.dom.dataset.get(
      el, D.CUSTOM_BASE_ERROR_MESSAGE, String, wzk.ui.grid.CursorBasedPaginatorRenderer.CUSTOM_BASE_ERROR_MESSAGE)

    @baseRange = wzk.dom.dataset.get(el, D.BASE_RANGE, goog.functions.compose(@baseRangeOrDefault, wzk.json.parse))
    if wzk.dom.dataset.get(el, D.BASE_TYPE) is wzk.ui.grid.CursorBasedPaginatorRenderer.BASE_TYPES.CUSTOM
      @deleteCustomerBaseElementIfExists(paginator, el)
      @createCustomBaseEl(paginator, el)

    paging = dom.cls(C.PAGING, el) ? el
    if @switcher
      dom.insertChildAt paging, @switcher, 0
    else
      switcher = dom.cls C.BASE_SWITCHER, el
      @decorateSwitcher paginator, switcher, dom

    goog.style.setStyle(el, 'visibility', 'inherit')

  ###*
    @protected
    @param {Element} el
  ###
  parseSwitchPattern: (el) ->
    pattern = wzk.dom.dataset.get(el, 'pattern')
    @switcherPattern = pattern if pattern?

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} el
    @param {goog.dom.DomHelper} dom
  ###
  decoratePagination: (paginator, el, dom) ->
    C = wzk.ui.grid.CursorBasedPaginatorRenderer.CLASSES

    next = dom.cls C.NEXT, el
    if paginator.isLast()
      @inactivateEl next
    else
      @setCursor next, paginator.nextCursor

  ###*
    @protected
    @param {Element} el
    @param {number} page
  ###
  setCursor: (el, nextCursor) ->
    goog.dom.classes.remove(el, wzk.ui.grid.CursorBasedPaginatorRenderer.CLASSES.INACTIVE)
    wzk.dom.dataset.set(el, wzk.ui.grid.CursorBasedPaginatorRenderer.DATA.CURSOR, nextCursor)

  ###*
    @protected
    @param {Element} el
  ###
  activateEl: (el) ->
    C = wzk.ui.grid.CursorBasedPaginatorRenderer.CLASSES
    @switchClass el, C.ACTIVE, C.INACTIVE

  ###*
    @protected
    @param {Element} el
  ###
  inactivateEl: (el) ->
    C = wzk.ui.grid.CursorBasedPaginatorRenderer.CLASSES
    @switchClass el, C.INACTIVE, C.ACTIVE

  ###*
    @protected
    @param {Element} el
    @param {string} add
    @param {string} remove
  ###
  switchClass: (el, add, remove) ->
    goog.dom.classes.add el, add
    goog.dom.classes.remove el, remove
    wzk.dom.dataset.remove el, wzk.ui.grid.CursorBasedPaginatorRenderer.DATA.CURSOR

  ###*
    @param {wzk.ui.Component} paginator
  ###
  clearPagingAndResult: (paginator) ->
    C = wzk.ui.grid.CursorBasedPaginatorRenderer.CLASSES
    dom = paginator.getDomHelper()
    pagEl = paginator.getElement()
    if pagEl?
      next = dom.getNextElementSibling pagEl
      dom.removeNode pagEl
      for el in dom.clss C.PAGE_ITEM, pagEl
        dom.removeNode el
      for el in dom.clss C.RESULT, pagEl
        el.innerHTML = ''

      dom.insertSiblingBefore pagEl, next

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element|null} el
    @param {goog.dom.DomHelper} dom
  ###
  decorateSwitcher: (paginator, el, dom) ->
    return unless el?
    @parseSwitchPattern el
    @attachSwitcher paginator, el, dom
    goog.dom.forms.setValue @switcherSelect, String(paginator.base)

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} parent
    @param {goog.dom.DomHelper} dom
  ###
  attachSwitcher: (paginator, parent, dom) ->
    select = @createSwitcher paginator, dom
    parent.appendChild select
    @switcherSelect = select
    @switcher = parent

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {goog.dom.DomHelper} dom
    @return {Element}
  ###
  createSwitcher: (paginator, dom) ->
    container = dom.createDom('div', 'dropdown') # menu-container
    @baseSelect = dom.createDom('button', 'btn btn-default dropdown-toggle') # dropdown-menu button

    # set default base
    @setSelectBase(@baseSelect, paginator.base)

    # add menu into menu-container
    dom.appendChild(container, @baseSelect)

    menu = new wzk.ui.menu.Menu(@dom)
    menu.setVisible(false)

    # create and add MenuItems
    for base in paginator.getBases()
      menuItem = new goog.ui.MenuItem(
        goog.string.format(@switcherPattern, base),
        base,
        @dom,
        wzk.ui.menu.MenuItemRenderer.getInstance())
      menu.addChild(menuItem, true)

    # do menu action on click of menu item
    goog.events.listen(menu, goog.ui.Component.EventType.ACTION, (event) =>
      base = event.target.getModel()
      menu.setVisible(false)
      dom.appendChild(container, @baseSelect)  # destroy menu and append select again
      @setSelectBase(@baseSelect, base)

      # save selected base to paginator
      paginator.setBase(base))

    menu.render(container)

    # show menu on click
    goog.events.listen(@baseSelect, goog.events.EventType.CLICK, (event) ->
      menu.setVisible not menu.isVisible())

    # menu disappers when clicked outside of the menu
    body = dom.getDocument().body
    handler = (event) ->
      if menu.isVisible()
        menu.setVisible false

    goog.events.listen(body, goog.events.EventType.CLICK, handler, true)

    container

  ###*
    @protected
    @param {Element} select
    @param {number} base
  ###
  setSelectBase: (select, base) ->
    if base? and select?
      select.innerHTML = [goog.string.format(@switcherPattern, base), '<span class="caret"></span>'].join('')

  ###*
    @param {number} base
  ###
  setBase: (base) ->
    @setSelectBase(@baseSelect, base)

  ###*
    @param {wzk.ui.Component} paginator
    @return {Element}
  ###
  getPagination: (paginator) ->
    paginator.getDomHelper().cls wzk.ui.grid.CursorBasedPaginatorRenderer.CLASSES.PAGINATION, paginator.getElement()

  ###*
    @param {Element} el
    @param {wzk.dom.Dom} dom
  ###
  getCursor: (el, dom) ->
    CURSOR = wzk.ui.grid.CursorBasedPaginatorRenderer.DATA.CURSOR
    PAGINATION = wzk.ui.grid.CursorBasedPaginatorRenderer.CLASSES.PAGINATION
    while true
      if not el or goog.dom.classes.has(el, PAGINATION)
        return null
      if el.tagName is @itemTag and wzk.dom.dataset.has(el, CURSOR)
        return wzk.dom.dataset.get(el, CURSOR)
      el =  dom.getParentElement el
