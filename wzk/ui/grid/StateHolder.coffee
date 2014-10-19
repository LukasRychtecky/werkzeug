goog.require 'goog.History'

goog.require 'wzk.ui.grid.FilterWatcher'

class wzk.ui.grid.StateHolder

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
    BASE: 10
    PAGE: 1

  ###*
    @param {wzk.stor.StateStorage} ss
  ###
  constructor: (@ss) ->
    @history = new goog.History()
    @history.setEnabled true
    @base = wzk.ui.grid.StateHolder.DEF.BASE

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
    wzk.num.parseDec @ss.get(wzk.ui.grid.StateHolder.PARAM.BASE), @base

  ###*
    @param {wzk.ui.grid.Paginator} paginator
  ###
  handle: (@paginator, @watcher) ->
    @paginator.listen wzk.ui.grid.Paginator.EventType.GO_TO, @handleGoTo
    @history.listen goog.history.EventType.NAVIGATE, @handleNav
    @watcher.listen wzk.ui.grid.FilterWatcher.EventType.CHANGED, @handleFilterChanged

  ###*
    @protected
  ###
  handleFilterChanged: =>
    @updateStorage {page: wzk.ui.grid.StateHolder.DEF.PAGE}

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleGoTo: (e) =>
    @updateStorage e.target

  ###*
    @protected
    @param {Object|null|undefined} args
  ###
  updateStorage: (args) =>
    return unless args?
    DEF = wzk.ui.grid.StateHolder.DEF
    PARAM = wzk.ui.grid.StateHolder.PARAM
    params = {}
    params[PARAM.BASE] = if args.base isnt @base then args.base else null
    params[PARAM.PAGE] = if args.page isnt DEF.PAGE then args.page else null

    @ss.setAll params

  ###*
    @protected
  ###
  handleNav: =>
    @paginator.goToPage @getBase(), @getPage()
