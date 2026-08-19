; extends

; Dedicated captures so `ii` can select the body of a conditional
; and a separate key the condition expression.
(if_statement
  condition: (_) @conditional.condition.outer)

(if_statement
  condition: (_) @conditional.condition.inner)

(if_statement
  consequence: (block) @conditional.body.outer)

(if_statement
  consequence: (block) @conditional.body.inner)

(elif_clause
  condition: (_) @conditional.condition.outer)

(elif_clause
  condition: (_) @conditional.condition.inner)

(elif_clause
  consequence: (block) @conditional.body.outer)

(elif_clause
  consequence: (block) @conditional.body.inner)

(else_clause
  body: (block) @conditional.body.outer)

(else_clause
  body: (block) @conditional.body.inner)

; Capture only the element itself, never the separating commas
(parameters
  (_) @param.inner @param.outer)

(lambda_parameters
  (_) @param.inner @param.outer)

(tuple
  (_) @param.inner @param.outer)

(list
  (_) @param.inner @param.outer)

(set
  (_) @param.inner @param.outer)

(dictionary
  (pair) @param.inner @param.outer)

(argument_list
  (_) @param.inner @param.outer)

(subscript
  (_) @param.inner @param.outer)

(import_statement
  (_) @param.inner @param.outer)

(import_from_statement
  (_) @param.inner @param.outer)
