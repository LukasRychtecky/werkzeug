goog.provide 'wzk.json'

goog.require 'goog.json'


###*
  Serializes an object or a value to a JSON string.

 @param {*} object The object to serialize.
 @param {?goog.json.Replacer=} opt_replacer A replacer function
        called for each (key, value) pair that determines how the value
        should be serialized. By defult, this just returns the value
        and allows default serialization to kick in.
 @throws Error if there are loops in the object graph.
 @return {string} A JSON string representation of the input.
###
wzk.json.serialize = goog.json.serialize


###*
  Parses a JSON string and returns the result. This throws an exception if the string is an invalid JSON string.
  Note that this is very slow on large strings. Use JSON.parse if possible.

  It doesn't throw an error, it rather returns `null` and calls `errorCallback` and returns its value.

 @param {*} s The JSON string to parse.
 @param {function(string):Object=} errorHandler
 @return {?Object} The object generated from the JSON string, or null.
###
wzk.json.parse = (s, errorHandler) ->
  try
    goog.json.parse(s)
  catch _
    if goog.isFunction(errorCallback) then errorCallback() else null
