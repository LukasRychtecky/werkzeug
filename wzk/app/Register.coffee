goog.provide 'wzk.app.Register'

class wzk.app.Register

  constructor: ->
    @filters = {}

  ###*
    @param {string} selector
    @param {function(Element, wzk.dom.Dom, wzk.net.XhrFactory, Object=)} filter
  ###
  register: (selector, filter) ->
    @filters[selector] = filter

  ###*
    @param {(Element|Document)} el
    @param {wzk.dom.Dom} dom
    @param {wzk.net.XhrFactory} xhrFac
    @param {Object=} opts
  ###
  process: (el, dom, xhrFac, opts) =>
    for selector, filter of @filters
      for child in el.querySelectorAll selector
        filter child, dom, xhrFac, opts
