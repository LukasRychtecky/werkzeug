goog.require 'goog.History'
goog.require 'goog.object'
goog.require 'goog.events'

goog.require 'wzk.obj'
goog.require 'wzk.json'
goog.require 'wzk.ui.grid.FilterWatcher'

class wzk.ui.grid.StateHolder extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @PARAM:
    BASE: 'b'
    PAGE: 'p'

  ###*
    @enum {number}
  ###
  @DEF:
    BASE: 0
    PAGE: 1

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGED: 'state-changed'

  ###*
    @param {wzk.stor.StateStorage} ss
    @param {string=} keySuffix
  ###
  constructor: (@ss, @keySuffix='') ->
    super()
    @history = new goog.History()
    @history.setEnabled true
    @base = wzk.ui.grid.StateHolder.DEF.BASE
    @LS_KEY = 'grid'

  ###*
    @param {number} base
  ###
  setBase: (@base) ->

  ###*
    @return {number}
  ###
  getPage: ->
    wzk.num.parseDec @ss.get(wzk.ui.grid.StateHolder.PARAM.PAGE), wzk.ui.grid.StateHolder.DEF.PAGE

  ###*
    @return {number}
  ###
  getBase: ->
    gridStorage = wzk.json.parse(goog.global['localStorage'].getItem(@LS_KEY)) or {}
    base = (`/** @type {number} */`) wzk.num.parseDec(
      wzk.obj.getIn(gridStorage, [@keySuffix, wzk.ui.grid.StateHolder.PARAM.BASE]))
    if wzk.num.isPos(base)
      base
    else
      @base

  ###*
    @param {wzk.ui.grid.BasePaginator} paginator
  ###
  handle: (@paginator, @watcher) ->
    @paginator.listen wzk.ui.grid.BasePaginator.EventType.CHANGED, @handlePaginatorChanged
    @watcher.listen wzk.ui.grid.FilterWatcher.EventType.CHANGED, @handleFilterChanged
    @watcher.listen wzk.ui.grid.FilterWatcher.EventType.RESET_PAGINATOR, @handleFilterResetPaginator

  ###*
    @protected
  ###
  dispatchChanged: ->
    @dispatchEvent new goog.events.Event wzk.ui.grid.StateHolder.EventType.CHANGED, {}

  ###*
    @protected
  ###
  handleFilterChanged: =>
    @paginator.reset(@getQuery())
    @updateStorage page: wzk.ui.grid.StateHolder.DEF.PAGE

  ###*
    @protected
  ###
  handleFilterResetPaginator: =>
    @paginator.reset(@getQuery)

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handlePaginatorChanged: (e) =>
    @updateStorage e.target

  ###*
    @protected
    @param {Object.<string, *>} params
  ###
  updateLS: (params) ->
    gridStorage = wzk.json.parse(goog.global['localStorage'].getItem(@LS_KEY)) or {}
    for k, v of params
      wzk.obj.assocIn(gridStorage, [@keySuffix, k], v)
    goog.global['localStorage'].setItem(@LS_KEY, wzk.json.serialize(gridStorage))

  ###*
    @protected
    @param {Object|null|undefined} args
  ###
  updateStorage: (args) =>
    return unless args?
    DEF = wzk.ui.grid.StateHolder.DEF
    PARAM = wzk.ui.grid.StateHolder.PARAM
    if args.base?
      paramsLS = {}
      paramsLS[PARAM.BASE] = args.base
      @updateLS(paramsLS)

    params = {}
    params[PARAM.PAGE] = if args.page isnt DEF.PAGE then args.page else null

    filterParams = @watcher.getParams()
    goog.object.extend filterParams, params

    @ss.removeOld()
    @ss.setAll filterParams, true
    @dispatchChanged()

  ###*
    @return {wzk.resource.Query}
  ###
  getQuery: ->
    @watcher.getQuery()
