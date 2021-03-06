structure Library = 
struct

  exception TypeError

  structure T = Types
  structure V = Value

  (* value getting functions *)
  fun getInt(V.IntVal x) = x
    | getInt(_) = raise TypeError

  fun getString(V.StringVal x) = x
    | getString(_) = raise TypeError

  fun getReal(V.RealVal x) = x
    | getReal(_) = raise TypeError

  fun getList(V.ListVal x) = x
    | getList(_) = raise TypeError

  fun getRef(V.RefVal x) = x
    | getRef(_) = raise TypeError
  
  fun getRecord(V.RecordVal x) = x
    | getRecord(_) = raise TypeError

  fun getFun(V.FunVal x) = x
    | getFun(_) = raise TypeError

  fun getBit(V.BitVal x) = x
    | getBit(_) = raise TypeError

  fun getArray(V.ArrayVal x) = x
    | getArray(_) = raise TypeError

  fun getBitArray(V.ArrayVal bs) = Vector.map getBit bs
    | getBitArray(_) = raise TypeError

  fun getSWInner(V.SWVal x) = x
    | getSWInner(_) = raise TypeError

  fun getHWRecord(V.HWRecordVal x) = x
    | getHWRecord(_) = raise TypeError

  fun getHWRecordField(fs, field) = #2(valOf(List.find (fn (sym, v) => Symbol.name(sym) = field) fs))

  structure Core = 
  struct

    (* print *)
    val print_ty = T.S_TY(T.ARROW(T.STRING, T.S_RECORD[]))
    val print_impl = V.FunVal (ref (fn (v) => let val () = print(getString(v)) in V.RecordVal [] end ))

  end

  structure List = 
  struct

    (* nth *)
    val nth_ty =
      let
        val meta = Meta.newMeta()
      in
        T.S_TY(T.S_POLY([meta], T.ARROW(T.S_RECORD[(Symbol.symbol("1"), T.LIST(T.S_META(meta))), (Symbol.symbol("2"), T.INT)], T.S_META(meta))))
      end

    val nth_impl = V.FunVal (ref (fn (v) => let
                                              val [(_, v1), (_, v2)] = getRecord(v)
                                            in
                                              List.nth(getList(v1), getInt(v2))
                                            end))

    (* length *)
    val length_ty =
      let
        val meta = Meta.newMeta()
      in
        T.S_TY(T.S_POLY([meta], T.ARROW(T.LIST(T.S_META(meta)), T.INT)))
      end

    val length_impl = V.FunVal (ref (fn (v) =>  let
                                                  val listVal = getList(v)
                                                in
                                                  V.IntVal (List.length(listVal))
                                                end))

    (* rev *)
    val rev_ty =
      let
        val meta = Meta.newMeta()
      in
        T.S_TY(T.S_POLY([meta], T.ARROW(T.LIST(T.S_META(meta)), T.LIST(T.S_META(meta)))))
      end

    val rev_impl = V.FunVal (ref (fn (v) => let
                                              val listVal = getList(v)
                                            in
                                              V.ListVal (List.rev(listVal))
                                            end))

  end

  structure Array = 
  struct

    (* toList *)
    (* hw[n] sw -> hw sw list*)
    val toList_ty = 
      let
        val meta = Meta.newMeta()
      in
        T.S_TY(
          T.ARROW(
            T.SW_H(T.ARRAY{ty = T.H_META(meta), size = ref ~1}),
            T.LIST(T.SW_H(T.H_META(meta)))
          )
        )
      end

    val toList_impl = V.FunVal (ref (fn (v) =>  let
                                                  val hwArrayVal = getSWInner(v)
                                                  val hwArray = getArray(hwArrayVal)
                                                in
                                                  V.ListVal (map (fn (v') => V.SWVal v') (Vector.toList(hwArray)))
                                                end))

    (* fromList *)
    (* hw sw list -> hw[n] sw *)
    val fromList_ty = 
      let
        val meta = Meta.newMeta()
      in
        T.S_TY(
          T.ARROW(
            T.LIST(T.SW_H(T.H_META(meta))),
            T.SW_H(T.ARRAY{ty = T.H_META(meta), size = ref ~1})
          )
        )
      end

    val fromList_impl = V.FunVal (ref (fn (v) =>  let
                                                  val swVals = getList(v)
                                                  val hwList = map (fn (v') => case v' of V.SWVal v' => v' | _ => raise TypeError) swVals
                                                in
                                                  V.SWVal (V.ArrayVal (Vector.fromList(hwList)))
                                                end))

  end

  structure BitArray = 
  struct
    
    (* 2s complement *)
    val twosComp_ty = T.M_TY(T.MODULE(T.ARRAY{ty = T.BIT, size = ref ~1}, T.ARRAY{ty = T.BIT, size = ref ~1}))

    val twosComp_impl = V.IntVal 0

  end

  structure HW = 
  struct

    (* dff *)
    val dff_ty =
      let
        val meta1 = Meta.newMeta()
        val meta2 = Meta.newMeta()
      in
        T.M_TY(T.MODULE(T.H_RECORD[(Symbol.symbol("data"), T.H_META(meta1)), (Symbol.symbol("clk"), T.H_META(meta2))], T.TEMPORAL{ty = T.H_META(meta1), time = ref ~1}))
      end
    val dff_impl = V.ModuleVal((fn(v) =>  let
                                            val record = getHWRecord(v)
                                            val data = getHWRecordField(record, "data")
                                            val clk = getHWRecordField(record, "clk")
                                          in
                                            V.DFFVal {data = data, clk = clk}
                                          end), V.HWRecordVal[(Symbol.symbol("data"), V.NamedVal(Symbol.symbol("data"), T.H_TY(T.H_META(Meta.newMeta())))),
                                                              (Symbol.symbol("clk"), V.NamedVal(Symbol.symbol("clk"), T.H_TY(T.BIT)))])
    
    (* clk *)
    val clk_ty = T.H_TY(T.BIT)
    val clk_impl = V.NamedVal(Symbol.symbol("clk"), T.H_TY(T.BIT))

  end

end