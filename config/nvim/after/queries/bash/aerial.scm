;; extends

(while_statement
  condition: (_) @name
  (#set! "kind" "Function")) @symbol

(for_statement
  variable: (_) @name
  (#set! "kind" "Function")) @symbol

(case_statement
  value: (_) @name
  (#set! "kind" "Function")) @symbol
