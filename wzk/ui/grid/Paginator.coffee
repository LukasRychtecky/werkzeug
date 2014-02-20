goog.require 'wzk.ui.grid.PaginatorRenderer'
goog.require 'goog.events.Event'
goog.require 'goog.dom.classes'
goog.require 'goog.dom.dataset'
goog.require 'goog.dom.forms'
goog.require 'goog.style'

class wzk.ui.grid.Paginator extends wzk.ui.Component

  ###*
    @enum {string}
  ###
  @EventType:
    GO_TO: 'go-to'

  ###*
    @param {Object} params
      renderer: {@link wzk.ui.grid.PaginatorRenderer}
      base: {number}
      page: {number}
  ###
  constructor: (params) ->
    params.renderer ?= new wzk.ui.grid.PaginatorRenderer()
    super params
    {@base, @page} = params

    @page = if @page >= 0 then @page else 1
    @base = if @base >= 0 then @base else 10
    @offset = @offsetFromPage()
    @firstPage = 1
    @clones = []
    @listeners = []
    @switcher = null
    @bases = null
    @defBases = [10, 25, 50, 100, 500, 1000]

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
  isFirst: ->
    @page is @firstPage

  ###*
    @return {boolean}
  ###
  isLast: ->
    @page is @lastPage

  ###*
    @protected
    @return {number}
  ###
  offsetFromPage: ->
    (@page - 1) * @base

  ###*
    Re-renders a paginator according to a current page

    @param {Object} result
      total: {number}
      count: {number}
  ###
  refresh: (result) ->
    {@total, @count} = result
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
    @calculatePageCount()
    @dispatchGoToPage()

  ###*
    @override
  ###
  decorateInternal: (el) ->
    unless @bases
      switcherEl = el.querySelector '.' + wzk.ui.grid.PaginatorRenderer.CLASSES.BASE_SWITCHER
      @parseBases switcherEl

    @renderer.decorate @, el
    @setElementInternal el

  ###*
    @protected
    @param {Element} el
  ###
  parseBases: (el) ->
    return if not el? or @bases

    basesPlain = goog.dom.dataset.get el, 'bases'
    if basesPlain?
      bases = goog.json.parse basesPlain
      if goog.isArray(bases) and bases.length > 0
        @bases = bases

    unless @bases
      @bases = @defBases

  ###*
    @return {Array.<number>}
  ###
  getBases: ->
    @bases ? @defBases

  goToPage: (base, page) ->
    # change page only if base and page are different
    unless page is @page and base is @base
      @page = page
      @base = base
      @offset = @offsetFromPage()
      @renderer.setBase(@base)
      @calculatePageCount()
      @dispatchGoToPage()

  ###*
    @protected
  ###
  hangPageListener: (paging) ->
    listener = goog.events.listen paging, goog.events.EventType.CLICK, (e) =>
      page = @renderer.getPage e.target, @dom
      if page?
        @page = parseInt page, 10
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
    clone = @getElement().cloneNode true
    @hangPageListener clone
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
    @param {boolean} visible
  ###
  show: (visible) ->
    visibility = if visible then 'visible' else 'hidden'
    goog.style.setStyle el, 'visibility', visibility for el in [@getElement()].concat @clones
