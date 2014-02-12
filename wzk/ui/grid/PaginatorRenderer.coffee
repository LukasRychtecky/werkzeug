goog.require 'goog.array'
goog.require 'goog.string'
goog.require 'goog.dom.dataset'
goog.require 'goog.dom.classes'
goog.require 'goog.json'
goog.require 'goog.dom.forms'
goog.require 'goog.style'

goog.require 'wzk.ui.menu.Menu'
goog.require 'wzk.ui.menu.MenuItemRenderer'
goog.require 'goog.dom'

class wzk.ui.grid.PaginatorRenderer extends wzk.ui.ComponentRenderer

  ###*
    @enum {string}
  ###
  @CLASSES:
    ACTIVE: 'active'
    INACTIVE: 'disabled'
    PREV: 'previous'
    NEXT: 'next'
    RESULT: 'result'
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

  constructor: ->
    super()
    @classes.push 'paginator'
    @resultPattern = null
    @switcher = null
    @switcherSelect = null
    @switcherPattern = '%d per page'
    @itemTag = 'LI'
    @itemInnerTag = 'SPAN'

  ###*
    @override
  ###
  createDom: (paginator) ->
    el = super paginator
    dom = paginator.getDomHelper()
    @attachResult paginator, el, dom
    @createPaging paginator, el, dom
    @attachSwitcher paginator, el, dom
    el

  ###*
    @protected
    @return {Element}
  ###
  createResult: (paginator, dom) ->
    el = dom.createDom @itemInnerTag, {}
    @decorateResult paginator, el, dom
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
    @param {goog.dom.DomHelper} dom
  ###
  attachResult: (paginator, parent, dom) ->
    result = @createResult paginator, dom
    parent.appendChild result

  ###*
    @protected
    @param {string} pattern
  ###
  setResultPattern: (pattern) ->
    @resultPattern = pattern unless @resultPattern

  ###*
    @suppress {checkTypes}
    @protected
    @return {string}
  ###
  getResultPattern: ->
    @resultPattern ? '%d-%d of %d'

  ###*
    @param {wzk.ui.Component} paginator
    @param {Element} el
  ###
  decorate: (paginator, el) ->
    dom = paginator.getDomHelper()
    C = wzk.ui.grid.PaginatorRenderer.CLASSES

    result = el.querySelector '.' + C.RESULT
    if result?
      @setResultPattern dom.getTextContent(result)
      @decorateResult paginator, result, dom
    else
      @attachResult paginator, el, dom

    pagination = el.querySelector('.' + C.PAGINATION) ? el
    @decoratePagination paginator, pagination, dom

    paging = el.querySelector('.' + C.PAGING) ? el
    if @switcher
      dom.insertChildAt paging, @switcher, 0
    else
      switcher = el.querySelector '.' + C.BASE_SWITCHER
      if switcher?
        @decorateSwitcher paginator, switcher, dom
      else
        @attachSwitcher paginator, el, dom
    goog.dom.forms.setValue @switcherSelect, String(paginator.base)

    goog.style.setStyle el, 'visibility', 'inherit'

  ###*
    @protected
    @param {Element} el
  ###
  parseSwitchPattern: (el) ->
    pattern = goog.dom.dataset.get el, 'pattern'
    @switcherPattern = pattern if pattern?

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @return {number}
  ###
  resultFrom: (paginator) ->
    paginator.offset + 1

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @return {number}
  ###
  resultTo: (paginator) ->
    paginator.offset + paginator.count

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
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} el
    @param {goog.dom.DomHelper} dom
  ###
  decorateResult: (paginator, el, dom) ->
    formatted = goog.string.format @getResultPattern(), @resultFrom(paginator), @resultTo(paginator), paginator.total
    dom.setTextContent el, formatted

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} el
    @param {goog.dom.DomHelper} dom
  ###
  decoratePagination: (paginator, el, dom) ->
    C = wzk.ui.grid.PaginatorRenderer.CLASSES

    prev = el.querySelector '.' + C.PREV
    if paginator.isFirst()
      @inactivateEl prev
    else
      @setPage prev, paginator.page - 1

    frag = dom.getDocument().createDocumentFragment()
    @createPaging paginator, frag, dom
    dom.insertSiblingAfter frag, prev

    next = el.querySelector '.' + C.NEXT
    if paginator.isLast()
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
      el = dom.el @itemTag, wzk.ui.grid.PaginatorRenderer.CLASSES.PAGE_ITEM

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
    goog.dom.classes.remove el, wzk.ui.grid.PaginatorRenderer.CLASSES.INACTIVE
    goog.dom.dataset.set el, wzk.ui.grid.PaginatorRenderer.DATA.PAGE, String(page)

  ###*
    @protected
    @param {Element} el
  ###
  activateEl: (el) ->
    C = wzk.ui.grid.PaginatorRenderer.CLASSES
    @switchClass el, C.ACTIVE, C.INACTIVE

  ###*
    @protected
    @param {Element} el
  ###
  inactivateEl: (el) ->
    C = wzk.ui.grid.PaginatorRenderer.CLASSES
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
    goog.dom.dataset.remove el, wzk.ui.grid.PaginatorRenderer.DATA.PAGE

  ###*
    @param {wzk.ui.Component} paginator
  ###
  clearPagingAndResult: (paginator) ->
    C = wzk.ui.grid.PaginatorRenderer.CLASSES
    dom = paginator.getDomHelper()
    pagEl = paginator.getElement()
    if pagEl?
      next = dom.getNextElementSibling pagEl
      dom.removeNode pagEl
      for el in pagEl.querySelectorAll ".#{C.PAGE_ITEM}"
        dom.removeNode el
      for el in pagEl.querySelectorAll ".#{C.RESULT}"
        el.innerHTML = ''

      dom.insertSiblingBefore pagEl, next

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} el
    @param {goog.dom.DomHelper} dom
  ###
  decorateSwitcher: (paginator, el, dom) ->
    @parseSwitchPattern el
    @attachSwitcher paginator, el, dom

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
    container = dom.createDom 'div','dropdown' # menu-container
    select = dom.createDom 'button', 'btn btn-default dropdown-toggle' # dopdown-menu button

    # set default base
    @setSelectBase select, paginator.base

    # add menu into menu-container
    dom.appendChild container, select

    menu = new wzk.ui.menu.Menu()
    menu.setVisible(false)

    # set menu tag to be ul
    menu.setRenderer( new wzk.ui.menu.MenuRenderer() )

    # create and add MenuItems
    for base in paginator.getBases()
      menuItem = new goog.ui.MenuItem( goog.string.format(@switcherPattern, base) )
      menuItem.base = base
      menuItem.setRenderer( new wzk.ui.menu.MenuItemRenderer() )
      menu.addItem menuItem

    # do menu action on click of menu item
    goog.events.listen menu, 'action', (event) =>
      base = event.target.base
      menu.setVisible false
      dom.appendChild container,select  # destroy menu and append select again
      @setSelectBase select, base

      # save selected base to paginator
      paginator.setBase base #

    menu.render container

    # show menu on click
    goog.events.listen select, goog.events.EventType.CLICK, (event) ->
      if menu.isVisible() == true
        menu.setVisible(false)
      else
        menu.setVisible(true)

    # menu disapperas when clicked outside menu
    body = goog.dom.getElementsByTagNameAndClass('body')[0]
    handler = (event) ->
      if menu.isVisible() == true
        menu.setVisible(false)

    goog.events.listen(body, goog.events.EventType.CLICK, handler ,true)

    container

  ###
    @protected
  ###
  setSelectBase: (select, base) ->
    caret = '<span class="caret"></span>'
    select.innerHTML = goog.string.format(@switcherPattern, base) + ' ' + caret

  ###*
    @param {wzk.ui.Component} paginator
    @return {Element}
  ###
  getPagination: (paginator) ->
    paginator.getElement().querySelector '.' + wzk.ui.grid.PaginatorRenderer.CLASSES.PAGINATION

  ###*
    @param {Element} el
    @param {wzk.dom.Dom} dom
  ###
  getPage: (el, dom) ->
    PAGE = wzk.ui.grid.PaginatorRenderer.DATA.PAGE
    PAGINATION = wzk.ui.grid.PaginatorRenderer.CLASSES.PAGINATION
    while true
      if goog.dom.classes.has el, PAGINATION
        return null
      if el.tagName is @itemTag and goog.dom.dataset.has el, PAGE
        return goog.dom.dataset.get el, PAGE
      el =  dom.getParentElement el
