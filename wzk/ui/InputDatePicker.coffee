class wzk.ui.InputDatePicker extends goog.ui.InputDatePicker

  @TIME_PATTERNS:
    5: /[0-9][0-9]:[0-9][0-9]/
    8: /[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/

  constructor: (dateTimeFormatter, dateTimeParser, datePicker, dom) ->
    super(dateTimeFormatter, dateTimeParser, datePicker, dom)

  ###*
    @override
  ###
  setInputValue: (value) ->
    super(@formatInputValue(value))

  ###*
    Override when format input value is needed.
    @param {string} value
    @return {string}
  ###
  formatInputValue: (value) ->
    origValue = @getElement().value
    if origValue
      time = origValue.split(' ').pop()
      regexp = wzk.ui.InputDatePicker.TIME_PATTERNS[time.length]
      if regexp? and regexp.test(time)
        return [value, time].join(' ')
    return value
