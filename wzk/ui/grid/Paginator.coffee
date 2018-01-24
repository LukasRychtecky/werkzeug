goog.provide 'wzk.ui.grid.Paginator'

goog.require 'goog.dom.classes'
goog.require 'goog.dom.forms'
goog.require 'goog.events.Event'
goog.require 'goog.functions'
goog.require 'goog.style'

goog.require 'wzk.array'
goog.require 'wzk.dom.dataset'
goog.require 'wzk.num'
goog.require 'wzk.ui.grid.PaginatorRenderer'


class wzk.ui.grid.Paginator extends wzk.ui.Component

  ###*
    @enum {string}
  ###
  @DATA:
    BASE: 'base'
    FORCE_DISPLAY: 'forceDisplay'

  ###*
    @enum {string}
  ###
  @EventType:
    GO_TO: 'go-to'

  ###*
    @enum {string}
  ###
  @CLASSES:
    TOP: 'top'
    BOTTOM: 'bottom'

  ###*
    @type {number}
  ###
  @BASE = 10

  ###*
    @param {Object} params
      renderer: {@link wzk.ui.grid.PaginatorRenderer}
      base: {number|undefined}
      page: {number}
  ###
  constructor: (params) ->
    params.renderer ?= new wzk.ui.grid.PaginatorRenderer()
    super params
    {@base, @page} = params

    @base = if @base >= 0 then @base else wzk.ui.grid.Paginator.BASE
    @page = if @page >= 0 then @page else 1
    @firstPage = 1
    @clones = []
    @listeners = []
    @switcher = null
    @defBases = [10, 25, 50, 100, 500, 1000]
    @bases = @defBases
    @forceDisplay = false

  ###*
    @return {number}
  ###
  getBase: ->
    @base

  baseOrDefault: (value) =>
    wzk.array.filterFirst([@base, value], wzk.num.isPos, wzk.ui.grid.Paginator.BASE)

  ###*
    @param {Element} el
  ###
  loadData: (el) ->
    @base = wzk.dom.dataset.get(
      el, wzk.ui.grid.Paginator.DATA.BASE, goog.functions.compose(@baseOrDefault, wzk.num.parseDec))
    @offsetFromPage()

  ###*
    @param {number} total
    @param {number} count
  ###
  init: (@total, @count) ->
    @calculatePageCount()
    @lastPage = @pageCount
    @count ?= @base

  ###*
    @protected
  ###
  calculatePageCount: ->
    @pageCount = Math.ceil @total / @base
    @lastPage = @pageCount

  ###*
    @override
  ###
  canDecorate: (el) ->
    el? and goog.dom.classes.has el, wzk.ui.grid.PaginatorRenderer.CLASSES.PAGINATOR

  ###*
    @override
  ###
  afterRendering: ->
    @hangPageListener @renderer.getPagination(@)

  ###*
    @return {boolean}
  ###
  isResultEmpty: ->
    @total is 0

  ###*
    @return {boolean}
  ###
  isFirst: ->
    @page is @firstPage

  ###*
    @return {boolean}
  ###
  isLast: ->
    @page is @lastPage

  ###*
    @protected
  ###
  offsetFromPage: ->
    @offset = (@page - 1) * @base

  ###*
    Re-renders a paginator according to a current page

    @param {Object} result
      total: {number}
      count: {number}
      offset: {number=}
  ###
  refresh: (result) ->
    {@total, @count} = result
    @offset = result.offset if result.offset?
    @calculatePageCount()
    @renderer.clearPagingAndResult @
    @decorateInternal @getElement()
    @afterRendering()

    newClones = []
    for oldClone in @clones
      newClone = @clone()
      @dom.replaceNode newClone, oldClone
      newClones.push newClone
    @clones = newClones
    @show(true)

  ###*
    @protected
  ###
  selectBase: ->
    @renderer.setSelectBase @base

  ###*
    setter with callback that handles change
    @param {number} base
  ###
  setBase: (base) ->
    @base = base
    @offset = 0
    @page = 1
    @calculatePageCount()
    @dispatchGoToPage()

  ###*
    @override
  ###
  decorateInternal: (el) ->
    @forceDisplay = wzk.dom.dataset.get(el, wzk.ui.grid.Paginator.DATA.FORCE_DISPLAY) is 'true'
    unless @bases
      switcherEl = el.querySelector '.' + wzk.ui.grid.PaginatorRenderer.CLASSES.BASE_SWITCHER
      @parseBases switcherEl

    @renderer.decorate @, el
    @setElementInternal el
    @showInternal(false)

  ###*
    @protected
    @param {Element} el
  ###
  parseBases: (el) ->
    if el? or @bases
      wzk.dom.dataset.get(el, 'bases', goog.json.parse, @defBases)

  ###*
    @return {Array.<number>}
  ###
  getBases: ->
    @bases

  setPage: (@page) ->
    @offset = @offsetFromPage()
    @calculatePageCount()

  ###*
    @param {number} base
    @param {number} page
  ###
  goToPage: (base, page) ->
    # change page only if base and page are different
    unless page is @page and base is @base
      @base = base
      @renderer.setBase(@base)
      @setPage page
      @dispatchGoToPage()

  ###*
    @protected
  ###
  hangPageListener: (paging) ->
    listener = goog.events.listen paging, goog.events.EventType.CLICK, (e) =>
      page = @renderer.getPage e.target, @dom
      if page?
        @page = wzk.num.parseDec page
        @offset = @offsetFromPage()
        @dispatchGoToPage()

    @listeners.push listener

  ###*
    @protected
  ###
  dispatchGoToPage: ->
    @cleanListeners()
    @dispatchEvent new goog.events.Event(wzk.ui.grid.Paginator.EventType.GO_TO, {offset: @offset, base: @base, page: @page})

  ###*
    @protected
    @return {Element}
  ###
  clone: ->
    clone = @getElement().cloneNode(true)
    @hangPageListener(clone)
    goog.dom.classes.add(@getElement(), wzk.ui.grid.Paginator.CLASSES.TOP)
    goog.dom.classes.add(clone, wzk.ui.grid.Paginator.CLASSES.BOTTOM)
    goog.dom.classes.remove(clone, wzk.ui.grid.Paginator.CLASSES.TOP)
    @renderer.hangCustomerBaseInputListeners(@, clone)
    clone

  ###*
    @return {Element}
  ###
  createClone: ->
    return null unless @getElement()?
    clone = @clone()
    @clones.push clone
    clone

  cleanListeners: ->
    goog.events.unlistenByKey listener for listener in @listeners
    @listeners = []

  ###*
    @protected
    @return {boolean}
  ###
  canHide: ->
    @pageCount < 2 and not @forceDisplay

  ###*
    @param {boolean} visible
    @param {boolean=} force default is false
  ###
  show: (visible, force = false) ->
    if not force and @canHide()
      @showInternal(false)
    else
      @showInternal(visible)

  ###*
    @protected
    @param {boolean} visible
  ###
  showInternal: (visible) ->
    func = if visible then goog.dom.classes.remove else goog.dom.classes.add
    func(el, 'empty') for el in [@getElement()].concat(@clones)
