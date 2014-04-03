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
    e.preventDefault()

  ###*
    @return {wzk.net.XhrIo}
  ###
  build: ->
    xhr = @buildXhr()

    xhr.listen goog.net.EventType.ERROR, =>
      if @isJsonReponse xhr
        response = xhr.getResponseJson()
        @flash.clearAll()
        @applyJsonResponse(response)
      else
        @flash.error()

    xhr.listen goog.net.EventType.COMPLETE, =>
      if xhr.getStatus() isnt 204
        try
          response = xhr.getResponseJson()
          @flash.clearAll()
          @applyJsonResponse(response)
        catch error
    xhr

  ###*
    Applies json response
    @param {Object} json response
  ###
  applyJsonResponse: (json) ->
    @flash.apply json
    @snip.apply json

  ###*
    @suppress {checkTypes}
    @protected
    @return {wzk.net.XhrIo}
  ###
  buildXhr: ->
    xhr = new wzk.net.XhrIo()
    @xhrs.push xhr
    xhr.id_ = @_i
    @_i++

    xhr.addMiddleware @auth

    xhr.listen wzk.net.XhrIo.Events.SEND, =>
      if @_running is 0
        flashes = @flash.loading()
        @_flashLoading = flashes.pop()
      @_running++

    xhr.listen wzk.net.XhrIo.Events.DONE, =>
      @_running--
      if @_running is 0
        @_flashLoading.destroy()

    xhr

  ###*
    @protected
    @param {wzk.net.XhrIo} xhr
    @return {boolean}
  ###
  isJsonReponse: (xhr) ->
    type = xhr.getResponseHeader 'Content-Type'
    type? and type.indexOf('json') isnt -1
