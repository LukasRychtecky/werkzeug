goog.require 'goog.dom.dataset'
goog.require 'goog.i18n.DateTimeFormat'
goog.require 'goog.i18n.DateTimeParse'
goog.require 'goog.json'
goog.require 'goog.ui.InputDatePicker'

goog.require 'wzk.events'
goog.require 'wzk.ui.CloseIcon'
goog.require 'wzk.ui.DatePicker'
goog.require 'wzk.ui.InputDatePicker'


class wzk.ui.I18NInputDatePicker extends wzk.ui.ClearableInput

  ###*
    @param {wzk.dom.Dom} dom
    @param {string|undefined=} pattern
    @param {Object=} params
      showToday {boolean}
      allowNone {boolean}
      showWeekNum {boolean}
      useSimpleNavigationMenu {boolean} hides year selection
  ###
  constructor: (@dom, @pattern = "yyyy'-'MM'-'dd", @params) ->
    super @dom
    @params = {} unless @params?

    @params.showToday ?= false
    @params.allowNone ?= false
    @params.showWeekNum ?= false
    @params.useSimpleNavigationMenu ?= false

  ###*
    @protected
    @param {Element} el
    @return {Array.<Number>|null}
  ###
  parseYearRange: (el) ->
    yearRangeStr = goog.dom.dataset.get(el, 'yearRange')
    return null unless yearRangeStr
    obj = goog.json.parse(yearRangeStr)
    unless goog.isArray(obj)
      throw Error('data-year-range must be an Array')
    return (`/** @type {Array.<Number>} */`) obj

  ###*
    @param {Element} el
    @return {goog.ui.InputDatePicker}
    @suppress {checkTypes}
  ###
  decorate: (@el) ->
    @el.type = 'text'

    PATTERN = @getPattern @el
    formatter = new goog.i18n.DateTimeFormat PATTERN
    parser = new goog.i18n.DateTimeParse PATTERN



    datePicker = new wzk.ui.DatePicker()
    datePicker.setYearMenuRange(@parseYearRange(el))
    datePicker.setShowToday(@params.showToday)
    datePicker.setAllowNone(@params.allowNone)
    datePicker.setShowWeekNum(@params.showWeekNum)
    datePicker.setUseSimpleNavigationMenu(@params.useSimpleNavigationMenu)

    picker = new wzk.ui.InputDatePicker(formatter, parser, datePicker)

    picker.listen(goog.ui.DatePicker.Events.CHANGE, @handleChanged)

    @clrBtn = new wzk.ui.CloseIcon(dom: @dom)
    @clrBtn.listen(goog.ui.Component.EventType.ACTION, @handleClean)
    @clrBtn.render(@dom.getParentElement(@el))

    picker.decorate(@el)
    picker

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleChanged: (e) =>
    wzk.events.dispatchNativeEvent(e.currentTarget.getElement(), goog.events.EventType.CHANGE)
    @handleInputChange e

  ###*
    @override
  ###
  getElement: =>
    @el

  ###*
    @protected
    @param {Element} el
    @return {string}
  ###
  getPattern: (el) ->
    PATTERN = @pattern
    pattern = goog.dom.dataset.get el, 'pattern'
    if pattern?
      PATTERN = String pattern
    PATTERN
