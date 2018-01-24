goog.provide 'wzk.dom.dataset'

goog.require 'goog.dom.dataset'


###*
  Gets a custom data attribute from an element. The key should be
  in camelCase format (e.g "keyName" for the "data-key-name" attribute).
   @param {Element} element DOM node to get the custom data attribute from.
   @param {string} key Key for the custom data attribute.
   @param {function(string):T=} coerce When a given `element` has `key` data attribute,
   `coerce` function is call on its value. When no `coerce` is provided, `goog.identityFunction` is used.
   @param {T=} implicit When a given `element` doesn't have a `key`, it returns `implicit`.
   @return {?T} The attribute value, if it exists.
###
wzk.dom.dataset.get = (element, key, coerce=goog.identityFunction, implicit=null) ->
  if wzk.dom.dataset.has(element, key) then coerce(goog.dom.dataset.get(element, key)) else implicit

###*
  Sets a custom data attribute on an element. The key should be
  in camelCase format (e.g "keyName" for the "data-key-name" attribute).
  @param {Element} element DOM node to set the custom data attribute on.
  @param {string} key Key for the custom data attribute.
  @param {string} value Value for the custom data attribute.
###
wzk.dom.dataset.set = goog.dom.dataset.set


###*
  Removes a custom data attribute from an element. The key should be
  in camelCase format (e.g "keyName" for the "data-key-name" attribute).
  @param {Element} element DOM node to get the custom data attribute from.
  @param {string} key Key for the custom data attribute.
###
wzk.dom.dataset.remove = goog.dom.dataset.remove


###*
  Checks whether custom data attribute exists on an element. The key should be
  in camelCase format (e.g "keyName" for the "data-key-name" attribute).

  @param {Element} element DOM node to get the custom data attribute from.
  @param {string} key Key for the custom data attribute.
  @return {boolean} Whether the attribute exists.
###
wzk.dom.dataset.has = goog.dom.dataset.has


###*
  Gets all custom data attributes as a string map.  The attribute names will be
  camel cased (e.g., data-foo-bar -> dataset['fooBar']).  This operation is not
  safe for attributes having camel-cased names clashing with already existing
  properties (e.g., data-to-string -> dataset['toString']).
  @param {!Element} element DOM node to get the data attributes from.
  @return {!Object} The string map containing data attributes and their respective values
###
wzk.dom.dataset.getAll = goog.dom.dataset.getAll
