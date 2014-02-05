goog.provide 'wzk.app.Processor'

goog.require 'wzk.dom.Dom'

class wzk.app.Processor

  constructor: ->
    @filters = []

  ###*
    @param {function((Element|Document), wzk.dom.Dom, wzk.net.XhrFactory)} filter
  ###
  add: (filter) ->
    @filters.push filter

  ###*
    @param {(Element|Document)} el
    @param {Document} doc
    @param {wzk.net.XhrFactory} xhrFac
    @param {Object=} opts
  ###
  process: (el, doc, xhrFac, opts = {}) ->
    for filter in @filters
      @once filter, el, doc, xhrFac, opts

  ###*
    @param {function((Element|Document), wzk.dom.Dom, wzk.net.XhrFactory, Object)} filter
    @param {(Element|Document)} el
    @param {Document} doc
    @param {wzk.net.XhrFactory} xhrFac
    @param {Object=} opts
  ###
  once: (filter, el, doc, xhrFac, opts = {}) ->
    filter el, new wzk.dom.Dom(doc), xhrFac, opts
