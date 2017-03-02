goog.provide 'wzk.html.SafeHtml'

###*
 Package-internal utility method to create SafeHtml instances.

 Copied from `goog.html.SafeHtml` after that it has been moved into a private.

 @param {string} html The string to initialize the SafeHtml object with.
 @param {?goog.i18n.bidi.Dir} dir The directionality of the SafeHtml to be
     constructed, or null if unknown.
 @return {!goog.html.SafeHtml} The initialized SafeHtml object.
###
wzk.html.SafeHtml.createSafeHtmlSecurityPrivateDoNotAccessOrElse = (html, dir) ->
  return new goog.html.SafeHtml().initSecurityPrivateDoNotAccessOrElse_(html, dir)


###*
 Called from createSafeHtmlSecurityPrivateDoNotAccessOrElse(). This
 method exists only so that the compiler can dead code eliminate static
 fields (like EMPTY) when they're not accessed.

 Copied from `goog.html.SafeHtml` after that it has been moved into a private.

 @param {string} html
 @param {?goog.i18n.bidi.Dir} dir
 @return {!goog.html.SafeHtml}
###
goog.html.SafeHtml.prototype.initSecurityPrivateDoNotAccessOrElse_ = (html, dir) ->
  @privateDoNotAccessOrElseSafeHtmlWrappedValue_ = html
  @dir_ = dir
  return this
