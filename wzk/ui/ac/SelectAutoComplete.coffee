goog.require 'wzk.ui.ac.InputHandler'
goog.require 'wzk.ui.ac.PictureCustomRenderer'
goog.require 'wzk.ui.ac.ArrayMatcher'
goog.require 'wzk.ui.ac.AutoComplete'
goog.require 'wzk.ui.ac.SelectOneStorage'
goog.require 'wzk.dom.Dom'

class wzk.ui.ac.SelectAutoComplete

  ###*
    Select is assumed to be prepopulated with options in templated

    @param {wzk.dom.Dom} dom
    @param {wzk.ui.ac.Renderer} renderer
  ###
  constructor: (@dom, @renderer) ->
    @select = null
    @handler = null
    @stor = null

  ###*
    @protected
    @param {Array.<wzk.resource.Model>} data
  ###
  findDefaultValue: (data) ->
    model = @stor.load data
    if model?
      @setDefaultValue model

  ###*
    @protected
    @param {wzk.resource.Model} model
  ###
  setDefaultValue: (model) ->
    input = @renderer.getInput()
    @handler.detachInput input.getElement()
    input.setValue model.toString()
    @handler.attachInput input.getElement()
    input.showClearButton() if input.getValue()

    @afterSelect model

  ###*
    @param {Element} select
  ###
  decorate: (@select) ->
    if select.hasAttribute 'multiple'
      throw new Error 'For select-multiple use wzk.ui.ac.ExtSelectbox'
    @renderer.decorate @select
    @stor = new wzk.ui.ac.SelectOneStorage @dom, @select
    @renderer.listen wzk.ui.ac.Renderer.EventType.CLEAN, @handleClean
    @renderer.listen wzk.ui.ac.Renderer.EventType.OPEN, @handleOpen

  ###*
    @protected
  ###
  handleClean: =>
    @stor.clean()
    goog.events.fireListeners(@select, goog.events.EventType.CHANGE, false, {type: goog.events.EventType.CHANGE, target: @select})

  ###*
     @protected
   ###
  handleOpen: =>
    @renderer.getInput().getElement().focus()
    @ac.renderRows(@data)

  ###*
    @param {Array} data
  ###
  load: (@data) ->
    @matcher = new wzk.ui.ac.ArrayMatcher @data, false
    @handler = new wzk.ui.ac.InputHandler null, null, false
    @ac = new wzk.ui.ac.AutoComplete @matcher, @renderer, @handler
    @ac.setTarget(@renderer.getInput().getElement())  # sets target element where to attach suggest box

    @handler.attachAutoComplete @ac
    @handler.attachInput @renderer.getInput().getElement()

    @ac.listen goog.ui.ac.AutoComplete.EventType.UPDATE, @handleUpdate

    @findDefaultValue @data

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleUpdate: (e) =>
    @stor.store e.row
    @afterSelect e.row

    @renderer.getInput().handleInputChange()
    goog.events.fireListeners(@select, goog.events.EventType.CHANGE, false, {type: goog.events.EventType.CHANGE, target: @select})

  ###*
    @protected
    @param {Object} row
  ###
  afterSelect: (row) ->
    @renderer.updateImage row

  ###*
    @param {wzk.resource.Model} model
  ###
  addModel: (model) ->
    opt = @dom.el 'option', value: model['pk']
    @dom.setTextContent opt, model.toString()
    @select.appendChild opt
    @data.push model
    @matcher.setRows @data
