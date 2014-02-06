goog.provide 'wzk.ui.grid.PaginatorRenderer'

goog.require 'wzk.ui.ComponentRenderer'
goog.require 'goog.array'
goog.require 'goog.string'
goog.require 'goog.dom.dataset'
goog.require 'goog.dom.classes'
goog.require 'goog.json'
goog.require 'goog.string'
goog.require 'goog.dom.forms'

class wzk.ui.grid.PaginatorRenderer extends wzk.ui.ComponentRenderer

  ###*
    @enum {string}
  ###
  @CLASSES:
    ACTIVE: 'active'
    INACTIVE: 'disabled'
    PREV: 'prev'
    NEXT: 'next'
    PAGES: 'pages'
    RESULT: 'result'
    PAGING: 'pagination'
    BASE_SWITCHER: 'base-switcher'

  ###*
    @constructor
    @extends {wzk.ui.ComponentRenderer}
  ###
  constructor: ->
    super()
    @classes.push 'paginator'
    @resultPattern = null
    @switcher = null
    @switcherSelect = null
    @switcherPattern = '%d per page'

  ###*
    @override
  ###
  createDom: (paginator) ->
    el = super paginator
    dom = paginator.getDomHelper()
    @attachResult paginator, el, dom
    @attachPaging paginator, el, dom
    @attachSwitcher paginator, el, dom
    el

  ###*
    @protected
    @return {Element}
  ###
  createResult: (paginator, dom) ->
    el = dom.createDom 'span', {}
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
  attachPaging: (paginator, parent, dom) ->
    pagingEl = dom.createDom 'div', {'class': wzk.ui.grid.PaginatorRenderer.CLASSES.PAGES}
    parent.appendChild pagingEl
    @createPaging paginator, pagingEl, dom

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

    paging = el.querySelector '.' + C.PAGING
    if paging?
      @decoratePaging paginator, paging, dom
    else
      @attachPaging paginator, el, dom

    if @switcher
      dom.insertChildAt paging, @switcher, 0
    else
      switcher = el.querySelector '.' + C.BASE_SWITCHER
      if switcher?
        @decorateSwitcher paginator, switcher, dom
      else
        @attachSwitcher paginator, el, dom
    goog.dom.forms.setValue @switcherSelect, String(paginator.base)

    goog.dom.classes.remove el, 'hidden'

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
    el = dom.createDom 'li', {'class': klass}
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
  decoratePaging: (paginator, el, dom) ->
    C = wzk.ui.grid.PaginatorRenderer.CLASSES

    prev = el.querySelector '.' + C.PREV
    if paginator.isFirst()
      @inactivateEl prev
    else
      @activateEl prev, paginator.page - 1

    pagesEl = el.querySelector '.' + C.PAGES
    pagesEl = @createPagesEl el, dom, C.PAGES unless pagesEl?
    @createPaging paginator, pagesEl, dom

    next = el.querySelector '.' + C.NEXT
    if paginator.isLast()
      @inactivateEl next
    else
      @activateEl next, paginator.page + 1

  ###*
    @protected
    @param {wzk.ui.Component} paginator
    @param {Element} parent
    @param {goog.dom.DomHelper} dom
  ###
  createPaging: (paginator, parent, dom) ->
    pages = @createPages paginator
    for page, i in pages

      el = dom.createDom 'span', {}, String(page)
      if page is paginator.page
        @inactivateEl el
      else
        @activateEl el, page

      parent.appendChild el

      if pages[i + 1] > page + 1
        parent.appendChild dom.createDom('span', {}, "...")

  ###*
    @protected
    @param {Element} el
    @param {number} page
  ###
  activateEl: (el, page) ->
    C = wzk.ui.grid.PaginatorRenderer.CLASSES
    @switchClass el, C.ACTIVE, C.INACTIVE
    goog.dom.dataset.set el, 'p', String(page)

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
    goog.dom.dataset.remove el, 'p'

  ###*
    @param {wzk.ui.Component} paginator
  ###
  clearPagingAndResult: (paginator) ->
    C = wzk.ui.grid.PaginatorRenderer.CLASSES
    if paginator.getElement()?
      for el in paginator.getElement().querySelectorAll ".#{C.PAGES}, .#{C.RESULT}"
        el.innerHTML = ''

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
    select = dom.createDom 'select'
    for base in paginator.getBases()
      opt = dom.createDom 'option', {'value': String(base)}, goog.string.format(@switcherPattern, base)
      select.appendChild opt
    select
