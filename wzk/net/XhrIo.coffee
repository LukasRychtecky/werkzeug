goog.provide 'wzk.net.XhrIo'

goog.require 'goog.net.XhrIo'

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
    @listen goog.net.EventType.COMPLETE, =>
      @dispatchEvent wzk.net.XhrIo.Events.DONE

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
