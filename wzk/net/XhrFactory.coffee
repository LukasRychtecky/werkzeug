goog.provide 'wzk.net.XhrFactory'

goog.require 'wzk.net.XhrIo'
goog.require 'goog.net.EventType'
goog.require 'goog.events'

class wzk.net.XhrFactory

  ###*
    @param {wzk.net.FlashMiddleware} flash
    @param {wzk.net.AuthMiddleware} auth
    @param {wzk.net.SnippetMiddleware} snip
  ###
  constructor: (@flash, @auth, @snip) ->
    @_i = 0
    @_running = 0
    @_flashLoading = null

  ###*
    @return {wzk.net.XhrIo}
  ###
  build: ->
    xhr = @buildXhr()

    xhr.listen goog.net.EventType.ERROR, =>
      if @isJsonReponse xhr
        response = xhr.getResponseJson()
        @applyJsonResponse(response)
      else
        @flash.error()

    xhr.listen goog.net.EventType.COMPLETE, =>
      if xhr.getStatus() isnt 204 and @isJsonReponse xhr
        response = xhr.getResponseJson()
        @applyJsonResponse(response)

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
