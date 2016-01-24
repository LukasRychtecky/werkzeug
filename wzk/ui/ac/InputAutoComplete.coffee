goog.require 'goog.dom.forms'

goog.require 'wzk.ui.ac.InputHandler'
goog.require 'wzk.ui.ac.PictureCustomRenderer'
goog.require 'wzk.ui.ac.RESTArrayMatcher'
goog.require 'wzk.ui.ac.RESTAutoComplete'
goog.require 'wzk.ui.ac.AutoComplete'


class wzk.ui.ac.InputAutoComplete extends goog.events.EventTarget

  ###*
    Select is assumed to be prepopulated with options in templated

    @param {wzk.dom.Dom} dom
    @param {wzk.ui.ac.Renderer} renderer
  ###
  constructor: (@dom, @renderer, @api, @tokenName, @limit, @tokenMinLength) ->
    super()
    @input = null
    @handler = null
    @stor = null
    @input = null

  ###*
    @param {Element} el
  ###
  decorate: (@el) ->
    @renderer.decorate(@el)
    @renderer.listen(wzk.ui.ac.Renderer.EventType.CLEAN, @handleClean)
    @input = @renderer.getInput()
    @input.setPlaceholder(@el.getAttribute('placeholder')) if @el.hasAttribute('placeholder')

    @matcher = new wzk.ui.ac.RESTArrayMatcher(
      @api,
      @tokenName,
      @limit,
      @tokenMinLength,
      ['id', '_autocomplete_value', '_obj_name'].concat(wzk.ui.ac.extractFieldNames(el)),
    )
    @handler = new wzk.ui.ac.InputHandler(null, null, false)
    @ac = new wzk.ui.ac.RESTAutoComplete(@matcher, @renderer, @handler)
    @ac.setTarget(@renderer.getInput().getElement())  # sets target element where to attach suggest box

    @handler.attachAutoComplete(@ac)
    @handler.attachInput(@renderer.getInput().getElement())

    @ac.listen(goog.ui.ac.AutoComplete.EventType.UPDATE, @handleUpdate)

  ###*
    @protected
  ###
  handleClean: =>
    goog.dom.forms.setValue(@el, '')
    @input.setValue('')
    goog.events.fireListeners(@input, goog.events.EventType.CHANGE, false, {type: goog.events.EventType.CHANGE, target: @input})

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleUpdate: (e) =>
    goog.dom.forms.setValue(@el, e.row['id'])
    @afterSelect(e.row)

    @renderer.getInput().handleInputChange()
    goog.events.fireListeners(@input, goog.events.EventType.CHANGE, false, {type: goog.events.EventType.CHANGE, target: @input})

  ###*
    @protected
    @param {Object} row
  ###
  afterSelect: (row) ->
    @renderer.updateImage(row)

  ###*
    Exits the DOM and remove the element from DOM
  ###
  destroy: ->
    @input.destroy()
