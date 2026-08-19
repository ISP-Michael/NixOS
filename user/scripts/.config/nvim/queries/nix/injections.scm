; extends

; lib.hm.dag.entryAfter [ "..." ] ''...'' → bash
((apply_expression
  function: (apply_expression
    function: (_) @_func)
  argument: (indented_string_expression
    (string_fragment) @injection.content))
  (#match? @_func "(^|\\.)entryAfter$")
  (#set! injection.language "bash")
  (#set! injection.combined))

; lib.mkAfter ''...'' → bash
((apply_expression
  function: (_) @_func
  argument: (indented_string_expression
    (string_fragment) @injection.content))
  (#match? @_func "(^|\\.)mkAfter$")
  (#set! injection.language "bash")
  (#set! injection.combined))
