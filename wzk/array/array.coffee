goog.provide 'wzk.array'

goog.require 'goog.array'


###*
  Returns new array of a given `arr` without last element
  @param {Array.<T>|goog.array.ArrayLike} arr
  @return {Array.<T>|goog.array.ArrayLike}
  @template T
###
wzk.array.head = (arr) ->
  if arr.length < 2
    return arr
  else
    return Array.prototype.slice.call(arr, 0, arr.length - 1)


###*
  Returns last element of a given `arr`. If the array is empty, returns `implicit`.
  @param {Array.<T>|goog.array.ArrayLike} arr
  @param {T} implicit
  @return {T}
  @template T
###
wzk.array.last = (arr, implicit = null) ->
  return if goog.array.isEmpty(arr) then implicit else goog.array.peek(arr)


###*
  Returns a givenn `arr` without first element. Original array is not modified.
  @param {Array.<T>|goog.array.ArrayLike} arr
  @return {Array.<T>}
  @template T
###
wzk.array.rest = (arr) ->
  goog.array.slice(arr, 1)


###*
  Returns first item of a given `arr` where a given `pred` returns `true`. When no item found, returns `implicit`.
  @param {Array.<T>|goog.array.ArrayLike} arr
  @param {function(T):boolean} pred
  @param {T=} implicit
  @return {?T}
  @template T
###
wzk.array.filterFirst = (arr, pred, implicit=null) ->
  if goog.array.isEmpty(arr)
    implicit
  else if pred(arr[0])
    arr[0]
  else
    wzk.array.filterFirst(wzk.array.rest(arr), pred, implicit)
