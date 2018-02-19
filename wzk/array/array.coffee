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

###*
 Calls a function for each element in an array and inserts the result into a new array.
 See {@link http://tinyurl.com/developer-mozilla-org-array-map}

 This function is safe, it means when anything then array is passed, it returns empty array.

 @param {IArrayLike<VALUE>|string|null} arr Array or array like object over which to iterate.
 @param {function(this:THIS, VALUE, number, ?): RESULT} f The function to call
     for every element. This function takes 3 arguments (the element,
     the index and the array) and should return something. The result will be
     inserted into a new array.
 @param {THIS=} opt_obj The object to be used as the value of 'this' within f.
 @return {!Array<RESULT>} a new array with the results from f.
 @template THIS, VALUE, RESULT
###
wzk.array.map = (arr, f, opt_obj) ->
  if goog.isArray(arr) then goog.array.map(arr, f, opt_obj) else []


###*
 Passes every element of an array into a function and accumulates the result.

 This function is safe, it means when anything then array is passed, it returns empty array.

 See {@link http://tinyurl.com/developer-mozilla-org-array-reduce}

 For example:
 var a = [1, 2, 3, 4];
 goog.array.reduce(a, function(r, v, i, arr) {return r + v;}, 0);
 returns 10

 @param {IArrayLike<T>|string} arr Array or array
     like object over which to iterate.
 @param {function(this:S, R, T, number, ?) : R} f The function to call for
     every element. This function
     takes 4 arguments (the function's previous result or the initial value,
     the value of the current array element, the current array index, and the
     array itself)
     function(previousValue, currentValue, index, array).
 @param {?} val The initial value to pass into the function on the first call.
 @param {S=} opt_obj  The object to be used as the value of 'this'
     within f.
 @return {R} Result of evaluating f repeatedly across the values of the array.
 @template T,S,R
###
wzk.array.reduce = (arr, f, val, opt_obj) ->
  if goog.isArray(arr) then goog.array.reduce(arr, f, val, opt_obj) else []


###*
  Whether the array is empty.
  This function is safe, it means when anything then array is passed, it returns false.

  @param {IArrayLike<?>|string|null} arr The array to test.
  @return {boolean} true if empty.
###
wzk.array.isEmpty = (arr) ->
  if goog.isArray(arr) then goog.array.isEmpty(arr) else true
