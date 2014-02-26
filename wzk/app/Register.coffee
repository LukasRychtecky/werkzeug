goog.provide 'wzk.app.Register'

class wzk.app.Register

  ###*
    @param {function(?, ?)} buildFunc
  ###
  constructor: (@buildFunc) ->
    @filters = {}

  ###*
    @param {string} selector
    @param {function(Element, wzk.dom.Dom, wzk.net.XhrFactory, Object=)} filter
  ###
  register: (selector, filter) ->
    @filters[selector] = filter

  ###*
    @param {(Element|Node|Document)} el
  ###
  process: (el) =>
    for selector, filter of @filters
      for child in el.querySelectorAll selector
        @buildFunc filter, child
