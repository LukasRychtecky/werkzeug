class wzk.ui.ac.AutoComplete extends goog.ui.ac.AutoComplete

  constructor: (matcher, renderer, handler) ->
    super(matcher, renderer, handler)

  ###*
    Overrides an origin method to allow passing an empty token.
    Enables to show a suggestion list.

    @override
    @suppress {accessControls}
  ###
  setToken: (token, fullString = undefined) ->
    @token_ = token
    @matcher_.requestMatchingRows(@token_, @matcher_.rows_.length, goog.bind(@matchListener_, @), fullString)
    @cancelDelayedDismiss()
