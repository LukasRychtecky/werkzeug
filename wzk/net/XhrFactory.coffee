goog.provide 'wzk.net.XhrFactory'

goog.require 'wzk.net.XhrIo'
goog.require 'goog.net.EventType'
goog.require 'goog.events'
goog.require 'wzk.obj'

class wzk.net.XhrFactory

  ###*
    @enum {string}
  ###
  @MSGS:
    'error': 'Internal error occured. Service is unavailable, sorry.'
    'loading': 'Loading...'

  ###*
    @param {wzk.ui.Flash} flash
    @param {Object.<string, string>} msgs
  ###
  constructor: (@flash, @msgs) ->
    wzk.obj.merge @msgs, wzk.net.XhrFactory.MSGS
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
        unless response['message']? or response['errors']?
          @flash.addError @msgs['error']
      else
        @flash.addError @msgs['error']

    xhr.listen goog.net.EventType.COMPLETE, =>
      if xhr.getStatus() isnt 204 and @isJsonReponse xhr
        response = xhr.getResponseJson()
        if response['message']?
          for type, msg of response['message']
            @flash.addMessage msg, type
          undefined

    xhr

  ###*
    @suppress {checkTypes}
    @protected
    @return {wzk.net.XhrIo}
  ###
  buildXhr: ->
    xhr = new wzk.net.XhrIo()
    xhr.id_ = @_i
    @_i++

    xhr.listen wzk.net.XhrIo.Events.SEND, =>
      if @_running is 0
        flashes = @flash.addMessage @msgs['loading'], 'info', false, false
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
