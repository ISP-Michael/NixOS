" Helix's git-ignore grammar uses @operator for globs/negation/ranges and
" @string for the pattern itself.  The legacy Vim syntax links globs to
" Special, which flatwhite/flatblack paint as a blue background chip.
highlight! link gitignorePattern String
highlight! link gitignoreGlob Operator
highlight! link gitignoreNegation Operator
highlight! link gitignoreRange Operator
highlight! link gitignoreSeparator String
