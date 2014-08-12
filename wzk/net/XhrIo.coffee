goog.require 'goog.net.XhrIo'
goog.require 'wzk.net.XhrConfig'

class wzk.net.XhrIo extends goog.net.XhrIo

  ###*
    @enum {string}
  ###
  @Events:
    SEND: 'send'
    DONE: 'done'

  ###*
    @param {goog.net.XmlHttpFactory=} fac
  ###
  constructor: (fac) ->
    super fac
    @middlewares = []
    @xhrConfig = new wzk.net.XhrConfig()
    @listen goog.net.EventType.COMPLETE, =>
      @dispatchEvent wzk.net.XhrIo.Events.DONE

  ###*
    @return {wzk.net.XhrConfig}
  ###
  getConfig: ->
    @xhrConfig

  ###*
    @param {wzk.net.XhrConfig} xhrConfig
  ###
  setConfig: (@xhrConfig) ->

  ###*
    @param {wzk.net.HeadersMiddleware} midware
  ###
  addMiddleware: (midware) ->
    @middlewares.push midware

  ###*
    @override
  ###
  send: (url, method, content, headers) ->
    @dispatchEvent wzk.net.XhrIo.Events.SEND
    for midware in @middlewares
      midware.apply headers
    super url, method, content, headers
