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
    @protected
    @param {goog.events.Event} e
  ###
  handleError: (e) =>
    xhr = (`/** @type {wzk.net.XhrIo} */`) e.target
    if @isJsonResponse xhr
      response = (`/** @type {Object} */`) xhr.getResponseJson()
      config = e.target.getConfig()
      @flash.clearAll() if config.flash
      @applyJsonResponse response, config, xhr.getStatus()
    else
      @flash.error(xhr.getStatus()) if e.target.getConfig().flash

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleComplete: (e) =>
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
