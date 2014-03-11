goog.require 'wzk.ui.ac.PictureTagRenderer'

class wzk.ui.ac.PictureCustomRenderer

  ###*
    @enum {string}
  ###
  @CLS:
    IMG: 'ac-image ac-image-list'
    IMG_PLACEHOLDER: 'ac-image-placeholder'

  ###*
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@dom) ->

  ###*
    Generic function that takes a row and renders a DOM structure for that row.
    @param {Object} row Object representing row.
    @param {string} token Token to highlight.
    @param {Node} node The node to render into.
  ###
  renderRow: (row, token, node) ->
    unless row instanceof wzk.resource.Model
      row = row['data']

    node.appendChild @createImageOrPlaceholder(row)
    node.appendChild @dom.createTextNode(row.toString())

  ###*
    @param {Object} data
    @return {Element|null}
  ###
  createImage: (data) ->
    C = wzk.ui.ac.PictureCustomRenderer.CLS
    @dom.createDom 'img', {src: data['photo'], class: C.IMG, alt: data.toString()}

  ###*
    @protected
    @return {Element}
  ###
  createImagePlaceholder: ->
    @dom.el 'div', wzk.ui.ac.PictureCustomRenderer.CLS.IMG_PLACEHOLDER

  ###*
    @param {Object|null|undefined=} data
    @return {Element}
  ###
  createImageOrPlaceholder: (data = null) ->
    if data? and data["photo"]? then @createImage(data) else @createImagePlaceholder()

  getTagRenderer: ->
    new wzk.ui.ac.PictureTagRenderer @dom, @
