-- Lua Fun - a high-performance functional programming library for LuaJIT
--
-- Copyright (c) 2013-2017 Roman Tsisyk <roman@tsisyk.com>
--
-- Distributed under the MIT/X11 License. See COPYING.md for more details.

---
--- Lua Fun is a high-performance functional programming library for
--- LuaJIT. Most functions operate on iterators and compose into lazy
--- pipelines. An iterator is a `gen, param, state` triplet; see
--- [`fun.Iterator`] for the object-oriented interface and [`fun.Generator`],
--- [`fun.Iterable`], [`fun.Predicate`], [`fun.Comparator`] and
--- [`fun.Reducer`] for the supporting types.
---
--- ## Basic Functions
---
--- Create an iterator from a table, string or function: [`fun.wrap`],
--- [`fun.iter`], [`fun.each`], [`fun.for_each`], [`fun.foreach`].
---
--- ## Generators
---
--- Produce finite and infinite sequences: [`fun.range`],
--- [`fun.duplicate`], [`fun.replicate`], [`fun.xrepeat`],
--- [`fun.tabulate`], [`fun.zeros`], [`fun.ones`], [`fun.rands`].
---
--- ## Slicing
---
--- Take, drop and split subsequences: [`fun.nth`], [`fun.head`],
--- [`fun.car`], [`fun.tail`], [`fun.cdr`], [`fun.take_n`],
--- [`fun.take_while`], [`fun.take`], [`fun.drop_n`], [`fun.drop_while`],
--- [`fun.drop`], [`fun.split`], [`fun.split_at`], [`fun.span`].
---
--- ## Indexing
---
--- Find values and their positions: [`fun.index`], [`fun.index_of`],
--- [`fun.elem_index`], [`fun.indexes`], [`fun.elem_indexes`],
--- [`fun.indices`], [`fun.elem_indices`].
---
--- ## Filtering
---
--- Select or partition values: [`fun.filter`], [`fun.remove_if`],
--- [`fun.grep`], [`fun.partition`].
---
--- ## Reducing
---
--- Fold, test and summarize sequences: [`fun.foldl`], [`fun.reduce`],
--- [`fun.length`], [`fun.is_null`], [`fun.is_prefix_of`], [`fun.all`],
--- [`fun.every`], [`fun.any`], [`fun.some`], [`fun.sum`],
--- [`fun.product`], [`fun.min`], [`fun.minimum`], [`fun.min_by`],
--- [`fun.minimum_by`], [`fun.max`], [`fun.maximum`], [`fun.max_by`],
--- [`fun.maximum_by`], [`fun.totable`], [`fun.tomap`].
---
--- ## Transformations
---
--- Transform each value lazily: [`fun.map`], [`fun.enumerate`],
--- [`fun.intersperse`].
---
--- ## Compositions
---
--- Combine iterators: [`fun.zip`], [`fun.cycle`], [`fun.chain`].
---
--- ## Operators
---
--- Lua operators exposed as functions: [`fun.operator`], [`fun.op`].
---
--- See [`fun.OperatorTable`] for the full operator table.
local exports = {}

---@alias fun.Generator fun(param: any, state: any): any, ...
---@alias fun.Iterable fun.Iterator|table|string|fun.Generator
---@alias fun.Predicate fun(...): any
---@alias fun.Comparator fun(a: any, b: any): any
---@alias fun.Reducer fun(acc: any, ...: any): any

--- An iterator over a sequence of values.
---
--- An iterator is a `gen, param, state` triplet: a generating function, a
--- permanent parameter and a transient state.
---
--- Iterators returned by the library also support the object-oriented style
--- and expose the following methods: `unwrap`, `each` (`for_each`, `foreach`),
--- `nth`, `head` (`car`), `tail` (`cdr`), `take_n`, `take_while`, `take`,
--- `drop_n`, `drop_while`, `drop`, `split` (`span`, `split_at`), `index`
--- (`index_of`, `elem_index`), `indexes` (`elem_indexes`, `indices`,
--- `elem_indices`), `filter` (`remove_if`), `grep`, `partition`, `foldl`
--- (`reduce`), `length`, `is_null`, `is_prefix_of`, `all` (`every`), `any`
--- (`some`), `sum`, `product`, `min` (`minimum`), `min_by` (`minimum_by`),
--- `max` (`maximum`), `max_by` (`maximum_by`), `totable`, `tomap`, `map`,
--- `enumerate`, `intersperse`, `zip`, `cycle`, `chain`, `operator` (`op`).
---
---@class fun.Iterator
---@field gen fun.Generator @The underlying generator function
---@field param any @The generator parameter (usually a constant)
---@field state any @The current generator state
---@field unwrap fun(self: fun.Iterator): fun.Generator, any, any @the triplet
---@field each fun(self: fun.Iterator, fn: (fun(...): any)): nil
---@field nth fun(self: fun.Iterator, n: integer): any ...
---@field head fun(self: fun.Iterator): any ...
---@field tail fun(self: fun.Iterator): fun.Iterator, any, any
---@field take_n fun(self: fun.Iterator, n: number): fun.Iterator, any, any
---@field take_while fun(self: fun.Iterator, fn: fun.Predicate):
---    fun.Iterator, any, any
---@field take fun(self: fun.Iterator, n_or_fun: number|fun.Predicate):
---    fun.Iterator, any, any
---@field drop_n fun(self: fun.Iterator, n: number): fun.Iterator, any, any
---@field drop_while fun(self: fun.Iterator, fn: fun.Predicate):
---    fun.Iterator, any, any
---@field drop fun(self: fun.Iterator, n_or_fun: number|fun.Predicate):
---    fun.Iterator, any, any
---@field split fun(self: fun.Iterator, n_or_fun: number|fun.Predicate):
---    fun.Iterator, fun.Iterator, any, any
---@field index fun(self: fun.Iterator, x: any): number|nil
---@field indexes fun(self: fun.Iterator, x: any): fun.Iterator, any, any
---@field filter fun(self: fun.Iterator, fn: fun.Predicate):
---    fun.Iterator, any, any
---@field grep fun(self: fun.Iterator, fun_or_regexp: fun.Predicate|string):
---    fun.Iterator, any, any
---@field partition fun(self: fun.Iterator, fn: fun.Predicate):
---    fun.Iterator, fun.Iterator, any, any
---@field foldl fun(self: fun.Iterator, fn: fun.Reducer, start: any): any
---@field length fun(self: fun.Iterator): number
---@field is_null fun(self: fun.Iterator): boolean
---@field is_prefix_of fun(self: fun.Iterator, iter_y: fun.Iterable): boolean
---@field all fun(self: fun.Iterator, fn: fun.Predicate): boolean
---@field any fun(self: fun.Iterator, fn: fun.Predicate): boolean
---@field sum fun(self: fun.Iterator): number
---@field product fun(self: fun.Iterator): number
---@field min fun(self: fun.Iterator): any
---@field min_by fun(self: fun.Iterator, cmp: fun.Comparator): any
---@field max fun(self: fun.Iterator): any
---@field max_by fun(self: fun.Iterator, cmp: fun.Comparator): any
---@field totable fun(self: fun.Iterator): any[]
---@field tomap fun(self: fun.Iterator): table<any, any>
---@field map fun(self: fun.Iterator, fn: (fun(...): any)):
---    fun.Iterator, any, any
---@field enumerate fun(self: fun.Iterator): fun.Iterator, any, any
---@field intersperse fun(self: fun.Iterator, x: any): fun.Iterator, any, any
---@field zip fun(self: fun.Iterator, ...: fun.Iterable): fun.Iterator, any, any
---@field cycle fun(self: fun.Iterator): fun.Iterator, any, any
---@field chain fun(self: fun.Iterator, ...: fun.Iterable):
---    fun.Iterator, any, any
---@field operator fun.OperatorTable
---@field op fun.OperatorTable
---@type table<string, any>
local methods = {}

-- compatibility with Lua 5.1/5.2
---@type any
local unpack = rawget(table, "unpack") or unpack

-- table.maxn was removed in Lua 5.3+
local maxn = table.maxn or function(t)
    local maxn = 0.0
    for k in pairs(t) do
        if type(k) == "number" and k > maxn then
            maxn = k
        end
    end
    return maxn
end

--------------------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------------------

local return_if_not_empty = function(state_x, ...)
    if state_x == nil then
        return nil
    end
    return ...
end

local call_if_not_empty = function(fun, state_x, ...)
    if state_x == nil then
        return nil
    end
    return state_x, fun(...)
end

local function deepcopy(orig) -- used by cycle()
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
    else
        copy = orig
    end
    return copy
end

local iterator_mt = {
    -- usually called by for-in loop
    __call = function(self, param, state)
        return self.gen(param, state)
    end;
    __tostring = function(_self)
        return '<generator>'
    end;
    -- add all exported methods
    __index = methods;
}

---@param gen fun.Generator @the generator function
---@param param any @the generator parameter (usually a constant)
---@param state any @the initial generator state
--- A wrapped iterator and the param, state triplet
---@return fun.Iterator, any, any
local wrap = function(gen, param, state)
    return setmetatable({
        gen = gen,
        param = param,
        state = state
    }, iterator_mt), param, state
end
--- Wrap the gen, param, state triplet into an iterator object
exports.wrap = wrap

---@param self fun.Iterator @the iterator to unwrap
---@return fun.Generator, any, any @the underlying gen, param, state triplet
local unwrap = function(self)
    return self.gen, self.param, self.state
end
methods.unwrap = unwrap

--------------------------------------------------------------------------------
-- Basic Functions
--------------------------------------------------------------------------------

---@type fun.Generator
local nil_gen = function(_param, _state)
    return nil
end

---@param param string
---@param state integer
local string_gen = function(param, state)
    local state = state + 1
    if state > #param then
        return nil
    end
    local r = string.sub(param, state, state)
    return state, r
end

local ipairs_gen = ipairs({}) -- get the generating function from ipairs

local pairs_gen = pairs({ a = 0 }) -- get the generating function from pairs
local map_gen = function(tab, key)
    local key, value = pairs_gen(tab, key)
    return key, key, value
end

--- An iterable object: table, string, function or iterator
---@param obj fun.Iterable
---@param param any @a generator parameter
---@param state any @a generator state
---@return fun.Generator, any, any @the raw gen, param, state triplet
local rawiter = function(obj, param, state)
    assert(obj ~= nil, "invalid iterator")
    if type(obj) == "table" then
        local mt = getmetatable(obj);
        if mt ~= nil then
            if mt == iterator_mt then
                return obj.gen, obj.param, obj.state
            elseif mt.__ipairs ~= nil then
                return mt.__ipairs(obj)
            elseif mt.__pairs ~= nil then
                return mt.__pairs(obj)
            end
        end
        if #obj > 0 then
            -- array
            return ipairs(obj)
        else
            -- hash
            return map_gen, obj, nil
        end
    elseif (type(obj) == "function") then
        return obj, param, state
    elseif (type(obj) == "string") then
        if #obj == 0 then
            return nil_gen, nil, nil
        end
        return string_gen, obj, 0
    end
    error(string.format('object %s of type "%s" is not iterable',
          obj, type(obj)))
end

--- An iterable object: table, string, function or iterator
---@param obj fun.Iterable
---@param param any @a generator parameter
---@param state any @a generator state
--- A wrapped iterator and the param, state triplet
---@return fun.Iterator, any, any
---@overload fun(obj: fun.Iterable, param?: any, state?: any):
---    fun.Iterator, any, any
local iter = function(obj, param, state)
    return wrap(rawiter(obj, param, state))
end
---
--- Make `gen, param, state` iterator from the iterable object.
--- The function is a generalized version of `pairs` and `ipairs`.
---
--- The function distinguishes between arrays and maps using the `#obj > 0`
--- check to detect arrays. For arrays `ipairs` is used. For maps a modified
--- version of `pairs` is used that also returns keys. Userdata objects are
--- not supported.
---
--- For tables with the `__pairs` (for maps) or `__ipairs` (for arrays)
--- metamethod, the metamethod is called directly and the first three results
--- are used. This does not require the `LUAJIT_ENABLE_LUA52COMPAT` mode.
---
--- See [LuaJIT extensions](http://luajit.org/extensions.html) and
--- [Lua 5.2 ipairs](http://www.lua.org/manual/5.2/manual.html#pdf-ipairs).
---
--- All library iterators are suitable to use with Lua's `for .. in` loop.
---
---
--- Example:
--- ```lua
--- for _it, a in iter({1, 2, 3}) do print(a) end
--- -- 1
--- -- 2
--- -- 3
---
--- -- The iteration order over maps is unspecified.
--- for _it, k, v in iter({ a = 1, b = 2, c = 3}) do print(k, v) end
--- -- a 1
--- -- b 2
--- -- c 3
---
--- for _it, a in iter("abcde") do print(a) end
--- -- a
--- -- b
--- -- c
--- -- d
--- -- e
--- ```
---
--- The first loop variable `_it` stores an internal state of the iterator and
--- must be always ignored in loops:
---
--- ```lua
--- for _it, a, b in iter({ a = 1, b = 2, c = 3}) do print(a, b) end
--- -- _it is some internal iterator state - always ignore it
--- -- a, b are values returned from the iterator
--- ```
---
--- Simple iterators like `iter({1, 2, 3})` have simple states, whereas other
--- iterators like [zip](fun.html#fun.zip) or
--- [chain](fun.html#fun.chain) have complicated internal states whose
--- values are senseless for the end user.
---
--- Check out the [Under the Hood](../../under_the_hood.html) section for
--- more details.
---
--- There is also the possibility to supply custom iterators to the function:
---
--- ```lua
--- local function mypairs_gen(max, state)
---     if (state >= max) then
---         return nil
---     end
---     return state + 1, state + 1
--- end
---
--- local function mypairs(max)
---     return mypairs_gen, max, 0
--- end
---
--- for _it, a in iter(mypairs(10)) do print(a) end
--- -- 1
--- -- 2
--- -- 3
--- -- ...
--- -- 10
--- ```
---
--- Iterators can return multiple values.
---
--- Check out the [Under the Hood](../../under_the_hood.html) section for
--- more details.
exports.iter = iter

local method0 = function(fun)
    return function(self)
        return fun(self.gen, self.param, self.state)
    end
end

local method1 = function(fun)
    return function(self, arg1)
        return fun(arg1, self.gen, self.param, self.state)
    end
end

local method2 = function(fun)
    return function(self, arg1, arg2)
        return fun(arg1, arg2, self.gen, self.param, self.state)
    end
end

---@param fun function
---@return fun(obj: fun.Iterable): any
local export0 = function(fun)
    return function(gen, param, state)
        return fun(rawiter(gen, param, state))
    end
end

---@param fun function
---@return fun(arg1: any, obj: fun.Iterable): any
local export1 = function(fun)
    return function(arg1, gen, param, state)
        return fun(arg1, rawiter(gen, param, state))
    end
end

---@param fun function
---@return fun(arg1: any, arg2: any, obj: fun.Iterable): any
local export2 = function(fun)
    return function(arg1, arg2, gen, param, state)
        return fun(arg1, arg2, rawiter(gen, param, state))
    end
end

---@param fun fun(...): any @a function executed for each iteration value
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return nil
local each = function(fun, gen, param, state)
    repeat
        state = call_if_not_empty(fun, gen(param, state))
    until state == nil
end
methods.each = method1(each)
---
--- Execute the *fun* for each iteration value. The function is equivalent to
--- the code below:
---
--- ```lua
--- for _it, ... in iter(gen, param, state) do
---     fun(...)
--- end
--- ```
---
--- The function is used for its side effects. The implementation directly
--- applies *fun* to all iteration values without returning a new iterator, in
--- contrast to functions like [map](fun.html#fun.map).
---
---
--- Example:
--- ```lua
--- -- The iteration order over maps is unspecified.
--- each(print, { a = 1, b = 2, c = 3})
--- -- a 1
--- -- b 2
--- -- c 3
---
--- each(print, {1, 2, 3})
--- -- 1
--- -- 2
--- -- 3
--- ```
---
--- See also: [map](fun.html#fun.map), [reduce](fun.html#fun.reduce).
---@type fun(fn: (fun(...): any), obj: fun.Iterable): nil
exports.each = export1(each)
methods.for_each = methods.each
--- An alias for [each](fun.html#fun.each).
exports.for_each = exports.each
methods.foreach = methods.each
--- An alias for [each](fun.html#fun.each).
exports.foreach = exports.each

--------------------------------------------------------------------------------
-- Generators
--------------------------------------------------------------------------------

local range_gen = function(param, state)
    local stop, step = param[1], param[2]
    local state = state + step
    if state > stop then
        return nil
    end
    return state, state
end

local range_rev_gen = function(param, state)
    local stop, step = param[1], param[2]
    local state = state + step
    if state < stop then
        return nil
    end
    return state, state
end

---@param start? number @an endpoint of the interval (see below)
---@param stop? number @an endpoint of the interval (see below)
---@param step? number @a step
--- An iterator over the arithmetic progression
---@return fun.Iterator|fun.Generator, any, any
---@overload fun(stop: number):
---    fun.Iterator|fun.Generator, any, any
---@overload fun(start: number, stop: number, step?: number):
---    fun.Iterator|fun.Generator, any, any
local range = function(start, stop, step)
    if step == nil then
        if stop == nil then
            if start == 0 then
                return nil_gen, nil, nil
            end
            stop = start
            start = stop > 0 and 1 or -1
        end
        step = start <= stop and 1 or -1
    end

    assert(type(start) == "number", "start must be a number")
    assert(type(stop) == "number", "stop must be a number")
    assert(type(step) == "number", "step must be a number")
    assert(step ~= 0, "step must not be zero")

    if (step > 0) then
        return wrap(range_gen, {stop, step}, start - step)
    elseif (step < 0) then
        return wrap(range_rev_gen, {stop, step}, start - step)
    end
    -- NaN falls through here; return an empty triplet.
    return nil, nil, nil
end
---
--- The iterator to create arithmetic progressions. Iteration values are
--- generated within the closed interval `[start, stop]` (i.e. *stop* is
--- included). If the *start* argument is omitted, it defaults to `1`
--- (*stop* > 0) or to `-1` (*stop* < 0). If the *step* argument is omitted,
--- it defaults to `1` (*start* <= *stop*) or to `-1` (*start* > *stop*). If
--- *step* is positive, the last element is the largest `start + i * step`
--- less than or equal to *stop*; if *step* is negative, the last element is
--- the smallest `start + i * step` greater than or equal to *stop*. *step*
--- must not be zero (or else an error is raised). `range(0)` returns an empty
--- iterator.
---
---
--- Example:
--- ```lua
--- for _it, v in range(5) do print(v) end
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
---
--- for _it, v in range(-5) do print(v) end
--- -- -1
--- -- -2
--- -- -3
--- -- -4
--- -- -5
---
--- for _it, v in range(1, 6) do print(v) end
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
--- -- 6
---
--- for _it, v in range(0, 20, 5) do print(v) end
--- -- 0
--- -- 5
--- -- 10
--- -- 15
--- -- 20
---
--- for _it, v in range(0, 10, 3) do print(v) end
--- -- 0
--- -- 3
--- -- 6
--- -- 9
---
--- for _it, v in range(0, 1.5, 0.2) do print(v) end
--- -- 0
--- -- 0.2
--- -- 0.4
--- -- 0.6
--- -- 0.8
--- -- 1
--- -- 1.2
--- -- 1.4
---
--- for _it, v in range(0) do print(v) end
---
--- for _it, v in range(1) do print(v) end
--- -- 1
---
--- for _it, v in range(1, 0) do print(v) end
--- -- 1
--- -- 0
---
--- for _it, v in range(0, 10, 0) do print(v) end
--- -- error: step must not be zero
--- ```
exports.range = range

local duplicate_table_gen = function(param_x, state_x)
    return state_x + 1, unpack(param_x)
end

local duplicate_fun_gen = function(param_x, state_x)
    return state_x + 1, param_x(state_x)
end

local duplicate_gen = function(param_x, state_x)
    return state_x + 1, param_x
end

---@param ... any @objects to duplicate
--- An iterator that returns the values indefinitely
---@return fun.Iterator, any, any
---@overload fun(...): fun.Iterator, any, any
local duplicate = function(...)
    ---@diagnostic disable-next-line: unnecessary-if
    if select('#', ...) <= 1 then
        return wrap(duplicate_gen, select(1, ...), 0)
    else
        return wrap(duplicate_table_gen, {...}, 0)
    end
end
---
--- The iterator returns values over and over again indefinitely. All values
--- that passed to the iterator are returned as-is during the iteration.
---
---
--- Example:
--- ```lua
--- each(print, take(3, duplicate('a', 'b', 'c')))
--- -- a       b       c
--- -- a       b       c
--- -- a       b       c
---
--- each(print, take(3, duplicate('x')))
--- -- x
--- -- x
--- -- x
---
--- for _it, a, b, c, d, e in take(3, duplicate(1, 2, 'a', 3, 'b')) do
---     print(a, b, c, d, e)
--- end
--- -- 1       2       a       3       b
--- -- 1       2       a       3       b
--- -- 1       2       a       3       b
--- ```
exports.duplicate = duplicate
--- An alias for [duplicate](fun.html#fun.duplicate).
exports.replicate = duplicate
--- An alias for [duplicate](fun.html#fun.duplicate).
exports.xrepeat = duplicate

---@param fun fun(index: number): any @a unary generating function
--- An iterator that returns fun(0), fun(1), fun(2), ...
--- and so on indefinitely
---@return fun.Iterator, any, any
---@overload fun(fn: fun(index: number): any): fun.Iterator, any, any
local tabulate = function(fun)
    assert(type(fun) == "function")
    return wrap(duplicate_fun_gen, fun, 0)
end
---
--- The iterator that returns `fun(0)`, `fun(1)`, `fun(2)`, `...` values
--- indefinitely.
---
---
--- Example:
--- ```lua
--- each(print, take(5, tabulate(function(x) return 'a', 'b', 2*x end)))
--- -- a       b       0
--- -- a       b       2
--- -- a       b       4
--- -- a       b       6
--- -- a       b       8
---
--- each(print, take(5, tabulate(function(x) return x^2 end)))
--- -- 0
--- -- 1
--- -- 4
--- -- 9
--- -- 16
--- ```
exports.tabulate = tabulate

---@return fun.Iterator, any, any @an iterator that returns 0 indefinitely
---@overload fun(): fun.Iterator, any, any
local zeros = function()
    return wrap(duplicate_gen, 0, 0)
end
---
--- The iterator returns `0` indefinitely.
---
---
--- Example:
--- ```lua
--- each(print, take(5, zeros()))
--- -- 0
--- -- 0
--- -- 0
--- -- 0
--- -- 0
--- ```
exports.zeros = zeros

---@return fun.Iterator, any, any @an iterator that returns 1 indefinitely
---@overload fun(): fun.Iterator, any, any
local ones = function()
    return wrap(duplicate_gen, 1, 0)
end
---
--- The iterator that returns `1` indefinitely.
---
---
--- Example:
--- ```lua
--- each(print, take(5, ones()))
--- -- 1
--- -- 1
--- -- 1
--- -- 1
--- -- 1
--- ```
exports.ones = ones

local rands_gen = function(param_x, _state_x)
    return 0, math.random(param_x[1], param_x[2])
end

local rands_nil_gen = function(_param_x, _state_x)
    return 0, math.random()
end

---@param n? number @the upper bound, or the lower bound when m is given
---@param m? number @the upper bound (exclusive)
---@return fun.Iterator, any, any @an iterator over pseudo-random values
---@overload fun(n?: number, m?: number): fun.Iterator, any, any
local rands = function(n, m)
    if n == nil and m == nil then
        return wrap(rands_nil_gen, 0, 0)
    end
    assert(type(n) == "number", "invalid first arg to rands")
    if m == nil then
        m = n
        n = 0
    else
        assert(type(m) == "number", "invalid second arg to rands")
    end
    assert(n < m, "empty interval")
    return wrap(rands_gen, {n, m - 1}, 0)
end
---
--- The iterator returns random values using `math.random`. If the **n** and
--- **m** are set then the iterator returns pseudo-random integers in the
--- `[n, m)` interval (i.e. **m** is not included). If the **m** is not set
--- then the iterator generates pseudo-random integers in the `[0, n)`
--- interval. When called without arguments it returns pseudo-random real
--- numbers with uniform distribution in the interval `[0, 1)`.
---
--- **Warning:** This iterator is not pure-functional and may not work as
--- expected with some library functions.
---
---
--- Example:
--- ```lua
--- each(print, take(10, rands(10, 20)))
--- -- 19
--- -- 17
--- -- 11
--- -- 19
--- -- 12
--- -- 13
--- -- 14
--- -- 16
--- -- 10
--- -- 11
---
--- each(print, take(5, rands(10)))
--- -- 7
--- -- 6
--- -- 5
--- -- 9
--- -- 0
---
--- each(print, take(5, rands()))
--- -- 0.79420629243124
--- -- 0.69885246563716
--- -- 0.5901037417281
--- -- 0.7532286166836
--- -- 0.080971251199854
--- ```
exports.rands = rands

--------------------------------------------------------------------------------
-- Slicing
--------------------------------------------------------------------------------

--- A sequential number (indexed starting from `1`, like Lua tables)
---@param n integer
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any ... @the n-th element, or nil
local nth = function(n, gen_x, param_x, state_x)
    assert(n > 0, "invalid first argument to nth")
    -- An optimization for arrays and strings
    if gen_x == ipairs_gen then
        return param_x[state_x + n]
    elseif gen_x == string_gen then
        if state_x + n <= #param_x then
            return string.sub(param_x, state_x + n, state_x + n)
        else
            return nil
        end
    end
    for _=1,n-1,1 do
        state_x = gen_x(param_x, state_x)
        if state_x == nil then
            return nil
        end
    end
    return return_if_not_empty(gen_x(param_x, state_x))
end
methods.nth = method1(nth)
---
--- This function returns the **n**-th element of the `gen, param, state`
--- iterator. If the iterator does not have **n** items then `nil` is returned.
---
--- This function is optimized for basic array and string iterators and has
--- `O(1)` complexity for these cases.
---
---
--- Example:
--- ```lua
--- print(nth(2, range(5)))
--- -- 2
---
--- print(nth(10, range(5)))
--- -- nil
---
--- print(nth(2, {"a", "b", "c", "d", "e"}))
--- -- b
---
--- print(nth(2, drop_n(3, {"a", "b", "c", "d", "e"})))
--- -- e
---
--- print(nth(2, enumerate({"a", "b", "c", "d", "e"})))
--- -- 2 b
--- ```
---@type fun(n: integer, obj: fun.Iterable): any ...
exports.nth = export1(nth)

local head_call = function(state, ...)
    if state == nil then
        error("head: iterator is empty")
    end
    return ...
end

---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return any ... @the first element; error if empty
local head = function(gen, param, state)
    return head_call(gen(param, state))
end
methods.head = method0(head)
---
--- Extract the first element of the `gen, param, state` iterator.
--- If the iterator is empty then an error is raised.
---
---
--- Example:
--- ```lua
--- print(head({"a", "b", "c", "d", "e"}))
--- -- a
---
--- print(head({}))
--- -- error: head: iterator is empty
---
--- print(head(range(0)))
--- -- error: head: iterator is empty
---
--- print(head(enumerate({"a", "b"})))
--- -- 1 a
--- ```
---@type fun(obj: fun.Iterable): any ...
exports.head = export0(head)
--- An alias for [head](fun.html#fun.head).
exports.car = exports.head
methods.car = methods.head

---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @the iterator without its first element
local tail = function(gen, param, state)
    state = gen(param, state)
    if state == nil then
        return wrap(nil_gen, nil, nil)
    end
    return wrap(gen, param, state)
end
methods.tail = method0(tail)
---
--- Return a copy of the `gen, param, state` iterator without its first
--- element. If the iterator is empty then an empty iterator is returned.
---
---
--- Example:
--- ```lua
--- each(print, tail({"a", "b", "c", "d", "e"}))
--- -- b
--- -- c
--- -- d
--- -- e
---
--- each(print, tail({}))
---
--- each(print, tail(range(0)))
---
--- each(print, tail(enumerate({"a", "b", "c"})))
--- -- 2 b
--- -- 3 c
--- ```
---@type fun(obj: fun.Iterable): fun.Iterator, any, any
exports.tail = export0(tail)
--- An alias for [tail](fun.html#fun.tail).
exports.cdr = exports.tail
methods.cdr = methods.tail

local take_n_gen_x = function(i, state_x, ...)
    if state_x == nil then
        return nil
    end
    return {i, state_x}, ...
end

local take_n_gen = function(param, state)
    local n, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    if i >= n then
        return nil
    end
    return take_n_gen_x(i + 1, gen_x(param_x, state_x))
end

---@param n number @a number of elements to take
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
--- An iterator on the subsequence of the first n elements
---@return fun.Iterator, any, any
local take_n = function(n, gen, param, state)
    assert(n >= 0, "invalid first argument to take_n")
    return wrap(take_n_gen, {n, gen, param}, {0, state})
end
methods.take_n = method1(take_n)
---
--- Return an iterator over the first **n** elements of the source iterator.
---
--- Example:
--- ```lua
--- each(print, take_n(5, range(10)))
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
---
--- each(print, take_n(5, enumerate(duplicate('x'))))
--- -- 1 x
--- -- 2 x
--- -- 3 x
--- -- 4 x
--- -- 5 x
--- ```
---@type fun(n: number, obj: fun.Iterable): fun.Iterator, any, any
exports.take_n = export1(take_n)

local take_while_gen_x = function(fun, state_x, ...)
    if state_x == nil or not fun(...) then
        return nil
    end
    return state_x, ...
end

local take_while_gen = function(param, state_x)
    local fun, gen_x, param_x = param[1], param[2], param[3]
    return take_while_gen_x(fun, gen_x(param_x, state_x))
end

---@param fun fun.Predicate @a predicate over iteration values
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
--- The longest prefix of elements that satisfy the predicate
---@return fun.Iterator, any, any
local take_while = function(fun, gen, param, state)
    assert(type(fun) == "function", "invalid first argument to take_while")
    return wrap(take_while_gen, {fun, gen, param}, state)
end
methods.take_while = method1(take_while)
---
--- Return an iterator over the longest prefix of elements that satisfy the
--- predicate.
---
--- Example:
--- ```lua
--- each(print, take_while(function(x) return x < 5 end, range(10)))
--- -- 1
--- -- 2
--- -- 3
--- -- 4
---
--- each(print, take_while(function(i, a) return i ~= a end,
---     enumerate({5, 3, 4, 4, 2})))
--- -- 1       5
--- -- 2       3
--- -- 3       4
--- ```
---
--- See also: [filter](fun.html#fun.filter).
---@type fun(fn: fun.Predicate, obj: fun.Iterable): fun.Iterator, any, any
exports.take_while = export1(take_while)

--- A number of elements or a predicate (take_n or take_while)
---@param n_or_fun number|fun.Predicate
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
--- An iterator on the subsequence of the first elements
---@return fun.Iterator, any, any
local take = function(n_or_fun, gen, param, state)
    if type(n_or_fun) == "number" then
        return take_n(n_or_fun, gen, param, state)
    else
        return take_while(n_or_fun, gen, param, state)
    end
end
methods.take = method1(take)
--- An alias for [take_n](fun.html#fun.take_n) and
--- [take_while](fun.html#fun.take_while) that autodetects the required function
--- based on the `n_or_fun` type.
---@type fun(n_or_fun: number|fun.Predicate,
---    obj: fun.Iterable): fun.Iterator, any, any
exports.take = export1(take)

---@param n number @the number of elements to drop
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator @the iterator after skipping n elements
---@return any @the generator parameter
---@return any @the generator state
local drop_n = function(n, gen, param, state)
    assert(n >= 0, "invalid first argument to drop_n")
    for _=1,n,1 do
        state = gen(param, state)
        if state == nil then
            return wrap(nil_gen, nil, nil)
        end
    end
    return wrap(gen, param, state)
end
methods.drop_n = method1(drop_n)
---
--- Return an iterator with the first **n** elements of the source iterator
--- dropped.
---
--- Example:
--- ```lua
--- each(print, drop_n(2, range(5)))
--- -- 3
--- -- 4
--- -- 5
---
--- each(print, drop_n(2, enumerate({'a', 'b', 'c', 'd', 'e'})))
--- -- 3       c
--- -- 4       d
--- -- 5       e
--- ```
---@type fun(n: number, obj: fun.Iterable): fun.Iterator, any, any
exports.drop_n = export1(drop_n)

-- Unpack values from param[3] on the first iteration, then return
-- values from the provided iterator.
--
-- A generator function for drop_while().
local drop_while_gen = function(param, state)
    local results = param[3]
    if not results then
        return param[1](param[2], state)
    else
        param[3] = nil
        return state, unpack(results, 1, maxn(results))
    end
end

-- Checks if drop_while should continue skipping. If iterator is not exhausted
-- and skipping is over, elements returned by iterator are wrapped into a table
-- and returned as the second return value. Note that a table is created only
-- once, on the last iteration, for the sake of performance.
local drop_while_x = function(fun, state_x, ...)
    if state_x ~= nil and not fun(...) then
        return state_x, {...}
    end
    return state_x
end

---@param fun fun.Predicate @a predicate over iteration values
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return fun.Iterator @the iterator after skipping matching elements
---@return any @the generator parameter
---@return any @the generator state
local drop_while = function(fun, gen_x, param_x, state_x)
    assert(type(fun) == "function", "invalid first argument to drop_while")
    local pivot = nil
    while state_x ~= nil and pivot == nil do
        state_x, pivot = drop_while_x(fun, gen_x(param_x, state_x))
    end
    if state_x == nil then
        return wrap(nil_gen, nil, nil)
    end
    return wrap(drop_while_gen, {gen_x, param_x, pivot}, state_x)
end
methods.drop_while = method1(drop_while)
---
--- Return an iterator with the leading elements that satisfy the predicate
--- dropped.
---
--- Example:
--- ```lua
--- each(print, drop_while(function(x) return x < 5 end, range(10)))
--- -- 5
--- -- 6
--- -- 7
--- -- 8
--- -- 9
--- -- 10
--- ```
---
--- See also: [filter](fun.html#fun.filter).
---@type fun(fn: fun.Predicate, obj: fun.Iterable): fun.Iterator, any, any
exports.drop_while = export1(drop_while)

--- A number of elements or a predicate (drop_n or drop_while)
---@param n_or_fun number|fun.Predicate
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return fun.Iterator @the iterator after skipping elements
---@return any @the generator parameter
---@return any @the generator state
local drop = function(n_or_fun, gen_x, param_x, state_x)
    if type(n_or_fun) == "number" then
        return drop_n(n_or_fun, gen_x, param_x, state_x)
    else
        return drop_while(n_or_fun, gen_x, param_x, state_x)
    end
end
methods.drop = method1(drop)
--- An alias for [drop_n](fun.html#fun.drop_n) and
--- [drop_while](fun.html#fun.drop_while) that autodetects the required function
--- based on the `n_or_fun` type.
---@type fun(n_or_fun: number|fun.Predicate,
---    obj: fun.Iterable): fun.Iterator, any, any
exports.drop = export1(drop)

--- A number of elements or a predicate (span)
---@param n_or_fun number|fun.Predicate
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return fun.Iterator @the prefix iterator
---@return fun.Iterator @the remainder iterator
---@return any @the remainder parameter
---@return any @the remainder state
local split = function(n_or_fun, gen_x, param_x, state_x)
    return (take(n_or_fun, gen_x, param_x, state_x)),
           drop(n_or_fun, gen_x, param_x, state_x)
end
methods.split = method1(split)
--- An alias for [span](fun.html#fun.span).
---@type fun(n_or_fun: number|fun.Predicate,
---    obj: fun.Iterable): fun.Iterator, fun.Iterator, any, any
exports.split = export1(split)
methods.split_at = methods.split
--- An alias for [span](fun.html#fun.span).
exports.split_at = exports.split
methods.span = methods.split
---
--- Return an iterator pair where the first operates on the longest prefix
--- (possibly empty) of the `gen, param, state` iterator of elements that
--- satisfy **predicate** and second operates the remainder of the
--- `gen, param, state` iterator. Equivalent to:
---
--- ```lua
--- return take(n_or_fun, gen_x, param_x, state_x),
---        drop(n_or_fun, gen_x, param_x, state_x)
--- ```
---
--- **Note:** `{gen, param, state}` must be pure functional to work properly
--- with the function.
---
--- [split](fun.html#fun.split) and [split_at](fun.html#fun.split_at)
--- are aliases of span.
---
---
--- Example:
--- ```lua
--- each(print, zip(span(function(x) return x < 5 end, range(10))))
--- -- 1       5
--- -- 2       6
--- -- 3       7
--- -- 4       8
---
--- each(print, zip(span(5, range(10))))
--- -- 1       6
--- -- 2       7
--- -- 3       8
--- -- 4       9
--- -- 5       10
--- ```
---
--- See also: [partition](fun.html#fun.partition).
exports.span = exports.split

--------------------------------------------------------------------------------
-- Indexing
--------------------------------------------------------------------------------

---@param x any @a value to find
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return number|nil @the position of the first element that equals x, or nil
local index = function(x, gen, param, state)
    local i = 1
    for _k, r in gen, param, state do
        if r == x then
            return i
        end
        i = i + 1
    end
    return nil
end
methods.index = method1(index)
---
--- Return the position of the first element that equals `x` (using `==`),
--- or `nil` if there is no such element. The position is 1-based.
---
--- [index_of](fun.html#fun.index_of) and [elem_index](fun.html#fun.elem_index)
--- are aliases of index.
---
---
--- Example:
--- ```lua
--- print(index(2, range(0)))
--- -- nil
---
--- print(index("b", {"a", "b", "c", "d", "e"}))
--- -- 2
--- ```
---@type fun(x: any, obj: fun.Iterable): number|nil
exports.index = export1(index)
methods.index_of = methods.index
--- An alias for [index](fun.html#fun.index).
exports.index_of = exports.index
methods.elem_index = methods.index
--- An alias for [index](fun.html#fun.index).
exports.elem_index = exports.index

local indexes_gen = function(param, state)
    local x, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    local r
    while true do
        state_x, r = gen_x(param_x, state_x)
        if state_x == nil then
            return nil
        end
        i = i + 1
        if r == x then
            return {i, state_x}, i
        end
    end
end

---@param x any @a value to find
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
--- An iterator over the positions of elements that equal x
---@return fun.Iterator, any, any
local indexes = function(x, gen, param, state)
    return wrap(indexes_gen, {x, gen, param}, {0, state})
end
methods.indexes = method1(indexes)
---
--- Return an iterator over the positions of elements that equal `x`.
---
--- [indices](fun.html#fun.indices),
--- [elem_indexes](fun.html#fun.elem_indexes) and
--- [elem_indices](fun.html#fun.elem_indices) are aliases of indexes.
---
---
--- Example:
--- ```lua
--- each(print, indexes("a", {"a", "b", "c", "d", "e", "a", "b", "a", "a"}))
--- -- 1
--- -- 6
--- -- 8
--- -- 9
--- ```
---
--- See also: [filter](fun.html#fun.filter).
---@type fun(x: any, obj: fun.Iterable): fun.Iterator, any, any
exports.indexes = export1(indexes)
methods.elem_indexes = methods.indexes
--- An alias for [indexes](fun.html#fun.indexes).
exports.elem_indexes = exports.indexes
methods.indices = methods.indexes
--- An alias for [indexes](fun.html#fun.indexes).
exports.indices = exports.indexes
methods.elem_indices = methods.indexes
--- An alias for [indexes](fun.html#fun.indexes).
exports.elem_indices = exports.indexes

--------------------------------------------------------------------------------
-- Filtering
--------------------------------------------------------------------------------

local filter1_gen = function(fun, gen_x, param_x, state_x, a)
    while true do
        if state_x == nil or fun(a) then break; end
        state_x, a = gen_x(param_x, state_x)
    end
    return state_x, a
end

-- call each other
local filterm_gen
local filterm_gen_shrink = function(fun, gen_x, param_x, state_x)
    ---@diagnostic disable-next-line: need-check-nil
    return filterm_gen(fun, gen_x, param_x, gen_x(param_x, state_x))
end

filterm_gen = function(fun, gen_x, param_x, state_x, ...)
    if state_x == nil then
        return nil
    end
    if fun(...) then
        return state_x, ...
    end
    return filterm_gen_shrink(fun, gen_x, param_x, state_x)
end

local filter_detect = function(fun, gen_x, param_x, state_x, ...)
    if select('#', ...) < 2 then
        return filter1_gen(fun, gen_x, param_x, state_x, ...)
    else
        return filterm_gen(fun, gen_x, param_x, state_x, ...)
    end
end

local filter_gen = function(param, state_x)
    local fun, gen_x, param_x = param[1], param[2], param[3]
    return filter_detect(fun, gen_x, param_x, gen_x(param_x, state_x))
end

---@param fun fun.Predicate @a predicate to filter the iterator
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
--- A new iterator of elements that satisfy the predicate
---@return fun.Iterator, any, any
local filter = function(fun, gen, param, state)
    return wrap(filter_gen, {fun, gen, param}, state)
end
methods.filter = method1(filter)
--- Return a new iterator of those elements that satisfy the predicate **fun**.
---
--- **Note:** Multireturn iterators are supported but can cause performance
--- regressions.
---
--- [remove_if](fun.html#fun.remove_if) is an alias of filter.
---
---
--- Example:
--- ```lua
--- each(print, filter(function(x) return x % 3 == 0 end, range(10)))
--- -- 3
--- -- 6
--- -- 9
---
--- each(print, take(5, filter(function(i, x) return i % 3 == 0 end,
---     enumerate(duplicate('x')))))
--- -- 3       x
--- -- 6       x
--- -- 9       x
--- -- 12      x
--- -- 15      x
--- ```
---
--- See also: [take_while](fun.html#fun.take_while) and
--- [drop_while](fun.html#fun.drop_while).
---@type fun(fn: fun.Predicate, obj: fun.Iterable): fun.Iterator, any, any
exports.filter = export1(filter)
methods.remove_if = methods.filter
--- An alias for [filter](fun.html#fun.filter).
exports.remove_if = exports.filter

--- A predicate or a Lua regular expression string
---@param fun_or_regexp fun.Predicate|string
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @a new iterator of matching elements
local grep = function(fun_or_regexp, gen, param, state)
    local fun = fun_or_regexp
    if type(fun_or_regexp) == "string" then
        fun = function(x) return string.find(x, fun_or_regexp) ~= nil end
    end
    ---@cast fun fun.Predicate
    return filter(fun, gen, param, state)
end
methods.grep = method1(grep)
--- Filter the iterator by a regular expression or a predicate.
---
--- If `fun_or_regexp` is a string then the parameter is used as a
--- regular expression to build a filtering predicate. Otherwise the function is
--- just an alias for [filter](fun.html#fun.filter). Equivalent to:
---
--- ```lua
--- local fun = fun_or_regexp
--- if type(fun_or_regexp) == "string" then
---     fun = function(x) return string.find(x, fun_or_regexp) ~= nil end
--- end
--- return filter(fun, gen, param, state)
--- ```
---
---
--- Example:
--- ```lua
--- local lines_to_grep = {
---     [[Emily]],
---     [[Chloe]],
---     [[Megan]],
---     [[Jessica]],
---     [[Emma]],
---     [[Sarah]],
---     [[Elizabeth]],
---     [[Sophie]],
---     [[Olivia]],
---     [[Lauren]]
--- }
---
--- each(print, grep("^Em", lines_to_grep))
--- -- Emily
--- -- Emma
---
--- each(print, grep(function(x) return x % 3 == 0 end, range(10)))
--- -- 3
--- -- 6
--- -- 9
--- ```
---@type fun(fun_or_regexp: fun.Predicate|string,
---    obj: fun.Iterable): fun.Iterator, any, any
exports.grep = export1(grep)

---@param fun fun.Predicate @a predicate over iteration values
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator @an iterator of matching elements
---@return fun.Iterator @an iterator of non-matching elements
---@return any @the non-matching iterator parameter
---@return any @the non-matching iterator state
local partition = function(fun, gen, param, state)
    local neg_fun = function(...)
        return not fun(...)
    end
    return (filter(fun, gen, param, state)),
           filter(neg_fun, gen, param, state)
end
methods.partition = method1(partition)
---
--- Return two iterators where elements do and do not satisfy the predicate.
---
--- Equivalent to:
---
--- ```lua
--- return filter(fun, gen, param, state),
---        filter(function(...) return not fun(...) end, gen, param, state)
--- ```
---
--- The function makes a clone of the source iterator. It is especially
--- useful together with functions that accept multiple iterators, such as
--- [zip](fun.html#fun.zip).
---
--- **Note:** `{gen, param, state}` must be pure functional to work properly
--- with the function.
---
---
--- Example:
--- ```lua
--- each(print, zip(partition(function(i, x) return i % 3 == 0 end, range(10))))
--- -- 3       1
--- -- 6       2
--- -- 9       4
--- ```
---
--- See also: [span](fun.html#fun.span).
---@type fun(fn: fun.Predicate,
---    obj: fun.Iterable): fun.Iterator, fun.Iterator, any, any
exports.partition = export1(partition)

--------------------------------------------------------------------------------
-- Reducing
--------------------------------------------------------------------------------

local foldl_call = function(fun, start, state, ...)
    if state == nil then
        return nil, start
    end
    return state, fun(start, ...)
end

---@param fun fun.Reducer @an accumulating function
--- An initial value that passed to **fun** on the first iteration
---@param start any
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any @the accumulated value
local foldl = function(fun, start, gen_x, param_x, state_x)
    while true do
        state_x, start = foldl_call(fun, start, gen_x(param_x, state_x))
        if state_x == nil then
            break;
        end
    end
    return start
end
methods.foldl = method2(foldl)
---
--- The function reduces the iterator from left to right using the binary
--- operator **fun** and the initial value **start**. Equivalent to:
---
--- ```lua
--- local val = start
--- for _k, ... in gen_x, param_x, state_x do
---     val = fun(val, ...)
--- end
--- return val
--- ```
---
--- [reduce](fun.html#fun.reduce) is an alias of foldl.
---
---
--- Example:
--- ```lua
--- print(foldl(function(acc, x) return acc + x end, 0, range(5)))
--- -- 15
---
--- print(foldl(operator.add, 0, range(5)))
--- -- 15
---
--- print(foldl(function(acc, x, y) return acc + x * y end, 0,
---     zip(range(1, 5), {4, 3, 2, 1})))
--- -- 20
--- ```
---@type fun(fn: fun.Reducer, start: any, obj: fun.Iterable): any
exports.foldl = export2(foldl)
methods.reduce = methods.foldl
--- An alias for [foldl](fun.html#fun.foldl).
exports.reduce = exports.foldl

---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return number @the number of elements in the iterator
local length = function(gen, param, state)
    if gen == ipairs_gen or gen == string_gen then
        return #param - state
    end
    local len = 0
    repeat
        state = gen(param, state)
        len = len + 1
    until state == nil
    return len - 1
end
methods.length = method0(length)
--- Return a number of elements in the iterator.
---
--- The function is equivalent to #obj for basic array and string iterators.
---
--- **Note:** This function has `O(n)` complexity for all iterators except
--- basic array and string iterators, where it has `O(1)` complexity.
---
--- **Warning:** An attempt to call this function on an infinite iterator will
--- result in an infinite loop.
---
---
--- Example:
--- ```lua
--- print(length({"a", "b", "c", "d", "e"}))
--- -- 5
---
--- print(length(drop_n(3, {"a", "b", "c", "d", "e"})))
--- -- 2
---
--- print(length({}))
--- -- 0
---
--- print(length(range(0)))
--- -- 0
--- ```
---@type fun(obj: fun.Iterable): number
exports.length = export0(length)

---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return boolean @true when the iterator is empty or finished, false otherwise
local is_null = function(gen, param, state)
    return gen(param, deepcopy(state)) == nil
end
methods.is_null = method0(is_null)
---
--- Return true when the iterator is empty or finished, and false otherwise.
---
---
--- Example:
--- ```lua
--- print(is_null({"a", "b", "c", "d", "e"}))
--- -- false
---
--- print(is_null({}))
--- -- true
---
--- print(is_null(range(0)))
--- -- true
--- ```
---@type fun(obj: fun.Iterable): boolean
exports.is_null = export0(is_null)

---@param iter_x fun.Iterable @the first iterator
---@param iter_y fun.Iterable @the second iterator
---@return boolean @true if the first iterator is a prefix of the second
local is_prefix_of = function(iter_x, iter_y)
    local gen_x, param_x, state_x = rawiter(iter_x)
    local gen_y, param_y, state_y = rawiter(iter_y)
    ---@cast gen_x fun.Generator
    ---@cast gen_y fun.Generator

    local r_x, r_y
    repeat
        state_x, r_x = gen_x(param_x, state_x)
        if state_x == nil then
            return true
        end

        state_y, r_y = gen_y(param_y, state_y)
    until state_y == nil or r_x ~= r_y

    return false
end
methods.is_prefix_of = is_prefix_of
--- Return `true` if the first iterator is a prefix of the second, and false
--- otherwise.
---
---
--- Example:
--- ```lua
--- print(is_prefix_of({"a"}, {"a", "b", "c"}))
--- -- true
---
--- print(is_prefix_of(range(6), range(5)))
--- -- false
--- ```
exports.is_prefix_of = is_prefix_of

---@param fun fun.Predicate @a predicate
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return boolean @true if all iteration values satisfy the predicate
local all = function(fun, gen_x, param_x, state_x)
    local r
    repeat
        state_x, r = call_if_not_empty(fun, gen_x(param_x, state_x))
    until state_x == nil or not r
    return state_x == nil
end
methods.all = method1(all)
--- Return true if all return values of the iterator satisfy the predicate
--- **fun**.
---
--- [every](fun.html#fun.every) is an alias of all.
---
---
--- Example:
--- ```lua
--- print(all(function(x) return x end, {true, true, true, true}))
--- -- true
---
--- print(all(function(x) return x end, {true, true, true, false}))
--- -- false
--- ```
---@type fun(fn: fun.Predicate, obj: fun.Iterable): boolean
exports.all = export1(all)
methods.every = methods.all
--- An alias for [all](fun.html#fun.all).
exports.every = exports.all

---@param fun fun.Predicate @a predicate
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return boolean @true if at least one iteration value satisfies the predicate
local any = function(fun, gen_x, param_x, state_x)
    local r
    repeat
        state_x, r = call_if_not_empty(fun, gen_x(param_x, state_x))
    until state_x == nil or r
    return not not r
end
methods.any = method1(any)
--- Return true if at least one return value of the iterator satisfies the
--- predicate **fun**. The iteration stops on the first such value. Therefore,
--- infinite iterators that have at least one satisfying value might work.
---
--- [some](fun.html#fun.some) is an alias of any.
---
---
--- Example:
--- ```lua
--- print(any(function(x) return x end, {false, false, false, false}))
--- -- false
---
--- print(any(function(x) return x end, {false, false, false, true}))
--- -- true
--- ```
---@type fun(fn: fun.Predicate, obj: fun.Iterable): boolean
exports.any = export1(any)
methods.some = methods.any
--- An alias for [any](fun.html#fun.any).
exports.some = exports.any

---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return number @the sum of all iteration values
local sum = function(gen, param, state)
    local s = 0
    local r = 0
    repeat
        s = s + r
        state, r = gen(param, state)
    until state == nil
    return s
end
methods.sum = method0(sum)
--- Sum up all iteration values. An optimized alias for
--- [foldl](fun.html#fun.foldl):
---
--- ```lua
--- foldl(operator.add, 0, gen, param, state)
--- ```
---
--- For an empty iterator `0` is returned.
---
---
--- Example:
--- ```lua
--- print(sum(range(5)))
--- -- 15
--- ```
---@type fun(obj: fun.Iterable): number
exports.sum = export0(sum)

---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return number @the product of all iteration values
local product = function(gen, param, state)
    local p = 1
    local r = 1
    repeat
        p = p * r
        state, r = gen(param, state)
    until state == nil
    return p
end
methods.product = method0(product)
--- Multiply all iteration values. An optimized alias for
--- [foldl](fun.html#fun.foldl):
---
--- ```lua
--- foldl(operator.mul, 1, gen, param, state)
--- ```
---
--- For an empty iterator `1` is returned.
---
---
--- Example:
--- ```lua
--- print(product(range(1, 5)))
--- -- 120
--- ```
---@type fun(obj: fun.Iterable): number
exports.product = export0(product)

local min_cmp = function(m, n)
    if n < m then return n else return m end
end

local max_cmp = function(m, n)
    if n > m then return n else return m end
end

---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return any @the minimum value; an error is raised if the iterator is empty
local min = function(gen, param, state)
    local state, m = gen(param, state)
    if state == nil then
        error("min: iterator is empty")
    end

    local cmp
    if type(m) == "number" then
        -- An optimization: use math.min for numbers
        cmp = math.min
    else
        cmp = min_cmp
    end

    for _, r in gen, param, state do
        m = cmp(m, r)
    end
    return m
end
methods.min = method0(min)
--- Return a minimum value from the iterator using `math.min` or `<` for
--- numbers and other types respectively. The iterator must be non-null,
--- otherwise an error is raised.
---
--- [minimum](fun.html#fun.minimum) is an alias of min.
---
---
--- Example:
--- ```lua
--- print(min(range(1, 10, 1)))
--- -- 1
---
--- print(min({"f", "d", "c", "d", "e"}))
--- -- c
---
--- print(min({}))
--- -- error: min: iterator is empty
--- ```
---@type fun(obj: fun.Iterable): any
exports.min = export0(min)
methods.minimum = methods.min
--- An alias for [min](fun.html#fun.min).
exports.minimum = exports.min

---@param cmp fun.Comparator @a function used as the comparison operator
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any @the minimum value; an error is raised if the iterator is empty
local min_by = function(cmp, gen_x, param_x, state_x)
    local state_x, m = gen_x(param_x, state_x)
    if state_x == nil then
        error("min: iterator is empty")
    end

    for _, r in gen_x, param_x, state_x do
        m = cmp(m, r)
    end
    return m
end
methods.min_by = method1(min_by)
--- Return a minimum value from the iterator using the **cmp** function to
--- compare two values. It must return the lesser of its arguments. The
--- iterator must be non-null, otherwise an error is raised.
---
--- [minimum_by](fun.html#fun.minimum_by) is an alias of min_by.
---
---
--- Example:
--- ```lua
--- local function shorter(a, b) if #a < #b then return a else return b end end
--- print(min_by(shorter, {"lua", "luajit", "c"}))
--- -- c
--- ```
---@type fun(fn: fun.Comparator, obj: fun.Iterable): any
exports.min_by = export1(min_by)
methods.minimum_by = methods.min_by
--- An alias for [min_by](fun.html#fun.min_by).
exports.minimum_by = exports.min_by

---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any @the maximum value; an error is raised if the iterator is empty
local max = function(gen_x, param_x, state_x)
    local state_x, m = gen_x(param_x, state_x)
    if state_x == nil then
        error("max: iterator is empty")
    end

    local cmp
    if type(m) == "number" then
        -- An optimization: use math.max for numbers
        cmp = math.max
    else
        cmp = max_cmp
    end

    for _, r in gen_x, param_x, state_x do
        m = cmp(m, r)
    end
    return m
end
methods.max = method0(max)
--- Return a maximum value from the iterator using `math.max` or `>` for
--- numbers and other types respectively. The iterator must be non-null,
--- otherwise an error is raised.
---
--- [maximum](fun.html#fun.maximum) is an alias of max.
---
---
--- Example:
--- ```lua
--- print(max(range(1, 10, 1)))
--- -- 10
---
--- print(max({"f", "d", "c", "d", "e"}))
--- -- f
---
--- print(max({}))
--- -- error: max: iterator is empty
--- ```
---@type fun(obj: fun.Iterable): any
exports.max = export0(max)
methods.maximum = methods.max
--- An alias for [max](fun.html#fun.max).
exports.maximum = exports.max

---@param cmp fun.Comparator @a function used as the comparison operator
---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any @the maximum value; an error is raised if the iterator is empty
local max_by = function(cmp, gen_x, param_x, state_x)
    local state_x, m = gen_x(param_x, state_x)
    if state_x == nil then
        error("max: iterator is empty")
    end

    for _, r in gen_x, param_x, state_x do
        m = cmp(m, r)
    end
    return m
end
methods.max_by = method1(max_by)
--- Return a maximum value from the iterator using the **cmp** function to
--- compare two values. It must return the greater of its arguments. The
--- iterator must be non-null, otherwise an error is raised.
---
--- [maximum_by](fun.html#fun.maximum_by) is an alias of max_by.
---
---
--- Example:
--- ```lua
--- local function longer(a, b) if #a > #b then return a else return b end end
--- print(max_by(longer, {"lua", "luajit", "c"}))
--- -- luajit
--- ```
---@type fun(fn: fun.Comparator, obj: fun.Iterable): any
exports.max_by = export1(max_by)
methods.maximum_by = methods.max_by
--- An alias for [max_by](fun.html#fun.max_by).
exports.maximum_by = exports.max_by

---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return any[] @a new table (array) with all iteration values
local totable = function(gen_x, param_x, state_x)
    local tab, val = {}
    while true do
        state_x, val = gen_x(param_x, state_x)
        if state_x == nil then
            break
        end
        table.insert(tab, val)
    end
    return tab
end
methods.totable = method0(totable)
---
--- Collect all iteration values into a new table (array).
---
--- The function reduces the iterator from left to right using `table.insert`.
---
---
--- Example:
--- ```lua
--- local tab = totable("abcdef")
--- print(type(tab), #tab)
--- -- table 6
--- each(print, tab)
--- -- a
--- -- b
--- -- c
--- -- d
--- -- e
--- -- f
--- ```
---@type fun(obj: fun.Iterable): any[]
exports.totable = export0(totable)

---@param gen_x fun.Generator @the generator function
---@param param_x any @the generator parameter
---@param state_x any @the generator state
---@return table<any, any> @a new table (map) from iteration key-value pairs
local tomap = function(gen_x, param_x, state_x)
    local tab, key, val = {}
    while true do
        state_x, key, val = gen_x(param_x, state_x)
        if state_x == nil then
            break
        end
        tab[key] = val
    end
    return tab
end
methods.tomap = method0(tomap)
---
--- Collect all iteration key-value pairs into a new table (map).
---
--- The function reduces the iterator from left to right using the
--- `tab[val1] = val2` expression.
---
---
--- Example:
--- ```lua
--- local tab = tomap(zip(range(1, 7), 'abcdef'))
--- print(type(tab), #tab)
--- -- table   6
--- each(print, iter(tab))
--- -- a
--- -- b
--- -- c
--- -- d
--- -- e
--- -- f
--- ```
---@type fun(obj: fun.Iterable): table<any, any>
exports.tomap = export0(tomap)

--------------------------------------------------------------------------------
-- Transformations
--------------------------------------------------------------------------------

local map_gen = function(param, state)
    local gen_x, param_x, fun = param[1], param[2], param[3]
    return call_if_not_empty(fun, gen_x(param_x, state))
end

---@param fun fun(...): any @a function to apply
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
--- A new iterator of mapped values (mapped on the fly)
---@return fun.Iterator, any, any
local map = function(fun, gen, param, state)
    return wrap(map_gen, {gen, param, fun}, state)
end
methods.map = method1(map)
---
--- Return a new iterator by applying the **fun** to each element of
--- `gen, param, state` iterator. The mapping is performed on the fly
--- and no values are buffered.
---
---
--- Example:
--- ```lua
--- each(print, map(function(x) return 2 * x end, range(4)))
--- -- 2
--- -- 4
--- -- 6
--- -- 8
---
--- local f = function(...) return 'map', ... end
--- each(print, map(f, range(4)))
--- -- map 1
--- -- map 2
--- -- map 3
--- -- map 4
--- ```
---@type fun(fn: (fun(...): any), obj: fun.Iterable): fun.Iterator, any, any
exports.map = export1(map)

local enumerate_gen_call = function(_state, i, state_x, ...)
    if state_x == nil then
        return nil
    end
    return {i + 1, state_x}, i, ...
end

local enumerate_gen = function(param, state)
    local gen_x, param_x = param[1], param[2]
    local i, state_x = state[1], state[2]
    return enumerate_gen_call(state, i, gen_x(param_x, state_x))
end

---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
--- A new iterator enumerating all elements starting from 1
---@return fun.Iterator, any, any
local enumerate = function(gen, param, state)
    return wrap(enumerate_gen, {gen, param}, {1, state})
end
methods.enumerate = method0(enumerate)
---
--- Return a new iterator by enumerating all elements of the
--- `gen, param, state` iterator starting from `1`. The mapping is performed
--- on the fly and no values are buffered.
---
---
--- Example:
--- ```lua
--- each(print, enumerate({"a", "b", "c", "d", "e"}))
--- -- 1 a
--- -- 2 b
--- -- 3 c
--- -- 4 d
--- -- 5 e
---
--- each(print, enumerate(zip({"one", "two", "three", "four", "five"},
---     {"a", "b", "c", "d", "e"})))
--- -- 1 one a
--- -- 2 two b
--- -- 3 three c
--- -- 4 four d
--- -- 5 five e
--- ```
---@type fun(obj: fun.Iterable): fun.Iterator, any, any
exports.enumerate = export0(enumerate)

local intersperse_call = function(i, state_x, ...)
    if state_x == nil then
        return nil
    end
    return {i + 1, state_x}, ...
end

local intersperse_gen = function(param, state)
    local x, gen_x, param_x = param[1], param[2], param[3]
    local i, state_x = state[1], state[2]
    if i % 2 == 1 then
        return {i + 1, state_x}, x
    else
        return intersperse_call(i, gen_x(param_x, state_x))
    end
end

-- TODO: interperse must not add x to the tail
---@param x any @a value to intersperse between the elements
---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
--- A new iterator with x interspersed between the elements
---@return fun.Iterator, any, any
local intersperse = function(x, gen, param, state)
    return wrap(intersperse_gen, {x, gen, param}, {0, state})
end
methods.intersperse = method1(intersperse)
---
--- Return a new iterator where the **x** value is interspersed between the
--- elements of the source iterator.
---
--- **Note:** the current implementation also appends **x** after the last
--- element. This is a known issue, see the TODO in the implementation.
---
---
--- Example:
--- ```lua
--- each(print, intersperse("x", {"a", "b", "c", "d", "e"}))
--- -- a
--- -- x
--- -- b
--- -- x
--- -- c
--- -- x
--- -- d
--- -- x
--- -- e
--- -- x
--- ```
---@type fun(x: any, obj: fun.Iterable): fun.Iterator, any, any
exports.intersperse = export1(intersperse)

--------------------------------------------------------------------------------
-- Compositions
--------------------------------------------------------------------------------

local function zip_gen_r(param, state, state_new, ...)
    if #state_new == #param / 2 then
        return state_new, ...
    end

    local i = #state_new + 1
    local gen_x, param_x = param[2 * i - 1], param[2 * i]
    local state_x, r = gen_x(param_x, state[i])
    if state_x == nil then
        return nil
    end
    table.insert(state_new, state_x)
    return zip_gen_r(param, state, state_new, r, ...)
end

local zip_gen = function(param, state)
    return zip_gen_r(param, state, {})
end

-- A special hack for zip/chain to skip last two state, if a wrapped iterator
-- has been passed
---@return integer
local numargs = function(...)
    local n = select('#', ...)
    if n >= 3 then
        -- Fix last argument
        local it = select(n - 2, ...)
        if type(it) == 'table' and getmetatable(it) == iterator_mt and
           it.param == select(n - 1, ...) and it.state == select(n, ...) then
            return n - 2
        end
    end
    return n
end

---@param ... fun.Iterable @iterators to zip
--- An iterator whose i-th value holds the i-th element of each iterator
---@return fun.Iterator, any, any
local zip = function(...)
    local n = numargs(...)
    if n == 0 then
        return wrap(nil_gen, nil, nil)
    end
    ---@type table<any, any>
    local param = { [2 * n] = 0 }
    ---@type table<any, any>
    local state = { [n] = 0 }

    local gen_x, param_x, state_x
    for i=1,n,1 do
        local it = select(n - i + 1, ...)
        gen_x, param_x, state_x = rawiter(it)
        param[2 * i - 1] = gen_x
        param[2 * i] = param_x
        state[i] = state_x
    end

    return wrap(zip_gen, param, state)
end
methods.zip = zip
---
--- Return a new iterator where the i-th return value contains the i-th
--- element from each of the iterators. The returned iterator is truncated in
--- length to the length of the shortest iterator. For multi-return iterators
--- only the first variable is used.
---
---
--- Example:
--- ```lua
--- each(print, zip({"a", "b", "c", "d"}, {"one", "two", "three"}))
--- -- a one
--- -- b two
--- -- c three
---
--- each(print, zip())
---
--- each(print, zip(range(5), {'a', 'b', 'c'}, rands()))
--- -- 1       a       0.57514179487402
--- -- 2       b       0.79693061238668
--- -- 3       c       0.45174307459403
---
--- each(print, zip(partition(function(x) return x > 7 end, range(1, 15, 1))))
--- -- 8       1
--- -- 9       2
--- -- 10      3
--- -- 11      4
--- -- 12      5
--- -- 13      6
--- -- 14      7
--- ```
exports.zip = zip

local cycle_gen_call = function(param, state_x, ...)
    if state_x == nil then
        local gen_x, param_x, state_x0 = param[1], param[2], param[3]
        return gen_x(param_x, deepcopy(state_x0))
    end
    return state_x, ...
end

local cycle_gen = function(param, state_x)
    local gen_x, param_x = param[1], param[2]
    return cycle_gen_call(param, gen_x(param_x, state_x))
end

---@param gen fun.Generator @the generator function
---@param param any @the generator parameter
---@param state any @the generator state
---@return fun.Iterator, any, any @a cycled version of the iterator
local cycle = function(gen, param, state)
    return wrap(cycle_gen, {gen, param, state}, deepcopy(state))
end
methods.cycle = method0(cycle)
---
--- Make a new iterator that returns elements from the iterator until the end
--- and then "restarts" the iteration using a saved clone of the iterator.
--- The returned iterator is constant space and no return values are buffered.
--- Instead of that the function makes a clone of the source iterator.
--- Therefore, the source iterator must be pure functional to make an identical
--- clone. Infinite iterators are supported, but are not recommended.
---
--- **Note:** `{gen, param, state}` must be pure functional to work properly
--- with the function.
---
---
--- Example:
--- ```lua
--- each(print, take(15, cycle(range(5))))
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
--- -- 1
--- -- 2
--- -- 3
--- -- 4
--- -- 5
---
--- each(print, take(15, cycle(zip(range(5), {"a", "b", "c", "d", "e"}))))
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- -- 4       d
--- -- 5       e
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- -- 4       d
--- -- 5       e
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- -- 4       d
--- -- 5       e
--- ```
---@type fun(obj: fun.Iterable): fun.Iterator, any, any
exports.cycle = export0(cycle)

-- call each other
local chain_gen_r1
local chain_gen_r2 = function(param, state, state_x, ...)
    if state_x == nil then
        local i = state[1]
        i = i + 1
        if param[3 * i - 2] == nil then
            return nil
        end
        ---@diagnostic disable-next-line: need-check-nil
        return chain_gen_r1(param, {i, param[3 * i]})
    end
    return {state[1], state_x}, ...
end

chain_gen_r1 = function(param, state)
    local i = state[1]
    local gen_x, param_x = param[3 * i - 2], param[3 * i - 1]
    return chain_gen_r2(param, state, gen_x(param_x, state[2]))
end

---@param ... fun.Iterable @iterators to chain
---@return fun.Iterator, any, any @a consecutive iterator from the sources
local chain = function(...)
    local n = numargs(...)
    if n == 0 then
        return wrap(nil_gen, nil, nil)
    end

    ---@type table<any, any>
    local param = { [3 * n] = 0 }
    local gen_x, param_x, state_x
    for i=1,n,1 do
        local elem = select(i, ...)
        gen_x, param_x, state_x = iter(elem)
        param[3 * i - 2] = gen_x
        param[3 * i - 1] = param_x
        param[3 * i] = state_x
    end

    return wrap(chain_gen_r1, param, {1, param[3]})
end
methods.chain = chain
---
--- Make an iterator that returns elements from the first iterator until it is
--- exhausted, then proceeds to the next iterator, until all of the iterators
--- are exhausted. Used for treating consecutive iterators as a single
--- iterator. Infinite iterators are supported, but are not recommended.
---
---
--- Example:
--- ```lua
--- each(print, chain(range(2), {"a", "b", "c"}, {"one", "two", "three"}))
--- -- 1
--- -- 2
--- -- a
--- -- b
--- -- c
--- -- one
--- -- two
--- -- three
---
--- each(print, take(15, cycle(chain(enumerate({"a", "b", "c"}),
---     {"one", "two", "three"}))))
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- -- one
--- -- two
--- -- three
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- -- one
--- -- two
--- -- three
--- -- 1       a
--- -- 2       b
--- -- 3       c
--- ```
exports.chain = chain

--------------------------------------------------------------------------------
-- Operators
--------------------------------------------------------------------------------

--- A table of Lua operators exported as intrinsic functions, to be used with
--- the library high-order primitives.
---
--- **Note:** **op** can be used as a shortcut to **operator**.
---
--- ### Comparison operators
---
--- [`fun.OperatorTable.le`], [`fun.OperatorTable.lt`],
--- [`fun.OperatorTable.eq`], [`fun.OperatorTable.ne`],
--- [`fun.OperatorTable.ge`], [`fun.OperatorTable.gt`].
---
--- ### Arithmetic operators
---
--- [`fun.OperatorTable.add`], [`fun.OperatorTable.div`]
--- ([`fun.OperatorTable.truediv`]), [`fun.OperatorTable.floordiv`],
--- [`fun.OperatorTable.intdiv`], [`fun.OperatorTable.mod`],
--- [`fun.OperatorTable.mul`], [`fun.OperatorTable.neq`]
--- ([`fun.OperatorTable.unm`]), [`fun.OperatorTable.pow`],
--- [`fun.OperatorTable.sub`].
---
--- ### String operators
---
--- [`fun.OperatorTable.concat`], [`fun.OperatorTable.len`]
--- ([`fun.OperatorTable.length`]).
---
--- ### Logical operators
---
--- [`fun.OperatorTable.land`], [`fun.OperatorTable.lor`],
--- [`fun.OperatorTable.lnot`], [`fun.OperatorTable.truth`].
---
--- Example:
--- ```lua
--- print(operator.div(10, 3))
--- -- 3.3333333333333
--- print(operator.div(-10, 3))
--- -- -3.3333333333333
---
--- print(operator.floordiv(10, 3))
--- -- 3
--- print(operator.floordiv(12, 3))
--- -- 4
--- print(operator.floordiv(-10, 3))
--- -- -4
--- print(operator.floordiv(-12, 3))
--- -- -4
---
--- print(operator.intdiv(10, 3))
--- -- 3
--- print(operator.intdiv(12, 3))
--- -- 4
--- print(operator.intdiv(-10, 3))
--- -- -3
--- print(operator.intdiv(-12, 3))
--- -- -4
---
--- print(operator.mod(10, 2))
--- -- 0
--- print(operator.mod(10, 3))
--- -- 2
--- print(operator.mod(-10, 3))
--- -- 2 -- == -1 in C, Java, JavaScript but not in Lua, Python, Haskell!
---
--- print(operator.truth(1))
--- -- true
--- print(operator.truth(0))
--- -- true -- It is Lua, baby!
--- print(operator.truth(nil))
--- -- false
--- print(operator.truth(""))
--- -- true
--- print(operator.truth({}))
--- -- true
--- ```
---
--- **Note:** Result has same sign as **divisor**. Modulo in Lua is defined
--- as `a % b == a - math.floor(a/b)*b`.
---
---@class fun.OperatorTable
---@field lt fun(a: any, b: any): boolean @Compares **a** and **b**,
--- returning `true` if **a** < **b**.
---@field le fun(a: any, b: any): boolean @Compares **a** and **b**,
--- returning `true` if **a** <= **b**.
---@field eq fun(a: any, b: any): boolean @Compares **a** and **b**,
--- returning `true` if **a** == **b**.
---@field ne fun(a: any, b: any): boolean @Compares **a** and **b**,
--- returning `true` if **a** ~= **b**.
---@field ge fun(a: any, b: any): boolean @Compares **a** and **b**,
--- returning `true` if **a** >= **b**.
---@field gt fun(a: any, b: any): boolean @Compares **a** and **b**,
--- returning `true` if **a** > **b**.
---@field add fun(a: number, b: number): number @Adds two numbers,
--- returning **a** + **b**.
---@field div fun(a: number, b: number): number @Performs true float division,
--- returning **a** / **b**,
--- an alias for [truediv](#fun.OperatorTable.truediv).
---@field floordiv fun(a: number, b: number): number @Divides **a** by **b**,
--- rounding the result down: `math.floor(a / b)`.
---@field intdiv fun(a: number, b: number): number @Divides **a** by **b**:
--- `math.floor(a / b)` if **a** >= 0, else `math.ceil(a / b)`.
--- It truncates toward zero only when **b** is positive.
---@field mod fun(a: number, b: number): number @Returns the remainder,
--- dividing **a** by **b**: **a** % **b**.
---@field mul fun(a: number, b: number): number @Multiplies **a** by **b**.
---@field neq fun(a: number): number @Negates a number: -**a**.
---@field unm fun(a: number): number @Negates a number: -**a**,
--- an alias for [neq](#fun.OperatorTable.neq).
---@field pow fun(a: number, b: number): number @Raises **a** to **b**,
--- i.e. `math.pow(a, b)`.
---@field sub fun(a: number, b: number): number @Subtracts **b** from **a**,
--- returning **a** - **b**.
---@field truediv fun(a: number, b: number): number @Performs true division,
--- returning **a** / **b**.
---@field concat fun(a: any, b: any): any @Concatenates two strings,
--- returning **a** .. **b**.
---@field len fun(a: string|table): number @Returns the length of a string,
--- or table: \#**a**.
---@field length fun(a: string|table): number @Returns the length of a string,
--- or table: \#**a**,
--- an alias for [len](#fun.OperatorTable.len).
---@field land fun(a: any, b: any): any @Returns **b** if **a** is truthy,
--- otherwise returns **a**: **a** and **b**.
---@field lor fun(a: any, b: any): any @Returns **a** if it is truthy,
--- otherwise returns **b**: **a** or **b**.
---@field lnot fun(a: any): boolean @Returns `true` if **a** is falsy,
--- otherwise `false`: not **a**.
---@field truth fun(a: any): boolean @Converts a value to a boolean,
--- returning not not **a**.
---@type fun.OperatorTable
local operator = {
    ----------------------------------------------------------------------------
    -- Comparison operators
    ----------------------------------------------------------------------------
    lt  = function(a, b) return a < b end,
    le  = function(a, b) return a <= b end,
    eq  = function(a, b) return a == b end,
    ne  = function(a, b) return a ~= b end,
    ge  = function(a, b) return a >= b end,
    gt  = function(a, b) return a > b end,

    ----------------------------------------------------------------------------
    -- Arithmetic operators
    ----------------------------------------------------------------------------
    add = function(a, b) return a + b end,
    div = function(a, b) return a / b end,
    floordiv = function(a, b) return math.floor(a/b) end,
    intdiv = function(a, b)
        local q = a / b
        if a >= 0 then return math.floor(q) else return math.ceil(q) end
    end,
    mod = function(a, b) return a % b end,
    mul = function(a, b) return a * b end,
    neq = function(a) return -a end,
    unm = function(a) return -a end, -- an alias
    pow = function(a, b) return a ^ b end,
    sub = function(a, b) return a - b end,
    truediv = function(a, b) return a / b end,

    ----------------------------------------------------------------------------
    -- String operators
    ----------------------------------------------------------------------------
    concat = function(a, b) return a..b end,
    len = function(a) return #a end,
    length = function(a) return #a end, -- an alias

    ----------------------------------------------------------------------------
    -- Logical operators
    ----------------------------------------------------------------------------
    land = function(a, b) return a and b end,
    lor = function(a, b) return a or b end,
    lnot = function(a) return not a end,
    truth = function(a) return not not a end,
}
--- Lua operators exported as functions
exports.operator = operator
methods.operator = operator
--- An alias for [operator](fun.html#fun.operator).
exports.op = operator
methods.op = operator

--------------------------------------------------------------------------------
-- module definitions
--------------------------------------------------------------------------------

-- a special syntax sugar to export all functions to the global table
setmetatable(exports, {
    __call = function(t, override)
        ---@cast _G table
        for k, v in pairs(t) do
            if rawget(_G, k) ~= nil then
                local msg = 'function ' .. k ..
                    ' already exists in global scope.'
                if override then
                    rawset(_G, k, v)
                    print('WARNING: ' .. msg .. ' Overwritten.')
                else
                    print('NOTICE: ' .. msg .. ' Skipped.')
                end
            else
                rawset(_G, k, v)
            end
        end
    end,
})

return exports
