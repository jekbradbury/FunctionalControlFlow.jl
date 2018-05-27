using MacroTools: @capture, postwalk, isexpr

thunk(ex) = :(() -> $ex)
macro thunk(ex) thunk(ex) end

_while(cond, body) = while cond() body() end
_if(cond, body1) = if cond() body1() end
_if(cond, body1, body2) = if cond() body1() else body2() end
_and(x1, x2) = x1() && x2()
_or(x1, x2) = x1() || x2()

#TODO break, continue, return
#continue requires adding conditionals
#break is continue plus setting an &&-ed while condition to false
#return from a while is break plus setting a return expr
macro functionalize(ex)

    postwalk(ex) do x
        isexpr(x, :elseif) && (x.head = :if)
        return if @capture(x, for i_ in v_ b_ end | for i_ = v_ b_ end)
            quote
                next = iterate($v)
                _while(@thunk(next !== nothing), @thunk(
                    begin
                        ($i, state) = next
                        $b # TODO maybe splice contents of block
                        next = iterate($v, state)
                    end))
            end
        elseif @capture(x, while c_ b_ end)
            :(_while($(thunk(c)), $(thunk(b))))
        elseif @capture(x, if c_ b_ else b2_ end)
            :(_if($(thunk(c)), $(thunk(b)), $(thunk(b2))))
        elseif @capture(x, if c_ b_ end)
            :(_if($(thunk(c)), $(thunk(b))))
        elseif @capture(x, a_ && b_)
            :(_and($(thunk(a)), $(thunk(b))))
        elseif @capture(x, a_ || b_)
            :(_or($(thunk(a)), $(thunk(b))))
        else
            x
        end
    end
end
