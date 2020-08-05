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

class wzk.ui.grid.OffsetBasedPaginatorRenderer extends wzk.ui.ComponentRenderer

  ###*
    @enum {string}
  ###
  @CLASSES:
    ACTIVE: 'active'
    INACTIVE: 'disabled'
    PREV: 'previous'
    NEXT: 'next'
    RESULT: 'result'
    RESULT_NUMBER: 'result-number'
    RESULT_CAPTION: 'result-caption'
    RESULT_TOTAL: 'result-total'
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
    PAGE: 'p'
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

  ###*
    @type {Array}
  ###
  @RESULT: [['Items total:', '%d'], ['Displayed', '%d to %d']]

  constructor: ->
    super()
    @classes.push 'paginator'
    @isPatternSet = [[false, false], [false, false]]
    @switcher = null
    @switcherSelect = null
    @switcherPattern = '%d per page'
    @itemTag = 'LI'
    @itemInnerTag = 'SPAN'
    @pagingStyle = wzk.ui.grid.OffsetBasedPaginatorRenderer.PAGING_STYLE.SIMPLE
    @resultComposers = [@composeTotalResult, @composeDisplayedResult]
    @baseRange = wzk.ui.grid.OffsetBasedPaginatorRenderer.BASE_RANGE_DEFAULT
    @customBaseLabel = wzk.ui.grid.OffsetBasedPaginatorRenderer.CUSTOM_BASE_LABEL
    @customBaseErrorMessage = wzk.ui.grid.OffsetBasedPaginatorRenderer.CUSTOM_BASE_ERROR_MESSAGE

  ###*
    @override
  ###
  createDom: (paginator) ->
    el = super paginator
    dom = paginator.getDomHelper()
    for i in [0..1]
      content = @composeResult paginator, @resultComposers[i]
      @attachResult paginator, el, content
    @createPaging paginator, el, dom
    @attachSwitcher paginator, el, dom
    el

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {string} content
    @return {Element}
  ###
  createResult: (paginator, content) ->
    el = paginator.getDomHelper().createDom @itemInnerTag, {}
    @decorateResult paginator, el, content
    el

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @return {Array.<number>}
  ###
  createPages: (paginator) ->
    pages = []
    if paginator.pageCount < 2
      pages = [paginator.page]
    else
      count = 4
      quotient = (paginator.pageCount - 1) / count

      from = Math.max paginator.firstPage, paginator.page - 3
      to = Math.min paginator.lastPage, paginator.page + 3
      pages = [from..to]

      for i in [0..count]
        pages.push Math.round(quotient * i) + paginator.firstPage

      goog.array.removeDuplicates pages
      pages.sort (a, b) ->
        return -1 if a < b
        return 1 if a > b
        0

    pages

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} parent
    @param {string} content
  ###
  attachResult: (paginator, parent, content) ->
    result = @createResult(paginator, content)
    parent.appendChild(result)

  ###*
    @protected
    @param {wzk.dom.Dom} dom
    @param {string} cls
    @param {Element} resultEl
    @param {number} i
    @param {number} part
  ###
  fetchResultText: (dom, cls, resultEl, i, part) ->
    return if @isPatternSet[i][part]

    el = dom.cls cls, resultEl
    txt = ''
    if el?
      txt = dom.getTextContent el

    wzk.ui.grid.OffsetBasedPaginatorRenderer.RESULT[i][part] = txt if txt? and txt isnt ''
    @isPatternSet[i][part] = true

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
    resultDisplayedEl = dom.cls(wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES.RESULT_DISPLAYED, paginatorEl)
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
      wzk.ui.grid.OffsetBasedPaginatorRenderer.BASE_RANGE_DEFAULT

  ###*
    @param {wzk.ui.Component} paginator
    @param {Element} el
  ###
  decorate: (paginator, el) ->
    dom = (`/** @type {wzk.dom.Dom} */`) paginator.getDomHelper()
    C = wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES

    for resultEl, i in [dom.cls(C.RESULT_TOTAL, el), dom.cls(C.RESULT_DISPLAYED, el)]
      if resultEl?

        @fetchResultText(dom, C.RESULT_CAPTION, resultEl, i, 0)
        @fetchResultText(dom, C.RESULT_NUMBER, resultEl, i, 1)

        numberEl = dom.cls(C.RESULT_NUMBER, resultEl)
        if numberEl?
          @decorateResult(paginator, numberEl, @composeResult(paginator, @resultComposers[i]))

    totalEl = dom.cls(C.RESULT_TOTAL, el)
    if totalEl?
      goog.style.setStyle(totalEl, 'display', (if paginator.hasTotal() then 'inline' else 'none'))

    D = wzk.ui.grid.OffsetBasedPaginatorRenderer.DATA

    @pagingStyle = wzk.dom.dataset.get(
      el,
      D.PAGING,
      String,
      wzk.ui.grid.OffsetBasedPaginatorRenderer.PAGING_STYLE.SIMPLE)
    pagination = dom.cls(C.PAGINATION, el) ? el
    @decoratePagination(paginator, pagination, dom)

    @customBaseLabel = wzk.dom.dataset.get(
      el, D.CUSTOM_BASE_LABEL, String, wzk.ui.grid.OffsetBasedPaginatorRenderer.CUSTOM_BASE_LABEL)
    @customBaseErrorMessage = wzk.dom.dataset.get(
      el, D.CUSTOM_BASE_ERROR_MESSAGE, String, wzk.ui.grid.OffsetBasedPaginatorRenderer.CUSTOM_BASE_ERROR_MESSAGE)

    @baseRange = wzk.dom.dataset.get(el, D.BASE_RANGE, goog.functions.compose(@baseRangeOrDefault, wzk.json.parse))
    if wzk.dom.dataset.get(el, D.BASE_TYPE) is wzk.ui.grid.OffsetBasedPaginatorRenderer.BASE_TYPES.CUSTOM
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
    @return {number}
  ###
  resultFrom: (paginator) ->
    if @resultTo(paginator) is 0 or paginator.isResultEmpty() then 0 else paginator.offset + 1

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @return {number}
  ###
  resultTo: (paginator) ->
    if paginator.isResultEmpty() then 0 else paginator.offset + paginator.count

  ###*
    @protected
    @param {Element} parent
    @param {goog.dom.DomHelper} dom
    @param {string} klass
  ###
  createPagesEl: (parent, dom, klass) ->
    el = dom.createDom @itemTag, {'class': klass}
    parent.appendChild el

  ###*
    @param {wzk.ui.Component} paginator
    @param {Element} el
    @param {string} content
  ###
  decorateResult: (paginator, el, content) ->
    paginator.getDomHelper().setTextContent el, content

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @return {Array}
  ###
  composeDisplayedResult: (paginator) =>
    [wzk.ui.grid.OffsetBasedPaginatorRenderer.RESULT[1][1], @resultFrom(paginator), @resultTo(paginator)]

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @return {Array}
  ###
  composeTotalResult: (paginator) ->
    [wzk.ui.grid.OffsetBasedPaginatorRenderer.RESULT[0][1], paginator.total]

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Function} composer
    @return {string}
  ###
  composeResult: (paginator, composer) ->
    goog.string.format.apply goog.string.format, composer(paginator)

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} el
    @param {goog.dom.DomHelper} dom
  ###
  decoratePagination: (paginator, el, dom) ->
    C = wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES

    prev = dom.cls C.PREV, el
    if paginator.isFirst() or paginator.isResultEmpty()
      @inactivateEl prev
    else
      @setPage prev, paginator.page - 1

    frag = dom.getDocument().createDocumentFragment()

    if @pagingStyle is wzk.ui.grid.OffsetBasedPaginatorRenderer.PAGING_STYLE.FULL
      @createPaging(paginator, frag, dom)

    dom.insertSiblingAfter frag, prev

    next = dom.cls C.NEXT, el
    if paginator.isLast() or paginator.isResultEmpty()
      @inactivateEl next
    else
      @setPage next, paginator.page + 1

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element|DocumentFragment} parent
    @param {goog.dom.DomHelper} dom
  ###
  createPaging: (paginator, parent, dom) ->
    pages = @createPages paginator
    for page, i in pages

      innerEl = dom.el @itemInnerTag, {}, String(page)
      el = dom.el @itemTag, wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES.PAGE_ITEM

      if page is paginator.page
        @activateEl el
      else
        @setPage el, page

      el.appendChild innerEl
      parent.appendChild el

      if pages[i + 1] > page + 1
        parent.appendChild dom.createDom(@itemTag, {}, "...")

  ###*
    @protected
    @param {Element} el
    @param {number} page
  ###
  setPage: (el, page) ->
    goog.dom.classes.remove(el, wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES.INACTIVE)
    wzk.dom.dataset.set(el, wzk.ui.grid.OffsetBasedPaginatorRenderer.DATA.PAGE, String(page))

  ###*
    @protected
    @param {Element} el
  ###
  activateEl: (el) ->
    C = wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES
    @switchClass el, C.ACTIVE, C.INACTIVE

  ###*
    @protected
    @param {Element} el
  ###
  inactivateEl: (el) ->
    C = wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES
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
    wzk.dom.dataset.remove el, wzk.ui.grid.OffsetBasedPaginatorRenderer.DATA.PAGE

  ###*
    @param {wzk.ui.Component} paginator
  ###
  clearPagingAndResult: (paginator) ->
    C = wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES
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
    paginator.getDomHelper().cls wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES.PAGINATION, paginator.getElement()

  ###*
    @param {Element} el
    @param {wzk.dom.Dom} dom
  ###
  getPage: (el, dom) ->
    PAGE = wzk.ui.grid.OffsetBasedPaginatorRenderer.DATA.PAGE
    PAGINATION = wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES.PAGINATION
    while true
      if not el or goog.dom.classes.has(el, PAGINATION)
        return null
      if el.tagName is @itemTag and wzk.dom.dataset.has(el, PAGE)
        return wzk.dom.dataset.get(el, PAGE)
      el =  dom.getParentElement el
