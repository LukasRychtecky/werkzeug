goog.require 'wzk.ui.ac.RESTArrayMatcher'


class wzk.ui.ac.RESTAutoComplete extends wzk.ui.ac.AutoComplete

  constructor: (@matcher, @renderer, @handler) ->
    super(@matcher, @renderer, @handler)

  setRowFilter: (rowFilter) ->
    @matcher.setRowFilter(rowFilter)

  ###*
    @override
    @suppress {accessControls}
  ###
  setToken: (token, fullString = undefined) ->
    return if @token_ is token
    @token_ = token
    @matcher_.requestMatchingRows(@token_, 0, goog.bind(@matchListener_, @), fullString)
    @cancelDelayedDismiss()
