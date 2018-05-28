# FunctionalControlFlow.jl

Provides macro `@functionalize`, which converts `if`, `while`, `for`, `&&`, and `||` to functional control flow `_if` and `_while` compatible with dataflow graph semantics as found in e.g. XLA or ONNX.

Currently does not support `break`, `continue`, or `return` inside a control flow block.
