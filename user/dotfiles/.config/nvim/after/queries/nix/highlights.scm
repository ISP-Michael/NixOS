; extends
; Многострочная строка должна оставаться строкой целиком: интерполяция
; внутри неё не перекрашивается в отдельное Nix-выражение.
((string_expression (interpolation) @string)
  (#set! priority 200))

((indented_string_expression (interpolation) @string)
  (#set! priority 200))
