goog.provide 'wzk.ui.grid.OffsetBasedPaginator'

goog.require 'goog.dom.classes'
goog.require 'goog.dom.forms'
goog.require 'goog.events.Event'
goog.require 'goog.functions'
goog.require 'goog.style'

goog.require 'wzk.array'
goog.require 'wzk.dom.dataset'
goog.require 'wzk.num'
goog.require 'wzk.ui.grid.OffsetBasedPaginatorRenderer'
goog.require 'wzk.ui.grid.BasePaginator'


class wzk.ui.grid.OffsetBasedPaginator extends wzk.ui.grid.BasePaginator

  ###*
    @param {Object} params
      renderer: {@link wzk.ui.grid.PaginatorRenderer}
      stateHolder: {wzk.ui.grid.StateHolder}
  ###
  constructor: (params) ->
    params.renderer ?= new wzk.ui.grid.OffsetBasedPaginatorRenderer()
    super params
    {stateHolder} = params

    @base = stateHolder.getBase()
    @page = stateHolder.getPage()

    @base = if @base >= 0 then @base else wzk.ui.grid.BasePaginator.BASE
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
    wzk.array.filterFirst([@base, value], wzk.num.isPos, wzk.ui.grid.BasePaginator.BASE)

  ###*
    @param {Element} el
  ###
  loadData: (el) ->
    @base = wzk.dom.dataset.get(
      el, wzk.ui.grid.BasePaginator.DATA.BASE, goog.functions.compose(@baseOrDefault, wzk.num.parseDec))
    @offsetFromPage()

  ###*
    @param {Object} result
  ###
  init: (result) ->
    {@total, @count, @prevOffset, @nextOffset} = result
    @calculatePageCount()
    @count ?= @base

  ###*
    @protected
  ###
  calculatePageCount: ->
    @pageCount = Math.ceil @total / @base

  ###*
    @override
  ###
  canDecorate: (el) ->
    el? and goog.dom.classes.has el, wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES.PAGINATOR

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
    isNaN @prevOffset

  ###*
    @return {boolean}
  ###
  isLast: ->
    isNaN @nextOffset

  ###*
    @return {boolean}
  ###
  hasTotal: ->
    ! isNaN @total

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
    {@total, @count, @prevOffset, @nextOffset} = result
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
    @dispatchChanged()

  ###*
    @override
  ###
  decorateInternal: (el) ->
    @forceDisplay = wzk.dom.dataset.get(el, wzk.ui.grid.BasePaginator.DATA.FORCE_DISPLAY) is 'true'
    unless @bases
      switcherEl = el.querySelector '.' + wzk.ui.grid.OffsetBasedPaginatorRenderer.CLASSES.BASE_SWITCHER
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
      @dispatchChanged()

  ###*
    @protected
  ###
  hangPageListener: (paging) ->
    listener = goog.events.listen paging, goog.events.EventType.CLICK, (e) =>
      page = @renderer.getPage e.target, @dom
      if page?
        @page = wzk.num.parseDec page
        @offset = @offsetFromPage()
        @dispatchChanged()

    @listeners.push listener

  ###*
    @protected
  ###
  dispatchChanged: ->
    @cleanListeners()
    @dispatchEvent new goog.events.Event(wzk.ui.grid.BasePaginator.EventType.CHANGED, {offset: @offset, base: @base, page: @page})

  ###*
    @protected
    @return {Element}
  ###
  clone: ->
    clone = @getElement().cloneNode(true)
    @hangPageListener(clone)
    goog.dom.classes.add(@getElement(), wzk.ui.grid.BasePaginator.CLASSES.TOP)
    goog.dom.classes.add(clone, wzk.ui.grid.BasePaginator.CLASSES.BOTTOM)
    goog.dom.classes.remove(clone, wzk.ui.grid.BasePaginator.CLASSES.TOP)
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

  ###*
    Reset paginator
    @param {wzk.resource.Query} query
  ###
  reset: (query) ->
    @offset = 0
    @page = 1
    @buildQuery(query)

  ###*
    @param {wzk.resource.Query} query
  ###
  buildQuery: (query) ->
    query.base = @base
    query.offset = @offset

  ###*
    Clear data
    @return {boolean}
  ###
  clearData: ->
    true

  ###*
    Reload data with delete element
    @return {boolean}
  ###
  reloadWithDelete: ->
    true

  ###*
    Clear data with sort
    @return {boolean}
  ###
  resetWithSort: ->
    false
