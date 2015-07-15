goog.provide 'wzk.net.XhrFactory'

goog.require 'wzk.net.XhrIo'
goog.require 'goog.net.EventType'
goog.require 'goog.events'

class wzk.net.XhrFactory

  ###*
    @enum {string}
  ###
  @EventType:
    BEFORE_UNLOAD: 'beforeunload'

  ###*
    @enum {boolean|null}
  ###
  @NET_STATUS:
    OFFLINE: false
    ONLINE: true
    UNKNOWN: null

  ###*
    @param {wzk.net.FlashMiddleware} flash
    @param {wzk.net.AuthMiddleware} auth
    @param {wzk.net.SnippetMiddleware} snip
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@flash, @auth, @snip, @dom) ->
    @_i = 0
    @_running = 0
    @_flashLoading = null
    @xhrs = []
    @navigator = @dom.getWindow()['navigator']
    @netStatus = @isOnline()
    @responseMiddlewares = []

    unless goog.userAgent.IE
      goog.events.listen @dom.getWindow(), wzk.net.XhrFactory.EventType.BEFORE_UNLOAD, @handleBeforeUnload

  ###*
    When user nagivates elsewhere (invokes unload of page), cancell all xhr requests
    Will not work for requests that have not been built by XhrFactory
    @protected
    @param {goog.events.Event} e
  ###
  handleBeforeUnload: (e) =>
    for xhr in @xhrs
      xhr.abort()
    undefined

  ###*
    @param {wzk.net.XhrConfig} config
    @return {wzk.net.XhrIo}
  ###
  build: (config = new wzk.net.XhrConfig()) ->
    xhr = @buildXhr config
    xhr.listen goog.net.EventType.ERROR, @handleError
    xhr.listen goog.net.EventType.COMPLETE, @handleComplete
    xhr

  ###*
    @param {boolean|null} netStatus
  ###
  setNetStatus: (@netStatus) ->

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleError: (e) =>
    @invokeResponseMiddlewares e
    xhr = (`/** @type {wzk.net.XhrIo} */`) e.target
    if @isJsonResponse xhr
      response = (`/** @type {Object} */`) xhr.getResponseJson()
      config = e.target.getConfig()
      @flash.clearAll() if config.flash
      @applyJsonResponse response, config, xhr.getStatus()
    else
      @handleCriticalError xhr, e.target.getConfig().flash


  ###*
    @protected
    @param {wzk.net.XhrIo} xhr
    @param {wzk.net.FlashMiddleware} flash
  ###
  handleCriticalError: (xhr, flash) ->
    return if not flash
    isOnline = @isOnline()
    if xhr.getStatus() is 0 and isOnline is false and @wasOnline()
      @flash.offline()
    else if xhr.getStatus() >= 500
      @flash.error xhr.getStatus()
    @setNetStatus isOnline

  ###*
    @return {boolean}
  ###
  wasOnline: ->
    @netStatus isnt wzk.net.XhrFactory.NET_STATUS.OFFLINE

  ###*
    @return {boolean|null}
  ###
  isOnline: ->
    status = wzk.net.XhrFactory.NET_STATUS.UNKNOWN
    if @navigator? and @navigator['onLine']?
      status = if @navigator['onLine'] then wzk.net.XhrFactory.NET_STATUS.ONLINE else wzk.net.XhrFactory.NET_STATUS.OFFLINE
    status

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleComplete: (e) =>
    @invokeResponseMiddlewares e
    xhr = (`/** @type {wzk.net.XhrIo} */`) e.target
    if xhr.getStatus() isnt 204
      config = e.target.getConfig()

      try
        # we cannot check response type because of IE
        # snippets must be sent with text/plain instead of application/json
        response = (`/** @type {wzk.net.XhrIo} */`) xhr.getResponseJson()
        @flash.clearAll() if config.flash
        @applyJsonResponse response, config, xhr.getStatus()
      catch error
        # TODO log error

  ###*
    Applies json response
    @param {Object} json response
    @param {wzk.net.XhrConfig} config
    @param {number} status
  ###
  applyJsonResponse: (json, config, status) ->
    @flash.apply json, status if config.flash
    @snip.apply json if config.snippet

  ###*
    @suppress {checkTypes}
    @protected
    @param {wzk.net.XhrConfig} config
    @return {wzk.net.XhrIo}
  ###
  buildXhr: (config) ->
    xhr = new wzk.net.XhrIo()
    xhr.setConfig config
    @xhrs.push xhr
    xhr.id_ = @_i
    @_i++

    xhr.addMiddleware @auth

    xhr.listen wzk.net.XhrIo.Events.SEND, (e) =>
      config = e.target.getConfig()
      if @_running is 0 and config.flash and config.loading
        flashes = @flash.loading()
        @_flashLoading = flashes.pop()
      @_running++

    xhr.listen wzk.net.XhrIo.Events.DONE, =>
      @_running--
      if @_running is 0 and @_flashLoading?
        @_flashLoading.destroy()

    xhr

  ###*
    @protected
    @param {wzk.net.XhrIo} xhr
    @return {boolean}
  ###
  isJsonResponse: (xhr) ->
    type = xhr.getResponseHeader 'Content-Type'
    type? and type.indexOf('json') isnt -1

  ###*
    @return {Location}
  ###
  getLocation: ->
    @dom.getWindow().location

  ###*
    @param {wzk.net.ResponseMiddleware} midware
  ###
  addResponseMiddleware: (midware) ->
    @responseMiddlewares.push midware

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  invokeResponseMiddlewares: (e) ->
    (mid.apply e for mid in @responseMiddlewares)
