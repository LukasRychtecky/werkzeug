goog.require 'goog.History'

class wzk.ui.grid.PaginatorHandler

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
    @base = wzk.ui.grid.PaginatorHandler.DEF.BASE

  ###*
    @param {number} base
  ###
  setBase: (@base) ->

  ###*
    @return {number}
  ###
  getPage: ->
    wzk.num.parseDec @ss.get(wzk.ui.grid.PaginatorHandler.PARAM.PAGE), wzk.ui.grid.PaginatorHandler.DEF.PAGE

  ###*
    @return {number}
  ###
  getBase: ->
    wzk.num.parseDec @ss.get(wzk.ui.grid.PaginatorHandler.PARAM.BASE), @base
  ###*
    @param {wzk.ui.grid.Paginator} paginator
  ###
  handle: (@paginator) ->
    @paginator.listen wzk.ui.grid.Paginator.EventType.GO_TO, @handleGoTo
    @history.listen goog.history.EventType.NAVIGATE, @handleNav

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleGoTo: (e) =>
    args = e.target
    DEF = wzk.ui.grid.PaginatorHandler.DEF
    PARAM = wzk.ui.grid.PaginatorHandler.PARAM
    params = {}
    params[PARAM.BASE] = if args.base isnt @base then args.base else null
    params[PARAM.PAGE] = if args.page isnt DEF.PAGE then args.page else null

    @ss.setAll params

  ###*
    @protected
  ###
  handleNav: =>
    @paginator.goToPage @getBase(), @getPage()
