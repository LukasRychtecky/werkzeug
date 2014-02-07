goog.provide 'wzk.ui.ConfirmDialog'

class wzk.ui.ConfirmDialog extends wzk.ui.Dialog

  ###*
    @param {string=} klass
    @param {boolean=} useIframeMask
    @param {wzk.dom.Dom=} dom
  ###
  constructor: (klass, useIframeMask, dom) ->
    super klass, useIframeMask, dom
    @confirm = 'Do you really want to delete %s?'

  ###*
    @param {string} txt
  ###
  formatContent: (txt) ->
    @setContent(goog.string.format(@confirm, ['"', txt, '"'].join('')))
