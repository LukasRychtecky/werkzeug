class wzk.ui.ac.PictureCustomRenderer

  ###*
    @enum {string}
  ###
  @STYLE:
    IMAGE_CLASS: 'ac-image ac-image-list'
    IMAGE_ALT: 'photo'

  ###*
    @param {wzk.ui.dom.Dom} dom
  ###
  constructor: (@dom) ->

  ###*
    Generic function that takes a row and renders a DOM structure for that row.
    @param {Object} row Object representing row.
    @param {string} token Token to highlight.
    @param {Node} node The node to render into.
  ###
  renderRow: (row, token, node) ->
    node.appendChild @createImage(row.data["photo"])
    node.appendChild @dom.createTextNode(row.data.toString())

  ###*
    @param {string} text
    @param {string} photo
  ###
  createImage: (photo) ->
    @STYLE = wzk.ui.ac.PictureCustomRenderer.STYLE
    img = @dom.createDom 'img', {src: photo, class: @STYLE.IMAGE_CLASS, alt: @STYLE.IMAGE_ALT}
