goog.provide 'wzk.array'

goog.require 'goog.array'


###*
  Returns new array of a given `arr` without last element
  @param {Array<(T|null)>} arr
  @return {Array<(T|null)>}
###
wzk.array.head = (arr) ->
  if arr.length < 2
    return arr
  else
    return Array.prototype.slice.call(arr, 0, arr.length - 1)


###*
  Returns last element of a given `arra`. If the array is empty, returns `implicit`.
  @param {IArrayLike<T>|string} arr
  @param {T} implicit
  @return {T}
  @template T
###
wzk.array.last = (arr, implicit = null) ->
  return if goog.array.isEmpty(arr) then implicit else goog.array.peek(arr)
