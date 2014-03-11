class wzk.ui.ac.PictureTagRenderer extends wzk.ui.TagRenderer

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.ui.ac.PictureCustomRenderer} pictureRenderer
  ###
  constructor: (@dom, @pictureRenderer) ->
    super()

  ###*
    @override
    @param {goog.ui.Control} tag
  ###
  createDom: (tag) ->
    parent = super(tag)
    model = (`/** @type {wzk.resource.Model} */`) tag.getModel()
    @dom.prependChild parent, @pictureRenderer.createImageOrPlaceholder(model)
    parent
