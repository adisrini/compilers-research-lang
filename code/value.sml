structure Value = 
struct

  type symbol = Symbol.symbol

  datatype value = IntVal of int
                 | StringVal of string
                 | RealVal of real
                 | ListVal of value list
                 | RefVal of value ref
                 | RecordVal of (symbol * value) list
                 | FunVal of (value -> value) ref
                 | DatatypeVal of (symbol * unit ref * value)
                 | BitVal of GeminiBit.bit
                 | ArrayVal of value vector
                 | HWRecordVal of (symbol * value) list
                 | BinOpVal of {left: value, oper: binop, right: value}
                 | UnOpVal of {value: value, oper: unop}
                 | ModuleVal of {name: symbol} (* TODO *)
                 | NoVal

  and binop = AndOp | OrOp | XorOp | SLLOp | SRLOp | SRAOp

  and unop = NotOp | AndReduceOp | OrReduceOp | XorReduceOp

  fun printlist f lst = case lst of 
                          [] => ""
                        | [x] => f x
                        | x::xs => (f x) ^ ", " ^ (printlist f xs)

  fun binopString(AndOp) = "AndOp"
    | binopString(OrOp) = "OrOp"
    | binopString(XorOp) = "XorOp"
    | binopString(SLLOp) = "SLLOp"
    | binopString(SRLOp) = "SRLOp"
    | binopString(SRAOp) = "SRAOp"

  fun unopString(NotOp) = "NotOp"
    | unopString(AndReduceOp) = "AndReduceOp"
    | unopString(OrReduceOp) = "OrReduceOp"
    | unopString(XorReduceOp) = "XorReduceOp"

  fun toString(IntVal(i)) = "int(" ^ Int.toString(i) ^ ")"
    | toString(StringVal(s)) = "string(" ^ s ^ ")"
    | toString(RealVal(r)) = "real(" ^ Real.toString(r) ^ ")"
    | toString(ListVal(vs)) = "list([" ^ printlist toString vs ^ "])"
    | toString(RefVal(vr)) = "ref(" ^ toString(!vr) ^ ")"
    | toString(RecordVal(fs)) = "record(" ^ (printlist (fn(sym, v) => Symbol.name(sym) ^ ": " ^ toString(v)) fs) ^ ")"
    | toString(FunVal(f)) = "funval"
    | toString(DatatypeVal(sym, unique, v)) = "data(" ^ Symbol.name(sym) ^ ", " ^ toString(v) ^ ")"
    | toString(BitVal(b)) = "bit(" ^ GeminiBit.toString(b) ^ ")"
    | toString(ArrayVal(vs)) = "array([" ^  printlist toString (Vector.toList(vs)) ^ "])"
    | toString(HWRecordVal(fs)) = "hwrecord(" ^ (printlist (fn(sym, v) => Symbol.name(sym) ^ ": " ^ toString(v)) fs) ^ ")"
    | toString(BinOpVal{left, oper, right}) = "oper{left: " ^ toString(left) ^ ", right: " ^ toString(right) ^ ", oper: " ^ binopString(oper) ^ "}"
    | toString(UnOpVal{value, oper}) = "oper{value: " ^ toString(value) ^ ", oper: " ^ unopString(oper) ^ "}"
    | toString(ModuleVal{name}) = "module{name: " ^ Symbol.name(name) ^ "}"
    | toString(NoVal) = "noval"

  type vstore = value Symbol.table

  val base_store = Symbol.empty

end