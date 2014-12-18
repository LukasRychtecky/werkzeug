goog.require 'wzk.num'

class wzk.ui.ac.AutoComplete extends goog.ui.ac.AutoComplete

  ###*
    @override
    @suppress {accessControls}
  ###
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

  ###*
    @override
    @suppress {accessControls}
  ###
  renderRows: (rows, optOptions) =>
    optionsObj = goog.typeOf(optOptions) is 'object' and optOptions

    preserveHilited = if optionsObj then optionsObj.getPreserveHilited() else optOptions
    indexToHilite = if preserveHilited then @getIndexOfId(@hiliteId_) else -1

    @firstRowId_ += @rows_.length
    @rows_ = @omitSelectedRows rows
    rendRows = []
    for i, row of @rows_
      rendRow =
        "id": @getIdOfIndex_(wzk.num.parseDec(i)),
        "data": row
      if row['group']?
        rendRow['group'] = row['group']
      rendRows.push(rendRow)
      anchor = null

    if @target_
      anchor = @inputToAnchorMap_[goog.getUid(@target_)] or @target_

    @renderer_.setAnchorElement(anchor)
    @renderer_.renderRows(rendRows, @token_, @target_)

    autoHilite = @autoHilite_
    if optionsObj and optionsObj.getAutoHilite()?
      autoHilite = optionsObj.getAutoHilite()

    @hiliteId_ = -1
    if autoHilite or indexToHilite >= 0 and rendRows.length != 0 and @token_
      if indexToHilite >= 0
        @hiliteId(@getIdOfIndex_(indexToHilite))
      else
        @hiliteNext()
    @dispatchEvent goog.ui.ac.AutoComplete.EventType.SUGGESTIONS_UPDATE
    return

  ###*
    @param {Array} rows
    @return {Array}
  ###
  omitSelectedRows: (rows) =>
    return (row for row in rows when not @isSelected(row, @renderer_.getSelectedRows()))

  ###*
    @protected
    @param {wzk.resource.Model} row
    @param {Array} selectedRows
    @return {boolean}
  ###
  isSelected: (row, selectedRows) =>
    selectedRows[row.toString()]?

  ###*
    @override
    @suppress {checkTypes|accessControls}
  ###
  selectHilited: =>
    index =  @getIndexOfId(@hiliteId_)
    if index != -1
      selectedRow = @rows_[index]
      suppressUpdate = @selectionHandler_.selectRow(selectedRow)
      if @triggerSuggestionsOnUpdate_
        @token_ = null
        @dismissOnDelay()
      else
        @dismiss()

      if !suppressUpdate
        @dispatchEvent({
          type: goog.ui.ac.AutoComplete.EventType.UPDATE,
          row: selectedRow,
          index: index
        })
        if @triggerSuggestionsOnUpdate_
          @selectionHandler_.update(true)

      return true
    else
      @dismiss()
      @dispatchEvent({
        type: goog.ui.ac.AutoComplete.EventType.UPDATE,
        row: null,
        index: null
      })
      false
