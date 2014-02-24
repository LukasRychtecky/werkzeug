goog.require 'goog.dom.dataset'
goog.require 'goog.ui.ac.InputHandler'
goog.require 'wzk.ui.ac.Renderer'
goog.require 'wzk.ui.ac.PictureCustomRenderer'
goog.require 'goog.dom.dataset'

###*
  Implements SelectionHandler interface
###
class wzk.ui.ac.SelectAutoComplete extends wzk.ui.ac.AutoComplete

  ###*
    @enum {string}
  ###
  @TAGS:
    ITEM: 'span'
    SELECTED_VALUE: 'on'

  ###*
    Select is assumed to be prepopulated with options in templated

    @param {wzk.dom.Dom} dom
    @param {Element} select with options, that has values of id's of items
    @param {wzk.ui.ac.ArrayMatcher} autocomplete matcher
    @param {Array.<string>} data
  ###
  constructor: (@dom, @select, matcher, data) ->
    @TAGS = wzk.ui.ac.SelectAutoComplete.TAGS

    # extract image placeholder attribute
    imagePlaceholder = goog.dom.dataset.get @select, 'imagePlaceholder'

    @rowCustomRenderer = new wzk.ui.ac.PictureCustomRenderer(@dom)
    @renderer = new wzk.ui.ac.Renderer(@dom, imagePlaceholder, null, @rowCustomRenderer)
    @renderer.decorate(@select)
    @input = @renderer.getInput()

    # hide select
    goog.style.showElement @select, false

    # tell autocomplete which input it should attach to
    @inputHandler = new goog.ui.ac.InputHandler()
    @inputHandler.attachAutoComplete(@)
    @inputHandler.attachInput(@input)

    @initData(data)

    # this class implements SelectionHandler interface
    super(matcher, @renderer, @)

  ###*
    Initializes autocomplete into defaultly setted data
  ###
  initData: (data) ->
    # works even on IE9
    id = goog.dom.forms.getValue(@select)
    for row in data
      if row["id"] is id
        @afterSelect(row)
        break

  ###*
    @param {Object} row
  ###
  selectRow: (row) ->
    goog.dom.forms.setValue @select, row["id"]
    @afterSelect(row)

  ###*
    @param {Object} row
  ###
  afterSelect: (row) ->
    # input must be detached in order to change text to prevent autocomplete
    # catching event of changed text and displaying autocomplete list
    @inputHandler.detachInput(@input)
    @input.value = row.toString()
    @inputHandler.attachInput(@input)
    @renderer.setImage(row["photo"])
