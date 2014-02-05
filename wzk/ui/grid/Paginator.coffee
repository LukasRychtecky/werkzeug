goog.provide 'wzk.ui.grid.Paginator'

goog.require 'wzk.ui.Component'
goog.require 'wzk.ui.grid.PaginatorRenderer'
goog.require 'goog.events.Event'
goog.require 'goog.dom.classes'
goog.require 'goog.dom.dataset'
goog.require 'goog.dom.forms'

class wzk.ui.grid.Paginator extends wzk.ui.Component

  ###*
    @enum {string}
  ###
  @EventType:
    GO_TO: 'go-to'

  ###*
    @constructor
    @extends {wzk.ui.Component}
    @param {Object} params
      renderer: {@link wzk.ui.grid.PaginatorRenderer}
      total: {number}
      offset: {number}
      base: {number}
      page: {number}
      count: {number}
  ###
  constructor: (params) ->
    params.renderer ?= new wzk.ui.grid.PaginatorRenderer()
    super params
    {@total, @offset, @base, @page, @count} = params
    @base ?= 10
    @offset ?= 0
    @firstPage = 1
    @calculatePageCount()
    @lastPage = @pageCount
    @page ?= 1
    @count ?= @base
    @clones = []
    @listeners = []
    @switcher = null
    @bases = null

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
    el? and goog.dom.classes.has el, 'paginator'

  ###*
    @override
  ###
  afterRendering: ->
    @hangPageListener @getElement()
    @hangBaseSwitcherListener @getElement()

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
    @param {Element} el
  ###
  selectBase: (el) ->
    select = el.querySelector '.' + wzk.ui.grid.PaginatorRenderer.CLASSES.BASE_SWITCHER + ' select'
    goog.dom.forms.setValue select, String(@base)

  ###*
    @override
  ###
  decorateInternal: (el) ->
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

  ###*
    @return {Array.<number>}
  ###
  getBases: ->
    @bases ? [10, 25, 50, 100, 500, 1000]

  ###*
    @protected
    @param {Element} el
  ###
  hangPageListener: (el) ->
    paging = el.querySelector '.' + wzk.ui.grid.PaginatorRenderer.CLASSES.PAGING
    listener = goog.events.listen paging, goog.events.EventType.CLICK, (e) =>
      page = goog.dom.dataset.get e.target, 'p'
      if page?
        @page = parseInt page, 10
        @offset = @offsetFromPage()
        @dispatchGoToPage()

    @listeners.push listener

  ###*
    @protected
    @param {Element} el
  ###
  hangBaseSwitcherListener: (el) ->
    switcher = el.querySelector '.' + wzk.ui.grid.PaginatorRenderer.CLASSES.BASE_SWITCHER
    listener = goog.events.listen switcher, goog.events.EventType.CHANGE, (e) =>
      base = goog.dom.forms.getValue e.target
      if base?
        @base = parseInt base, 10
        @calculatePageCount()
        @dispatchGoToPage()

    @listeners.push listener

  ###*
    @protected
  ###
  dispatchGoToPage: ->
    @cleanListeners()
    @dispatchEvent new goog.events.Event(wzk.ui.grid.Paginator.EventType.GO_TO, {offset: @offset, base: @base})

  ###*
    @protected
    @return {Element}
  ###
  clone: ->
    clone = @getElement().cloneNode true
    @selectBase clone
    @hangPageListener clone
    @hangBaseSwitcherListener clone
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
