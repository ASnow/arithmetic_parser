class Expression
  @expessions_counter = 0
  @expessions = []

  constructor: (@text) ->
    @id = Expression.expessions_counter++;
    Expression.expessions[@id] = @
    @arguments = []
    # operator_name, arguments
    @length = @to_s().length
    @parse @text
    # polynomic optimization

    # dry form
  to_s: ->
    "{e#{@id}}"

  arity: ->
    @arguments.length

  parse: (text) ->
    string = @text[0]
    for operator, type of operators
      entry = string.indexOf operator
      if entry != -1
        switch type
          when 3
            b = @getLeftArgument entry
            entry -= string.length - text[0].length
            a = @getRightArgument entry
            @type = type
            @name = operator
            string = text[0]
            if string.substring(0, entry - b.length) or string.substring(entry + a.length + 1)
              @text[0] = string.substring(0, entry - b.length) + @to_s() + string.substring(entry + a.length + 1)
            else
              @text[0] = ''
            return true

  getRightArgument: (entry) ->
    # op =>
    string = @text[0]
    after = string.substring entry+1
    if after[0] == '('
      pos = findUpperPriorityRight string, entry
      temp = [string.substring(pos[0]+1, pos[1]-1)]
      while temp[0]
        e = new Expression temp
      @arguments.push e
      if string.substring(0, pos[0]) or string.substring(pos[1])
        @text[0] = string.substring(0, pos[0]) + e.to_s() + string.substring(pos[1])
      else
        @text[0] = ''
    else if after[0] == '{'
      @arguments.push getExpressionFromRight(string, entry)
    else if match = after.match /^[0-9.,]+/
      # const
      @arguments.push match[0]
    else if match = after.match /^[a-z]+[0-9_a-z]*/
      # var
      @arguments.push match[0]
    @arguments[@arity()-1]


  getLeftArgument: (entry) ->
    # <= op
    string = @text[0]
    before = string.substring 0, entry
    if string[entry-1] == ')'
      pos = findUpperPriorityLeft string, entry
      temp = [string.substring(pos[0]+1, pos[1]-1)]
      while temp[0]
        e = new Expression temp
      @arguments.push e
      if string.substring(0, pos[0]) or string.substring(pos[1])
        @text[0] = string.substring(0, pos[0]) + e.to_s() + string.substring(pos[1])
      else
        @text[0] = ''
    else if string[entry-1] == '}'
      @arguments.push getExpressionFromLeft(string, entry)
    else if match = before.match /[0-9.,]+$/
      # const
      @arguments.push match[0]
    else if match = before.match /[a-z]+[0-9_a-z]*$/
      # var
      @arguments.push match[0]
    @arguments[@arity()-1]


# operator types
# 0 - unary,    +x, !x
# 1 - right,    sin(x)
# 2 - left,     ()max
# 3 - binary    x+y
operators = 
  "sin": 1
  "cos": 1
  "tan": 1
  "ctg": 1
  "log": 1
  "ln": 1
  "^": 3
  "%": 3
  "*": 3
  "/": 3
  "+": 3
  "-": 3

parse = (string) ->
  string = string.replace(" ", "")
  parseExpression string


parseExpression = (string) ->
  string = [string]
  while string[0]
    getNextExpression(string)

getNextExpression = (string) ->
  new Expression(string)

# string = "(a^(b/a))*(b+c)"
# operator = "*"

getExpressionFromRight = (string, postion) ->
  pos = findSemicolonRight string, postion, '{', '}'
  id = string.substring(pos[0], pos[1]).match(/{e([0-9]+)}/)[1]
  Expression.expessions[id]

getExpressionFromLeft = (string, postion) ->
  pos = findSemicolonLeft string, postion, '}', '{'
  id = string.substring(pos[0], pos[1]).match(/{e([0-9]+)}/)[1]
  Expression.expessions[id]

findUpperPriorityRight = (string, postion) ->
  findSemicolonRight string, postion, '(', ')'

findUpperPriorityLeft = (string, postion) ->
  findSemicolonLeft string, postion, ')', '('

findSemicolonLeft = (string, from, open_tag, close_tag) ->
  res = findSemicolon string, from - 1, open_tag, close_tag, 'lastIndexOf', -1, (a, b) -> a > b
  y = res[0] + 1
  res[0] = res[1] + 1
  res[1] = y
  res

findSemicolonRight = (string, from, open_tag, close_tag) ->
  findSemicolon string, from, open_tag, close_tag, 'indexOf', 1, (a, b) -> a < b

findSemicolon = (string, from, open_tag, close_tag, func, delta, cond) ->
  # (()(()())((()())(())(()))())
  # ( # 0
  #   () # 1, 3
  #   (  # 3
  #     () # 4, 6
  #     () # 6, 8
  #   )  # 9
  #   (  # 9
  #     (  # 10
  #       () # 11, 13
  #       () # 13, 15
  #     )  # 16
  #     (()) # [16, 20], [17, 19]
  #     (()) # [20, 24], [21, 23]
  #   )  # 25
  #   () # 25, 27
  # ) #28
  from = string[func](open_tag, from)
  next_close = string[func](close_tag, from)
  test = string[func](open_tag, from + delta)
  if cond(test, next_close) && test != -1 && next_close != -1
    while cond(test, next_close) && test != -1
      prev_test = test
      next_close = string[func](close_tag, next_close + delta)
      test = string[func](open_tag, test + delta)

    if prev_test == -1 or next_close == -1
      alert('bad +' + next_close + ' + ' + (test + delta))

  [from, next_close + delta]



expressions = parse "1+1+(2*3+4^5)%2"
last = expressions[expressions.length-1]

# treeRoot = (last) ->
#   for arg in last.arguments
#     if typeof arg == 'object'
#       1

# optimizationPolynoms = (tree) ->
