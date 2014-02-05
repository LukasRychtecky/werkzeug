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
    @listen goog.net.EventType.COMPLETE, =>
      @dispatchEvent wzk.net.XhrIo.Events.DONE

  ###*
    @override
  ###
  send: (url, method, content, headers) ->
    @dispatchEvent wzk.net.XhrIo.Events.SEND
    super url, method, content, headers
