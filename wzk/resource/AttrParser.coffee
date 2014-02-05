goog.provide 'wzk.resource.AttrParser'

goog.require 'goog.dom.dataset'

class wzk.resource.AttrParser

  constructor: ->

  ###*
    @param {Element} el
    @return {string}
  ###
  parseResource: (el) ->
    @getAttr(el, 'resource')

  ###*
    @param {Element} el
    @return {string}
  ###
  parseContext: (el) ->
    @getAttr(el, 'context')

  ###*
    @suppress {checkTypes}
    @param {Element} el
    @return {string}
  ###
  getAttr: (el, attr) ->
    goog.dom.dataset.get(el, attr) ? ''
