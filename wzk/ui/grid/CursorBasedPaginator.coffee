goog.provide 'wzk.ui.grid.CursorBasedPaginator'

goog.require 'goog.dom.classes'
goog.require 'goog.dom.forms'
goog.require 'goog.events.Event'
goog.require 'goog.functions'
goog.require 'goog.style'

goog.require 'wzk.array'
goog.require 'wzk.dom.dataset'
goog.require 'wzk.num'
goog.require 'wzk.ui.grid.CursorBasedPaginatorRenderer'
goog.require 'wzk.ui.grid.BasePaginator'


class wzk.ui.grid.CursorBasedPaginator extends wzk.ui.grid.BasePaginator

  ###*
    @param {Object} params
      renderer: {@link wzk.ui.grid.PaginatorRenderer}
      stateHolder: {wzk.ui.grid.StateHolder}
  ###
  constructor: (params) ->
    params.renderer ?= new wzk.ui.grid.CursorBasedPaginatorRenderer()
    super params
    {stateHolder} = params

    @base = stateHolder.getBase()

    @base = if @base >= 0 then @base else wzk.ui.grid.BasePaginator.BASE
    @clones = []
    @listeners = []
    @switcher = null
    @defBases = [10, 25, 50, 100, 500, 1000]
    @bases = @defBases
    @forceDisplay = false
    @cursor = null
    @nextCursor = null

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

  ###*
    @param {Object} result
  ###
  init: (result) ->
    {@total, @count, @nextCursor} = result
    @nextCursor ?= null
    @count ?= @base

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
  isLast: ->
    @nextCursor is null

  ###*
    @return {boolean}
  ###
  hasTotal: ->
    ! isNaN @total

  ###*
    Re-renders a paginator according to a current page

    @param {Object} result
      total: {number}
      count: {number}
  ###
  refresh: (result) ->
    {@total, @count, @prevOffset, @nextOffset} = result
    if result.nextCursor
      @nextCursor = result.nextCursor
    else
      @nextCursor = null
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
    @cursor = null
    @nextCursor = null
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

  ###*
    @protected
  ###
  hangPageListener: (paging) ->
    listener = goog.events.listen paging, goog.events.EventType.CLICK, (e) =>
      cursor = @renderer.getCursor e.target, @dom
      if cursor?
        @cursor = cursor
        @dispatchChanged()

    @listeners.push listener

  ###*
    @protected
  ###
  dispatchChanged: ->
    @cleanListeners()
    @dispatchEvent new goog.events.Event(wzk.ui.grid.BasePaginator.EventType.CHANGED, {base: @base, cursor: @cursor})

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
    @cursor = null
    @nextCursor = null
    @buildQuery(query)

  ###*
    @param {wzk.resource.Query} query
  ###
  buildQuery: (query) ->
    query.base = @base
    query.cursor = @cursor

  ###*
    Clear data
    @return {boolean}
  ###
  clearData: ->
    @nextCursor is null

  ###*
    Reload data with delete element
    @return {boolean}
  ###
  reloadWithDelete: ->
    false

  ###*
    Clear data with sort
    @return {boolean}
  ###
  resetWithSort: ->
    true
