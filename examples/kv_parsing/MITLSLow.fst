module MITLSLow
// module E = Extensions
module S = Slice
module P = GhostParsing
module IP = IntegerParsing

let parse_synth
  (#t1: Type0)
  (#t2: Type0)
  (p1: P.parser t1)
  (f2: P.parse_arrow t1 (fun _ -> t2))
= P.and_then p1 (fun v1 -> P.parse_ret (f2 v1))

let validate_synth
  (#t1: Type0)
  (#t2: Type0)
  (#p1: P.parser t1)
  (v1: P.stateful_validator p1)
  (f2: P.parse_arrow t1 (fun _ -> t2))
: Tot (P.stateful_validator (parse_synth p1 f2))
= fun b -> v1 b

let validate_synth_nochk
  (#t1: Type0)
  (#t2: Type0)
  (#p1: P.parser t1)
  (v1: P.stateful_validator_nochk p1)
  (f2: P.parse_arrow t1 (fun _ -> t2))
: Tot (P.stateful_validator_nochk (parse_synth p1 f2))
= fun b -> v1 b

val parse_tagged_union
  (#tag: Type0)
  (#tu: tag -> Type0)
  (pt: P.parser tag)
//  (p: P.parse_arrow (t: tag) (fun t -> P.parser (tu t)))
  (p: (t: tag) -> Tot (P.parser (tu t))) // Tot really needed here by validator
: Tot (P.parser (t: tag & tu t))

let parse_tagged_union #tag #tu pt p =
  pt `P.and_then` (fun (v: tag) ->
    parse_synth #(tu v) #(t: tag & tu t) (p v) (fun (v': tu v) -> (| v, v' |)
  ))

let parse_then_check
  (#t1: Type0)
  (#p1: P.parser t1)
  (ps1: P.parser_st p1)
  (#t2: Type0)
  (#p2: P.parse_arrow t1 (fun _ -> P.parser t2))
  (ps2: ((x1: t1) -> Tot (P.stateful_validator (p2 x1))))
: Tot (P.stateful_validator (P.and_then p1 p2))
= fun input ->
  match ps1 input with
  | Some (v1, off1) ->
    let input2 = S.advance_slice input off1 in
    begin match ps2 v1 input2 with
    | Some off2 ->
      if S.u32_add_overflows off1 off2
      then None
      else Some (UInt32.add off1 off2)
    | _ -> None
    end
  | _ -> None

val validate_tagged_union
  (#tag: Type0)
  (#tu: tag -> Type0)
  (#pt: P.parser tag)
  (pt_st: P.parser_st pt)
  (#p: (t: tag) -> Tot (P.parser (tu t)))
  (v_st: (t: tag) -> Tot (P.stateful_validator (p t)))
: Tot (P.stateful_validator (parse_tagged_union pt p))

let validate_tagged_union #tag #tu #pt pt_st #p v_st =
  parse_then_check pt_st #(t : tag & tu t) #(fun v -> parse_synth #(tu v) #(t: tag & tu t) (p v) (fun (v': tu v) -> (| v, v' |) )) (fun v -> validate_synth #(tu v) #(t: tag & tu t) #(p v) (v_st v) (fun (v': tu v) -> (| v, v' |)))

let parse_nochk_then_nochk
  (#t1: Type0)
  (#p1: P.parser t1)
  (ps1: P.parser_st_nochk p1)
  (#t2: Type0)
  (#p2: P.parse_arrow t1 (fun _ -> P.parser t2))
  (ps2: ((x1: t1) -> Tot (P.stateful_validator_nochk (p2 x1))))
: Tot (P.stateful_validator_nochk (P.and_then p1 p2))
= fun input ->
  let (v1, off1) = ps1 input in
  let input2 = S.advance_slice input off1 in
  let off2 = ps2 v1 input2 in
  UInt32.add off1 off2

val validate_tagged_union_nochk
  (#tag: Type0)
  (#tu: tag -> Type0)
  (#pt: P.parser tag)
  (pt_st: P.parser_st_nochk pt)
  (#p: (t: tag) -> Tot (P.parser (tu t)))
  (v_st: (t: tag) -> Tot (P.stateful_validator_nochk (p t)))
: Tot (P.stateful_validator_nochk (parse_tagged_union pt p))

let validate_tagged_union_nochk #tag #tu #pt pt_st #p v_st =
  parse_nochk_then_nochk pt_st #(t : tag & tu t) #(fun v -> parse_synth #(tu v) #(t: tag & tu t) (p v) (fun (v': tu v) -> (| v, v' |) )) (fun v -> validate_synth_nochk #(tu v) #(t: tag & tu t) #(p v) (v_st v) (fun (v': tu v) -> (| v, v' |)))

val parse_sized : (#t: Type0) -> (p: P.parser t) -> (sz: nat) -> Tot (P.parser t)

let parse_sized #t p sz =
  let () = () in // Necessary to pass arity checking
  fun s ->
  if Seq.length s < sz
  then None
  else
    match p (Seq.slice s 0 sz) with
    | Some (v, consumed) ->
      if consumed = sz
      then Some (v, consumed)
      else None
    | _ -> None

let parse_sized1 (#t: Type0) (p: P.parser t) (sz: UInt8.t) : Tot (P.parser t) = parse_sized p (UInt8.v sz)

let parse_vlbytes1 (#t: Type0) (p: P.parser t) : Tot (P.parser t) =
  IP.parse_u8 `P.and_then` (fun len -> parse_sized1 p len)

(*  Useless for now
<<
let parse_sized1_st
  (#t: Type0)
  (#p: Ghost.erased (P.parser t))
  (ps: P.parser_st p)
  (len: UInt8.t)
: P.parser_st (erased_arrow (parse_sized1_erased p) len)
= fun input ->
  let len' : UInt32.t = Int.Cast.uint8_to_uint32 len in
  assert (UInt32.v len' == UInt8.v len);
  let blen = S.BSlice?.len input in
  let test = UInt32.lt blen len' in
  assume (test = (UInt32.v blen < UInt32.v len' ));
  if test
  then begin
    assert (UInt32.v blen < UInt32.v len');
    None
  end else begin
    assert (UInt32.v len' <= UInt32.v blen);
    let input' = S.truncate_slice input len' in
    match ps input' with
    | Some (v, consumed) ->
      let test = (consumed = len') in
      assume (test == (UInt32.v consumed = UInt32.v len' ));
      if test
      then Some (v, consumed)
      else None
    | _ -> None
  end
>>

// TODO: WHY WHY WHY do I need all those unfold above? 

let and_then_st
  (#t1: Type0)
  (#p1: Ghost.erased (P.parser t1))
  (ps1: P.parser_st p1)
  (#t2: Type0)
  (#p2: Ghost.erased (t1 -> P.parser t2))
  (ps2: ((x1: t1) -> P.parser_st (erased_arrow p2 x1)))
: P.parser_st (Ghost.elift2 P.and_then p1 p2)
= fun input ->
  match ps1 input with
  | Some (v1, off1) ->
    let input2 = S.advance_slice input off1 in
    begin match ps2 v1 input2 with
    | Some (v2, off2) ->
      if S.u32_add_overflows off1 off2
      then None
      else Some (v2, UInt32.add off1 off2)
    | _ -> None
    end
  | _ -> None

let parse_vlbytes1_st
  (#t: Type0)
  (#p: Ghost.erased (P.parser t))
  (ps: P.parser_st p)
: P.parser_st (Ghost.elift1 (parse_vlbytes1 #t) p)
= let t1 = Ghost.elift1 (parse_vlbytes1 #t) p in
  let ps' : P.parser_st t1 =
    and_then_st #UInt8.t #(Ghost.hide IP.parse_u8) IP.parse_u8_st (parse_sized1_st ps)
  in
  ps'
>>
*)

let validate_sized1
  (#t: Type0)
  (#p: P.parser t)
  (ps: P.stateful_validator p)
  (len: UInt8.t)
: Tot (P.stateful_validator (parse_sized1 p len))
= fun input ->
  let len' : UInt32.t = Int.Cast.uint8_to_uint32 len in
  let blen = S.BSlice?.len input in
  if UInt32.lt blen len'
  then begin
    None
  end else begin
    let input'  = S.truncate_slice input len'  in
    match ps input' with
    | Some consumed ->
      if consumed = len'
      then Some consumed
      else None
    | _ -> None
  end

let validate_sized1_nochk
  (#t: Type0)
  (p: P.parser t)
  (len: UInt8.t)
: Tot (P.stateful_validator_nochk (parse_sized1 p len))
= fun _ -> Int.Cast.uint8_to_uint32 len

let validate_vlbytes1
  (#t: Type0)
  (#p: P.parser t)
  (ps: P.stateful_validator p)
: P.stateful_validator (parse_vlbytes1 p)
= parse_then_check #_ #IP.parse_u8 IP.parse_u8_st #_ #(fun n -> parse_sized1 p n) (fun n -> validate_sized1 ps n)

let validate_vlbytes1_nochk
  (#t: Type0)
  (p: P.parser t)
: Tot (P.stateful_validator_nochk (parse_vlbytes1 p))
= parse_nochk_then_nochk #_ #IP.parse_u8 IP.parse_u8_st_nochk #_ #(fun n -> parse_sized1 p n) (fun n -> validate_sized1_nochk p n)

module HS = FStar.HyperStack
module HST = FStar.HyperStack.ST
module B = FStar.Buffer

val point_to_vlbytes1_contents
  (#t: Type0)
  (#p: P.parser t)
  (ps: P.stateful_validator p)
  (b: S.bslice)
: HST.Stack S.bslice
  (requires (fun h ->
    S.live h b /\ (
    let s = S.as_seq h b in (
    Some? (parse_vlbytes1 p s)
  ))))
  (ensures (fun h0 b' h1 ->
    B.modifies_none h0 h1 /\
    S.live h0 b /\
    S.live h0 b' /\ (
    let s = S.as_seq h0 b in
    let v = parse_vlbytes1 p s in (
    Some? v /\ (
    let (Some (v', consumed)) = v in (
    B.includes (S.truncated_slice b (UInt32.uint_to_t consumed)).S.p b'.S.p /\
    (
    let s' = S.as_seq h1 b' in
    let v'' = p s' in (
    Some? v'' /\ (
    let (Some (v'', len')) = v'' in (
    v'' == v' /\
    len' == UInt32.v (S.BSlice?.len b')
  ))))))))))

#set-options "--z3rlimit 16"

let point_to_vlbytes1_contents #t #p ps b =
  let h0 = HST.get () in
  let v = IP.parse_u8_st b in
  assert (Some? v);
  let (Some (len, off1)) = v in
  let b1 = S.advance_slice b off1 in
  assert (b1.S.p == B.sub b.S.p off1 (UInt32.sub b.S.len off1));
  let len' = FStar.Int.Cast.uint8_to_uint32 len in
  assert (UInt32.v len' <= UInt32.v (S.BSlice?.len b1));
  let b' = S.truncate_slice b1 len' in
  assert (b1.S.p == B.sub b.S.p off1 (UInt32.sub b.S.len off1));
  assert (b'.S.p == B.sub b1.S.p 0ul len');
  let f () : Lemma
  (
    let s = S.as_seq h0 b in
    let (Some (_, consumed)) = parse_vlbytes1 p s in
    b'.S.p == B.sub (B.sub b.S.p 0ul (UInt32.uint_to_t consumed)) off1 len'
  )
  = let s = S.as_seq h0 b in
    let (Some (_, consumed)) = parse_vlbytes1 p s in
    B.sub_sub b.S.p 0ul (UInt32.uint_to_t consumed) off1 len';
    B.sub_sub b.S.p off1 (UInt32.sub b.S.len off1) 0ul len'
  in
  f ();
  b'

assume val validate_u8_st : P.stateful_validator IP.parse_u8
assume val validate_u16_st: P.stateful_validator IP.parse_u16

(* Special case for non-dependent parsing *)

let nondep_then
  (#t1 #t2: Type0)
  (p1: P.parser t1)
  (p2: P.parser t2)
: Tot (P.parser (t1 * t2))
= p1 `P.and_then` (fun v1 -> p2 `P.and_then` (fun v2 -> P.parse_ret (v1, v2)))

let validate_nondep_then
  (#t1: Type0)
  (#p1: P.parser t1)
  (v1: P.stateful_validator p1)
  (#t2: Type0)
  (#p2: P.parser t2)
  (v2: P.stateful_validator p2)
: Tot (P.stateful_validator (nondep_then p1 p2))
= P.then_check p1 v1 p2 v2 (fun x1 x2 -> (x1, x2))

let validate_nondep_then_nochk
  (#t1: Type0)
  (#p1: P.parser t1)
  (v1: P.stateful_validator_nochk p1)
  (#t2: Type0)
  (#p2: P.parser t2)
  (v2: P.stateful_validator_nochk p2)
: Tot (P.stateful_validator_nochk (nondep_then p1 p2))
= fun s1 ->
  let off1 = v1 s1 in
  let s2 = S.advance_slice s1 off1 in
  let off2 = v2 s2 in
  UInt32.add off1 off2

let parse_filter
  (#t: Type0)
  (p: P.parser t)
  (f: P.parse_arrow t (fun _ -> bool))
: Tot (P.parser (x: t { f x == true }))
= p `P.and_then` (fun v ->
    if f v
    then
      let (v' : t { f v' == true } ) = v in
      P.parse_ret v'
    else P.fail_parser
  )
 
let stateful_filter_validator
  (#t: Type0)
  (p: P.parser t)
  (f: P.parse_arrow t (fun _ -> bool))
: Tot Type0
= (v2: (
    (b: S.bslice) ->
    HST.Stack bool
    (requires (fun h ->
      S.live h b /\ (
      let s = S.as_seq h b in (
      Some? (p s)
    ))))
    (ensures (fun h0 r h1 ->
      S.live h0 b /\
      S.live h1 b /\
      B.modifies_none h0 h1 /\ (
      let s = S.as_seq h0 b in
      let v' = p s in (
      Some? v' /\ (
      let (Some (w, _)) = v' in (
      r == f w
  ))))))))

let validate_filter
  (#t: Type0)
  (#p: P.parser t)
  (v1: P.stateful_validator p)
  (#f: P.parse_arrow t (fun _ -> bool))
  (v2: stateful_filter_validator p f)
: Tot (P.stateful_validator (parse_filter p f))
= fun b ->
    let r1 = v1 b in
    if Some? r1
    then
      let r2 = v2 b in
      if r2
      then r1
      else None
    else None

let validate_filter_nochk
  (#t: Type0)
  (#p: P.parser t)
  (v1: P.stateful_validator_nochk p)
  (f: P.parse_arrow t (fun _ -> bool))
: Tot (P.stateful_validator_nochk (parse_filter p f))
= fun b -> v1 b

type example' =
| Left':
    (u1: UInt8.t) ->
    (u2: UInt8.t) ->
    example'
| Right' of UInt16.t

let parse_example' : P.parser example' =
  IP.parse_u8 `P.and_then` (fun j ->
    let j' = Int.Cast.uint8_to_uint32 j in
    if j' = 0ul
    then parse_synth (nondep_then IP.parse_u8 IP.parse_u8) (fun (u1, u2) -> Left' u1 u2)
    else parse_synth IP.parse_u16 (fun v -> Right' v)
  )

let validate_example_st' : P.stateful_validator parse_example' =
   parse_then_check #_ #IP.parse_u8 IP.parse_u8_st #_ #(fun j -> (* FIXME: WHY WHY WHY do I need this F* explicit argument? *)
     let j' = Int.Cast.uint8_to_uint32 j in
     if j' = 0ul
     then parse_synth (nondep_then IP.parse_u8 IP.parse_u8) (fun (u1, u2) -> Left' u1 u2)
     else parse_synth IP.parse_u16 (fun v -> Right' v)
   ) (fun j ->
     let j' = Int.Cast.uint8_to_uint32 j in
     if j' = 0ul
     then
        (validate_synth (validate_nondep_then validate_u8_st validate_u8_st) (fun (u1, u2) -> Left' u1 u2))
     else
        (validate_synth validate_u16_st (fun v -> Right' v))
   )

let validate_u8_st_nochk : P.stateful_validator_nochk IP.parse_u8 = fun _ -> 1ul
let validate_u16_st_nochk: P.stateful_validator_nochk IP.parse_u16 = fun _ -> 2ul

let validate_example_st_nochk' : P.stateful_validator_nochk parse_example' =
   parse_nochk_then_nochk #_ #IP.parse_u8 IP.parse_u8_st_nochk #_ #(fun j -> (* FIXME: WHY WHY WHY do I need this F* explicit argument? *)
     let j' = Int.Cast.uint8_to_uint32 j in
     if j' = 0ul
     then parse_synth (nondep_then IP.parse_u8 IP.parse_u8) (fun (u1, u2) -> Left' u1 u2)
     else parse_synth IP.parse_u16 (fun v -> Right' v)
   ) (fun j ->
     let j' = Int.Cast.uint8_to_uint32 j in
     if j' = 0ul
     then
        (validate_synth_nochk (validate_nondep_then_nochk #_ #IP.parse_u8 validate_u8_st_nochk #_ #IP.parse_u8 validate_u8_st_nochk) (fun (u1, u2) -> Left' u1 u2))
     else
        (validate_synth_nochk #_ #_ #IP.parse_u16 validate_u16_st_nochk (fun v -> Right' v))
   )

type example_tag = | Left | Right

type example = ( t: example_tag & (
  match t with
  | Left -> (UInt8.t * UInt8.t)
  | Right -> UInt16.t
) )

(* Parse a list, until there is nothing left to read. This parser will mostly fail EXCEPT if the whole size is known and the slice has been suitably truncated beforehand, or if the elements of the list all have a known constant size. *)

val parse_list_aux
  (#t: Type0)
  (p: P.parser t)
  (b: P.bytes32)
: Tot (P.parse_arrow unit (fun _ -> option (list t * (n: nat { n <= Seq.length b } ))))
  (decreases (Seq.length b))

let rec parse_list_aux #t p b =
  let () = () in
  fun () ->
  if Seq.length b = 0
  then 
    Some ([], 0)
  else
    match p b with
    | None -> None
    | Some (v, n) ->
      if n = 0
      then None (* elements cannot be empty *)
      else
        match parse_list_aux p (Seq.slice b n (Seq.length b)) () with
	| Some (l, n') -> Some (v :: l, n + n')
	| _ -> None

val parse_list
  (#t: Type0)
  (p: P.parser t)
: Tot (P.parser (list t))

let parse_list #t p b = parse_list_aux #t p b ()

let rec parse_list_tailrec
  (#t: Type0)
  (p: P.parser t)
  (b: P.bytes32)
: Tot (P.parse_arrow (aux: list t) (fun _ -> option (list t)))
  (decreases (Seq.length b))
= fun aux ->
  if Seq.length b = 0
  then 
    Some aux
  else
    match p b with
    | None -> None
    | Some (v, n) ->
      if n = 0
      then None (* elements cannot be empty *)
      else
	parse_list_tailrec p (Seq.slice b n (Seq.length b)) (List.Tot.append aux [v])

let rec parse_list_tailrec_append
  (#t: Type0)
  (p: P.parser t)
  (b: P.bytes32)
  (auxl: list t)
  (auxr: list t)
: Lemma
  (requires True)
  (ensures (
    parse_list_tailrec p b (List.Tot.append auxl auxr) == (
    match parse_list_tailrec p b auxr with
    | None -> None
    | Some l -> Some (List.Tot.append auxl l)
  )))
  (decreases (Seq.length b))
= if Seq.length b = 0
  then ()
  else
    match p b with
    | None -> ()
    | Some (v, n) ->
      if n = 0
      then ()
      else begin
	parse_list_tailrec_append p (Seq.slice b n (Seq.length b)) auxl (List.Tot.append auxr [v]);
	List.Tot.append_assoc auxl auxr [v]
      end

let rec parse_list_tailrec_correct
  (#t: Type0)
  (p: P.parser t)
  (b: P.bytes32)
  (aux: list t)
: Lemma
  (requires True)
  (ensures (
    parse_list_tailrec p b aux == (
    match parse_list p b with
    | Some (l, n) -> Some (List.Tot.append aux l)
    | None -> None
  )))
  (decreases (Seq.length b))
= if Seq.length b = 0
  then
    List.Tot.append_l_nil aux
  else
    match p b with
    | None -> ()
    | Some (v, n) ->
      if n = 0
      then ()
      else begin
	let s = Seq.slice b n (Seq.length b) in
	parse_list_tailrec_correct p s (List.Tot.append aux [v]);
	match parse_list p s with
	| Some (l, n') ->
	  List.Tot.append_assoc aux [v] l
	| None -> ()
      end

(* No stateful parser for lists, because we do not know how to extract the resulting list -- or even the list while it is being constructed *)

let advance_slice_advance_slice
  (b: S.bslice)
  (off1: UInt32.t {UInt32.v off1 <= UInt32.v b.S.len } )
  (off2: UInt32.t {UInt32.v off2 <= UInt32.v (S.advance_slice b off1).S.len } )
: Lemma
  (requires (
    S.u32_add_overflows off1 off2 == false
  ))
  (ensures (
    S.u32_add_overflows off1 off2 == false /\
    S.advance_slice (S.advance_slice b off1) off2 == S.advance_slice b (UInt32.add off1 off2)
  ))
= let s1 = S.advance_slice b off1 in
  let s2 = S.advance_slice s1 off2 in
  B.sub_sub (S.BSlice?.p b) off1 (S.BSlice?.len s1) off2 (S.BSlice?.len s2)

(* TODO: move to FStar.List.Tot.Properties *)

let rec list_append_index_r
  (#t: Type0)
  (l1: list t)
  (l2: list t)
  (i: nat)
: Lemma
  (requires (
    i >= List.Tot.length l1 /\
    i < List.Tot.length l1 + List.Tot.length l2
  ))
  (ensures (
    i >= List.Tot.length l1 /\
    i < List.Tot.length l1 + List.Tot.length l2 /\
    i < List.Tot.length (List.Tot.append l1 l2) /\
    List.Tot.index (List.Tot.append l1 l2) i ==
    List.Tot.index l2 (i - List.Tot.length l1)
  ))
  (decreases l1)
= List.Tot.append_length l1 l2; // TODO: replace/augment the patterns on @ with patterns on List.Tot.append
  match l1 with
  | [] -> ()
  | _ :: l1' ->
    list_append_index_r l1' l2 (i - 1)


(* TODO: move to FStar.Buffer or FStar.HyperStack? *)
   
let modifies_tip_popped h0 h1 h2 h3 : Lemma
  (requires (HS.fresh_frame h0 h1 /\ HS.popped h2 h3 /\ HS.modifies_one h1.HS.tip h1 h2 /\ h1.HS.tip == h2.HS.tip))
  (ensures  (B.modifies_none h0 h3))
  = ()

(* TODO: move to C.Loops *)
(* To be extracted as:
    for (int i = <start>; i != <finish>; ++i)
      <f> i;
*)
(*
val for_with_ghost_state:
  (#gt: Type0) ->
  start:UInt32.t ->
  finish:UInt32.t{UInt32.v finish >= UInt32.v start} ->
  gt_start: Ghost.erased gt ->
  inv:(HS.mem -> nat -> gt -> GTot Type0) ->
  f:(
    i:UInt32.t{FStar.UInt32.(v start <= v i /\ v i < v finish)} ->
    g : Ghost.erased gt ->
    HST.Stack (Ghost.erased gt)
    (requires (fun h -> inv h (UInt32.v i) (Ghost.reveal g)))
    (ensures (fun h_1 g' h_2 -> FStar.UInt32.(inv h_1 (v i) (Ghost.reveal g) /\ inv h_2 (v i + 1) (Ghost.reveal g'))))
  ) ->
  HST.Stack (Ghost.erased gt)
    (requires (fun h -> inv h (UInt32.v start) (Ghost.reveal gt_start)))
    (ensures (fun _ g' h_2 -> inv h_2 (UInt32.v finish) (Ghost.reveal g')))
let rec for_with_ghost_state #gt start finish gt_start inv f =
  if start = finish then
    gt_start
  else begin
    let g' = f start gt_start in
    for_with_ghost_state (FStar.UInt32.(start +^ 1ul)) finish g' inv f
  end
*)

val list_head
  (#t: Type0)
  (p: P.parser t)
  (b: S.bslice)
: HST.Stack S.bslice
  (requires (fun h ->
    S.live h b /\ (
    let sq = S.as_seq h b in
    let pl = parse_list p sq in (
    Some? pl /\ (
    let (Some (l, _)) = pl in (
    Cons? l
  ))))))
  (ensures (fun h b' h' ->
    B.modifies_none h h' /\
    S.live h b /\
    S.live h b' /\
    B.includes b.S.p b'.S.p /\ (
    let sq = S.as_seq h b in
    let pl = parse_list p sq in (
    Some? pl /\ (
    let (Some (l, _)) = pl in (
    Cons? l /\ (
    let sq' = S.as_seq h b' in
    let pb' = p sq' in (
    Some? pb' /\ (
    let (Some (v, _)) = pb' in (
    v == List.Tot.hd l
  ))))))))))

let list_head #t p b = b

val list_tail
  (#t: Type0)
  (#p: P.parser t)
  (sv: P.stateful_validator_nochk p)
  (b: S.bslice)
: HST.Stack S.bslice
  (requires (fun h ->
    S.live h b /\ (
    let sq = S.as_seq h b in
    let pl = parse_list p sq in (
    Some? pl /\ (
    let (Some (l, _)) = pl in (
    Cons? l
  ))))))
  (ensures (fun h b' h' ->
    B.modifies_none h h' /\
    S.live h b /\
    S.live h b' /\
    B.includes b.S.p b'.S.p /\ (
    let sq = S.as_seq h b in
    let pl = parse_list p sq in (
    Some? pl /\ (
    let (Some (l, _)) = pl in (
    Cons? l /\ (
    let sq' = S.as_seq h b' in
    let pb' = parse_list p sq' in (
    Some? pb' /\ (
    let (Some (v, _)) = pb' in (
    v == List.Tot.tl l
  ))))))))))

let list_tail #t #p sv b =
  let off = sv b in
  let b' = S.advance_slice b off in
  b'

val list_is_empty
  (#t: Type0)
  (p: P.parser t)
  (b: S.bslice)
: HST.Stack bool
  (requires (fun h ->
    S.live h b /\ (
    let sq = S.as_seq h b in
    let pl = parse_list p sq in
    Some? pl
  )))
  (ensures (fun h b' h' ->
    B.modifies_none h h' /\
    S.live h b /\ (
    let sq = S.as_seq h b in
    let pl = parse_list p sq in (
    Some? pl /\ (
    let (Some (l, _)) = pl in (
    b' == Nil? l
  ))))))

let list_is_empty #t p b =
  b.S.len = 0ul

let index_tail
  (#a: Type0)
  (l: list a)
  (i: nat)
: Lemma
  (requires (
    i < List.Tot.length l /\
    0 < i
  ))
  (ensures (
    i < List.Tot.length l /\
    0 < i /\
    List.Tot.index l i == List.Tot.index (List.Tot.tl l) (i - 1)
  ))
= ()

let list_nth_slice_precond
  (#t: Type0)
  (p: P.parser t)
  (sv: P.stateful_validator_nochk p)
  (b: S.bslice)
  (i: UInt32.t)
  (h: HS.mem)
: GTot Type0
=   S.live h b /\ (
    let sq = S.as_seq h b in
    let pl = parse_list p sq in (
    Some? pl /\ (
    let (Some (l, _)) = pl in
    UInt32.v i < List.Tot.length l
  )))

let list_nth_slice_inv
  (#t: Type0)
  (p: P.parser t)
  (sv: P.stateful_validator_nochk p)
  (b: S.bslice)
  (i: UInt32.t)
  (h0: Ghost.erased HS.mem)
  (sl: B.buffer S.bslice)
  (h: HS.mem)
  (j: nat)
: GTot Type0
= B.disjoint b.S.p sl /\
  B.length sl == 1 /\
  list_nth_slice_precond p sv b i (Ghost.reveal h0) /\
  B.modifies_1 sl (Ghost.reveal h0) h /\
  j <= UInt32.v i /\
  B.live h sl /\ (
  let b' = Seq.index (B.as_seq h sl) 0 in (
  S.live (Ghost.reveal h0) b' /\
  B.includes b.S.p b'.S.p /\ (
  let sq = S.as_seq (Ghost.reveal h0) b in
  let pl = parse_list p sq in (
  let (Some (l, _)) = pl in (
  let sq' = S.as_seq (Ghost.reveal h0) b' in
  let pb' = parse_list p sq' in (
  Some? pb' /\ (
  let (Some (lr, _)) = pb' in (
  List.Tot.length lr == List.Tot.length l - j /\
  List.Tot.index l (UInt32.v i) == List.Tot.index lr (UInt32.v i - j)
  ))))))))

val list_nth_slice_advance
  (#t: Type0)
  (p: P.parser t)
  (sv: P.stateful_validator_nochk p)
  (b: S.bslice)
  (i: UInt32.t)
  (h0: Ghost.erased HS.mem)
  (sl: B.buffer S.bslice)
  (j: UInt32.t)
: HST.Stack unit
  (requires (fun h ->
    list_nth_slice_inv p sv b i h0 sl h (UInt32.v j) /\
    UInt32.v j < UInt32.v i
  ))
  (ensures (fun h1 _ h2 ->
    list_nth_slice_inv p sv b i h0 sl h1 (UInt32.v j) /\
    UInt32.v j < UInt32.v i /\
    list_nth_slice_inv p sv b i h0 sl h2 (UInt32.v j + 1)
  ))

let list_nth_slice_advance #t p sv b i h0 sl j =
  let h1 = HST.get () in
  B.no_upd_lemma_1 (Ghost.reveal h0) h1 sl b.S.p;
  let s = B.index sl 0ul in
  assert (S.as_seq h1 s == S.as_seq (Ghost.reveal h0) s);
  let h2 = HST.get () in
  assert (B.modifies_1 sl h1 h2);
  assert (S.as_seq h2 s == S.as_seq (Ghost.reveal h0) s);
  let s' = list_tail sv s in
  let h3 = HST.get () in
  assert (B.modifies_none h2 h3);
  assert (S.as_seq h3 s == S.as_seq (Ghost.reveal h0) s);
  assert (S.as_seq h3 s' == S.as_seq (Ghost.reveal h0) s');
  B.lemma_intro_modifies_1 sl h2 h3;
  B.upd sl 0ul s';
  let h = HST.get () in
  assert (B.modifies_1 sl (Ghost.reveal h0) h);
  B.includes_trans b.S.p s.S.p s'.S.p;
  ()

val list_nth_slice
  (#t: Type0)
  (p: P.parser t)
  (sv: P.stateful_validator_nochk p)
  (b: S.bslice)
  (i: UInt32.t)
: HST.Stack S.bslice
  (requires (fun h ->
    S.live h b /\ (
    let sq = S.as_seq h b in
    let pl = parse_list p sq in (
    Some? pl /\ (
    let (Some (l, _)) = pl in (
    UInt32.v i < List.Tot.length l
  ))))))
  (ensures (fun h b' h' ->
    B.modifies_none h h' /\
    S.live h b /\
    S.live h b' /\
    B.includes b.S.p b'.S.p /\ (
    let sq = S.as_seq h b in
    let pl = parse_list p sq in (
    Some? pl /\ (
    let (Some (l, _)) = pl in (
    UInt32.v i < List.Tot.length l /\ (
    let sq' = S.as_seq h b' in
    let pb' = p sq' in (
    Some? pb' /\ (
    let (Some (v, _)) = pb' in (
    v == List.Tot.index l (UInt32.v i)
  ))))))))))

let list_nth_slice #t p sv b i =
  let h0 = HST.get () in
  HST.push_frame ();
  let h1 = HST.get () in
  let sl : B.buffer S.bslice = B.create b 1ul in
  let h2 = HST.get () in
  B.lemma_reveal_modifies_0 h1 h2; // I really need to switch to my new modifies clauses very soon!
  assert (S.as_seq h2 b == S.as_seq h0 b);
  assert (list_nth_slice_inv p sv b i (Ghost.hide h2) sl h2 0);
  C.Loops.for
    0ul
    i
    (fun h j -> list_nth_slice_inv p sv b i (Ghost.hide h2) sl h j)
    (fun j -> list_nth_slice_advance p sv b i (Ghost.hide h2) sl j)
  ;
  let h3 = HST.get () in
  B.lemma_reveal_modifies_1 sl h2 h3;
  let tail = B.index sl 0ul in
  let res = list_head p tail in
  let h4 = HST.get () in
  assert (S.as_seq h4 b == S.as_seq h0 b);
  assert (S.as_seq h4 res == S.as_seq h0 res);
  HST.pop_frame ();
  let h = HST.get () in
  assert (S.as_seq h b == S.as_seq h0 b);
  assert (S.as_seq h res == S.as_seq h0 res);
  res

let validate_list_inv
  (#t: Type0)
  (#p: P.parser t)
  (sv: P.stateful_validator p)
  (b: S.bslice)
  (h0: Ghost.erased HS.mem)
  (sl: B.buffer (option S.bslice))
  (h: HS.mem)
  (j: nat)
  (interrupt: bool)
: GTot Type0
= B.disjoint b.S.p sl /\
  B.length sl == 1 /\
  S.live (Ghost.reveal h0) b /\
  B.modifies_1 sl (Ghost.reveal h0) h /\
  B.live h sl /\ (
  let sq = S.as_seq (Ghost.reveal h0) b in
  let slo = Seq.index (B.as_seq h sl) 0 in
  if interrupt
  then
    (Some? slo ==> Some? (parse_list p sq))
  else (
    Some? slo /\ (
    let (Some sl) = slo in (
    B.includes b.S.p sl.S.p /\
    S.live (Ghost.reveal h0) sl /\
    j <= UInt32.v b.S.len /\
    UInt32.v sl.S.len <= UInt32.v b.S.len - j /\ (
    let sq' = S.as_seq (Ghost.reveal h0) sl in
    (Some? (parse_list p sq') ==> Some? (parse_list p sq))
  )))))

(*
  j <= UInt32.v i /\
  B.live h sl /\ (
  let b' = Seq.index (B.as_seq h sl) 0 in (
  S.live (Ghost.reveal h0) b' /\
  B.includes b.S.p b'.S.p /\ (
  let sq = S.as_seq (Ghost.reveal h0) b in
  let pl = parse_list p sq in (
  let (Some (l, _)) = pl in (
  let sq' = S.as_seq (Ghost.reveal h0) b' in
  let pb' = parse_list p sq' in (
  Some? pb' /\ (
  let (Some (lr, _)) = pb' in (
  List.Tot.length lr == List.Tot.length l - j /\
  List.Tot.index l (UInt32.v i) == List.Tot.index lr (UInt32.v i - j)
  ))))))))


val validate_list
  (#t: Type0)
  (#p: P.parser t)
  (v: P.stateful_validator p)
: P.stateful_validator (parse_list p)


(*
  HST.pop_frame ();
  res

(*





  let l : Ghost.erased (list t) =
    Ghost.elift1
      (fun () ->
	let sq = S.as_seq h1 b in
	let (Some (l, _)) = parse_list' p sq () in
	l
      )
      (Ghost.hide ())
  in
  let n : Ghost.erased nat =
    Ghost.elift1 List.Tot.length l
  in
  let inv1
    (h: HS.mem)
    (j: nat)
  : GTot Type0
  = HS.modifies_one h1.HS.tip h1 h
  in
  let inv
    (h: HS.mem)
    (j: nat)
  : GTot Type0
  = inv1 h j /\
    h.HS.tip == h1.HS.tip /\
    S.live h b /\
    B.live h sl /\ (
    let s = Seq.index (B.as_seq h sl) 0 in (
    B.includes b.S.p s.S.p /\
    S.live h s /\ (
    let sq = S.as_seq h s in
    let pl = parse_list' p sq () in (
    Some? pl /\ (
    let (Some (lr, _)) = pl in (
    j <= UInt32.v i /\
    List.Tot.length lr == Ghost.reveal n - j /\
    List.Tot.index (Ghost.reveal l) (UInt32.v i) == List.Tot.index lr (UInt32.v i - j)
    ))))))
  in
  assert (inv1 h2 0);
  assert (inv h2 0);
    (fun j ->
      let s = B.index sl 0ul in
      let s' = list_tail sv s in
      B.upd sl 0ul s';
      let h = HST.get () in
      let f () : Lemma (
	let sq' = S.as_seq h s' in
	let pl' = parse_list' p sq' () in (
	Some? pl' /\ (
	let (Some (lr', _)) = pl' in (
	List.Tot.index (Ghost.reveal l) (UInt32.v i) == List.Tot.index lr' (UInt32.v i - (UInt32.v j + 1))
      )))) =
	let sq = S.as_seq h s in
	let pl = parse_list' p sq () in
	assert (Some? pl);
	let (Some (lr, _)) = pl in
	assert (Cons? lr);
	let sq' = S.as_seq h s' in
	let pl' = parse_list' p sq' () in
	assert (Some? pl');
	let (Some (lr', _)) = pl' in
	assert (lr' == List.Tot.tl lr);
	index_tail lr (UInt32.v i - UInt32.v j)
      in
      f ()
    )
  in
  admit ()
  
  (*
  let h' = HST.get () in
  assume (inv h' (UInt32.v i));
  let res = B.index sl 0ul in
  HST.pop_frame ();
  let h = HST.get () in
  res


(*

  let correctness () : Lemma (
    let sq = S.as_seq h res in
    let (Some (v, _)) = p sq in (
    v == List.Tot.index (Ghost.reveal l) (UInt32.v i)
  )) =
    let sq = S.as_seq h res in
    let (Some (lr, _)) = parse_list' p sq () in
    list_append_index_r (Ghost.reveal ll) lr (UInt32.v i)
  in
  correctness ();
  let _ : squash (B.modifies_none h0 h) =
    assert (HS.fresh_frame h0 h1);
    assert (HS.modifies_one h1.HS.tip h1 h');
    assert (HS.popped h' h);
    modifies_tip_popped h0 h1 h' h
  in


let validate_list
  (#t: Type0)
  (#p: Ghost.erased (P.parser t))
  (v: P.stateful_validator p)
: P.stateful_validator (Ghost.elift1 (parse_list #t) p)
= fun input ->
    HST.push_frame ();
    let res = B.create 0ul 1ul in
    let valid = B.create false 1ul in
    assert (B.frameOf (S.BSlice?.p input) <> B.frameOf res);
    let h1 = HST.get () in
    let start : UInt32.t = 0ul in
    let finish : UInt32.t = S.BSlice?.len input in
    let inv
      (h: HS.mem)
      (i: nat)
      (interrupt: bool)
    : GTot Type0
    = h.HS.tip == h1.HS.tip /\
      HS.modifies h1.HS.tip h1 h /\
      
    in
    let f
      (i: UInt32.t { FStar.UInt32.(v start <= v i /\ v i < v finish) } )
    : HST.Stack bool
      (requires (fun h -> inv h (UInt32.v i) false))
      (ensures (fun h_1 b h_2 ->
	inv h_1 (UInt32.v i) false /\
	inv h_2 (UInt32.v i) b
      ))
    = let cur = B.index res 0ul in
      let s = S.advance_slice input cur in
      if S.BSlice?.len s = 0ul
      then begin
	B.upd valid 0ul true;
	true
      end else
	match v s with
	| Some off ->
	  if S.u32_add_overflows cur off
	  then true
	  else begin
	    advance_slice_advance_slice input cur off;
	    B.upd res 0ul (UInt32.add cur off);
	    false
	  end
	| _ -> true
    in
    let _ = C.Loops.interruptible_for start finish inv f in
    let final_valid = B.index valid 0ul in
    let final_result = B.index res 0ul in
    HST.pop_frame ();
    if final_valid then Some final_result else None
    


(*

let parse_sized2 (#t: Type0) (p: P.parser t) (sz: UInt16.t) = parse_sized p (UInt16.v sz)

let parse_vlbytes2 (#t: Type0) (p: P.parser t) : P.parser t =
  IP.parse_u16 `P.and_then` (parse_sized2 p)

let parse_sized4 (#t: Type0) (p: P.parser t) (sz: UInt32.t) = parse_sized p (UInt32.v sz)

let parse_vlbytes4 (#t: Type0) (p: P.parser t) : P.parser t =
  IP.parse_u32 `P.and_then` (parse_sized4 p)


let parse_vlbytes1_st
  (#t: Type0)
  (#p: Ghost.erased (P.parser t))
  (ps: P.parser_st p)
: P.parser_st (Ghost.elift1 (fun p' -> P.and_then IP.parse_u8 (parse_sized1 p')) p)
= P.


(*
let parse_vlbytes1 (#t: Type0) (p: P.parser t) : P.parser t =
  

  match IP.parse_u8 s with
  | None -> None
  | Some (len' , _) ->
    let s1 = Seq.slice s 1 (Seq.length s) in
    let len = UInt8.v len' in
    if Seq.length s1 < len
    then None
    else
      let s2 = Seq.slice s1 0 len in
      match p s2 with
      | Some (v, consumed) ->
	if consumed = len
	then Some (v, 1 + len)
	else None
      | _ -> None

(*
let pure_vlbytes_prop (n: nat) (s: nat * S.bytes) : GTot Type0 =
  let (len, pl) = s in (
    len < pow2 n /\
    Seq.length pl == len
  )

let pure_vlbytes (n: nat) : Tot Type0 = (s: (nat * S.bytes) { pure_vlbytes_prop n s } )

let parse_uint (n: nat) : 
  

let repr_psk_identifier = vlbytes
