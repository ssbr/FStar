
open Prims

let trans_aqual : FStar_Parser_AST.arg_qualifier Prims.option  ->  FStar_Syntax_Syntax.arg_qualifier Prims.option = (fun uu___183_5 -> (match (uu___183_5) with
| Some (FStar_Parser_AST.Implicit) -> begin
Some (FStar_Syntax_Syntax.imp_tag)
end
| Some (FStar_Parser_AST.Equality) -> begin
Some (FStar_Syntax_Syntax.Equality)
end
| uu____8 -> begin
None
end))


let trans_qual : FStar_Range.range  ->  FStar_Ident.lident Prims.option  ->  FStar_Parser_AST.qualifier  ->  FStar_Syntax_Syntax.qualifier = (fun r maybe_effect_id uu___184_19 -> (match (uu___184_19) with
| FStar_Parser_AST.Private -> begin
FStar_Syntax_Syntax.Private
end
| FStar_Parser_AST.Assumption -> begin
FStar_Syntax_Syntax.Assumption
end
| FStar_Parser_AST.Unfold_for_unification_and_vcgen -> begin
FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen
end
| FStar_Parser_AST.Inline_for_extraction -> begin
FStar_Syntax_Syntax.Inline_for_extraction
end
| FStar_Parser_AST.NoExtract -> begin
FStar_Syntax_Syntax.NoExtract
end
| FStar_Parser_AST.Irreducible -> begin
FStar_Syntax_Syntax.Irreducible
end
| FStar_Parser_AST.Logic -> begin
FStar_Syntax_Syntax.Logic
end
| FStar_Parser_AST.TotalEffect -> begin
FStar_Syntax_Syntax.TotalEffect
end
| FStar_Parser_AST.Effect_qual -> begin
FStar_Syntax_Syntax.Effect
end
| FStar_Parser_AST.New -> begin
FStar_Syntax_Syntax.New
end
| FStar_Parser_AST.Abstract -> begin
FStar_Syntax_Syntax.Abstract
end
| FStar_Parser_AST.Opaque -> begin
((FStar_Errors.warn r "The \'opaque\' qualifier is deprecated since its use was strangely schizophrenic. There were two overloaded uses: (1) Given \'opaque val f : t\', the behavior was to exclude the definition of \'f\' to the SMT solver. This corresponds roughly to the new \'irreducible\' qualifier. (2) Given \'opaque type t = t\'\', the behavior was to provide the definition of \'t\' to the SMT solver, but not to inline it, unless absolutely required for unification. This corresponds roughly to the behavior of \'unfoldable\' (which is currently the default).");
FStar_Syntax_Syntax.Visible_default;
)
end
| FStar_Parser_AST.Reflectable -> begin
(match (maybe_effect_id) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((("Qualifier reflect only supported on effects"), (r)))))
end
| Some (effect_id) -> begin
FStar_Syntax_Syntax.Reflectable (effect_id)
end)
end
| FStar_Parser_AST.Reifiable -> begin
FStar_Syntax_Syntax.Reifiable
end
| FStar_Parser_AST.Noeq -> begin
FStar_Syntax_Syntax.Noeq
end
| FStar_Parser_AST.Unopteq -> begin
FStar_Syntax_Syntax.Unopteq
end
| FStar_Parser_AST.DefaultEffect -> begin
(Prims.raise (FStar_Errors.Error ((("The \'default\' qualifier on effects is no longer supported"), (r)))))
end
| (FStar_Parser_AST.Inline) | (FStar_Parser_AST.Visible) -> begin
(Prims.raise (FStar_Errors.Error ((("Unsupported qualifier"), (r)))))
end))


let trans_pragma : FStar_Parser_AST.pragma  ->  FStar_Syntax_Syntax.pragma = (fun uu___185_25 -> (match (uu___185_25) with
| FStar_Parser_AST.SetOptions (s) -> begin
FStar_Syntax_Syntax.SetOptions (s)
end
| FStar_Parser_AST.ResetOptions (sopt) -> begin
FStar_Syntax_Syntax.ResetOptions (sopt)
end
| FStar_Parser_AST.LightOff -> begin
FStar_Syntax_Syntax.LightOff
end))


let as_imp : FStar_Parser_AST.imp  ->  FStar_Syntax_Syntax.arg_qualifier Prims.option = (fun uu___186_32 -> (match (uu___186_32) with
| FStar_Parser_AST.Hash -> begin
Some (FStar_Syntax_Syntax.imp_tag)
end
| uu____34 -> begin
None
end))


let arg_withimp_e = (fun imp t -> ((t), ((as_imp imp))))


let arg_withimp_t = (fun imp t -> (match (imp) with
| FStar_Parser_AST.Hash -> begin
((t), (Some (FStar_Syntax_Syntax.imp_tag)))
end
| uu____67 -> begin
((t), (None))
end))


let contains_binder : FStar_Parser_AST.binder Prims.list  ->  Prims.bool = (fun binders -> (FStar_All.pipe_right binders (FStar_Util.for_some (fun b -> (match (b.FStar_Parser_AST.b) with
| FStar_Parser_AST.Annotated (uu____76) -> begin
true
end
| uu____79 -> begin
false
end)))))


let rec unparen : FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Paren (t) -> begin
(unparen t)
end
| uu____84 -> begin
t
end))


let tm_type_z : FStar_Range.range  ->  FStar_Parser_AST.term = (fun r -> (let _0_382 = FStar_Parser_AST.Name ((FStar_Ident.lid_of_path (("Type0")::[]) r))
in (FStar_Parser_AST.mk_term _0_382 r FStar_Parser_AST.Kind)))


let tm_type : FStar_Range.range  ->  FStar_Parser_AST.term = (fun r -> (let _0_383 = FStar_Parser_AST.Name ((FStar_Ident.lid_of_path (("Type")::[]) r))
in (FStar_Parser_AST.mk_term _0_383 r FStar_Parser_AST.Kind)))


let rec is_comp_type : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.term  ->  Prims.bool = (fun env t -> (match (t.FStar_Parser_AST.tm) with
| (FStar_Parser_AST.Name (l)) | (FStar_Parser_AST.Construct (l, _)) -> begin
(let _0_384 = (FStar_ToSyntax_Env.try_lookup_effect_name env l)
in (FStar_All.pipe_right _0_384 FStar_Option.isSome))
end
| FStar_Parser_AST.App (head, uu____104, uu____105) -> begin
(is_comp_type env head)
end
| (FStar_Parser_AST.Paren (t)) | (FStar_Parser_AST.Ascribed (t, _)) | (FStar_Parser_AST.LetOpen (_, t)) -> begin
(is_comp_type env t)
end
| uu____109 -> begin
false
end))


let unit_ty : FStar_Parser_AST.term = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.unit_lid)) FStar_Range.dummyRange FStar_Parser_AST.Type_level)


let compile_op_lid : Prims.int  ->  Prims.string  ->  FStar_Range.range  ->  FStar_Ident.lident = (fun n s r -> (let _0_387 = (let _0_386 = (FStar_Ident.mk_ident (let _0_385 = (FStar_Parser_AST.compile_op n s)
in ((_0_385), (r))))
in (_0_386)::[])
in (FStar_All.pipe_right _0_387 FStar_Ident.lid_of_ids)))


let op_as_term : FStar_ToSyntax_Env.env  ->  Prims.int  ->  FStar_Range.range  ->  Prims.string  ->  FStar_Syntax_Syntax.term Prims.option = (fun env arity rng s -> (

let r = (fun l dd -> Some ((let _0_388 = (FStar_Syntax_Syntax.lid_as_fv (FStar_Ident.set_lid_range l rng) dd None)
in (FStar_All.pipe_right _0_388 FStar_Syntax_Syntax.fv_to_tm))))
in (

let fallback = (fun uu____146 -> (match (s) with
| "=" -> begin
(r FStar_Syntax_Const.op_Eq FStar_Syntax_Syntax.Delta_equational)
end
| ":=" -> begin
(r FStar_Syntax_Const.write_lid FStar_Syntax_Syntax.Delta_equational)
end
| "<" -> begin
(r FStar_Syntax_Const.op_LT FStar_Syntax_Syntax.Delta_equational)
end
| "<=" -> begin
(r FStar_Syntax_Const.op_LTE FStar_Syntax_Syntax.Delta_equational)
end
| ">" -> begin
(r FStar_Syntax_Const.op_GT FStar_Syntax_Syntax.Delta_equational)
end
| ">=" -> begin
(r FStar_Syntax_Const.op_GTE FStar_Syntax_Syntax.Delta_equational)
end
| "&&" -> begin
(r FStar_Syntax_Const.op_And FStar_Syntax_Syntax.Delta_equational)
end
| "||" -> begin
(r FStar_Syntax_Const.op_Or FStar_Syntax_Syntax.Delta_equational)
end
| "+" -> begin
(r FStar_Syntax_Const.op_Addition FStar_Syntax_Syntax.Delta_equational)
end
| "-" when (arity = (Prims.parse_int "1")) -> begin
(r FStar_Syntax_Const.op_Minus FStar_Syntax_Syntax.Delta_equational)
end
| "-" -> begin
(r FStar_Syntax_Const.op_Subtraction FStar_Syntax_Syntax.Delta_equational)
end
| "/" -> begin
(r FStar_Syntax_Const.op_Division FStar_Syntax_Syntax.Delta_equational)
end
| "%" -> begin
(r FStar_Syntax_Const.op_Modulus FStar_Syntax_Syntax.Delta_equational)
end
| "!" -> begin
(r FStar_Syntax_Const.read_lid FStar_Syntax_Syntax.Delta_equational)
end
| "@" -> begin
(

let uu____148 = (FStar_Options.ml_ish ())
in (match (uu____148) with
| true -> begin
(r FStar_Syntax_Const.list_append_lid FStar_Syntax_Syntax.Delta_equational)
end
| uu____150 -> begin
(r FStar_Syntax_Const.list_tot_append_lid FStar_Syntax_Syntax.Delta_equational)
end))
end
| "^" -> begin
(r FStar_Syntax_Const.strcat_lid FStar_Syntax_Syntax.Delta_equational)
end
| "|>" -> begin
(r FStar_Syntax_Const.pipe_right_lid FStar_Syntax_Syntax.Delta_equational)
end
| "<|" -> begin
(r FStar_Syntax_Const.pipe_left_lid FStar_Syntax_Syntax.Delta_equational)
end
| "<>" -> begin
(r FStar_Syntax_Const.op_notEq FStar_Syntax_Syntax.Delta_equational)
end
| "~" -> begin
(r FStar_Syntax_Const.not_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "2"))))
end
| "==" -> begin
(r FStar_Syntax_Const.eq2_lid FStar_Syntax_Syntax.Delta_constant)
end
| "<<" -> begin
(r FStar_Syntax_Const.precedes_lid FStar_Syntax_Syntax.Delta_constant)
end
| "/\\" -> begin
(r FStar_Syntax_Const.and_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))))
end
| "\\/" -> begin
(r FStar_Syntax_Const.or_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))))
end
| "==>" -> begin
(r FStar_Syntax_Const.imp_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))))
end
| "<==>" -> begin
(r FStar_Syntax_Const.iff_lid (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "2"))))
end
| uu____151 -> begin
None
end))
in (

let uu____152 = (let _0_389 = (compile_op_lid arity s rng)
in (FStar_ToSyntax_Env.try_lookup_lid env _0_389))
in (match (uu____152) with
| Some (t) -> begin
Some ((Prims.fst t))
end
| uu____162 -> begin
(fallback ())
end)))))


let sort_ftv : FStar_Ident.ident Prims.list  ->  FStar_Ident.ident Prims.list = (fun ftv -> (let _0_390 = (FStar_Util.remove_dups (fun x y -> (x.FStar_Ident.idText = y.FStar_Ident.idText)) ftv)
in (FStar_All.pipe_left (FStar_Util.sort_with (fun x y -> (FStar_String.compare x.FStar_Ident.idText y.FStar_Ident.idText))) _0_390)))


let rec free_type_vars_b : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.binder  ->  (FStar_ToSyntax_Env.env * FStar_Ident.ident Prims.list) = (fun env binder -> (match (binder.FStar_Parser_AST.b) with
| FStar_Parser_AST.Variable (uu____195) -> begin
((env), ([]))
end
| FStar_Parser_AST.TVariable (x) -> begin
(

let uu____198 = (FStar_ToSyntax_Env.push_bv env x)
in (match (uu____198) with
| (env, uu____205) -> begin
((env), ((x)::[]))
end))
end
| FStar_Parser_AST.Annotated (uu____207, term) -> begin
(let _0_391 = (free_type_vars env term)
in ((env), (_0_391)))
end
| FStar_Parser_AST.TAnnotated (id, uu____211) -> begin
(

let uu____212 = (FStar_ToSyntax_Env.push_bv env id)
in (match (uu____212) with
| (env, uu____219) -> begin
((env), ([]))
end))
end
| FStar_Parser_AST.NoName (t) -> begin
(let _0_392 = (free_type_vars env t)
in ((env), (_0_392)))
end))
and free_type_vars : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Ident.ident Prims.list = (fun env t -> (

let uu____225 = (unparen t).FStar_Parser_AST.tm
in (match (uu____225) with
| FStar_Parser_AST.Labeled (uu____227) -> begin
(failwith "Impossible --- labeled source term")
end
| FStar_Parser_AST.Tvar (a) -> begin
(

let uu____233 = (FStar_ToSyntax_Env.try_lookup_id env a)
in (match (uu____233) with
| None -> begin
(a)::[]
end
| uu____240 -> begin
[]
end))
end
| (FStar_Parser_AST.Wild) | (FStar_Parser_AST.Const (_)) | (FStar_Parser_AST.Uvar (_)) | (FStar_Parser_AST.Var (_)) | (FStar_Parser_AST.Projector (_)) | (FStar_Parser_AST.Discrim (_)) | (FStar_Parser_AST.Name (_)) -> begin
[]
end
| (FStar_Parser_AST.Assign (_, t)) | (FStar_Parser_AST.Requires (t, _)) | (FStar_Parser_AST.Ensures (t, _)) | (FStar_Parser_AST.NamedTyp (_, t)) | (FStar_Parser_AST.Paren (t)) | (FStar_Parser_AST.Ascribed (t, _)) -> begin
(free_type_vars env t)
end
| FStar_Parser_AST.Construct (uu____258, ts) -> begin
(FStar_List.collect (fun uu____268 -> (match (uu____268) with
| (t, uu____273) -> begin
(free_type_vars env t)
end)) ts)
end
| FStar_Parser_AST.Op (uu____274, ts) -> begin
(FStar_List.collect (free_type_vars env) ts)
end
| FStar_Parser_AST.App (t1, t2, uu____280) -> begin
(let _0_394 = (free_type_vars env t1)
in (let _0_393 = (free_type_vars env t2)
in (FStar_List.append _0_394 _0_393)))
end
| FStar_Parser_AST.Refine (b, t) -> begin
(

let uu____283 = (free_type_vars_b env b)
in (match (uu____283) with
| (env, f) -> begin
(let _0_395 = (free_type_vars env t)
in (FStar_List.append f _0_395))
end))
end
| (FStar_Parser_AST.Product (binders, body)) | (FStar_Parser_AST.Sum (binders, body)) -> begin
(

let uu____298 = (FStar_List.fold_left (fun uu____305 binder -> (match (uu____305) with
| (env, free) -> begin
(

let uu____317 = (free_type_vars_b env binder)
in (match (uu____317) with
| (env, f) -> begin
((env), ((FStar_List.append f free)))
end))
end)) ((env), ([])) binders)
in (match (uu____298) with
| (env, free) -> begin
(let _0_396 = (free_type_vars env body)
in (FStar_List.append free _0_396))
end))
end
| FStar_Parser_AST.Project (t, uu____336) -> begin
(free_type_vars env t)
end
| FStar_Parser_AST.Attributes (cattributes) -> begin
(FStar_List.collect (free_type_vars env) cattributes)
end
| (FStar_Parser_AST.Abs (_)) | (FStar_Parser_AST.Let (_)) | (FStar_Parser_AST.LetOpen (_)) | (FStar_Parser_AST.If (_)) | (FStar_Parser_AST.QForall (_)) | (FStar_Parser_AST.QExists (_)) | (FStar_Parser_AST.Record (_)) | (FStar_Parser_AST.Match (_)) | (FStar_Parser_AST.TryWith (_)) | (FStar_Parser_AST.Seq (_)) -> begin
[]
end)))


let head_and_args : FStar_Parser_AST.term  ->  (FStar_Parser_AST.term * (FStar_Parser_AST.term * FStar_Parser_AST.imp) Prims.list) = (fun t -> (

let rec aux = (fun args t -> (

let uu____375 = (unparen t).FStar_Parser_AST.tm
in (match (uu____375) with
| FStar_Parser_AST.App (t, arg, imp) -> begin
(aux ((((arg), (imp)))::args) t)
end
| FStar_Parser_AST.Construct (l, args') -> begin
(({FStar_Parser_AST.tm = FStar_Parser_AST.Name (l); FStar_Parser_AST.range = t.FStar_Parser_AST.range; FStar_Parser_AST.level = t.FStar_Parser_AST.level}), ((FStar_List.append args' args)))
end
| uu____399 -> begin
((t), (args))
end)))
in (aux [] t)))


let close : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun env t -> (

let ftv = (let _0_397 = (free_type_vars env t)
in (FStar_All.pipe_left sort_ftv _0_397))
in (match (((FStar_List.length ftv) = (Prims.parse_int "0"))) with
| true -> begin
t
end
| uu____417 -> begin
(

let binders = (FStar_All.pipe_right ftv (FStar_List.map (fun x -> (let _0_399 = FStar_Parser_AST.TAnnotated ((let _0_398 = (tm_type x.FStar_Ident.idRange)
in ((x), (_0_398))))
in (FStar_Parser_AST.mk_binder _0_399 x.FStar_Ident.idRange FStar_Parser_AST.Type_level (Some (FStar_Parser_AST.Implicit)))))))
in (

let result = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((binders), (t)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
in result))
end)))


let close_fun : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun env t -> (

let ftv = (let _0_400 = (free_type_vars env t)
in (FStar_All.pipe_left sort_ftv _0_400))
in (match (((FStar_List.length ftv) = (Prims.parse_int "0"))) with
| true -> begin
t
end
| uu____437 -> begin
(

let binders = (FStar_All.pipe_right ftv (FStar_List.map (fun x -> (let _0_402 = FStar_Parser_AST.TAnnotated ((let _0_401 = (tm_type x.FStar_Ident.idRange)
in ((x), (_0_401))))
in (FStar_Parser_AST.mk_binder _0_402 x.FStar_Ident.idRange FStar_Parser_AST.Type_level (Some (FStar_Parser_AST.Implicit)))))))
in (

let t = (

let uu____444 = (unparen t).FStar_Parser_AST.tm
in (match (uu____444) with
| FStar_Parser_AST.Product (uu____445) -> begin
t
end
| uu____449 -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.App ((((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.effect_Tot_lid)) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)), (t), (FStar_Parser_AST.Nothing)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
end))
in (

let result = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((binders), (t)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
in result)))
end)))


let rec uncurry : FStar_Parser_AST.binder Prims.list  ->  FStar_Parser_AST.term  ->  (FStar_Parser_AST.binder Prims.list * FStar_Parser_AST.term) = (fun bs t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Product (binders, t) -> begin
(uncurry (FStar_List.append bs binders) t)
end
| uu____470 -> begin
((bs), (t))
end))


let rec is_var_pattern : FStar_Parser_AST.pattern  ->  Prims.bool = (fun p -> (match (p.FStar_Parser_AST.pat) with
| (FStar_Parser_AST.PatWild) | (FStar_Parser_AST.PatTvar (_, _)) | (FStar_Parser_AST.PatVar (_, _)) -> begin
true
end
| FStar_Parser_AST.PatAscribed (p, uu____482) -> begin
(is_var_pattern p)
end
| uu____483 -> begin
false
end))


let rec is_app_pattern : FStar_Parser_AST.pattern  ->  Prims.bool = (fun p -> (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (p, uu____488) -> begin
(is_app_pattern p)
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (uu____489); FStar_Parser_AST.prange = uu____490}, uu____491) -> begin
true
end
| uu____497 -> begin
false
end))


let replace_unit_pattern : FStar_Parser_AST.pattern  ->  FStar_Parser_AST.pattern = (fun p -> (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatConst (FStar_Const.Const_unit) -> begin
(FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatAscribed ((((FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild p.FStar_Parser_AST.prange)), (unit_ty)))) p.FStar_Parser_AST.prange)
end
| uu____501 -> begin
p
end))


let rec destruct_app_pattern : FStar_ToSyntax_Env.env  ->  Prims.bool  ->  FStar_Parser_AST.pattern  ->  ((FStar_Ident.ident, FStar_Ident.lident) FStar_Util.either * FStar_Parser_AST.pattern Prims.list * FStar_Parser_AST.term Prims.option) = (fun env is_top_level p -> (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (p, t) -> begin
(

let uu____527 = (destruct_app_pattern env is_top_level p)
in (match (uu____527) with
| (name, args, uu____544) -> begin
((name), (args), (Some (t)))
end))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, uu____558); FStar_Parser_AST.prange = uu____559}, args) when is_top_level -> begin
(let _0_403 = FStar_Util.Inr ((FStar_ToSyntax_Env.qualify env id))
in ((_0_403), (args), (None)))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, uu____570); FStar_Parser_AST.prange = uu____571}, args) -> begin
((FStar_Util.Inl (id)), (args), (None))
end
| uu____581 -> begin
(failwith "Not an app pattern")
end))


let rec gather_pattern_bound_vars_maybe_top : FStar_Ident.ident FStar_Util.set  ->  FStar_Parser_AST.pattern  ->  FStar_Ident.ident FStar_Util.set = (fun acc p -> (

let gather_pattern_bound_vars_from_list = (FStar_List.fold_left gather_pattern_bound_vars_maybe_top acc)
in (match (p.FStar_Parser_AST.pat) with
| (FStar_Parser_AST.PatWild) | (FStar_Parser_AST.PatConst (_)) | (FStar_Parser_AST.PatVar (_, Some (FStar_Parser_AST.Implicit))) | (FStar_Parser_AST.PatName (_)) | (FStar_Parser_AST.PatTvar (_)) | (FStar_Parser_AST.PatOp (_)) -> begin
acc
end
| FStar_Parser_AST.PatApp (phead, pats) -> begin
(gather_pattern_bound_vars_from_list ((phead)::pats))
end
| FStar_Parser_AST.PatVar (x, uu____616) -> begin
(FStar_Util.set_add x acc)
end
| (FStar_Parser_AST.PatList (pats)) | (FStar_Parser_AST.PatTuple (pats, _)) | (FStar_Parser_AST.PatOr (pats)) -> begin
(gather_pattern_bound_vars_from_list pats)
end
| FStar_Parser_AST.PatRecord (guarded_pats) -> begin
(gather_pattern_bound_vars_from_list (FStar_List.map Prims.snd guarded_pats))
end
| FStar_Parser_AST.PatAscribed (pat, uu____632) -> begin
(gather_pattern_bound_vars_maybe_top acc pat)
end)))


let gather_pattern_bound_vars : FStar_Parser_AST.pattern  ->  FStar_Ident.ident FStar_Util.set = (

let acc = (FStar_Util.new_set (fun id1 id2 -> (match ((id1.FStar_Ident.idText = id2.FStar_Ident.idText)) with
| true -> begin
(Prims.parse_int "0")
end
| uu____640 -> begin
(Prims.parse_int "1")
end)) (fun uu____641 -> (Prims.parse_int "0")))
in (fun p -> (gather_pattern_bound_vars_maybe_top acc p)))

type bnd =
| LocalBinder of (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual)
| LetBinder of (FStar_Ident.lident * FStar_Syntax_Syntax.term)


let uu___is_LocalBinder : bnd  ->  Prims.bool = (fun projectee -> (match (projectee) with
| LocalBinder (_0) -> begin
true
end
| uu____659 -> begin
false
end))


let __proj__LocalBinder__item___0 : bnd  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual) = (fun projectee -> (match (projectee) with
| LocalBinder (_0) -> begin
_0
end))


let uu___is_LetBinder : bnd  ->  Prims.bool = (fun projectee -> (match (projectee) with
| LetBinder (_0) -> begin
true
end
| uu____679 -> begin
false
end))


let __proj__LetBinder__item___0 : bnd  ->  (FStar_Ident.lident * FStar_Syntax_Syntax.term) = (fun projectee -> (match (projectee) with
| LetBinder (_0) -> begin
_0
end))


let binder_of_bnd : bnd  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual) = (fun uu___187_697 -> (match (uu___187_697) with
| LocalBinder (a, aq) -> begin
((a), (aq))
end
| uu____702 -> begin
(failwith "Impossible")
end))


let as_binder : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.arg_qualifier Prims.option  ->  (FStar_Ident.ident Prims.option * FStar_Syntax_Syntax.term)  ->  (FStar_Syntax_Syntax.binder * FStar_ToSyntax_Env.env) = (fun env imp uu___188_719 -> (match (uu___188_719) with
| (None, k) -> begin
(let _0_404 = (FStar_Syntax_Syntax.null_binder k)
in ((_0_404), (env)))
end
| (Some (a), k) -> begin
(

let uu____731 = (FStar_ToSyntax_Env.push_bv env a)
in (match (uu____731) with
| (env, a) -> begin
(((((

let uu___209_742 = a
in {FStar_Syntax_Syntax.ppname = uu___209_742.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = uu___209_742.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k})), ((trans_aqual imp)))), (env))
end))
end))


type env_t =
FStar_ToSyntax_Env.env


type lenv_t =
FStar_Syntax_Syntax.bv Prims.list


let mk_lb : ((FStar_Syntax_Syntax.bv, FStar_Syntax_Syntax.fv) FStar_Util.either * (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax * (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax)  ->  FStar_Syntax_Syntax.letbinding = (fun uu____755 -> (match (uu____755) with
| (n, t, e) -> begin
{FStar_Syntax_Syntax.lbname = n; FStar_Syntax_Syntax.lbunivs = []; FStar_Syntax_Syntax.lbtyp = t; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_ALL_lid; FStar_Syntax_Syntax.lbdef = e}
end))


let no_annot_abs : (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual) Prims.list  ->  FStar_Syntax_Syntax.term  ->  FStar_Syntax_Syntax.term = (fun bs t -> (FStar_Syntax_Util.abs bs t None))


let mk_ref_read = (fun tm -> (

let tm' = FStar_Syntax_Syntax.Tm_app ((let _0_408 = (FStar_Syntax_Syntax.fv_to_tm (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.sread_lid FStar_Syntax_Syntax.Delta_constant None))
in (let _0_407 = (let _0_406 = (let _0_405 = (FStar_Syntax_Syntax.as_implicit false)
in ((tm), (_0_405)))
in (_0_406)::[])
in ((_0_408), (_0_407)))))
in (FStar_Syntax_Syntax.mk tm' None tm.FStar_Syntax_Syntax.pos)))


let mk_ref_alloc = (fun tm -> (

let tm' = FStar_Syntax_Syntax.Tm_app ((let _0_412 = (FStar_Syntax_Syntax.fv_to_tm (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.salloc_lid FStar_Syntax_Syntax.Delta_constant None))
in (let _0_411 = (let _0_410 = (let _0_409 = (FStar_Syntax_Syntax.as_implicit false)
in ((tm), (_0_409)))
in (_0_410)::[])
in ((_0_412), (_0_411)))))
in (FStar_Syntax_Syntax.mk tm' None tm.FStar_Syntax_Syntax.pos)))


let mk_ref_assign = (fun t1 t2 pos -> (

let tm = FStar_Syntax_Syntax.Tm_app ((let _0_419 = (FStar_Syntax_Syntax.fv_to_tm (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.swrite_lid FStar_Syntax_Syntax.Delta_constant None))
in (let _0_418 = (let _0_417 = (let _0_413 = (FStar_Syntax_Syntax.as_implicit false)
in ((t1), (_0_413)))
in (let _0_416 = (let _0_415 = (let _0_414 = (FStar_Syntax_Syntax.as_implicit false)
in ((t2), (_0_414)))
in (_0_415)::[])
in (_0_417)::_0_416))
in ((_0_419), (_0_418)))))
in (FStar_Syntax_Syntax.mk tm None pos)))


let is_special_effect_combinator : Prims.string  ->  Prims.bool = (fun uu___189_918 -> (match (uu___189_918) with
| ("repr") | ("post") | ("pre") | ("wp") -> begin
true
end
| uu____919 -> begin
false
end))


let rec sum_to_universe : FStar_Syntax_Syntax.universe  ->  Prims.int  ->  FStar_Syntax_Syntax.universe = (fun u n -> (match ((n = (Prims.parse_int "0"))) with
| true -> begin
u
end
| uu____926 -> begin
FStar_Syntax_Syntax.U_succ ((sum_to_universe u (n - (Prims.parse_int "1"))))
end))


let int_to_universe : Prims.int  ->  FStar_Syntax_Syntax.universe = (fun n -> (sum_to_universe FStar_Syntax_Syntax.U_zero n))


let rec desugar_maybe_non_constant_universe : FStar_Parser_AST.term  ->  (Prims.int, FStar_Syntax_Syntax.universe) FStar_Util.either = (fun t -> (

let uu____937 = (unparen t).FStar_Parser_AST.tm
in (match (uu____937) with
| FStar_Parser_AST.Wild -> begin
FStar_Util.Inr (FStar_Syntax_Syntax.U_unif ((FStar_Unionfind.fresh None)))
end
| FStar_Parser_AST.Uvar (u) -> begin
FStar_Util.Inr (FStar_Syntax_Syntax.U_name (u))
end
| FStar_Parser_AST.Const (FStar_Const.Const_int (repr, uu____943)) -> begin
(

let n = (FStar_Util.int_of_string repr)
in ((match ((n < (Prims.parse_int "0"))) with
| true -> begin
(Prims.raise (FStar_Errors.Error ((((Prims.strcat "Negative universe constant  are not supported : " repr)), (t.FStar_Parser_AST.range)))))
end
| uu____952 -> begin
()
end);
FStar_Util.Inl (n);
))
end
| FStar_Parser_AST.Op (op_plus, (t1)::(t2)::[]) -> begin
(

let u1 = (desugar_maybe_non_constant_universe t1)
in (

let u2 = (desugar_maybe_non_constant_universe t2)
in (match (((u1), (u2))) with
| (FStar_Util.Inl (n1), FStar_Util.Inl (n2)) -> begin
FStar_Util.Inl ((n1 + n2))
end
| ((FStar_Util.Inl (n), FStar_Util.Inr (u))) | ((FStar_Util.Inr (u), FStar_Util.Inl (n))) -> begin
FStar_Util.Inr ((sum_to_universe u n))
end
| (FStar_Util.Inr (u1), FStar_Util.Inr (u2)) -> begin
(Prims.raise (FStar_Errors.Error ((let _0_421 = (let _0_420 = (FStar_Parser_AST.term_to_string t)
in (Prims.strcat "This universe might contain a sum of two universe variables " _0_420))
in ((_0_421), (t.FStar_Parser_AST.range))))))
end)))
end
| FStar_Parser_AST.App (uu____994) -> begin
(

let rec aux = (fun t univargs -> (

let uu____1013 = (unparen t).FStar_Parser_AST.tm
in (match (uu____1013) with
| FStar_Parser_AST.App (t, targ, uu____1018) -> begin
(

let uarg = (desugar_maybe_non_constant_universe targ)
in (aux t ((uarg)::univargs)))
end
| FStar_Parser_AST.Var (max_lid) -> begin
(match ((FStar_List.existsb (fun uu___190_1030 -> (match (uu___190_1030) with
| FStar_Util.Inr (uu____1033) -> begin
true
end
| uu____1034 -> begin
false
end)) univargs)) with
| true -> begin
FStar_Util.Inr (FStar_Syntax_Syntax.U_max ((FStar_List.map (fun uu___191_1039 -> (match (uu___191_1039) with
| FStar_Util.Inl (n) -> begin
(int_to_universe n)
end
| FStar_Util.Inr (u) -> begin
u
end)) univargs)))
end
| uu____1044 -> begin
(

let nargs = (FStar_List.map (fun uu___192_1049 -> (match (uu___192_1049) with
| FStar_Util.Inl (n) -> begin
n
end
| FStar_Util.Inr (uu____1053) -> begin
(failwith "impossible")
end)) univargs)
in FStar_Util.Inl ((FStar_List.fold_left (fun m n -> (match ((m > n)) with
| true -> begin
m
end
| uu____1056 -> begin
n
end)) (Prims.parse_int "0") nargs)))
end)
end
| uu____1057 -> begin
(Prims.raise (FStar_Errors.Error ((let _0_424 = (let _0_423 = (let _0_422 = (FStar_Parser_AST.term_to_string t)
in (Prims.strcat _0_422 " in universe context"))
in (Prims.strcat "Unexpected term " _0_423))
in ((_0_424), (t.FStar_Parser_AST.range))))))
end)))
in (aux t []))
end
| uu____1062 -> begin
(Prims.raise (FStar_Errors.Error ((let _0_427 = (let _0_426 = (let _0_425 = (FStar_Parser_AST.term_to_string t)
in (Prims.strcat _0_425 " in universe context"))
in (Prims.strcat "Unexpected term " _0_426))
in ((_0_427), (t.FStar_Parser_AST.range))))))
end)))


let rec desugar_universe : FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.universe = (fun t -> (

let u = (desugar_maybe_non_constant_universe t)
in (match (u) with
| FStar_Util.Inl (n) -> begin
(int_to_universe n)
end
| FStar_Util.Inr (u) -> begin
u
end)))


let check_fields = (fun env fields rg -> (

let uu____1096 = (FStar_List.hd fields)
in (match (uu____1096) with
| (f, uu____1102) -> begin
(

let record = (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_record_by_field_name env) f)
in (

let check_field = (fun uu____1109 -> (match (uu____1109) with
| (f', uu____1113) -> begin
(

let uu____1114 = (FStar_ToSyntax_Env.belongs_to_record env f' record)
in (match (uu____1114) with
| true -> begin
()
end
| uu____1115 -> begin
(

let msg = (FStar_Util.format3 "Field %s belongs to record type %s, whereas field %s does not" f.FStar_Ident.str record.FStar_ToSyntax_Env.typename.FStar_Ident.str f'.FStar_Ident.str)
in (Prims.raise (FStar_Errors.Error (((msg), (rg))))))
end))
end))
in ((let _0_428 = (FStar_List.tl fields)
in (FStar_List.iter check_field _0_428));
(match (()) with
| () -> begin
record
end);
)))
end)))


let rec desugar_data_pat : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.pattern  ->  Prims.bool  ->  (env_t * bnd * FStar_Syntax_Syntax.pat) = (fun env p is_mut -> (

let check_linear_pattern_variables = (fun p -> (

let rec pat_vars = (fun p -> (match (p.FStar_Syntax_Syntax.v) with
| (FStar_Syntax_Syntax.Pat_dot_term (_)) | (FStar_Syntax_Syntax.Pat_wild (_)) | (FStar_Syntax_Syntax.Pat_constant (_)) -> begin
FStar_Syntax_Syntax.no_names
end
| FStar_Syntax_Syntax.Pat_var (x) -> begin
(FStar_Util.set_add x FStar_Syntax_Syntax.no_names)
end
| FStar_Syntax_Syntax.Pat_cons (uu____1272, pats) -> begin
(FStar_All.pipe_right pats (FStar_List.fold_left (fun out uu____1294 -> (match (uu____1294) with
| (p, uu____1300) -> begin
(let _0_429 = (pat_vars p)
in (FStar_Util.set_union out _0_429))
end)) FStar_Syntax_Syntax.no_names))
end
| FStar_Syntax_Syntax.Pat_disj ([]) -> begin
(failwith "Impossible")
end
| FStar_Syntax_Syntax.Pat_disj ((hd)::tl) -> begin
(

let xs = (pat_vars hd)
in (

let uu____1313 = (not ((FStar_Util.for_all (fun p -> (

let ys = (pat_vars p)
in ((FStar_Util.set_is_subset_of xs ys) && (FStar_Util.set_is_subset_of ys xs)))) tl)))
in (match (uu____1313) with
| true -> begin
(Prims.raise (FStar_Errors.Error ((("Disjunctive pattern binds different variables in each case"), (p.FStar_Syntax_Syntax.p)))))
end
| uu____1316 -> begin
xs
end)))
end))
in (pat_vars p)))
in ((match (((is_mut), (p.FStar_Parser_AST.pat))) with
| ((false, _)) | ((true, FStar_Parser_AST.PatVar (_))) -> begin
()
end
| (true, uu____1320) -> begin
(Prims.raise (FStar_Errors.Error ((("let-mutable is for variables only"), (p.FStar_Parser_AST.prange)))))
end);
(

let push_bv_maybe_mut = (match (is_mut) with
| true -> begin
FStar_ToSyntax_Env.push_bv_mutable
end
| uu____1334 -> begin
FStar_ToSyntax_Env.push_bv
end)
in (

let resolvex = (fun l e x -> (

let uu____1348 = (FStar_All.pipe_right l (FStar_Util.find_opt (fun y -> (y.FStar_Syntax_Syntax.ppname.FStar_Ident.idText = x.FStar_Ident.idText))))
in (match (uu____1348) with
| Some (y) -> begin
((l), (e), (y))
end
| uu____1356 -> begin
(

let uu____1358 = (push_bv_maybe_mut e x)
in (match (uu____1358) with
| (e, x) -> begin
(((x)::l), (e), (x))
end))
end)))
in (

let rec aux = (fun loc env p -> (

let pos = (fun q -> (FStar_Syntax_Syntax.withinfo q FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n p.FStar_Parser_AST.prange))
in (

let pos_r = (fun r q -> (FStar_Syntax_Syntax.withinfo q FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n r))
in (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatOp (op) -> begin
(let _0_432 = (let _0_431 = FStar_Parser_AST.PatVar ((let _0_430 = (FStar_Ident.id_of_text (FStar_Parser_AST.compile_op (Prims.parse_int "0") op))
in ((_0_430), (None))))
in {FStar_Parser_AST.pat = _0_431; FStar_Parser_AST.prange = p.FStar_Parser_AST.prange})
in (aux loc env _0_432))
end
| FStar_Parser_AST.PatOr ([]) -> begin
(failwith "impossible")
end
| FStar_Parser_AST.PatOr ((p)::ps) -> begin
(

let uu____1418 = (aux loc env p)
in (match (uu____1418) with
| (loc, env, var, p, uu____1437) -> begin
(

let uu____1442 = (FStar_List.fold_left (fun uu____1455 p -> (match (uu____1455) with
| (loc, env, ps) -> begin
(

let uu____1478 = (aux loc env p)
in (match (uu____1478) with
| (loc, env, uu____1494, p, uu____1496) -> begin
((loc), (env), ((p)::ps))
end))
end)) ((loc), (env), ([])) ps)
in (match (uu____1442) with
| (loc, env, ps) -> begin
(

let pat = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_disj ((p)::(FStar_List.rev ps))))
in ((loc), (env), (var), (pat), (false)))
end))
end))
end
| FStar_Parser_AST.PatAscribed (p, t) -> begin
(

let uu____1540 = (aux loc env p)
in (match (uu____1540) with
| (loc, env', binder, p, imp) -> begin
(

let binder = (match (binder) with
| LetBinder (uu____1565) -> begin
(failwith "impossible")
end
| LocalBinder (x, aq) -> begin
(

let t = (let _0_433 = (close_fun env t)
in (desugar_term env _0_433))
in ((match ((match (x.FStar_Syntax_Syntax.sort.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_unknown -> begin
false
end
| uu____1572 -> begin
true
end)) with
| true -> begin
(let _0_436 = (FStar_Syntax_Print.bv_to_string x)
in (let _0_435 = (FStar_Syntax_Print.term_to_string x.FStar_Syntax_Syntax.sort)
in (let _0_434 = (FStar_Syntax_Print.term_to_string t)
in (FStar_Util.print3_warning "Multiple ascriptions for %s in pattern, type %s was shadowed by %s" _0_436 _0_435 _0_434))))
end
| uu____1573 -> begin
()
end);
LocalBinder ((((

let uu___210_1574 = x
in {FStar_Syntax_Syntax.ppname = uu___210_1574.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = uu___210_1574.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = t})), (aq)));
))
end)
in ((loc), (env'), (binder), (p), (imp)))
end))
end
| FStar_Parser_AST.PatWild -> begin
(

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _0_437 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_wild (x)))
in ((loc), (env), (LocalBinder (((x), (None)))), (_0_437), (false))))
end
| FStar_Parser_AST.PatConst (c) -> begin
(

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _0_438 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_constant (c)))
in ((loc), (env), (LocalBinder (((x), (None)))), (_0_438), (false))))
end
| (FStar_Parser_AST.PatTvar (x, aq)) | (FStar_Parser_AST.PatVar (x, aq)) -> begin
(

let imp = (aq = Some (FStar_Parser_AST.Implicit))
in (

let aq = (trans_aqual aq)
in (

let uu____1600 = (resolvex loc env x)
in (match (uu____1600) with
| (loc, env, xbv) -> begin
(let _0_439 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_var (xbv)))
in ((loc), (env), (LocalBinder (((xbv), (aq)))), (_0_439), (imp)))
end))))
end
| FStar_Parser_AST.PatName (l) -> begin
(

let l = (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_datacon env) l)
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _0_440 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_cons (((l), ([])))))
in ((loc), (env), (LocalBinder (((x), (None)))), (_0_440), (false)))))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatName (l); FStar_Parser_AST.prange = uu____1637}, args) -> begin
(

let uu____1641 = (FStar_List.fold_right (fun arg uu____1659 -> (match (uu____1659) with
| (loc, env, args) -> begin
(

let uu____1689 = (aux loc env arg)
in (match (uu____1689) with
| (loc, env, uu____1707, arg, imp) -> begin
((loc), (env), ((((arg), (imp)))::args))
end))
end)) args ((loc), (env), ([])))
in (match (uu____1641) with
| (loc, env, args) -> begin
(

let l = (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_datacon env) l)
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _0_441 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_cons (((l), (args)))))
in ((loc), (env), (LocalBinder (((x), (None)))), (_0_441), (false)))))
end))
end
| FStar_Parser_AST.PatApp (uu____1766) -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected pattern"), (p.FStar_Parser_AST.prange)))))
end
| FStar_Parser_AST.PatList (pats) -> begin
(

let uu____1779 = (FStar_List.fold_right (fun pat uu____1793 -> (match (uu____1793) with
| (loc, env, pats) -> begin
(

let uu____1815 = (aux loc env pat)
in (match (uu____1815) with
| (loc, env, uu____1831, pat, uu____1833) -> begin
((loc), (env), ((pat)::pats))
end))
end)) pats ((loc), (env), ([])))
in (match (uu____1779) with
| (loc, env, pats) -> begin
(

let pat = (let _0_447 = (let _0_446 = (pos_r (FStar_Range.end_range p.FStar_Parser_AST.prange))
in (let _0_445 = FStar_Syntax_Syntax.Pat_cons ((let _0_444 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.nil_lid FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor)))
in ((_0_444), ([]))))
in (FStar_All.pipe_left _0_446 _0_445)))
in (FStar_List.fold_right (fun hd tl -> (

let r = (FStar_Range.union_ranges hd.FStar_Syntax_Syntax.p tl.FStar_Syntax_Syntax.p)
in (let _0_443 = FStar_Syntax_Syntax.Pat_cons ((let _0_442 = (FStar_Syntax_Syntax.lid_as_fv FStar_Syntax_Const.cons_lid FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor)))
in ((_0_442), ((((hd), (false)))::(((tl), (false)))::[]))))
in (FStar_All.pipe_left (pos_r r) _0_443)))) pats _0_447))
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in ((loc), (env), (LocalBinder (((x), (None)))), (pat), (false))))
end))
end
| FStar_Parser_AST.PatTuple (args, dep) -> begin
(

let uu____1920 = (FStar_List.fold_left (fun uu____1937 p -> (match (uu____1937) with
| (loc, env, pats) -> begin
(

let uu____1968 = (aux loc env p)
in (match (uu____1968) with
| (loc, env, uu____1986, pat, uu____1988) -> begin
((loc), (env), ((((pat), (false)))::pats))
end))
end)) ((loc), (env), ([])) args)
in (match (uu____1920) with
| (loc, env, args) -> begin
(

let args = (FStar_List.rev args)
in (

let l = (match (dep) with
| true -> begin
(FStar_Syntax_Util.mk_dtuple_data_lid (FStar_List.length args) p.FStar_Parser_AST.prange)
end
| uu____2051 -> begin
(FStar_Syntax_Util.mk_tuple_data_lid (FStar_List.length args) p.FStar_Parser_AST.prange)
end)
in (

let uu____2059 = (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_lid env) l)
in (match (uu____2059) with
| (constr, uu____2072) -> begin
(

let l = (match (constr.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) -> begin
fv
end
| uu____2075 -> begin
(failwith "impossible")
end)
in (

let x = (FStar_Syntax_Syntax.new_bv (Some (p.FStar_Parser_AST.prange)) FStar_Syntax_Syntax.tun)
in (let _0_448 = (FStar_All.pipe_left pos (FStar_Syntax_Syntax.Pat_cons (((l), (args)))))
in ((loc), (env), (LocalBinder (((x), (None)))), (_0_448), (false)))))
end))))
end))
end
| FStar_Parser_AST.PatRecord ([]) -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected pattern"), (p.FStar_Parser_AST.prange)))))
end
| FStar_Parser_AST.PatRecord (fields) -> begin
(

let record = (check_fields env fields p.FStar_Parser_AST.prange)
in (

let fields = (FStar_All.pipe_right fields (FStar_List.map (fun uu____2115 -> (match (uu____2115) with
| (f, p) -> begin
((f.FStar_Ident.ident), (p))
end))))
in (

let args = (FStar_All.pipe_right record.FStar_ToSyntax_Env.fields (FStar_List.map (fun uu____2130 -> (match (uu____2130) with
| (f, uu____2134) -> begin
(

let uu____2135 = (FStar_All.pipe_right fields (FStar_List.tryFind (fun uu____2147 -> (match (uu____2147) with
| (g, uu____2151) -> begin
(f.FStar_Ident.idText = g.FStar_Ident.idText)
end))))
in (match (uu____2135) with
| None -> begin
(FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild p.FStar_Parser_AST.prange)
end
| Some (uu____2154, p) -> begin
p
end))
end))))
in (

let app = (let _0_451 = FStar_Parser_AST.PatApp ((let _0_450 = (let _0_449 = FStar_Parser_AST.PatName ((FStar_Ident.lid_of_ids (FStar_List.append record.FStar_ToSyntax_Env.typename.FStar_Ident.ns ((record.FStar_ToSyntax_Env.constrname)::[]))))
in (FStar_Parser_AST.mk_pattern _0_449 p.FStar_Parser_AST.prange))
in ((_0_450), (args))))
in (FStar_Parser_AST.mk_pattern _0_451 p.FStar_Parser_AST.prange))
in (

let uu____2160 = (aux loc env app)
in (match (uu____2160) with
| (env, e, b, p, uu____2179) -> begin
(

let p = (match (p.FStar_Syntax_Syntax.v) with
| FStar_Syntax_Syntax.Pat_cons (fv, args) -> begin
(let _0_455 = FStar_Syntax_Syntax.Pat_cons ((let _0_454 = (

let uu___211_2208 = fv
in (let _0_453 = Some (FStar_Syntax_Syntax.Record_ctor ((let _0_452 = (FStar_All.pipe_right record.FStar_ToSyntax_Env.fields (FStar_List.map Prims.fst))
in ((record.FStar_ToSyntax_Env.typename), (_0_452)))))
in {FStar_Syntax_Syntax.fv_name = uu___211_2208.FStar_Syntax_Syntax.fv_name; FStar_Syntax_Syntax.fv_delta = uu___211_2208.FStar_Syntax_Syntax.fv_delta; FStar_Syntax_Syntax.fv_qual = _0_453}))
in ((_0_454), (args))))
in (FStar_All.pipe_left pos _0_455))
end
| uu____2219 -> begin
p
end)
in ((env), (e), (b), (p), (false)))
end))))))
end))))
in (

let uu____2222 = (aux [] env p)
in (match (uu____2222) with
| (uu____2233, env, b, p, uu____2237) -> begin
((let _0_456 = (check_linear_pattern_variables p)
in (FStar_All.pipe_left Prims.ignore _0_456));
((env), (b), (p));
)
end)))));
)))
and desugar_binding_pat_maybe_top : Prims.bool  ->  FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.pattern  ->  Prims.bool  ->  (env_t * bnd * FStar_Syntax_Syntax.pat Prims.option) = (fun top env p is_mut -> (

let mklet = (fun x -> (let _0_458 = LetBinder ((let _0_457 = (FStar_ToSyntax_Env.qualify env x)
in ((_0_457), (FStar_Syntax_Syntax.tun))))
in ((env), (_0_458), (None))))
in (match (top) with
| true -> begin
(match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatOp (x) -> begin
(mklet (FStar_Ident.id_of_text (FStar_Parser_AST.compile_op (Prims.parse_int "0") x)))
end
| FStar_Parser_AST.PatVar (x, uu____2272) -> begin
(mklet x)
end
| FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (x, uu____2276); FStar_Parser_AST.prange = uu____2277}, t) -> begin
(let _0_461 = LetBinder ((let _0_460 = (FStar_ToSyntax_Env.qualify env x)
in (let _0_459 = (desugar_term env t)
in ((_0_460), (_0_459)))))
in ((env), (_0_461), (None)))
end
| uu____2282 -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected pattern at the top-level"), (p.FStar_Parser_AST.prange)))))
end)
end
| uu____2287 -> begin
(

let uu____2288 = (desugar_data_pat env p is_mut)
in (match (uu____2288) with
| (env, binder, p) -> begin
(

let p = (match (p.FStar_Syntax_Syntax.v) with
| (FStar_Syntax_Syntax.Pat_var (_)) | (FStar_Syntax_Syntax.Pat_wild (_)) -> begin
None
end
| uu____2304 -> begin
Some (p)
end)
in ((env), (binder), (p)))
end))
end)))
and desugar_binding_pat : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.pattern  ->  (env_t * bnd * FStar_Syntax_Syntax.pat Prims.option) = (fun env p -> (desugar_binding_pat_maybe_top false env p false))
and desugar_match_pat_maybe_top : Prims.bool  ->  FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.pattern  ->  (env_t * FStar_Syntax_Syntax.pat) = (fun uu____2308 env pat -> (

let uu____2311 = (desugar_data_pat env pat false)
in (match (uu____2311) with
| (env, uu____2318, pat) -> begin
((env), (pat))
end)))
and desugar_match_pat : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.pattern  ->  (env_t * FStar_Syntax_Syntax.pat) = (fun env p -> (desugar_match_pat_maybe_top false env p))
and desugar_term : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun env e -> (

let env = (

let uu___212_2325 = env
in {FStar_ToSyntax_Env.curmodule = uu___212_2325.FStar_ToSyntax_Env.curmodule; FStar_ToSyntax_Env.curmonad = uu___212_2325.FStar_ToSyntax_Env.curmonad; FStar_ToSyntax_Env.modules = uu___212_2325.FStar_ToSyntax_Env.modules; FStar_ToSyntax_Env.scope_mods = uu___212_2325.FStar_ToSyntax_Env.scope_mods; FStar_ToSyntax_Env.exported_ids = uu___212_2325.FStar_ToSyntax_Env.exported_ids; FStar_ToSyntax_Env.trans_exported_ids = uu___212_2325.FStar_ToSyntax_Env.trans_exported_ids; FStar_ToSyntax_Env.includes = uu___212_2325.FStar_ToSyntax_Env.includes; FStar_ToSyntax_Env.sigaccum = uu___212_2325.FStar_ToSyntax_Env.sigaccum; FStar_ToSyntax_Env.sigmap = uu___212_2325.FStar_ToSyntax_Env.sigmap; FStar_ToSyntax_Env.iface = uu___212_2325.FStar_ToSyntax_Env.iface; FStar_ToSyntax_Env.admitted_iface = uu___212_2325.FStar_ToSyntax_Env.admitted_iface; FStar_ToSyntax_Env.expect_typ = false})
in (desugar_term_maybe_top false env e)))
and desugar_typ : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun env e -> (

let env = (

let uu___213_2329 = env
in {FStar_ToSyntax_Env.curmodule = uu___213_2329.FStar_ToSyntax_Env.curmodule; FStar_ToSyntax_Env.curmonad = uu___213_2329.FStar_ToSyntax_Env.curmonad; FStar_ToSyntax_Env.modules = uu___213_2329.FStar_ToSyntax_Env.modules; FStar_ToSyntax_Env.scope_mods = uu___213_2329.FStar_ToSyntax_Env.scope_mods; FStar_ToSyntax_Env.exported_ids = uu___213_2329.FStar_ToSyntax_Env.exported_ids; FStar_ToSyntax_Env.trans_exported_ids = uu___213_2329.FStar_ToSyntax_Env.trans_exported_ids; FStar_ToSyntax_Env.includes = uu___213_2329.FStar_ToSyntax_Env.includes; FStar_ToSyntax_Env.sigaccum = uu___213_2329.FStar_ToSyntax_Env.sigaccum; FStar_ToSyntax_Env.sigmap = uu___213_2329.FStar_ToSyntax_Env.sigmap; FStar_ToSyntax_Env.iface = uu___213_2329.FStar_ToSyntax_Env.iface; FStar_ToSyntax_Env.admitted_iface = uu___213_2329.FStar_ToSyntax_Env.admitted_iface; FStar_ToSyntax_Env.expect_typ = true})
in (desugar_term_maybe_top false env e)))
and desugar_machine_integer : FStar_ToSyntax_Env.env  ->  Prims.string  ->  (FStar_Const.signedness * FStar_Const.width)  ->  FStar_Range.range  ->  (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax = (fun env repr uu____2332 range -> (match (uu____2332) with
| (signedness, width) -> begin
(

let lid = (Prims.strcat "FStar." (Prims.strcat (match (signedness) with
| FStar_Const.Unsigned -> begin
"U"
end
| FStar_Const.Signed -> begin
""
end) (Prims.strcat "Int" (Prims.strcat (match (width) with
| FStar_Const.Int8 -> begin
"8"
end
| FStar_Const.Int16 -> begin
"16"
end
| FStar_Const.Int32 -> begin
"32"
end
| FStar_Const.Int64 -> begin
"64"
end) (Prims.strcat "." (Prims.strcat (match (signedness) with
| FStar_Const.Unsigned -> begin
"u"
end
| FStar_Const.Signed -> begin
""
end) "int_to_t"))))))
in (

let lid = (FStar_Ident.lid_of_path (FStar_Ident.path_of_text lid) range)
in (

let lid = (

let uu____2343 = (FStar_ToSyntax_Env.try_lookup_lid env lid)
in (match (uu____2343) with
| Some (lid) -> begin
(Prims.fst lid)
end
| None -> begin
(failwith (FStar_Util.format1 "%s not in scope\n" (FStar_Ident.text_of_lid lid)))
end))
in (

let repr = ((FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_int (((repr), (None)))))) None range)
in ((FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_app ((let _0_464 = (let _0_463 = (let _0_462 = (FStar_Syntax_Syntax.as_implicit false)
in ((repr), (_0_462)))
in (_0_463)::[])
in ((lid), (_0_464)))))) None range)))))
end))
and desugar_name : (FStar_Syntax_Syntax.term'  ->  FStar_Syntax_Syntax.term)  ->  (FStar_Syntax_Syntax.term  ->  (FStar_Syntax_Syntax.term', FStar_Syntax_Syntax.term') FStar_Syntax_Syntax.syntax)  ->  env_t  ->  FStar_Ident.lid  ->  FStar_Syntax_Syntax.term = (fun mk setpos env l -> (

let uu____2403 = (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_lid env) l)
in (match (uu____2403) with
| (tm, mut) -> begin
(

let tm = (setpos tm)
in (match (mut) with
| true -> begin
(let _0_466 = FStar_Syntax_Syntax.Tm_meta ((let _0_465 = (mk_ref_read tm)
in ((_0_465), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Mutable_rval)))))
in (FStar_All.pipe_left mk _0_466))
end
| uu____2415 -> begin
tm
end))
end)))
and desugar_attributes : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.term Prims.list  ->  FStar_Syntax_Syntax.cflags Prims.list = (fun env cattributes -> (

let desugar_attribute = (fun t -> (

let uu____2424 = (unparen t).FStar_Parser_AST.tm
in (match (uu____2424) with
| FStar_Parser_AST.Var ({FStar_Ident.ns = uu____2425; FStar_Ident.ident = uu____2426; FStar_Ident.nsstr = uu____2427; FStar_Ident.str = "cps"}) -> begin
FStar_Syntax_Syntax.CPS
end
| uu____2429 -> begin
(Prims.raise (FStar_Errors.Error ((let _0_468 = (let _0_467 = (FStar_Parser_AST.term_to_string t)
in (Prims.strcat "Unknown attribute " _0_467))
in ((_0_468), (t.FStar_Parser_AST.range))))))
end)))
in (FStar_List.map desugar_attribute cattributes)))
and desugar_term_maybe_top : Prims.bool  ->  env_t  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun top_level env top -> (

let mk = (fun e -> ((FStar_Syntax_Syntax.mk e) None top.FStar_Parser_AST.range))
in (

let setpos = (fun e -> (

let uu___214_2457 = e
in {FStar_Syntax_Syntax.n = uu___214_2457.FStar_Syntax_Syntax.n; FStar_Syntax_Syntax.tk = uu___214_2457.FStar_Syntax_Syntax.tk; FStar_Syntax_Syntax.pos = top.FStar_Parser_AST.range; FStar_Syntax_Syntax.vars = uu___214_2457.FStar_Syntax_Syntax.vars}))
in (

let uu____2464 = (unparen top).FStar_Parser_AST.tm
in (match (uu____2464) with
| FStar_Parser_AST.Wild -> begin
(setpos FStar_Syntax_Syntax.tun)
end
| FStar_Parser_AST.Labeled (uu____2465) -> begin
(desugar_formula env top)
end
| FStar_Parser_AST.Requires (t, lopt) -> begin
(desugar_formula env t)
end
| FStar_Parser_AST.Ensures (t, lopt) -> begin
(desugar_formula env t)
end
| FStar_Parser_AST.Attributes (ts) -> begin
(failwith "Attributes should not be desugared by desugar_term_maybe_top")
end
| FStar_Parser_AST.Const (FStar_Const.Const_int (i, Some (size))) -> begin
(desugar_machine_integer env i size top.FStar_Parser_AST.range)
end
| FStar_Parser_AST.Const (c) -> begin
(mk (FStar_Syntax_Syntax.Tm_constant (c)))
end
| FStar_Parser_AST.Op ("=!=", args) -> begin
(desugar_term env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Op ((("~"), (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Op ((("=="), (args)))) top.FStar_Parser_AST.range top.FStar_Parser_AST.level))::[])))) top.FStar_Parser_AST.range top.FStar_Parser_AST.level))
end
| FStar_Parser_AST.Op ("*", (uu____2494)::(uu____2495)::[]) when (let _0_469 = (op_as_term env (Prims.parse_int "2") top.FStar_Parser_AST.range "*")
in (FStar_All.pipe_right _0_469 FStar_Option.isNone)) -> begin
(

let rec flatten = (fun t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Op ("*", (t1)::(t2)::[]) -> begin
(let _0_470 = (flatten t1)
in (FStar_List.append _0_470 ((t2)::[])))
end
| uu____2507 -> begin
(t)::[]
end))
in (

let targs = (let _0_471 = (flatten (unparen top))
in (FStar_All.pipe_right _0_471 (FStar_List.map (fun t -> (FStar_Syntax_Syntax.as_arg (desugar_typ env t))))))
in (

let uu____2513 = (let _0_472 = (FStar_Syntax_Util.mk_tuple_lid (FStar_List.length targs) top.FStar_Parser_AST.range)
in (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_lid env) _0_472))
in (match (uu____2513) with
| (tup, uu____2522) -> begin
(mk (FStar_Syntax_Syntax.Tm_app (((tup), (targs)))))
end))))
end
| FStar_Parser_AST.Tvar (a) -> begin
(let _0_473 = (Prims.fst (FStar_ToSyntax_Env.fail_or2 (FStar_ToSyntax_Env.try_lookup_id env) a))
in (FStar_All.pipe_left setpos _0_473))
end
| FStar_Parser_AST.Uvar (u) -> begin
(Prims.raise (FStar_Errors.Error ((((Prims.strcat "Unexpected universe variable " (Prims.strcat (FStar_Ident.text_of_id u) " in non-universe context"))), (top.FStar_Parser_AST.range)))))
end
| FStar_Parser_AST.Op (s, args) -> begin
(

let uu____2536 = (op_as_term env (FStar_List.length args) top.FStar_Parser_AST.range s)
in (match (uu____2536) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((((Prims.strcat "Unexpected or unbound operator: " s)), (top.FStar_Parser_AST.range)))))
end
| Some (op) -> begin
(match (((FStar_List.length args) > (Prims.parse_int "0"))) with
| true -> begin
(

let args = (FStar_All.pipe_right args (FStar_List.map (fun t -> (let _0_474 = (desugar_term env t)
in ((_0_474), (None))))))
in (mk (FStar_Syntax_Syntax.Tm_app (((op), (args))))))
end
| uu____2563 -> begin
op
end)
end))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = uu____2564; FStar_Ident.ident = uu____2565; FStar_Ident.nsstr = uu____2566; FStar_Ident.str = "Type0"}) -> begin
(mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_zero)))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = uu____2568; FStar_Ident.ident = uu____2569; FStar_Ident.nsstr = uu____2570; FStar_Ident.str = "Type"}) -> begin
(mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_unknown)))
end
| FStar_Parser_AST.Construct ({FStar_Ident.ns = uu____2572; FStar_Ident.ident = uu____2573; FStar_Ident.nsstr = uu____2574; FStar_Ident.str = "Type"}, ((t, FStar_Parser_AST.UnivApp))::[]) -> begin
(mk (FStar_Syntax_Syntax.Tm_type ((desugar_universe t))))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = uu____2584; FStar_Ident.ident = uu____2585; FStar_Ident.nsstr = uu____2586; FStar_Ident.str = "Effect"}) -> begin
(mk (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_effect)))
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = uu____2588; FStar_Ident.ident = uu____2589; FStar_Ident.nsstr = uu____2590; FStar_Ident.str = "True"}) -> begin
(FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range FStar_Syntax_Const.true_lid top.FStar_Parser_AST.range) FStar_Syntax_Syntax.Delta_constant None)
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = uu____2592; FStar_Ident.ident = uu____2593; FStar_Ident.nsstr = uu____2594; FStar_Ident.str = "False"}) -> begin
(FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range FStar_Syntax_Const.false_lid top.FStar_Parser_AST.range) FStar_Syntax_Syntax.Delta_constant None)
end
| FStar_Parser_AST.Projector (eff_name, {FStar_Ident.idText = txt; FStar_Ident.idRange = uu____2598}) when ((is_special_effect_combinator txt) && (FStar_ToSyntax_Env.is_effect_name env eff_name)) -> begin
(

let uu____2599 = (FStar_ToSyntax_Env.try_lookup_effect_defn env eff_name)
in (match (uu____2599) with
| Some (ed) -> begin
(let _0_475 = (FStar_Ident.lid_of_path (FStar_Ident.path_of_text (Prims.strcat (FStar_Ident.text_of_lid ed.FStar_Syntax_Syntax.mname) (Prims.strcat "_" txt))) FStar_Range.dummyRange)
in (FStar_Syntax_Syntax.fvar _0_475 (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))) None))
end
| None -> begin
(failwith "immpossible special_effect_combinator")
end))
end
| FStar_Parser_AST.Assign (ident, t2) -> begin
(

let t2 = (desugar_term env t2)
in (

let uu____2605 = (FStar_ToSyntax_Env.fail_or2 (FStar_ToSyntax_Env.try_lookup_id env) ident)
in (match (uu____2605) with
| (t1, mut) -> begin
((match ((not (mut))) with
| true -> begin
(Prims.raise (FStar_Errors.Error ((("Can only assign to mutable values"), (top.FStar_Parser_AST.range)))))
end
| uu____2613 -> begin
()
end);
(mk_ref_assign t1 t2 top.FStar_Parser_AST.range);
)
end)))
end
| (FStar_Parser_AST.Var (l)) | (FStar_Parser_AST.Name (l)) -> begin
(desugar_name mk setpos env l)
end
| FStar_Parser_AST.Projector (l, i) -> begin
(

let found = ((FStar_Option.isSome (FStar_ToSyntax_Env.try_lookup_datacon env l)) || (FStar_Option.isSome (FStar_ToSyntax_Env.try_lookup_effect_defn env l)))
in (match (found) with
| true -> begin
(let _0_476 = (FStar_Syntax_Util.mk_field_projector_name_from_ident l i)
in (desugar_name mk setpos env _0_476))
end
| uu____2618 -> begin
(Prims.raise (FStar_Errors.Error ((let _0_477 = (FStar_Util.format1 "Data constructor or effect %s not found" l.FStar_Ident.str)
in ((_0_477), (top.FStar_Parser_AST.range))))))
end))
end
| FStar_Parser_AST.Discrim (lid) -> begin
(

let uu____2620 = (FStar_ToSyntax_Env.try_lookup_datacon env lid)
in (match (uu____2620) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((let _0_478 = (FStar_Util.format1 "Data constructor %s not found" lid.FStar_Ident.str)
in ((_0_478), (top.FStar_Parser_AST.range))))))
end
| uu____2622 -> begin
(

let lid' = (FStar_Syntax_Util.mk_discriminator lid)
in (desugar_name mk setpos env lid'))
end))
end
| FStar_Parser_AST.Construct (l, args) -> begin
(

let uu____2633 = (FStar_ToSyntax_Env.try_lookup_datacon env l)
in (match (uu____2633) with
| Some (head) -> begin
(

let uu____2636 = (let _0_479 = (mk (FStar_Syntax_Syntax.Tm_fvar (head)))
in ((_0_479), (true)))
in (match (uu____2636) with
| (head, is_data) -> begin
(match (args) with
| [] -> begin
head
end
| uu____2651 -> begin
(

let uu____2655 = (FStar_Util.take (fun uu____2666 -> (match (uu____2666) with
| (uu____2669, imp) -> begin
(imp = FStar_Parser_AST.UnivApp)
end)) args)
in (match (uu____2655) with
| (universes, args) -> begin
(

let universes = (FStar_List.map (fun x -> (desugar_universe (Prims.fst x))) universes)
in (

let args = (FStar_List.map (fun uu____2702 -> (match (uu____2702) with
| (t, imp) -> begin
(

let te = (desugar_term env t)
in (arg_withimp_e imp te))
end)) args)
in (

let head = (match ((universes = [])) with
| true -> begin
head
end
| uu____2717 -> begin
(mk (FStar_Syntax_Syntax.Tm_uinst (((head), (universes)))))
end)
in (

let app = (mk (FStar_Syntax_Syntax.Tm_app (((head), (args)))))
in (match (is_data) with
| true -> begin
(mk (FStar_Syntax_Syntax.Tm_meta (((app), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app))))))
end
| uu____2732 -> begin
app
end)))))
end))
end)
end))
end
| None -> begin
(Prims.raise (FStar_Errors.Error ((((Prims.strcat "Constructor " (Prims.strcat l.FStar_Ident.str " not found"))), (top.FStar_Parser_AST.range)))))
end))
end
| FStar_Parser_AST.Sum (binders, t) -> begin
(

let uu____2737 = (FStar_List.fold_left (fun uu____2754 b -> (match (uu____2754) with
| (env, tparams, typs) -> begin
(

let uu____2785 = (desugar_binder env b)
in (match (uu____2785) with
| (xopt, t) -> begin
(

let uu____2801 = (match (xopt) with
| None -> begin
(let _0_480 = (FStar_Syntax_Syntax.new_bv (Some (top.FStar_Parser_AST.range)) FStar_Syntax_Syntax.tun)
in ((env), (_0_480)))
end
| Some (x) -> begin
(FStar_ToSyntax_Env.push_bv env x)
end)
in (match (uu____2801) with
| (env, x) -> begin
(let _0_484 = (let _0_483 = (let _0_482 = (let _0_481 = (no_annot_abs tparams t)
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _0_481))
in (_0_482)::[])
in (FStar_List.append typs _0_483))
in ((env), ((FStar_List.append tparams (((((

let uu___215_2829 = x
in {FStar_Syntax_Syntax.ppname = uu___215_2829.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = uu___215_2829.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = t})), (None)))::[]))), (_0_484)))
end))
end))
end)) ((env), ([]), ([])) (FStar_List.append binders (((FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName (t)) t.FStar_Parser_AST.range FStar_Parser_AST.Type_level None))::[])))
in (match (uu____2737) with
| (env, uu____2842, targs) -> begin
(

let uu____2854 = (let _0_485 = (FStar_Syntax_Util.mk_dtuple_lid (FStar_List.length targs) top.FStar_Parser_AST.range)
in (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_lid env) _0_485))
in (match (uu____2854) with
| (tup, uu____2863) -> begin
(FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_app (((tup), (targs)))))
end))
end))
end
| FStar_Parser_AST.Product (binders, t) -> begin
(

let uu____2871 = (uncurry binders t)
in (match (uu____2871) with
| (bs, t) -> begin
(

let rec aux = (fun env bs uu___193_2894 -> (match (uu___193_2894) with
| [] -> begin
(

let cod = (desugar_comp top.FStar_Parser_AST.range env t)
in (let _0_486 = (FStar_Syntax_Util.arrow (FStar_List.rev bs) cod)
in (FStar_All.pipe_left setpos _0_486)))
end
| (hd)::tl -> begin
(

let bb = (desugar_binder env hd)
in (

let uu____2917 = (as_binder env hd.FStar_Parser_AST.aqual bb)
in (match (uu____2917) with
| (b, env) -> begin
(aux env ((b)::bs) tl)
end)))
end))
in (aux env [] bs))
end))
end
| FStar_Parser_AST.Refine (b, f) -> begin
(

let uu____2928 = (desugar_binder env b)
in (match (uu____2928) with
| (None, uu____2932) -> begin
(failwith "Missing binder in refinement")
end
| b -> begin
(

let uu____2938 = (as_binder env None b)
in (match (uu____2938) with
| ((x, uu____2942), env) -> begin
(

let f = (desugar_formula env f)
in (let _0_487 = (FStar_Syntax_Util.refine x f)
in (FStar_All.pipe_left setpos _0_487)))
end))
end))
end
| FStar_Parser_AST.Abs (binders, body) -> begin
(

let binders = (FStar_All.pipe_right binders (FStar_List.map replace_unit_pattern))
in (

let uu____2959 = (FStar_List.fold_left (fun uu____2966 pat -> (match (uu____2966) with
| (env, ftvs) -> begin
(match (pat.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (uu____2981, t) -> begin
(let _0_489 = (let _0_488 = (free_type_vars env t)
in (FStar_List.append _0_488 ftvs))
in ((env), (_0_489)))
end
| uu____2984 -> begin
((env), (ftvs))
end)
end)) ((env), ([])) binders)
in (match (uu____2959) with
| (uu____2987, ftv) -> begin
(

let ftv = (sort_ftv ftv)
in (

let binders = (let _0_490 = (FStar_All.pipe_right ftv (FStar_List.map (fun a -> (FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatTvar (((a), (Some (FStar_Parser_AST.Implicit))))) top.FStar_Parser_AST.range))))
in (FStar_List.append _0_490 binders))
in (

let rec aux = (fun env bs sc_pat_opt uu___194_3022 -> (match (uu___194_3022) with
| [] -> begin
(

let body = (desugar_term env body)
in (

let body = (match (sc_pat_opt) with
| Some (sc, pat) -> begin
(

let body = (let _0_492 = (let _0_491 = (FStar_Syntax_Syntax.pat_bvs pat)
in (FStar_All.pipe_right _0_491 (FStar_List.map FStar_Syntax_Syntax.mk_binder)))
in (FStar_Syntax_Subst.close _0_492 body))
in ((FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_match (((sc), ((((pat), (None), (body)))::[]))))) None body.FStar_Syntax_Syntax.pos))
end
| None -> begin
body
end)
in (setpos (no_annot_abs (FStar_List.rev bs) body))))
end
| (p)::rest -> begin
(

let uu____3096 = (desugar_binding_pat env p)
in (match (uu____3096) with
| (env, b, pat) -> begin
(

let uu____3108 = (match (b) with
| LetBinder (uu____3127) -> begin
(failwith "Impossible")
end
| LocalBinder (x, aq) -> begin
(

let sc_pat_opt = (match (((pat), (sc_pat_opt))) with
| (None, uu____3158) -> begin
sc_pat_opt
end
| (Some (p), None) -> begin
Some ((let _0_493 = (FStar_Syntax_Syntax.bv_to_name x)
in ((_0_493), (p))))
end
| (Some (p), Some (sc, p')) -> begin
(match (((sc.FStar_Syntax_Syntax.n), (p'.FStar_Syntax_Syntax.v))) with
| (FStar_Syntax_Syntax.Tm_name (uu____3205), uu____3206) -> begin
(

let tup2 = (let _0_494 = (FStar_Syntax_Util.mk_tuple_data_lid (Prims.parse_int "2") top.FStar_Parser_AST.range)
in (FStar_Syntax_Syntax.lid_as_fv _0_494 FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor))))
in (

let sc = ((FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_app ((let _0_500 = (mk (FStar_Syntax_Syntax.Tm_fvar (tup2)))
in (let _0_499 = (let _0_498 = (FStar_Syntax_Syntax.as_arg sc)
in (let _0_497 = (let _0_496 = (let _0_495 = (FStar_Syntax_Syntax.bv_to_name x)
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _0_495))
in (_0_496)::[])
in (_0_498)::_0_497))
in ((_0_500), (_0_499))))))) None top.FStar_Parser_AST.range)
in (

let p = (let _0_501 = (FStar_Range.union_ranges p'.FStar_Syntax_Syntax.p p.FStar_Syntax_Syntax.p)
in (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_cons (((tup2), ((((p'), (false)))::(((p), (false)))::[])))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n _0_501))
in Some (((sc), (p))))))
end
| (FStar_Syntax_Syntax.Tm_app (uu____3244, args), FStar_Syntax_Syntax.Pat_cons (uu____3246, pats)) -> begin
(

let tupn = (let _0_502 = (FStar_Syntax_Util.mk_tuple_data_lid ((Prims.parse_int "1") + (FStar_List.length args)) top.FStar_Parser_AST.range)
in (FStar_Syntax_Syntax.lid_as_fv _0_502 FStar_Syntax_Syntax.Delta_constant (Some (FStar_Syntax_Syntax.Data_ctor))))
in (

let sc = (mk (FStar_Syntax_Syntax.Tm_app ((let _0_507 = (mk (FStar_Syntax_Syntax.Tm_fvar (tupn)))
in (let _0_506 = (let _0_505 = (let _0_504 = (let _0_503 = (FStar_Syntax_Syntax.bv_to_name x)
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _0_503))
in (_0_504)::[])
in (FStar_List.append args _0_505))
in ((_0_507), (_0_506)))))))
in (

let p = (let _0_508 = (FStar_Range.union_ranges p'.FStar_Syntax_Syntax.p p.FStar_Syntax_Syntax.p)
in (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_cons (((tupn), ((FStar_List.append pats ((((p), (false)))::[])))))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n _0_508))
in Some (((sc), (p))))))
end
| uu____3319 -> begin
(failwith "Impossible")
end)
end)
in ((((x), (aq))), (sc_pat_opt)))
end)
in (match (uu____3108) with
| (b, sc_pat_opt) -> begin
(aux env ((b)::bs) sc_pat_opt rest)
end))
end))
end))
in (aux env [] None binders))))
end)))
end
| FStar_Parser_AST.App ({FStar_Parser_AST.tm = FStar_Parser_AST.Var (a); FStar_Parser_AST.range = rng; FStar_Parser_AST.level = uu____3362}, phi, uu____3364) when ((FStar_Ident.lid_equals a FStar_Syntax_Const.assert_lid) || (FStar_Ident.lid_equals a FStar_Syntax_Const.assume_lid)) -> begin
(

let phi = (desugar_formula env phi)
in (

let a = (FStar_Ident.set_lid_range a rng)
in (mk (FStar_Syntax_Syntax.Tm_app ((let _0_514 = (FStar_Syntax_Syntax.fvar a FStar_Syntax_Syntax.Delta_equational None)
in (let _0_513 = (let _0_512 = (FStar_Syntax_Syntax.as_arg phi)
in (let _0_511 = (let _0_510 = (let _0_509 = (mk (FStar_Syntax_Syntax.Tm_constant (FStar_Const.Const_unit)))
in (FStar_All.pipe_left FStar_Syntax_Syntax.as_arg _0_509))
in (_0_510)::[])
in (_0_512)::_0_511))
in ((_0_514), (_0_513)))))))))
end
| FStar_Parser_AST.App (uu____3368, uu____3369, FStar_Parser_AST.UnivApp) -> begin
(

let rec aux = (fun universes e -> (

let uu____3381 = (unparen e).FStar_Parser_AST.tm
in (match (uu____3381) with
| FStar_Parser_AST.App (e, t, FStar_Parser_AST.UnivApp) -> begin
(

let univ_arg = (desugar_universe t)
in (aux ((univ_arg)::universes) e))
end
| uu____3387 -> begin
(

let head = (desugar_term env e)
in (mk (FStar_Syntax_Syntax.Tm_uinst (((head), (universes))))))
end)))
in (aux [] top))
end
| FStar_Parser_AST.App (uu____3390) -> begin
(

let rec aux = (fun args e -> (

let uu____3411 = (unparen e).FStar_Parser_AST.tm
in (match (uu____3411) with
| FStar_Parser_AST.App (e, t, imp) when (imp <> FStar_Parser_AST.UnivApp) -> begin
(

let arg = (let _0_515 = (desugar_term env t)
in (FStar_All.pipe_left (arg_withimp_e imp) _0_515))
in (aux ((arg)::args) e))
end
| uu____3427 -> begin
(

let head = (desugar_term env e)
in (mk (FStar_Syntax_Syntax.Tm_app (((head), (args))))))
end)))
in (aux [] top))
end
| FStar_Parser_AST.Seq (t1, t2) -> begin
(mk (FStar_Syntax_Syntax.Tm_meta ((let _0_516 = (desugar_term env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Let (((FStar_Parser_AST.NoLetQualifier), (((((FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild t1.FStar_Parser_AST.range)), (t1)))::[]), (t2)))) top.FStar_Parser_AST.range FStar_Parser_AST.Expr))
in ((_0_516), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Sequence)))))))
end
| FStar_Parser_AST.LetOpen (lid, e) -> begin
(

let env = (FStar_ToSyntax_Env.push_namespace env lid)
in (desugar_term_maybe_top top_level env e))
end
| FStar_Parser_AST.Let (qual, ((pat, _snd))::_tl, body) -> begin
(

let is_rec = (qual = FStar_Parser_AST.Rec)
in (

let ds_let_rec_or_app = (fun uu____3467 -> (

let bindings = (((pat), (_snd)))::_tl
in (

let funs = (FStar_All.pipe_right bindings (FStar_List.map (fun uu____3509 -> (match (uu____3509) with
| (p, def) -> begin
(

let uu____3523 = (is_app_pattern p)
in (match (uu____3523) with
| true -> begin
(let _0_517 = (destruct_app_pattern env top_level p)
in ((_0_517), (def)))
end
| uu____3540 -> begin
(match ((FStar_Parser_AST.un_function p def)) with
| Some (p, def) -> begin
(let _0_518 = (destruct_app_pattern env top_level p)
in ((_0_518), (def)))
end
| uu____3561 -> begin
(match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, uu____3575); FStar_Parser_AST.prange = uu____3576}, t) -> begin
(match (top_level) with
| true -> begin
(let _0_520 = (let _0_519 = FStar_Util.Inr ((FStar_ToSyntax_Env.qualify env id))
in ((_0_519), ([]), (Some (t))))
in ((_0_520), (def)))
end
| uu____3600 -> begin
((((FStar_Util.Inl (id)), ([]), (Some (t)))), (def))
end)
end
| FStar_Parser_AST.PatVar (id, uu____3613) -> begin
(match (top_level) with
| true -> begin
(let _0_522 = (let _0_521 = FStar_Util.Inr ((FStar_ToSyntax_Env.qualify env id))
in ((_0_521), ([]), (None)))
in ((_0_522), (def)))
end
| uu____3636 -> begin
((((FStar_Util.Inl (id)), ([]), (None))), (def))
end)
end
| uu____3648 -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected let binding"), (p.FStar_Parser_AST.prange)))))
end)
end)
end))
end))))
in (

let uu____3658 = (FStar_List.fold_left (fun uu____3682 uu____3683 -> (match (((uu____3682), (uu____3683))) with
| ((env, fnames, rec_bindings), ((f, uu____3727, uu____3728), uu____3729)) -> begin
(

let uu____3769 = (match (f) with
| FStar_Util.Inl (x) -> begin
(

let uu____3783 = (FStar_ToSyntax_Env.push_bv env x)
in (match (uu____3783) with
| (env, xx) -> begin
(let _0_524 = (let _0_523 = (FStar_Syntax_Syntax.mk_binder xx)
in (_0_523)::rec_bindings)
in ((env), (FStar_Util.Inl (xx)), (_0_524)))
end))
end
| FStar_Util.Inr (l) -> begin
(let _0_525 = (FStar_ToSyntax_Env.push_top_level_rec_binding env l.FStar_Ident.ident FStar_Syntax_Syntax.Delta_equational)
in ((_0_525), (FStar_Util.Inr (l)), (rec_bindings)))
end)
in (match (uu____3769) with
| (env, lbname, rec_bindings) -> begin
((env), ((lbname)::fnames), (rec_bindings))
end))
end)) ((env), ([]), ([])) funs)
in (match (uu____3658) with
| (env', fnames, rec_bindings) -> begin
(

let fnames = (FStar_List.rev fnames)
in (

let rec_bindings = (FStar_List.rev rec_bindings)
in (

let desugar_one_def = (fun env lbname uu____3870 -> (match (uu____3870) with
| ((uu____3882, args, result_t), def) -> begin
(

let args = (FStar_All.pipe_right args (FStar_List.map replace_unit_pattern))
in (

let def = (match (result_t) with
| None -> begin
def
end
| Some (t) -> begin
(

let t = (

let uu____3908 = (is_comp_type env t)
in (match (uu____3908) with
| true -> begin
((

let uu____3910 = (FStar_All.pipe_right args (FStar_List.tryFind (fun x -> (not ((is_var_pattern x))))))
in (match (uu____3910) with
| None -> begin
()
end
| Some (p) -> begin
(Prims.raise (FStar_Errors.Error ((("Computation type annotations are only permitted on let-bindings without inlined patterns; replace this pattern with a variable"), (p.FStar_Parser_AST.prange)))))
end));
t;
)
end
| uu____3916 -> begin
(

let uu____3917 = (((FStar_Options.ml_ish ()) && (FStar_Option.isSome (FStar_ToSyntax_Env.try_lookup_effect_name env FStar_Syntax_Const.effect_ML_lid))) && ((not (is_rec)) || ((FStar_List.length args) <> (Prims.parse_int "0"))))
in (match (uu____3917) with
| true -> begin
(FStar_Parser_AST.ml_comp t)
end
| uu____3920 -> begin
(FStar_Parser_AST.tot_comp t)
end))
end))
in (let _0_526 = (FStar_Range.union_ranges t.FStar_Parser_AST.range def.FStar_Parser_AST.range)
in (FStar_Parser_AST.mk_term (FStar_Parser_AST.Ascribed (((def), (t)))) _0_526 FStar_Parser_AST.Expr)))
end)
in (

let def = (match (args) with
| [] -> begin
def
end
| uu____3922 -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.un_curry_abs args def) top.FStar_Parser_AST.range top.FStar_Parser_AST.level)
end)
in (

let body = (desugar_term env def)
in (

let lbname = (match (lbname) with
| FStar_Util.Inl (x) -> begin
FStar_Util.Inl (x)
end
| FStar_Util.Inr (l) -> begin
FStar_Util.Inr ((let _0_527 = (FStar_Syntax_Util.incr_delta_qualifier body)
in (FStar_Syntax_Syntax.lid_as_fv l _0_527 None)))
end)
in (

let body = (match (is_rec) with
| true -> begin
(FStar_Syntax_Subst.close rec_bindings body)
end
| uu____3933 -> begin
body
end)
in (mk_lb ((lbname), (FStar_Syntax_Syntax.tun), (body)))))))))
end))
in (

let lbs = (FStar_List.map2 (desugar_one_def (match (is_rec) with
| true -> begin
env'
end
| uu____3949 -> begin
env
end)) fnames funs)
in (

let body = (desugar_term env' body)
in (let _0_529 = FStar_Syntax_Syntax.Tm_let ((let _0_528 = (FStar_Syntax_Subst.close rec_bindings body)
in ((((is_rec), (lbs))), (_0_528))))
in (FStar_All.pipe_left mk _0_529)))))))
end)))))
in (

let ds_non_rec = (fun pat t1 t2 -> (

let t1 = (desugar_term env t1)
in (

let is_mutable = (qual = FStar_Parser_AST.Mutable)
in (

let t1 = (match (is_mutable) with
| true -> begin
(mk_ref_alloc t1)
end
| uu____3976 -> begin
t1
end)
in (

let uu____3977 = (desugar_binding_pat_maybe_top top_level env pat is_mutable)
in (match (uu____3977) with
| (env, binder, pat) -> begin
(

let tm = (match (binder) with
| LetBinder (l, t) -> begin
(

let body = (desugar_term env t2)
in (

let fv = (let _0_530 = (FStar_Syntax_Util.incr_delta_qualifier t1)
in (FStar_Syntax_Syntax.lid_as_fv l _0_530 None))
in (FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_let (((((false), (({FStar_Syntax_Syntax.lbname = FStar_Util.Inr (fv); FStar_Syntax_Syntax.lbunivs = []; FStar_Syntax_Syntax.lbtyp = t; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_ALL_lid; FStar_Syntax_Syntax.lbdef = t1})::[]))), (body)))))))
end
| LocalBinder (x, uu____4005) -> begin
(

let body = (desugar_term env t2)
in (

let body = (match (pat) with
| (None) | (Some ({FStar_Syntax_Syntax.v = FStar_Syntax_Syntax.Pat_wild (_); FStar_Syntax_Syntax.ty = _; FStar_Syntax_Syntax.p = _})) -> begin
body
end
| Some (pat) -> begin
((FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_match ((let _0_533 = (FStar_Syntax_Syntax.bv_to_name x)
in (let _0_532 = (let _0_531 = (FStar_Syntax_Util.branch ((pat), (None), (body)))
in (_0_531)::[])
in ((_0_533), (_0_532))))))) None body.FStar_Syntax_Syntax.pos)
end)
in (let _0_537 = FStar_Syntax_Syntax.Tm_let ((let _0_536 = (let _0_535 = (let _0_534 = (FStar_Syntax_Syntax.mk_binder x)
in (_0_534)::[])
in (FStar_Syntax_Subst.close _0_535 body))
in ((((false), (((mk_lb ((FStar_Util.Inl (x)), (x.FStar_Syntax_Syntax.sort), (t1))))::[]))), (_0_536))))
in (FStar_All.pipe_left mk _0_537))))
end)
in (match (is_mutable) with
| true -> begin
(FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_meta (((tm), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Mutable_alloc))))))
end
| uu____4046 -> begin
tm
end))
end))))))
in (

let uu____4047 = (is_rec || (is_app_pattern pat))
in (match (uu____4047) with
| true -> begin
(ds_let_rec_or_app ())
end
| uu____4048 -> begin
(ds_non_rec pat _snd body)
end)))))
end
| FStar_Parser_AST.If (t1, t2, t3) -> begin
(

let x = (FStar_Syntax_Syntax.new_bv (Some (t3.FStar_Parser_AST.range)) FStar_Syntax_Syntax.tun)
in (mk (FStar_Syntax_Syntax.Tm_match ((let _0_546 = (desugar_term env t1)
in (let _0_545 = (let _0_544 = (let _0_539 = (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_constant (FStar_Const.Const_bool (true))) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n t2.FStar_Parser_AST.range)
in (let _0_538 = (desugar_term env t2)
in ((_0_539), (None), (_0_538))))
in (let _0_543 = (let _0_542 = (let _0_541 = (FStar_Syntax_Syntax.withinfo (FStar_Syntax_Syntax.Pat_wild (x)) FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n t3.FStar_Parser_AST.range)
in (let _0_540 = (desugar_term env t3)
in ((_0_541), (None), (_0_540))))
in (_0_542)::[])
in (_0_544)::_0_543))
in ((_0_546), (_0_545))))))))
end
| FStar_Parser_AST.TryWith (e, branches) -> begin
(

let r = top.FStar_Parser_AST.range
in (

let handler = (FStar_Parser_AST.mk_function branches r r)
in (

let body = (FStar_Parser_AST.mk_function (((((FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatConst (FStar_Const.Const_unit)) r)), (None), (e)))::[]) r r)
in (

let a1 = (FStar_Parser_AST.mk_term (FStar_Parser_AST.App ((((FStar_Parser_AST.mk_term (FStar_Parser_AST.Var (FStar_Syntax_Const.try_with_lid)) r top.FStar_Parser_AST.level)), (body), (FStar_Parser_AST.Nothing)))) r top.FStar_Parser_AST.level)
in (

let a2 = (FStar_Parser_AST.mk_term (FStar_Parser_AST.App (((a1), (handler), (FStar_Parser_AST.Nothing)))) r top.FStar_Parser_AST.level)
in (desugar_term env a2))))))
end
| FStar_Parser_AST.Match (e, branches) -> begin
(

let desugar_branch = (fun uu____4145 -> (match (uu____4145) with
| (pat, wopt, b) -> begin
(

let uu____4155 = (desugar_match_pat env pat)
in (match (uu____4155) with
| (env, pat) -> begin
(

let wopt = (match (wopt) with
| None -> begin
None
end
| Some (e) -> begin
Some ((desugar_term env e))
end)
in (

let b = (desugar_term env b)
in (FStar_Syntax_Util.branch ((pat), (wopt), (b)))))
end))
end))
in (let _0_549 = FStar_Syntax_Syntax.Tm_match ((let _0_548 = (desugar_term env e)
in (let _0_547 = (FStar_List.map desugar_branch branches)
in ((_0_548), (_0_547)))))
in (FStar_All.pipe_left mk _0_549)))
end
| FStar_Parser_AST.Ascribed (e, t) -> begin
(

let annot = (

let uu____4180 = (is_comp_type env t)
in (match (uu____4180) with
| true -> begin
FStar_Util.Inr ((desugar_comp t.FStar_Parser_AST.range env t))
end
| uu____4187 -> begin
FStar_Util.Inl ((desugar_term env t))
end))
in (let _0_551 = FStar_Syntax_Syntax.Tm_ascribed ((let _0_550 = (desugar_term env e)
in ((_0_550), (annot), (None))))
in (FStar_All.pipe_left mk _0_551)))
end
| FStar_Parser_AST.Record (uu____4197, []) -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected empty record"), (top.FStar_Parser_AST.range)))))
end
| FStar_Parser_AST.Record (eopt, fields) -> begin
(

let record = (check_fields env fields top.FStar_Parser_AST.range)
in (

let user_ns = (

let uu____4218 = (FStar_List.hd fields)
in (match (uu____4218) with
| (f, uu____4225) -> begin
f.FStar_Ident.ns
end))
in (

let get_field = (fun xopt f -> (

let found = (FStar_All.pipe_right fields (FStar_Util.find_opt (fun uu____4249 -> (match (uu____4249) with
| (g, uu____4253) -> begin
(f.FStar_Ident.idText = g.FStar_Ident.ident.FStar_Ident.idText)
end))))
in (

let fn = (FStar_Ident.lid_of_ids (FStar_List.append user_ns ((f)::[])))
in (match (found) with
| Some (uu____4257, e) -> begin
((fn), (e))
end
| None -> begin
(match (xopt) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((let _0_552 = (FStar_Util.format2 "Field %s of record type %s is missing" f.FStar_Ident.idText record.FStar_ToSyntax_Env.typename.FStar_Ident.str)
in ((_0_552), (top.FStar_Parser_AST.range))))))
end
| Some (x) -> begin
((fn), ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Project (((x), (fn)))) x.FStar_Parser_AST.range x.FStar_Parser_AST.level)))
end)
end))))
in (

let user_constrname = (FStar_Ident.lid_of_ids (FStar_List.append user_ns ((record.FStar_ToSyntax_Env.constrname)::[])))
in (

let recterm = (match (eopt) with
| None -> begin
FStar_Parser_AST.Construct ((let _0_555 = (FStar_All.pipe_right record.FStar_ToSyntax_Env.fields (FStar_List.map (fun uu____4283 -> (match (uu____4283) with
| (f, uu____4289) -> begin
(let _0_554 = (let _0_553 = (get_field None f)
in (FStar_All.pipe_left Prims.snd _0_553))
in ((_0_554), (FStar_Parser_AST.Nothing)))
end))))
in ((user_constrname), (_0_555))))
end
| Some (e) -> begin
(

let x = (FStar_Ident.gen e.FStar_Parser_AST.range)
in (

let xterm = (let _0_556 = FStar_Parser_AST.Var ((FStar_Ident.lid_of_ids ((x)::[])))
in (FStar_Parser_AST.mk_term _0_556 x.FStar_Ident.idRange FStar_Parser_AST.Expr))
in (

let record = FStar_Parser_AST.Record ((let _0_557 = (FStar_All.pipe_right record.FStar_ToSyntax_Env.fields (FStar_List.map (fun uu____4310 -> (match (uu____4310) with
| (f, uu____4316) -> begin
(get_field (Some (xterm)) f)
end))))
in ((None), (_0_557))))
in FStar_Parser_AST.Let (((FStar_Parser_AST.NoLetQualifier), (((((FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatVar (((x), (None)))) x.FStar_Ident.idRange)), (e)))::[]), ((FStar_Parser_AST.mk_term record top.FStar_Parser_AST.range top.FStar_Parser_AST.level)))))))
end)
in (

let recterm = (FStar_Parser_AST.mk_term recterm top.FStar_Parser_AST.range top.FStar_Parser_AST.level)
in (

let e = (desugar_term env recterm)
in (match (e.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_meta ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_app ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar (fv); FStar_Syntax_Syntax.tk = uu____4328; FStar_Syntax_Syntax.pos = uu____4329; FStar_Syntax_Syntax.vars = uu____4330}, args); FStar_Syntax_Syntax.tk = uu____4332; FStar_Syntax_Syntax.pos = uu____4333; FStar_Syntax_Syntax.vars = uu____4334}, FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app)) -> begin
(

let e = (let _0_561 = FStar_Syntax_Syntax.Tm_app ((let _0_560 = (let _0_559 = Some (FStar_Syntax_Syntax.Record_ctor ((let _0_558 = (FStar_All.pipe_right record.FStar_ToSyntax_Env.fields (FStar_List.map Prims.fst))
in ((record.FStar_ToSyntax_Env.typename), (_0_558)))))
in (FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v e.FStar_Syntax_Syntax.pos) FStar_Syntax_Syntax.Delta_constant _0_559))
in ((_0_560), (args))))
in (FStar_All.pipe_left mk _0_561))
in (FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_meta (((e), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Data_app)))))))
end
| uu____4378 -> begin
e
end))))))))
end
| FStar_Parser_AST.Project (e, f) -> begin
(

let uu____4381 = (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_dc_by_field_name env) f)
in (match (uu____4381) with
| (constrname, is_rec) -> begin
(

let e = (desugar_term env e)
in (

let projname = (FStar_Syntax_Util.mk_field_projector_name_from_ident constrname f.FStar_Ident.ident)
in (

let qual = (match (is_rec) with
| true -> begin
Some (FStar_Syntax_Syntax.Record_projector (((constrname), (f.FStar_Ident.ident))))
end
| uu____4393 -> begin
None
end)
in (let _0_565 = FStar_Syntax_Syntax.Tm_app ((let _0_564 = (FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range projname (FStar_Ident.range_of_lid f)) FStar_Syntax_Syntax.Delta_equational qual)
in (let _0_563 = (let _0_562 = (FStar_Syntax_Syntax.as_arg e)
in (_0_562)::[])
in ((_0_564), (_0_563)))))
in (FStar_All.pipe_left mk _0_565)))))
end))
end
| (FStar_Parser_AST.NamedTyp (_, e)) | (FStar_Parser_AST.Paren (e)) -> begin
(desugar_term env e)
end
| uu____4399 when (top.FStar_Parser_AST.level = FStar_Parser_AST.Formula) -> begin
(desugar_formula env top)
end
| uu____4400 -> begin
(FStar_Parser_AST.error "Unexpected term" top top.FStar_Parser_AST.range)
end
| FStar_Parser_AST.Let (uu____4401, uu____4402, uu____4403) -> begin
(failwith "Not implemented yet")
end
| FStar_Parser_AST.QForall (uu____4410, uu____4411, uu____4412) -> begin
(failwith "Not implemented yet")
end
| FStar_Parser_AST.QExists (uu____4419, uu____4420, uu____4421) -> begin
(failwith "Not implemented yet")
end)))))
and desugar_args : FStar_ToSyntax_Env.env  ->  (FStar_Parser_AST.term * FStar_Parser_AST.imp) Prims.list  ->  (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list = (fun env args -> (FStar_All.pipe_right args (FStar_List.map (fun uu____4445 -> (match (uu____4445) with
| (a, imp) -> begin
(let _0_566 = (desugar_term env a)
in (arg_withimp_e imp _0_566))
end)))))
and desugar_comp : FStar_Range.range  ->  FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.term  ->  (FStar_Syntax_Syntax.comp', Prims.unit) FStar_Syntax_Syntax.syntax = (fun r env t -> (

let fail = (fun msg -> (Prims.raise (FStar_Errors.Error (((msg), (r))))))
in (

let is_requires = (fun uu____4469 -> (match (uu____4469) with
| (t, uu____4473) -> begin
(

let uu____4474 = (unparen t).FStar_Parser_AST.tm
in (match (uu____4474) with
| FStar_Parser_AST.Requires (uu____4475) -> begin
true
end
| uu____4479 -> begin
false
end))
end))
in (

let is_ensures = (fun uu____4485 -> (match (uu____4485) with
| (t, uu____4489) -> begin
(

let uu____4490 = (unparen t).FStar_Parser_AST.tm
in (match (uu____4490) with
| FStar_Parser_AST.Ensures (uu____4491) -> begin
true
end
| uu____4495 -> begin
false
end))
end))
in (

let is_app = (fun head uu____4504 -> (match (uu____4504) with
| (t, uu____4508) -> begin
(

let uu____4509 = (unparen t).FStar_Parser_AST.tm
in (match (uu____4509) with
| FStar_Parser_AST.App ({FStar_Parser_AST.tm = FStar_Parser_AST.Var (d); FStar_Parser_AST.range = uu____4511; FStar_Parser_AST.level = uu____4512}, uu____4513, uu____4514) -> begin
(d.FStar_Ident.ident.FStar_Ident.idText = head)
end
| uu____4515 -> begin
false
end))
end))
in (

let is_decreases = (is_app "decreases")
in (

let pre_process_comp_typ = (fun t -> (

let uu____4533 = (head_and_args t)
in (match (uu____4533) with
| (head, args) -> begin
(match (head.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Name (lemma) when (lemma.FStar_Ident.ident.FStar_Ident.idText = "Lemma") -> begin
(

let unit_tm = (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.unit_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Type_level)), (FStar_Parser_AST.Nothing))
in (

let nil_pat = (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.nil_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Expr)), (FStar_Parser_AST.Nothing))
in (

let req_true = (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Requires ((((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.true_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Formula)), (None)))) t.FStar_Parser_AST.range FStar_Parser_AST.Type_level)), (FStar_Parser_AST.Nothing))
in (

let args = (match (args) with
| [] -> begin
(Prims.raise (FStar_Errors.Error ((("Not enough arguments to \'Lemma\'"), (t.FStar_Parser_AST.range)))))
end
| (ens)::[] -> begin
(unit_tm)::(req_true)::(ens)::(nil_pat)::[]
end
| (req)::(ens)::[] when ((is_requires req) && (is_ensures ens)) -> begin
(unit_tm)::(req)::(ens)::(nil_pat)::[]
end
| (ens)::(dec)::[] when ((is_ensures ens) && (is_decreases dec)) -> begin
(unit_tm)::(req_true)::(ens)::(nil_pat)::(dec)::[]
end
| (req)::(ens)::(dec)::[] when (((is_requires req) && (is_ensures ens)) && (is_app "decreases" dec)) -> begin
(unit_tm)::(req)::(ens)::(nil_pat)::(dec)::[]
end
| more -> begin
(unit_tm)::more
end)
in (

let head_and_attributes = (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_effect_name_and_attributes env) lemma)
in ((head_and_attributes), (args)))))))
end
| FStar_Parser_AST.Name (l) when (FStar_ToSyntax_Env.is_effect_name env l) -> begin
(let _0_567 = (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_effect_name_and_attributes env) l)
in ((_0_567), (args)))
end
| FStar_Parser_AST.Name (l) when ((let _0_568 = (FStar_ToSyntax_Env.current_module env)
in (FStar_Ident.lid_equals _0_568 FStar_Syntax_Const.prims_lid)) && (l.FStar_Ident.ident.FStar_Ident.idText = "Tot")) -> begin
(((((FStar_Ident.set_lid_range FStar_Syntax_Const.effect_Tot_lid head.FStar_Parser_AST.range)), ([]))), (args))
end
| FStar_Parser_AST.Name (l) when ((let _0_569 = (FStar_ToSyntax_Env.current_module env)
in (FStar_Ident.lid_equals _0_569 FStar_Syntax_Const.prims_lid)) && (l.FStar_Ident.ident.FStar_Ident.idText = "GTot")) -> begin
(((((FStar_Ident.set_lid_range FStar_Syntax_Const.effect_GTot_lid head.FStar_Parser_AST.range)), ([]))), (args))
end
| FStar_Parser_AST.Name (l) when (((l.FStar_Ident.ident.FStar_Ident.idText = "Type") || (l.FStar_Ident.ident.FStar_Ident.idText = "Type0")) || (l.FStar_Ident.ident.FStar_Ident.idText = "Effect")) -> begin
(((((FStar_Ident.set_lid_range FStar_Syntax_Const.effect_Tot_lid head.FStar_Parser_AST.range)), ([]))), ((((t), (FStar_Parser_AST.Nothing)))::[]))
end
| uu____4735 -> begin
(

let default_effect = (

let uu____4737 = (FStar_Options.ml_ish ())
in (match (uu____4737) with
| true -> begin
FStar_Syntax_Const.effect_ML_lid
end
| uu____4738 -> begin
((

let uu____4740 = (FStar_Options.warn_default_effects ())
in (match (uu____4740) with
| true -> begin
(FStar_Errors.warn head.FStar_Parser_AST.range "Using default effect Tot")
end
| uu____4741 -> begin
()
end));
FStar_Syntax_Const.effect_Tot_lid;
)
end))
in (((((FStar_Ident.set_lid_range default_effect head.FStar_Parser_AST.range)), ([]))), ((((t), (FStar_Parser_AST.Nothing)))::[])))
end)
end)))
in (

let uu____4753 = (pre_process_comp_typ t)
in (match (uu____4753) with
| ((eff, cattributes), args) -> begin
((match (((FStar_List.length args) = (Prims.parse_int "0"))) with
| true -> begin
(fail (let _0_570 = (FStar_Syntax_Print.lid_to_string eff)
in (FStar_Util.format1 "Not enough args to effect %s" _0_570)))
end
| uu____4783 -> begin
()
end);
(

let is_universe = (fun uu____4789 -> (match (uu____4789) with
| (uu____4792, imp) -> begin
(imp = FStar_Parser_AST.UnivApp)
end))
in (

let uu____4794 = (FStar_Util.take is_universe args)
in (match (uu____4794) with
| (universes, args) -> begin
(

let universes = (FStar_List.map (fun uu____4825 -> (match (uu____4825) with
| (u, imp) -> begin
(desugar_universe u)
end)) universes)
in (

let uu____4830 = (let _0_572 = (FStar_List.hd args)
in (let _0_571 = (FStar_List.tl args)
in ((_0_572), (_0_571))))
in (match (uu____4830) with
| (result_arg, rest) -> begin
(

let result_typ = (desugar_typ env (Prims.fst result_arg))
in (

let rest = (desugar_args env rest)
in (

let uu____4867 = (FStar_All.pipe_right rest (FStar_List.partition (fun uu____4905 -> (match (uu____4905) with
| (t, uu____4912) -> begin
(match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_app ({FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_fvar (fv); FStar_Syntax_Syntax.tk = uu____4920; FStar_Syntax_Syntax.pos = uu____4921; FStar_Syntax_Syntax.vars = uu____4922}, (uu____4923)::[]) -> begin
(FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.decreases_lid)
end
| uu____4945 -> begin
false
end)
end))))
in (match (uu____4867) with
| (dec, rest) -> begin
(

let decreases_clause = (FStar_All.pipe_right dec (FStar_List.map (fun uu____4988 -> (match (uu____4988) with
| (t, uu____4995) -> begin
(match (t.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_app (uu____5002, ((arg, uu____5004))::[]) -> begin
FStar_Syntax_Syntax.DECREASES (arg)
end
| uu____5026 -> begin
(failwith "impos")
end)
end))))
in (

let no_additional_args = (

let is_empty = (fun l -> (match (l) with
| [] -> begin
true
end
| uu____5038 -> begin
false
end))
in ((((is_empty decreases_clause) && (is_empty rest)) && (is_empty cattributes)) && (is_empty universes)))
in (match ((no_additional_args && (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Tot_lid))) with
| true -> begin
(FStar_Syntax_Syntax.mk_Total result_typ)
end
| uu____5047 -> begin
(match ((no_additional_args && (FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_GTot_lid))) with
| true -> begin
(FStar_Syntax_Syntax.mk_GTotal result_typ)
end
| uu____5050 -> begin
(

let flags = (match ((FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Lemma_lid)) with
| true -> begin
(FStar_Syntax_Syntax.LEMMA)::[]
end
| uu____5054 -> begin
(match ((FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Tot_lid)) with
| true -> begin
(FStar_Syntax_Syntax.TOTAL)::[]
end
| uu____5056 -> begin
(match ((FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_ML_lid)) with
| true -> begin
(FStar_Syntax_Syntax.MLEFFECT)::[]
end
| uu____5058 -> begin
(match ((FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_GTot_lid)) with
| true -> begin
(FStar_Syntax_Syntax.SOMETRIVIAL)::[]
end
| uu____5060 -> begin
[]
end)
end)
end)
end)
in (

let flags = (FStar_List.append flags cattributes)
in (

let rest = (match ((FStar_Ident.lid_equals eff FStar_Syntax_Const.effect_Lemma_lid)) with
| true -> begin
(match (rest) with
| (req)::(ens)::((pat, aq))::[] -> begin
(

let pat = (match (pat.FStar_Syntax_Syntax.n) with
| FStar_Syntax_Syntax.Tm_fvar (fv) when (FStar_Syntax_Syntax.fv_eq_lid fv FStar_Syntax_Const.nil_lid) -> begin
(

let nil = (FStar_Syntax_Syntax.mk_Tm_uinst pat ((FStar_Syntax_Syntax.U_succ (FStar_Syntax_Syntax.U_zero))::[]))
in (

let pattern = (let _0_573 = (FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range FStar_Syntax_Const.pattern_lid pat.FStar_Syntax_Syntax.pos) FStar_Syntax_Syntax.Delta_constant None)
in (FStar_Syntax_Syntax.mk_Tm_uinst _0_573 ((FStar_Syntax_Syntax.U_zero)::[])))
in ((FStar_Syntax_Syntax.mk_Tm_app nil ((((pattern), (Some (FStar_Syntax_Syntax.imp_tag))))::[])) None pat.FStar_Syntax_Syntax.pos)))
end
| uu____5141 -> begin
pat
end)
in (let _0_577 = (let _0_576 = (let _0_575 = (let _0_574 = ((FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_meta (((pat), (FStar_Syntax_Syntax.Meta_desugared (FStar_Syntax_Syntax.Meta_smt_pat)))))) None pat.FStar_Syntax_Syntax.pos)
in ((_0_574), (aq)))
in (_0_575)::[])
in (ens)::_0_576)
in (req)::_0_577))
end
| uu____5179 -> begin
rest
end)
end
| uu____5186 -> begin
rest
end)
in (FStar_Syntax_Syntax.mk_Comp {FStar_Syntax_Syntax.comp_univs = universes; FStar_Syntax_Syntax.effect_name = eff; FStar_Syntax_Syntax.result_typ = result_typ; FStar_Syntax_Syntax.effect_args = rest; FStar_Syntax_Syntax.flags = (FStar_List.append flags decreases_clause)}))))
end)
end)))
end))))
end)))
end)));
)
end)))))))))
and desugar_formula : env_t  ->  FStar_Parser_AST.term  ->  FStar_Syntax_Syntax.term = (fun env f -> (

let connective = (fun s -> (match (s) with
| "/\\" -> begin
Some (FStar_Syntax_Const.and_lid)
end
| "\\/" -> begin
Some (FStar_Syntax_Const.or_lid)
end
| "==>" -> begin
Some (FStar_Syntax_Const.imp_lid)
end
| "<==>" -> begin
Some (FStar_Syntax_Const.iff_lid)
end
| "~" -> begin
Some (FStar_Syntax_Const.not_lid)
end
| uu____5195 -> begin
None
end))
in (

let mk = (fun t -> ((FStar_Syntax_Syntax.mk t) None f.FStar_Parser_AST.range))
in (

let pos = (fun t -> (t None f.FStar_Parser_AST.range))
in (

let setpos = (fun t -> (

let uu___216_5236 = t
in {FStar_Syntax_Syntax.n = uu___216_5236.FStar_Syntax_Syntax.n; FStar_Syntax_Syntax.tk = uu___216_5236.FStar_Syntax_Syntax.tk; FStar_Syntax_Syntax.pos = f.FStar_Parser_AST.range; FStar_Syntax_Syntax.vars = uu___216_5236.FStar_Syntax_Syntax.vars}))
in (

let desugar_quant = (fun q b pats body -> (

let tk = (desugar_binder env (

let uu___217_5266 = b
in {FStar_Parser_AST.b = uu___217_5266.FStar_Parser_AST.b; FStar_Parser_AST.brange = uu___217_5266.FStar_Parser_AST.brange; FStar_Parser_AST.blevel = FStar_Parser_AST.Formula; FStar_Parser_AST.aqual = uu___217_5266.FStar_Parser_AST.aqual}))
in (

let desugar_pats = (fun env pats -> (FStar_List.map (fun es -> (FStar_All.pipe_right es (FStar_List.map (fun e -> (let _0_578 = (desugar_term env e)
in (FStar_All.pipe_left (arg_withimp_t FStar_Parser_AST.Nothing) _0_578)))))) pats))
in (match (tk) with
| (Some (a), k) -> begin
(

let uu____5307 = (FStar_ToSyntax_Env.push_bv env a)
in (match (uu____5307) with
| (env, a) -> begin
(

let a = (

let uu___218_5315 = a
in {FStar_Syntax_Syntax.ppname = uu___218_5315.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = uu___218_5315.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k})
in (

let pats = (desugar_pats env pats)
in (

let body = (desugar_formula env body)
in (

let body = (match (pats) with
| [] -> begin
body
end
| uu____5328 -> begin
(mk (FStar_Syntax_Syntax.Tm_meta (((body), (FStar_Syntax_Syntax.Meta_pattern (pats))))))
end)
in (

let body = (let _0_581 = (let _0_580 = (let _0_579 = (FStar_Syntax_Syntax.mk_binder a)
in (_0_579)::[])
in (no_annot_abs _0_580 body))
in (FStar_All.pipe_left setpos _0_581))
in (let _0_585 = FStar_Syntax_Syntax.Tm_app ((let _0_584 = (FStar_Syntax_Syntax.fvar (FStar_Ident.set_lid_range q b.FStar_Parser_AST.brange) (FStar_Syntax_Syntax.Delta_defined_at_level ((Prims.parse_int "1"))) None)
in (let _0_583 = (let _0_582 = (FStar_Syntax_Syntax.as_arg body)
in (_0_582)::[])
in ((_0_584), (_0_583)))))
in (FStar_All.pipe_left mk _0_585)))))))
end))
end
| uu____5344 -> begin
(failwith "impossible")
end))))
in (

let push_quant = (fun q binders pats body -> (match (binders) with
| (b)::(b')::_rest -> begin
(

let rest = (b')::_rest
in (

let body = (let _0_587 = (q ((rest), (pats), (body)))
in (let _0_586 = (FStar_Range.union_ranges b'.FStar_Parser_AST.brange body.FStar_Parser_AST.range)
in (FStar_Parser_AST.mk_term _0_587 _0_586 FStar_Parser_AST.Formula)))
in (let _0_588 = (q (((b)::[]), ([]), (body)))
in (FStar_Parser_AST.mk_term _0_588 f.FStar_Parser_AST.range FStar_Parser_AST.Formula))))
end
| uu____5400 -> begin
(failwith "impossible")
end))
in (

let uu____5402 = (unparen f).FStar_Parser_AST.tm
in (match (uu____5402) with
| FStar_Parser_AST.Labeled (f, l, p) -> begin
(

let f = (desugar_formula env f)
in (FStar_All.pipe_left mk (FStar_Syntax_Syntax.Tm_meta (((f), (FStar_Syntax_Syntax.Meta_labeled (((l), (f.FStar_Syntax_Syntax.pos), (p)))))))))
end
| (FStar_Parser_AST.QForall ([], _, _)) | (FStar_Parser_AST.QExists ([], _, _)) -> begin
(failwith "Impossible: Quantifier without binders")
end
| FStar_Parser_AST.QForall ((_1)::(_2)::_3, pats, body) -> begin
(

let binders = (_1)::(_2)::_3
in (let _0_589 = (push_quant (fun x -> FStar_Parser_AST.QForall (x)) binders pats body)
in (desugar_formula env _0_589)))
end
| FStar_Parser_AST.QExists ((_1)::(_2)::_3, pats, body) -> begin
(

let binders = (_1)::(_2)::_3
in (let _0_590 = (push_quant (fun x -> FStar_Parser_AST.QExists (x)) binders pats body)
in (desugar_formula env _0_590)))
end
| FStar_Parser_AST.QForall ((b)::[], pats, body) -> begin
(desugar_quant FStar_Syntax_Const.forall_lid b pats body)
end
| FStar_Parser_AST.QExists ((b)::[], pats, body) -> begin
(desugar_quant FStar_Syntax_Const.exists_lid b pats body)
end
| FStar_Parser_AST.Paren (f) -> begin
(desugar_formula env f)
end
| uu____5476 -> begin
(desugar_term env f)
end)))))))))
and typars_of_binders : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.binder Prims.list  ->  (FStar_ToSyntax_Env.env * (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.arg_qualifier Prims.option) Prims.list) = (fun env bs -> (

let uu____5480 = (FStar_List.fold_left (fun uu____5493 b -> (match (uu____5493) with
| (env, out) -> begin
(

let tk = (desugar_binder env (

let uu___219_5521 = b
in {FStar_Parser_AST.b = uu___219_5521.FStar_Parser_AST.b; FStar_Parser_AST.brange = uu___219_5521.FStar_Parser_AST.brange; FStar_Parser_AST.blevel = FStar_Parser_AST.Formula; FStar_Parser_AST.aqual = uu___219_5521.FStar_Parser_AST.aqual}))
in (match (tk) with
| (Some (a), k) -> begin
(

let uu____5531 = (FStar_ToSyntax_Env.push_bv env a)
in (match (uu____5531) with
| (env, a) -> begin
(

let a = (

let uu___220_5543 = a
in {FStar_Syntax_Syntax.ppname = uu___220_5543.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = uu___220_5543.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k})
in ((env), ((((a), ((trans_aqual b.FStar_Parser_AST.aqual))))::out)))
end))
end
| uu____5552 -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected binder"), (b.FStar_Parser_AST.brange)))))
end))
end)) ((env), ([])) bs)
in (match (uu____5480) with
| (env, tpars) -> begin
((env), ((FStar_List.rev tpars)))
end)))
and desugar_binder : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.binder  ->  (FStar_Ident.ident Prims.option * FStar_Syntax_Syntax.term) = (fun env b -> (match (b.FStar_Parser_AST.b) with
| (FStar_Parser_AST.TAnnotated (x, t)) | (FStar_Parser_AST.Annotated (x, t)) -> begin
(let _0_591 = (desugar_typ env t)
in ((Some (x)), (_0_591)))
end
| FStar_Parser_AST.TVariable (x) -> begin
(let _0_592 = ((FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_type (FStar_Syntax_Syntax.U_unknown))) None x.FStar_Ident.idRange)
in ((Some (x)), (_0_592)))
end
| FStar_Parser_AST.NoName (t) -> begin
(let _0_593 = (desugar_typ env t)
in ((None), (_0_593)))
end
| FStar_Parser_AST.Variable (x) -> begin
((Some (x)), (FStar_Syntax_Syntax.tun))
end))


let mk_data_discriminators = (fun quals env t tps k datas -> (

let quals = (FStar_All.pipe_right quals (FStar_List.filter (fun uu___195_5668 -> (match (uu___195_5668) with
| (FStar_Syntax_Syntax.Abstract) | (FStar_Syntax_Syntax.Private) -> begin
true
end
| uu____5669 -> begin
false
end))))
in (

let quals = (fun q -> (

let uu____5677 = ((FStar_All.pipe_left Prims.op_Negation env.FStar_ToSyntax_Env.iface) || env.FStar_ToSyntax_Env.admitted_iface)
in (match (uu____5677) with
| true -> begin
(FStar_List.append ((FStar_Syntax_Syntax.Assumption)::q) quals)
end
| uu____5679 -> begin
(FStar_List.append q quals)
end)))
in (FStar_All.pipe_right datas (FStar_List.map (fun d -> (

let disc_name = (FStar_Syntax_Util.mk_discriminator d)
in FStar_Syntax_Syntax.Sig_declare_typ ((let _0_594 = (quals ((FStar_Syntax_Syntax.OnlyName)::(FStar_Syntax_Syntax.Discriminator (d))::[]))
in ((disc_name), ([]), (FStar_Syntax_Syntax.tun), (_0_594), ((FStar_Ident.range_of_lid disc_name))))))))))))


let mk_indexed_projector_names : FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Syntax_Syntax.fv_qual  ->  FStar_ToSyntax_Env.env  ->  FStar_Ident.lid  ->  FStar_Syntax_Syntax.binder Prims.list  ->  FStar_Syntax_Syntax.sigelt Prims.list = (fun iquals fvq env lid fields -> (

let p = (FStar_Ident.range_of_lid lid)
in (let _0_601 = (FStar_All.pipe_right fields (FStar_List.mapi (fun i uu____5717 -> (match (uu____5717) with
| (x, uu____5722) -> begin
(

let uu____5723 = (FStar_Syntax_Util.mk_field_projector_name lid x i)
in (match (uu____5723) with
| (field_name, uu____5728) -> begin
(

let only_decl = (((let _0_595 = (FStar_ToSyntax_Env.current_module env)
in (FStar_Ident.lid_equals FStar_Syntax_Const.prims_lid _0_595)) || (fvq <> FStar_Syntax_Syntax.Data_ctor)) || (FStar_Options.dont_gen_projectors (FStar_ToSyntax_Env.current_module env).FStar_Ident.str))
in (

let no_decl = (FStar_Syntax_Syntax.is_type x.FStar_Syntax_Syntax.sort)
in (

let quals = (fun q -> (match (only_decl) with
| true -> begin
(let _0_596 = (FStar_List.filter (fun uu___196_5739 -> (match (uu___196_5739) with
| FStar_Syntax_Syntax.Abstract -> begin
false
end
| uu____5740 -> begin
true
end)) q)
in (FStar_Syntax_Syntax.Assumption)::_0_596)
end
| uu____5741 -> begin
q
end))
in (

let quals = (

let iquals = (FStar_All.pipe_right iquals (FStar_List.filter (fun uu___197_5748 -> (match (uu___197_5748) with
| (FStar_Syntax_Syntax.Abstract) | (FStar_Syntax_Syntax.Private) -> begin
true
end
| uu____5749 -> begin
false
end))))
in (quals ((FStar_Syntax_Syntax.OnlyName)::(FStar_Syntax_Syntax.Projector (((lid), (x.FStar_Syntax_Syntax.ppname))))::iquals)))
in (

let decl = FStar_Syntax_Syntax.Sig_declare_typ (((field_name), ([]), (FStar_Syntax_Syntax.tun), (quals), ((FStar_Ident.range_of_lid field_name))))
in (match (only_decl) with
| true -> begin
(decl)::[]
end
| uu____5754 -> begin
(

let dd = (

let uu____5756 = (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Abstract))
in (match (uu____5756) with
| true -> begin
FStar_Syntax_Syntax.Delta_abstract (FStar_Syntax_Syntax.Delta_equational)
end
| uu____5758 -> begin
FStar_Syntax_Syntax.Delta_equational
end))
in (

let lb = (let _0_597 = FStar_Util.Inr ((FStar_Syntax_Syntax.lid_as_fv field_name dd None))
in {FStar_Syntax_Syntax.lbname = _0_597; FStar_Syntax_Syntax.lbunivs = []; FStar_Syntax_Syntax.lbtyp = FStar_Syntax_Syntax.tun; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_Tot_lid; FStar_Syntax_Syntax.lbdef = FStar_Syntax_Syntax.tun})
in (

let impl = FStar_Syntax_Syntax.Sig_let ((let _0_600 = (let _0_599 = (let _0_598 = (FStar_All.pipe_right lb.FStar_Syntax_Syntax.lbname FStar_Util.right)
in (FStar_All.pipe_right _0_598 (fun fv -> fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)))
in (_0_599)::[])
in ((((false), ((lb)::[]))), (p), (_0_600), (quals), ([]))))
in (match (no_decl) with
| true -> begin
(impl)::[]
end
| uu____5776 -> begin
(decl)::(impl)::[]
end))))
end))))))
end))
end))))
in (FStar_All.pipe_right _0_601 FStar_List.flatten))))


let mk_data_projector_names = (fun iquals env uu____5797 -> (match (uu____5797) with
| (inductive_tps, se) -> begin
(match (se) with
| FStar_Syntax_Syntax.Sig_datacon (lid, uu____5805, t, uu____5807, n, quals, uu____5810, uu____5811) when (not ((FStar_Ident.lid_equals lid FStar_Syntax_Const.lexcons_lid))) -> begin
(

let uu____5816 = (FStar_Syntax_Util.arrow_formals t)
in (match (uu____5816) with
| (formals, uu____5826) -> begin
(match (formals) with
| [] -> begin
[]
end
| uu____5840 -> begin
(

let filter_records = (fun uu___198_5848 -> (match (uu___198_5848) with
| FStar_Syntax_Syntax.RecordConstructor (uu____5850, fns) -> begin
Some (FStar_Syntax_Syntax.Record_ctor (((lid), (fns))))
end
| uu____5857 -> begin
None
end))
in (

let fv_qual = (

let uu____5859 = (FStar_Util.find_map quals filter_records)
in (match (uu____5859) with
| None -> begin
FStar_Syntax_Syntax.Data_ctor
end
| Some (q) -> begin
q
end))
in (

let iquals = (match ((FStar_List.contains FStar_Syntax_Syntax.Abstract iquals)) with
| true -> begin
(FStar_Syntax_Syntax.Private)::iquals
end
| uu____5865 -> begin
iquals
end)
in (

let uu____5866 = (FStar_Util.first_N n formals)
in (match (uu____5866) with
| (uu____5878, rest) -> begin
(mk_indexed_projector_names iquals fv_qual env lid rest)
end)))))
end)
end))
end
| uu____5892 -> begin
[]
end)
end))


let mk_typ_abbrev : FStar_Ident.lident  ->  FStar_Syntax_Syntax.univ_name Prims.list  ->  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.aqual) Prims.list  ->  FStar_Syntax_Syntax.typ  ->  FStar_Syntax_Syntax.term  ->  FStar_Ident.lident Prims.list  ->  FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Range.range  ->  FStar_Syntax_Syntax.sigelt = (fun lid uvs typars k t lids quals rng -> (

let dd = (

let uu____5930 = (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Abstract))
in (match (uu____5930) with
| true -> begin
FStar_Syntax_Syntax.Delta_abstract ((FStar_Syntax_Util.incr_delta_qualifier t))
end
| uu____5932 -> begin
(FStar_Syntax_Util.incr_delta_qualifier t)
end))
in (

let lb = (let _0_605 = FStar_Util.Inr ((FStar_Syntax_Syntax.lid_as_fv lid dd None))
in (let _0_604 = (let _0_602 = (FStar_Syntax_Syntax.mk_Total k)
in (FStar_Syntax_Util.arrow typars _0_602))
in (let _0_603 = (no_annot_abs typars t)
in {FStar_Syntax_Syntax.lbname = _0_605; FStar_Syntax_Syntax.lbunivs = uvs; FStar_Syntax_Syntax.lbtyp = _0_604; FStar_Syntax_Syntax.lbeff = FStar_Syntax_Const.effect_Tot_lid; FStar_Syntax_Syntax.lbdef = _0_603})))
in FStar_Syntax_Syntax.Sig_let (((((false), ((lb)::[]))), (rng), (lids), (quals), ([]))))))


let rec desugar_tycon : FStar_ToSyntax_Env.env  ->  FStar_Range.range  ->  FStar_Syntax_Syntax.qualifier Prims.list  ->  FStar_Parser_AST.tycon Prims.list  ->  (env_t * FStar_Syntax_Syntax.sigelts) = (fun env rng quals tcs -> (

let tycon_id = (fun uu___199_5964 -> (match (uu___199_5964) with
| (FStar_Parser_AST.TyconAbstract (id, _, _)) | (FStar_Parser_AST.TyconAbbrev (id, _, _, _)) | (FStar_Parser_AST.TyconRecord (id, _, _, _)) | (FStar_Parser_AST.TyconVariant (id, _, _, _)) -> begin
id
end))
in (

let binder_to_term = (fun b -> (match (b.FStar_Parser_AST.b) with
| (FStar_Parser_AST.Annotated (x, _)) | (FStar_Parser_AST.Variable (x)) -> begin
(let _0_606 = FStar_Parser_AST.Var ((FStar_Ident.lid_of_ids ((x)::[])))
in (FStar_Parser_AST.mk_term _0_606 x.FStar_Ident.idRange FStar_Parser_AST.Expr))
end
| (FStar_Parser_AST.TAnnotated (a, _)) | (FStar_Parser_AST.TVariable (a)) -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar (a)) a.FStar_Ident.idRange FStar_Parser_AST.Type_level)
end
| FStar_Parser_AST.NoName (t) -> begin
t
end))
in (

let tot = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.effect_Tot_lid)) rng FStar_Parser_AST.Expr)
in (

let with_constructor_effect = (fun t -> (FStar_Parser_AST.mk_term (FStar_Parser_AST.App (((tot), (t), (FStar_Parser_AST.Nothing)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level))
in (

let apply_binders = (fun t binders -> (

let imp_of_aqual = (fun b -> (match (b.FStar_Parser_AST.aqual) with
| Some (FStar_Parser_AST.Implicit) -> begin
FStar_Parser_AST.Hash
end
| uu____6024 -> begin
FStar_Parser_AST.Nothing
end))
in (FStar_List.fold_left (fun out b -> (let _0_608 = FStar_Parser_AST.App ((let _0_607 = (binder_to_term b)
in ((out), (_0_607), ((imp_of_aqual b)))))
in (FStar_Parser_AST.mk_term _0_608 out.FStar_Parser_AST.range out.FStar_Parser_AST.level))) t binders)))
in (

let tycon_record_as_variant = (fun uu___200_6033 -> (match (uu___200_6033) with
| FStar_Parser_AST.TyconRecord (id, parms, kopt, fields) -> begin
(

let constrName = (FStar_Ident.mk_ident (((Prims.strcat "Mk" id.FStar_Ident.idText)), (id.FStar_Ident.idRange)))
in (

let mfields = (FStar_List.map (fun uu____6062 -> (match (uu____6062) with
| (x, t, uu____6069) -> begin
(FStar_Parser_AST.mk_binder (FStar_Parser_AST.Annotated ((((FStar_Syntax_Util.mangle_field_name x)), (t)))) x.FStar_Ident.idRange FStar_Parser_AST.Expr None)
end)) fields)
in (

let result = (let _0_610 = (let _0_609 = FStar_Parser_AST.Var ((FStar_Ident.lid_of_ids ((id)::[])))
in (FStar_Parser_AST.mk_term _0_609 id.FStar_Ident.idRange FStar_Parser_AST.Type_level))
in (apply_binders _0_610 parms))
in (

let constrTyp = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((mfields), ((with_constructor_effect result))))) id.FStar_Ident.idRange FStar_Parser_AST.Type_level)
in (let _0_611 = (FStar_All.pipe_right fields (FStar_List.map (fun uu____6109 -> (match (uu____6109) with
| (x, uu____6115, uu____6116) -> begin
(FStar_Syntax_Util.unmangle_field_name x)
end))))
in ((FStar_Parser_AST.TyconVariant (((id), (parms), (kopt), ((((constrName), (Some (constrTyp)), (None), (false)))::[])))), (_0_611)))))))
end
| uu____6119 -> begin
(failwith "impossible")
end))
in (

let desugar_abstract_tc = (fun quals _env mutuals uu___201_6141 -> (match (uu___201_6141) with
| FStar_Parser_AST.TyconAbstract (id, binders, kopt) -> begin
(

let uu____6155 = (typars_of_binders _env binders)
in (match (uu____6155) with
| (_env', typars) -> begin
(

let k = (match (kopt) with
| None -> begin
FStar_Syntax_Util.ktype
end
| Some (k) -> begin
(desugar_term _env' k)
end)
in (

let tconstr = (let _0_613 = (let _0_612 = FStar_Parser_AST.Var ((FStar_Ident.lid_of_ids ((id)::[])))
in (FStar_Parser_AST.mk_term _0_612 id.FStar_Ident.idRange FStar_Parser_AST.Type_level))
in (apply_binders _0_613 binders))
in (

let qlid = (FStar_ToSyntax_Env.qualify _env id)
in (

let typars = (FStar_Syntax_Subst.close_binders typars)
in (

let k = (FStar_Syntax_Subst.close typars k)
in (

let se = FStar_Syntax_Syntax.Sig_inductive_typ (((qlid), ([]), (typars), (k), (mutuals), ([]), (quals), (rng)))
in (

let _env = (FStar_ToSyntax_Env.push_top_level_rec_binding _env id FStar_Syntax_Syntax.Delta_constant)
in (

let _env2 = (FStar_ToSyntax_Env.push_top_level_rec_binding _env' id FStar_Syntax_Syntax.Delta_constant)
in ((_env), (_env2), (se), (tconstr))))))))))
end))
end
| uu____6193 -> begin
(failwith "Unexpected tycon")
end))
in (

let push_tparams = (fun env bs -> (

let uu____6219 = (FStar_List.fold_left (fun uu____6235 uu____6236 -> (match (((uu____6235), (uu____6236))) with
| ((env, tps), (x, imp)) -> begin
(

let uu____6284 = (FStar_ToSyntax_Env.push_bv env x.FStar_Syntax_Syntax.ppname)
in (match (uu____6284) with
| (env, y) -> begin
((env), ((((y), (imp)))::tps))
end))
end)) ((env), ([])) bs)
in (match (uu____6219) with
| (env, bs) -> begin
((env), ((FStar_List.rev bs)))
end)))
in (match (tcs) with
| (FStar_Parser_AST.TyconAbstract (id, bs, kopt))::[] -> begin
(

let kopt = (match (kopt) with
| None -> begin
Some ((tm_type_z id.FStar_Ident.idRange))
end
| uu____6345 -> begin
kopt
end)
in (

let tc = FStar_Parser_AST.TyconAbstract (((id), (bs), (kopt)))
in (

let uu____6350 = (desugar_abstract_tc quals env [] tc)
in (match (uu____6350) with
| (uu____6357, uu____6358, se, uu____6360) -> begin
(

let se = (match (se) with
| FStar_Syntax_Syntax.Sig_inductive_typ (l, uu____6363, typars, k, [], [], quals, rng) -> begin
(

let quals = (

let uu____6374 = (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Assumption))
in (match (uu____6374) with
| true -> begin
quals
end
| uu____6377 -> begin
((let _0_615 = (FStar_Range.string_of_range rng)
in (let _0_614 = (FStar_Syntax_Print.lid_to_string l)
in (FStar_Util.print2 "%s (Warning): Adding an implicit \'assume new\' qualifier on %s\n" _0_615 _0_614)));
(FStar_Syntax_Syntax.Assumption)::(FStar_Syntax_Syntax.New)::quals;
)
end))
in (

let t = (match (typars) with
| [] -> begin
k
end
| uu____6382 -> begin
((FStar_Syntax_Syntax.mk (FStar_Syntax_Syntax.Tm_arrow ((let _0_616 = (FStar_Syntax_Syntax.mk_Total k)
in ((typars), (_0_616)))))) None rng)
end)
in FStar_Syntax_Syntax.Sig_declare_typ (((l), ([]), (t), (quals), (rng)))))
end
| uu____6393 -> begin
se
end)
in (

let env = (FStar_ToSyntax_Env.push_sigelt env se)
in ((env), ((se)::[]))))
end))))
end
| (FStar_Parser_AST.TyconAbbrev (id, binders, kopt, t))::[] -> begin
(

let uu____6404 = (typars_of_binders env binders)
in (match (uu____6404) with
| (env', typars) -> begin
(

let k = (match (kopt) with
| None -> begin
(

let uu____6424 = (FStar_Util.for_some (fun uu___202_6425 -> (match (uu___202_6425) with
| FStar_Syntax_Syntax.Effect -> begin
true
end
| uu____6426 -> begin
false
end)) quals)
in (match (uu____6424) with
| true -> begin
FStar_Syntax_Syntax.teff
end
| uu____6427 -> begin
FStar_Syntax_Syntax.tun
end))
end
| Some (k) -> begin
(desugar_term env' k)
end)
in (

let t0 = t
in (

let quals = (

let uu____6432 = (FStar_All.pipe_right quals (FStar_Util.for_some (fun uu___203_6434 -> (match (uu___203_6434) with
| FStar_Syntax_Syntax.Logic -> begin
true
end
| uu____6435 -> begin
false
end))))
in (match (uu____6432) with
| true -> begin
quals
end
| uu____6437 -> begin
(match ((t0.FStar_Parser_AST.level = FStar_Parser_AST.Formula)) with
| true -> begin
(FStar_Syntax_Syntax.Logic)::quals
end
| uu____6439 -> begin
quals
end)
end))
in (

let se = (

let uu____6441 = (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Effect))
in (match (uu____6441) with
| true -> begin
(

let uu____6443 = (

let uu____6447 = (unparen t).FStar_Parser_AST.tm
in (match (uu____6447) with
| FStar_Parser_AST.Construct (head, args) -> begin
(

let uu____6459 = (match ((FStar_List.rev args)) with
| ((last_arg, uu____6475))::args_rev -> begin
(

let uu____6482 = (unparen last_arg).FStar_Parser_AST.tm
in (match (uu____6482) with
| FStar_Parser_AST.Attributes (ts) -> begin
((ts), ((FStar_List.rev args_rev)))
end
| uu____6497 -> begin
(([]), (args))
end))
end
| uu____6502 -> begin
(([]), (args))
end)
in (match (uu____6459) with
| (cattributes, args) -> begin
(let _0_617 = (desugar_attributes env cattributes)
in (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Construct (((head), (args)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)), (_0_617)))
end))
end
| uu____6527 -> begin
((t), ([]))
end))
in (match (uu____6443) with
| (t, cattributes) -> begin
(

let c = (desugar_comp t.FStar_Parser_AST.range env' t)
in (

let typars = (FStar_Syntax_Subst.close_binders typars)
in (

let c = (FStar_Syntax_Subst.close_comp typars c)
in FStar_Syntax_Syntax.Sig_effect_abbrev ((let _0_619 = (FStar_ToSyntax_Env.qualify env id)
in (let _0_618 = (FStar_All.pipe_right quals (FStar_List.filter (fun uu___204_6543 -> (match (uu___204_6543) with
| FStar_Syntax_Syntax.Effect -> begin
false
end
| uu____6544 -> begin
true
end))))
in ((_0_619), ([]), (typars), (c), (_0_618), ((FStar_List.append cattributes (FStar_Syntax_Util.comp_flags c))), (rng))))))))
end))
end
| uu____6545 -> begin
(

let t = (desugar_typ env' t)
in (

let nm = (FStar_ToSyntax_Env.qualify env id)
in (mk_typ_abbrev nm [] typars k t ((nm)::[]) quals rng)))
end))
in (

let env = (FStar_ToSyntax_Env.push_sigelt env se)
in ((env), ((se)::[])))))))
end))
end
| (FStar_Parser_AST.TyconRecord (uu____6550))::[] -> begin
(

let trec = (FStar_List.hd tcs)
in (

let uu____6563 = (tycon_record_as_variant trec)
in (match (uu____6563) with
| (t, fs) -> begin
(let _0_622 = (let _0_621 = FStar_Syntax_Syntax.RecordType ((let _0_620 = (FStar_Ident.ids_of_lid (FStar_ToSyntax_Env.current_module env))
in ((_0_620), (fs))))
in (_0_621)::quals)
in (desugar_tycon env rng _0_622 ((t)::[])))
end)))
end
| (uu____6575)::uu____6576 -> begin
(

let env0 = env
in (

let mutuals = (FStar_List.map (fun x -> (FStar_All.pipe_left (FStar_ToSyntax_Env.qualify env) (tycon_id x))) tcs)
in (

let rec collect_tcs = (fun quals et tc -> (

let uu____6663 = et
in (match (uu____6663) with
| (env, tcs) -> begin
(match (tc) with
| FStar_Parser_AST.TyconRecord (uu____6777) -> begin
(

let trec = tc
in (

let uu____6790 = (tycon_record_as_variant trec)
in (match (uu____6790) with
| (t, fs) -> begin
(let _0_625 = (let _0_624 = FStar_Syntax_Syntax.RecordType ((let _0_623 = (FStar_Ident.ids_of_lid (FStar_ToSyntax_Env.current_module env))
in ((_0_623), (fs))))
in (_0_624)::quals)
in (collect_tcs _0_625 ((env), (tcs)) t))
end)))
end
| FStar_Parser_AST.TyconVariant (id, binders, kopt, constructors) -> begin
(

let uu____6866 = (desugar_abstract_tc quals env mutuals (FStar_Parser_AST.TyconAbstract (((id), (binders), (kopt)))))
in (match (uu____6866) with
| (env, uu____6897, se, tconstr) -> begin
((env), ((FStar_Util.Inl (((se), (constructors), (tconstr), (quals))))::tcs))
end))
end
| FStar_Parser_AST.TyconAbbrev (id, binders, kopt, t) -> begin
(

let uu____6975 = (desugar_abstract_tc quals env mutuals (FStar_Parser_AST.TyconAbstract (((id), (binders), (kopt)))))
in (match (uu____6975) with
| (env, uu____7006, se, tconstr) -> begin
((env), ((FStar_Util.Inr (((se), (binders), (t), (quals))))::tcs))
end))
end
| uu____7070 -> begin
(failwith "Unrecognized mutual type definition")
end)
end)))
in (

let uu____7094 = (FStar_List.fold_left (collect_tcs quals) ((env), ([])) tcs)
in (match (uu____7094) with
| (env, tcs) -> begin
(

let tcs = (FStar_List.rev tcs)
in (

let tps_sigelts = (FStar_All.pipe_right tcs (FStar_List.collect (fun uu___206_7332 -> (match (uu___206_7332) with
| FStar_Util.Inr (FStar_Syntax_Syntax.Sig_inductive_typ (id, uvs, tpars, k, uu____7364, uu____7365, uu____7366, uu____7367), binders, t, quals) -> begin
(

let t = (

let uu____7400 = (typars_of_binders env binders)
in (match (uu____7400) with
| (env, tpars) -> begin
(

let uu____7417 = (push_tparams env tpars)
in (match (uu____7417) with
| (env_tps, tpars) -> begin
(

let t = (desugar_typ env_tps t)
in (

let tpars = (FStar_Syntax_Subst.close_binders tpars)
in (FStar_Syntax_Subst.close tpars t)))
end))
end))
in (let _0_627 = (let _0_626 = (mk_typ_abbrev id uvs tpars k t ((id)::[]) quals rng)
in (([]), (_0_626)))
in (_0_627)::[]))
end
| FStar_Util.Inl (FStar_Syntax_Syntax.Sig_inductive_typ (tname, univs, tpars, k, mutuals, uu____7460, tags, uu____7462), constrs, tconstr, quals) -> begin
(

let mk_tot = (fun t -> (

let tot = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Syntax_Const.effect_Tot_lid)) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
in (FStar_Parser_AST.mk_term (FStar_Parser_AST.App (((tot), (t), (FStar_Parser_AST.Nothing)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)))
in (

let tycon = ((tname), (tpars), (k))
in (

let uu____7515 = (push_tparams env tpars)
in (match (uu____7515) with
| (env_tps, tps) -> begin
(

let data_tpars = (FStar_List.map (fun uu____7550 -> (match (uu____7550) with
| (x, uu____7558) -> begin
((x), (Some (FStar_Syntax_Syntax.Implicit (true))))
end)) tps)
in (

let tot_tconstr = (mk_tot tconstr)
in (

let uu____7563 = (let _0_633 = (FStar_All.pipe_right constrs (FStar_List.map (fun uu____7629 -> (match (uu____7629) with
| (id, topt, uu____7646, of_notation) -> begin
(

let t = (match (of_notation) with
| true -> begin
(match (topt) with
| Some (t) -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((((FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName (t)) t.FStar_Parser_AST.range t.FStar_Parser_AST.level None))::[]), (tot_tconstr)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
end
| None -> begin
tconstr
end)
end
| uu____7655 -> begin
(match (topt) with
| None -> begin
(failwith "Impossible")
end
| Some (t) -> begin
t
end)
end)
in (

let t = (let _0_628 = (close env_tps t)
in (desugar_term env_tps _0_628))
in (

let name = (FStar_ToSyntax_Env.qualify env id)
in (

let quals = (FStar_All.pipe_right tags (FStar_List.collect (fun uu___205_7663 -> (match (uu___205_7663) with
| FStar_Syntax_Syntax.RecordType (fns) -> begin
(FStar_Syntax_Syntax.RecordConstructor (fns))::[]
end
| uu____7670 -> begin
[]
end))))
in (

let ntps = (FStar_List.length data_tpars)
in (let _0_632 = (let _0_631 = FStar_Syntax_Syntax.Sig_datacon ((let _0_630 = (let _0_629 = (FStar_Syntax_Syntax.mk_Total (FStar_All.pipe_right t FStar_Syntax_Util.name_function_binders))
in (FStar_Syntax_Util.arrow data_tpars _0_629))
in ((name), (univs), (_0_630), (tname), (ntps), (quals), (mutuals), (rng))))
in ((tps), (_0_631)))
in ((name), (_0_632))))))))
end))))
in (FStar_All.pipe_left FStar_List.split _0_633))
in (match (uu____7563) with
| (constrNames, constrs) -> begin
((([]), (FStar_Syntax_Syntax.Sig_inductive_typ (((tname), (univs), (tpars), (k), (mutuals), (constrNames), (tags), (rng))))))::constrs
end))))
end))))
end
| uu____7735 -> begin
(failwith "impossible")
end))))
in (

let sigelts = (FStar_All.pipe_right tps_sigelts (FStar_List.map Prims.snd))
in (

let uu____7783 = (let _0_634 = (FStar_List.collect FStar_Syntax_Util.lids_of_sigelt sigelts)
in (FStar_Syntax_MutRecTy.disentangle_abbrevs_from_bundle sigelts quals _0_634 rng))
in (match (uu____7783) with
| (bundle, abbrevs) -> begin
(

let env = (FStar_ToSyntax_Env.push_sigelt env0 bundle)
in (

let env = (FStar_List.fold_left FStar_ToSyntax_Env.push_sigelt env abbrevs)
in (

let data_ops = (FStar_All.pipe_right tps_sigelts (FStar_List.collect (mk_data_projector_names quals env)))
in (

let discs = (FStar_All.pipe_right sigelts (FStar_List.collect (fun uu___207_7819 -> (match (uu___207_7819) with
| FStar_Syntax_Syntax.Sig_inductive_typ (tname, uu____7822, tps, k, uu____7825, constrs, quals, uu____7828) when ((FStar_List.length constrs) > (Prims.parse_int "1")) -> begin
(

let quals = (match ((FStar_List.contains FStar_Syntax_Syntax.Abstract quals)) with
| true -> begin
(FStar_Syntax_Syntax.Private)::quals
end
| uu____7841 -> begin
quals
end)
in (mk_data_discriminators quals env tname tps k constrs))
end
| uu____7842 -> begin
[]
end))))
in (

let ops = (FStar_List.append discs data_ops)
in (

let env = (FStar_List.fold_left FStar_ToSyntax_Env.push_sigelt env ops)
in ((env), ((FStar_List.append ((bundle)::[]) (FStar_List.append abbrevs ops))))))))))
end)))))
end)))))
end
| [] -> begin
(failwith "impossible")
end))))))))))


let desugar_binders : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.binder Prims.list  ->  (FStar_ToSyntax_Env.env * FStar_Syntax_Syntax.binder Prims.list) = (fun env binders -> (

let uu____7860 = (FStar_List.fold_left (fun uu____7867 b -> (match (uu____7867) with
| (env, binders) -> begin
(

let uu____7879 = (desugar_binder env b)
in (match (uu____7879) with
| (Some (a), k) -> begin
(

let uu____7889 = (FStar_ToSyntax_Env.push_bv env a)
in (match (uu____7889) with
| (env, a) -> begin
(let _0_636 = (let _0_635 = (FStar_Syntax_Syntax.mk_binder (

let uu___221_7898 = a
in {FStar_Syntax_Syntax.ppname = uu___221_7898.FStar_Syntax_Syntax.ppname; FStar_Syntax_Syntax.index = uu___221_7898.FStar_Syntax_Syntax.index; FStar_Syntax_Syntax.sort = k}))
in (_0_635)::binders)
in ((env), (_0_636)))
end))
end
| uu____7899 -> begin
(Prims.raise (FStar_Errors.Error ((("Missing name in binder"), (b.FStar_Parser_AST.brange)))))
end))
end)) ((env), ([])) binders)
in (match (uu____7860) with
| (env, binders) -> begin
((env), ((FStar_List.rev binders)))
end)))


let rec desugar_effect : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.decl  ->  FStar_Parser_AST.qualifiers  ->  FStar_Ident.ident  ->  FStar_Parser_AST.binder Prims.list  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.decl Prims.list  ->  FStar_Parser_AST.decl Prims.list  ->  Prims.bool  ->  (FStar_ToSyntax_Env.env * FStar_Syntax_Syntax.sigelt Prims.list) = (fun env d quals eff_name eff_binders eff_kind eff_decls actions for_free -> (

let env0 = env
in (

let monad_env = (FStar_ToSyntax_Env.enter_monad_scope env eff_name)
in (

let uu____7993 = (desugar_binders monad_env eff_binders)
in (match (uu____7993) with
| (env, binders) -> begin
(

let eff_k = (desugar_term env eff_kind)
in (

let uu____8005 = (FStar_All.pipe_right eff_decls (FStar_List.fold_left (fun uu____8016 decl -> (match (uu____8016) with
| (env, out) -> begin
(

let uu____8028 = (desugar_decl env decl)
in (match (uu____8028) with
| (env, ses) -> begin
(let _0_638 = (let _0_637 = (FStar_List.hd ses)
in (_0_637)::out)
in ((env), (_0_638)))
end))
end)) ((env), ([]))))
in (match (uu____8005) with
| (env, decls) -> begin
(

let binders = (FStar_Syntax_Subst.close_binders binders)
in (

let actions = (FStar_All.pipe_right actions (FStar_List.map (fun d -> (match (d.FStar_Parser_AST.d) with
| FStar_Parser_AST.Tycon (uu____8051, ((FStar_Parser_AST.TyconAbbrev (name, uu____8053, uu____8054, {FStar_Parser_AST.tm = FStar_Parser_AST.Construct (uu____8055, ((def, uu____8057))::((cps_type, uu____8059))::[]); FStar_Parser_AST.range = uu____8060; FStar_Parser_AST.level = uu____8061}), uu____8062))::[]) when (not (for_free)) -> begin
(let _0_643 = (FStar_ToSyntax_Env.qualify env name)
in (let _0_642 = (let _0_639 = (desugar_term env def)
in (FStar_Syntax_Subst.close binders _0_639))
in (let _0_641 = (let _0_640 = (desugar_typ env cps_type)
in (FStar_Syntax_Subst.close binders _0_640))
in {FStar_Syntax_Syntax.action_name = _0_643; FStar_Syntax_Syntax.action_unqualified_name = name; FStar_Syntax_Syntax.action_univs = []; FStar_Syntax_Syntax.action_defn = _0_642; FStar_Syntax_Syntax.action_typ = _0_641})))
end
| FStar_Parser_AST.Tycon (uu____8088, ((FStar_Parser_AST.TyconAbbrev (name, uu____8090, uu____8091, defn), uu____8093))::[]) when for_free -> begin
(let _0_646 = (FStar_ToSyntax_Env.qualify env name)
in (let _0_645 = (let _0_644 = (desugar_term env defn)
in (FStar_Syntax_Subst.close binders _0_644))
in {FStar_Syntax_Syntax.action_name = _0_646; FStar_Syntax_Syntax.action_unqualified_name = name; FStar_Syntax_Syntax.action_univs = []; FStar_Syntax_Syntax.action_defn = _0_645; FStar_Syntax_Syntax.action_typ = FStar_Syntax_Syntax.tun}))
end
| uu____8110 -> begin
(Prims.raise (FStar_Errors.Error ((("Malformed action declaration; if this is an \"effect for free\", just provide the direct-style declaration. If this is not an \"effect for free\", please provide a pair of the definition and its cps-type with arrows inserted in the right place (see examples)."), (d.FStar_Parser_AST.drange)))))
end))))
in (

let eff_k = (FStar_Syntax_Subst.close binders eff_k)
in (

let lookup = (fun s -> (

let l = (FStar_ToSyntax_Env.qualify env (FStar_Ident.mk_ident ((s), (d.FStar_Parser_AST.drange))))
in (let _0_648 = (let _0_647 = (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_definition env) l)
in (FStar_All.pipe_left (FStar_Syntax_Subst.close binders) _0_647))
in (([]), (_0_648)))))
in (

let mname = (FStar_ToSyntax_Env.qualify env0 eff_name)
in (

let qualifiers = (FStar_List.map (trans_qual d.FStar_Parser_AST.drange (Some (mname))) quals)
in (

let se = (match (for_free) with
| true -> begin
(

let dummy_tscheme = (let _0_649 = (FStar_Syntax_Syntax.mk FStar_Syntax_Syntax.Tm_unknown None FStar_Range.dummyRange)
in (([]), (_0_649)))
in FStar_Syntax_Syntax.Sig_new_effect_for_free ((let _0_653 = (let _0_652 = (Prims.snd (lookup "repr"))
in (let _0_651 = (lookup "return")
in (let _0_650 = (lookup "bind")
in {FStar_Syntax_Syntax.qualifiers = qualifiers; FStar_Syntax_Syntax.cattributes = []; FStar_Syntax_Syntax.mname = mname; FStar_Syntax_Syntax.univs = []; FStar_Syntax_Syntax.binders = binders; FStar_Syntax_Syntax.signature = eff_k; FStar_Syntax_Syntax.ret_wp = dummy_tscheme; FStar_Syntax_Syntax.bind_wp = dummy_tscheme; FStar_Syntax_Syntax.if_then_else = dummy_tscheme; FStar_Syntax_Syntax.ite_wp = dummy_tscheme; FStar_Syntax_Syntax.stronger = dummy_tscheme; FStar_Syntax_Syntax.close_wp = dummy_tscheme; FStar_Syntax_Syntax.assert_p = dummy_tscheme; FStar_Syntax_Syntax.assume_p = dummy_tscheme; FStar_Syntax_Syntax.null_wp = dummy_tscheme; FStar_Syntax_Syntax.trivial = dummy_tscheme; FStar_Syntax_Syntax.repr = _0_652; FStar_Syntax_Syntax.return_repr = _0_651; FStar_Syntax_Syntax.bind_repr = _0_650; FStar_Syntax_Syntax.actions = actions})))
in ((_0_653), (d.FStar_Parser_AST.drange)))))
end
| uu____8143 -> begin
(

let rr = ((FStar_All.pipe_right qualifiers (FStar_List.contains FStar_Syntax_Syntax.Reifiable)) || (FStar_All.pipe_right qualifiers FStar_Syntax_Syntax.contains_reflectable))
in (

let un_ts = (([]), (FStar_Syntax_Syntax.tun))
in FStar_Syntax_Syntax.Sig_new_effect ((let _0_668 = (let _0_667 = (lookup "return_wp")
in (let _0_666 = (lookup "bind_wp")
in (let _0_665 = (lookup "if_then_else")
in (let _0_664 = (lookup "ite_wp")
in (let _0_663 = (lookup "stronger")
in (let _0_662 = (lookup "close_wp")
in (let _0_661 = (lookup "assert_p")
in (let _0_660 = (lookup "assume_p")
in (let _0_659 = (lookup "null_wp")
in (let _0_658 = (lookup "trivial")
in (let _0_657 = (match (rr) with
| true -> begin
(let _0_654 = (lookup "repr")
in (FStar_All.pipe_left Prims.snd _0_654))
end
| uu____8156 -> begin
FStar_Syntax_Syntax.tun
end)
in (let _0_656 = (match (rr) with
| true -> begin
(lookup "return")
end
| uu____8157 -> begin
un_ts
end)
in (let _0_655 = (match (rr) with
| true -> begin
(lookup "bind")
end
| uu____8158 -> begin
un_ts
end)
in {FStar_Syntax_Syntax.qualifiers = qualifiers; FStar_Syntax_Syntax.cattributes = []; FStar_Syntax_Syntax.mname = mname; FStar_Syntax_Syntax.univs = []; FStar_Syntax_Syntax.binders = binders; FStar_Syntax_Syntax.signature = eff_k; FStar_Syntax_Syntax.ret_wp = _0_667; FStar_Syntax_Syntax.bind_wp = _0_666; FStar_Syntax_Syntax.if_then_else = _0_665; FStar_Syntax_Syntax.ite_wp = _0_664; FStar_Syntax_Syntax.stronger = _0_663; FStar_Syntax_Syntax.close_wp = _0_662; FStar_Syntax_Syntax.assert_p = _0_661; FStar_Syntax_Syntax.assume_p = _0_660; FStar_Syntax_Syntax.null_wp = _0_659; FStar_Syntax_Syntax.trivial = _0_658; FStar_Syntax_Syntax.repr = _0_657; FStar_Syntax_Syntax.return_repr = _0_656; FStar_Syntax_Syntax.bind_repr = _0_655; FStar_Syntax_Syntax.actions = actions})))))))))))))
in ((_0_668), (d.FStar_Parser_AST.drange))))))
end)
in (

let env = (FStar_ToSyntax_Env.push_sigelt env0 se)
in (

let env = (FStar_All.pipe_right actions (FStar_List.fold_left (fun env a -> (let _0_669 = (FStar_Syntax_Util.action_as_lb mname a)
in (FStar_ToSyntax_Env.push_sigelt env _0_669))) env))
in (

let env = (

let uu____8165 = (FStar_All.pipe_right quals (FStar_List.contains FStar_Parser_AST.Reflectable))
in (match (uu____8165) with
| true -> begin
(

let reflect_lid = (FStar_All.pipe_right (FStar_Ident.id_of_text "reflect") (FStar_ToSyntax_Env.qualify monad_env))
in (

let refl_decl = FStar_Syntax_Syntax.Sig_declare_typ (((reflect_lid), ([]), (FStar_Syntax_Syntax.tun), ((FStar_Syntax_Syntax.Assumption)::(FStar_Syntax_Syntax.Reflectable (mname))::[]), (d.FStar_Parser_AST.drange)))
in (FStar_ToSyntax_Env.push_sigelt env refl_decl)))
end
| uu____8170 -> begin
env
end))
in ((env), ((se)::[]))))))))))))
end)))
end)))))
and desugar_redefine_effect : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.decl  ->  (FStar_Ident.lident Prims.option  ->  FStar_Parser_AST.qualifier  ->  FStar_Syntax_Syntax.qualifier)  ->  FStar_Parser_AST.qualifier Prims.list  ->  FStar_Ident.ident  ->  FStar_Parser_AST.binder Prims.list  ->  FStar_Parser_AST.term  ->  (FStar_Syntax_Syntax.eff_decl  ->  FStar_Range.range  ->  FStar_Syntax_Syntax.sigelt)  ->  (FStar_ToSyntax_Env.env * FStar_Syntax_Syntax.sigelt Prims.list) = (fun env d trans_qual quals eff_name eff_binders defn build_sigelt -> (

let env0 = env
in (

let env = (FStar_ToSyntax_Env.enter_monad_scope env eff_name)
in (

let uu____8193 = (desugar_binders env eff_binders)
in (match (uu____8193) with
| (env, binders) -> begin
(

let uu____8204 = (

let uu____8213 = (head_and_args defn)
in (match (uu____8213) with
| (head, args) -> begin
(

let ed = (match (head.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Name (l) -> begin
(FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_effect_defn env) l)
end
| uu____8237 -> begin
(Prims.raise (FStar_Errors.Error ((let _0_672 = (let _0_671 = (let _0_670 = (FStar_Parser_AST.term_to_string head)
in (Prims.strcat _0_670 " not found"))
in (Prims.strcat "Effect " _0_671))
in ((_0_672), (d.FStar_Parser_AST.drange))))))
end)
in (

let uu____8238 = (match ((FStar_List.rev args)) with
| ((last_arg, uu____8254))::args_rev -> begin
(

let uu____8261 = (unparen last_arg).FStar_Parser_AST.tm
in (match (uu____8261) with
| FStar_Parser_AST.Attributes (ts) -> begin
((ts), ((FStar_List.rev args_rev)))
end
| uu____8276 -> begin
(([]), (args))
end))
end
| uu____8281 -> begin
(([]), (args))
end)
in (match (uu____8238) with
| (cattributes, args) -> begin
(let _0_674 = (desugar_args env args)
in (let _0_673 = (desugar_attributes env cattributes)
in ((ed), (_0_674), (_0_673))))
end)))
end))
in (match (uu____8204) with
| (ed, args, cattributes) -> begin
(

let binders = (FStar_Syntax_Subst.close_binders binders)
in (

let sub = (fun uu____8338 -> (match (uu____8338) with
| (uu____8345, x) -> begin
(

let uu____8349 = (FStar_Syntax_Subst.open_term ed.FStar_Syntax_Syntax.binders x)
in (match (uu____8349) with
| (edb, x) -> begin
((match (((FStar_List.length args) <> (FStar_List.length edb))) with
| true -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected number of arguments to effect constructor"), (defn.FStar_Parser_AST.range)))))
end
| uu____8367 -> begin
()
end);
(

let s = (FStar_Syntax_Util.subst_of_list edb args)
in (let _0_676 = (let _0_675 = (FStar_Syntax_Subst.subst s x)
in (FStar_Syntax_Subst.close binders _0_675))
in (([]), (_0_676))));
)
end))
end))
in (

let mname = (FStar_ToSyntax_Env.qualify env0 eff_name)
in (

let ed = (let _0_696 = (let _0_677 = (trans_qual (Some (mname)))
in (FStar_List.map _0_677 quals))
in (let _0_695 = (Prims.snd (sub (([]), (ed.FStar_Syntax_Syntax.signature))))
in (let _0_694 = (sub ed.FStar_Syntax_Syntax.ret_wp)
in (let _0_693 = (sub ed.FStar_Syntax_Syntax.bind_wp)
in (let _0_692 = (sub ed.FStar_Syntax_Syntax.if_then_else)
in (let _0_691 = (sub ed.FStar_Syntax_Syntax.ite_wp)
in (let _0_690 = (sub ed.FStar_Syntax_Syntax.stronger)
in (let _0_689 = (sub ed.FStar_Syntax_Syntax.close_wp)
in (let _0_688 = (sub ed.FStar_Syntax_Syntax.assert_p)
in (let _0_687 = (sub ed.FStar_Syntax_Syntax.assume_p)
in (let _0_686 = (sub ed.FStar_Syntax_Syntax.null_wp)
in (let _0_685 = (sub ed.FStar_Syntax_Syntax.trivial)
in (let _0_684 = (Prims.snd (sub (([]), (ed.FStar_Syntax_Syntax.repr))))
in (let _0_683 = (sub ed.FStar_Syntax_Syntax.return_repr)
in (let _0_682 = (sub ed.FStar_Syntax_Syntax.bind_repr)
in (let _0_681 = (FStar_List.map (fun action -> (let _0_680 = (FStar_ToSyntax_Env.qualify env action.FStar_Syntax_Syntax.action_unqualified_name)
in (let _0_679 = (Prims.snd (sub (([]), (action.FStar_Syntax_Syntax.action_defn))))
in (let _0_678 = (Prims.snd (sub (([]), (action.FStar_Syntax_Syntax.action_typ))))
in {FStar_Syntax_Syntax.action_name = _0_680; FStar_Syntax_Syntax.action_unqualified_name = action.FStar_Syntax_Syntax.action_unqualified_name; FStar_Syntax_Syntax.action_univs = action.FStar_Syntax_Syntax.action_univs; FStar_Syntax_Syntax.action_defn = _0_679; FStar_Syntax_Syntax.action_typ = _0_678})))) ed.FStar_Syntax_Syntax.actions)
in {FStar_Syntax_Syntax.qualifiers = _0_696; FStar_Syntax_Syntax.cattributes = cattributes; FStar_Syntax_Syntax.mname = mname; FStar_Syntax_Syntax.univs = []; FStar_Syntax_Syntax.binders = binders; FStar_Syntax_Syntax.signature = _0_695; FStar_Syntax_Syntax.ret_wp = _0_694; FStar_Syntax_Syntax.bind_wp = _0_693; FStar_Syntax_Syntax.if_then_else = _0_692; FStar_Syntax_Syntax.ite_wp = _0_691; FStar_Syntax_Syntax.stronger = _0_690; FStar_Syntax_Syntax.close_wp = _0_689; FStar_Syntax_Syntax.assert_p = _0_688; FStar_Syntax_Syntax.assume_p = _0_687; FStar_Syntax_Syntax.null_wp = _0_686; FStar_Syntax_Syntax.trivial = _0_685; FStar_Syntax_Syntax.repr = _0_684; FStar_Syntax_Syntax.return_repr = _0_683; FStar_Syntax_Syntax.bind_repr = _0_682; FStar_Syntax_Syntax.actions = _0_681}))))))))))))))))
in (

let se = (build_sigelt ed d.FStar_Parser_AST.drange)
in (

let monad_env = env
in (

let env = (FStar_ToSyntax_Env.push_sigelt env0 se)
in (

let env = (FStar_All.pipe_right ed.FStar_Syntax_Syntax.actions (FStar_List.fold_left (fun env a -> (let _0_697 = (FStar_Syntax_Util.action_as_lb mname a)
in (FStar_ToSyntax_Env.push_sigelt env _0_697))) env))
in (

let env = (

let uu____8389 = (FStar_All.pipe_right quals (FStar_List.contains FStar_Parser_AST.Reflectable))
in (match (uu____8389) with
| true -> begin
(

let reflect_lid = (FStar_All.pipe_right (FStar_Ident.id_of_text "reflect") (FStar_ToSyntax_Env.qualify monad_env))
in (

let refl_decl = FStar_Syntax_Syntax.Sig_declare_typ (((reflect_lid), ([]), (FStar_Syntax_Syntax.tun), ((FStar_Syntax_Syntax.Assumption)::(FStar_Syntax_Syntax.Reflectable (mname))::[]), (d.FStar_Parser_AST.drange)))
in (FStar_ToSyntax_Env.push_sigelt env refl_decl)))
end
| uu____8395 -> begin
env
end))
in ((env), ((se)::[])))))))))))
end))
end)))))
and desugar_decl : env_t  ->  FStar_Parser_AST.decl  ->  (env_t * FStar_Syntax_Syntax.sigelts) = (fun env d -> (

let trans_qual = (trans_qual d.FStar_Parser_AST.drange)
in (match (d.FStar_Parser_AST.d) with
| FStar_Parser_AST.Pragma (p) -> begin
(

let se = FStar_Syntax_Syntax.Sig_pragma ((((trans_pragma p)), (d.FStar_Parser_AST.drange)))
in ((match ((p = FStar_Parser_AST.LightOff)) with
| true -> begin
(FStar_Options.set_ml_ish ())
end
| uu____8412 -> begin
()
end);
((env), ((se)::[]));
))
end
| FStar_Parser_AST.Fsdoc (uu____8414) -> begin
((env), ([]))
end
| FStar_Parser_AST.TopLevelModule (id) -> begin
((env), ([]))
end
| FStar_Parser_AST.Open (lid) -> begin
(

let env = (FStar_ToSyntax_Env.push_namespace env lid)
in ((env), ([])))
end
| FStar_Parser_AST.Include (lid) -> begin
(

let env = (FStar_ToSyntax_Env.push_include env lid)
in ((env), ([])))
end
| FStar_Parser_AST.ModuleAbbrev (x, l) -> begin
(let _0_698 = (FStar_ToSyntax_Env.push_module_abbrev env x l)
in ((_0_698), ([])))
end
| FStar_Parser_AST.Tycon (is_effect, tcs) -> begin
(

let quals = (match (is_effect) with
| true -> begin
(FStar_Parser_AST.Effect_qual)::d.FStar_Parser_AST.quals
end
| uu____8440 -> begin
d.FStar_Parser_AST.quals
end)
in (

let tcs = (FStar_List.map (fun uu____8446 -> (match (uu____8446) with
| (x, uu____8451) -> begin
x
end)) tcs)
in (let _0_699 = (FStar_List.map (trans_qual None) quals)
in (desugar_tycon env d.FStar_Parser_AST.drange _0_699 tcs))))
end
| FStar_Parser_AST.TopLevelLet (isrec, lets) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (

let attrs = d.FStar_Parser_AST.attrs
in (

let attrs = (FStar_List.map (desugar_term env) attrs)
in (

let expand_toplevel_pattern = ((isrec = FStar_Parser_AST.NoLetQualifier) && (match (lets) with
| ((({FStar_Parser_AST.pat = FStar_Parser_AST.PatOp (_); FStar_Parser_AST.prange = _}, _))::[]) | ((({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (_); FStar_Parser_AST.prange = _}, _))::[]) | ((({FStar_Parser_AST.pat = FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (_); FStar_Parser_AST.prange = _}, _); FStar_Parser_AST.prange = _}, _))::[]) -> begin
false
end
| ((p, uu____8491))::[] -> begin
(not ((is_app_pattern p)))
end
| uu____8496 -> begin
false
end))
in (match ((not (expand_toplevel_pattern))) with
| true -> begin
(

let as_inner_let = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Let (((isrec), (lets), ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Const (FStar_Const.Const_unit)) d.FStar_Parser_AST.drange FStar_Parser_AST.Expr))))) d.FStar_Parser_AST.drange FStar_Parser_AST.Expr)
in (

let ds_lets = (desugar_term_maybe_top true env as_inner_let)
in (

let uu____8507 = (FStar_All.pipe_left FStar_Syntax_Subst.compress ds_lets).FStar_Syntax_Syntax.n
in (match (uu____8507) with
| FStar_Syntax_Syntax.Tm_let (lbs, uu____8511) -> begin
(

let fvs = (FStar_All.pipe_right (Prims.snd lbs) (FStar_List.map (fun lb -> (FStar_Util.right lb.FStar_Syntax_Syntax.lbname))))
in (

let quals = (match (quals) with
| (uu____8531)::uu____8532 -> begin
(FStar_List.map (trans_qual None) quals)
end
| uu____8534 -> begin
(FStar_All.pipe_right (Prims.snd lbs) (FStar_List.collect (fun uu___208_8538 -> (match (uu___208_8538) with
| {FStar_Syntax_Syntax.lbname = FStar_Util.Inl (uu____8540); FStar_Syntax_Syntax.lbunivs = uu____8541; FStar_Syntax_Syntax.lbtyp = uu____8542; FStar_Syntax_Syntax.lbeff = uu____8543; FStar_Syntax_Syntax.lbdef = uu____8544} -> begin
[]
end
| {FStar_Syntax_Syntax.lbname = FStar_Util.Inr (fv); FStar_Syntax_Syntax.lbunivs = uu____8551; FStar_Syntax_Syntax.lbtyp = uu____8552; FStar_Syntax_Syntax.lbeff = uu____8553; FStar_Syntax_Syntax.lbdef = uu____8554} -> begin
(FStar_ToSyntax_Env.lookup_letbinding_quals env fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)
end))))
end)
in (

let quals = (

let uu____8566 = (FStar_All.pipe_right lets (FStar_Util.for_some (fun uu____8572 -> (match (uu____8572) with
| (uu____8575, t) -> begin
(t.FStar_Parser_AST.level = FStar_Parser_AST.Formula)
end))))
in (match (uu____8566) with
| true -> begin
(FStar_Syntax_Syntax.Logic)::quals
end
| uu____8578 -> begin
quals
end))
in (

let lbs = (

let uu____8583 = (FStar_All.pipe_right quals (FStar_List.contains FStar_Syntax_Syntax.Abstract))
in (match (uu____8583) with
| true -> begin
(let _0_700 = (FStar_All.pipe_right (Prims.snd lbs) (FStar_List.map (fun lb -> (

let fv = (FStar_Util.right lb.FStar_Syntax_Syntax.lbname)
in (

let uu___222_8595 = lb
in {FStar_Syntax_Syntax.lbname = FStar_Util.Inr ((

let uu___223_8596 = fv
in {FStar_Syntax_Syntax.fv_name = uu___223_8596.FStar_Syntax_Syntax.fv_name; FStar_Syntax_Syntax.fv_delta = FStar_Syntax_Syntax.Delta_abstract (fv.FStar_Syntax_Syntax.fv_delta); FStar_Syntax_Syntax.fv_qual = uu___223_8596.FStar_Syntax_Syntax.fv_qual})); FStar_Syntax_Syntax.lbunivs = uu___222_8595.FStar_Syntax_Syntax.lbunivs; FStar_Syntax_Syntax.lbtyp = uu___222_8595.FStar_Syntax_Syntax.lbtyp; FStar_Syntax_Syntax.lbeff = uu___222_8595.FStar_Syntax_Syntax.lbeff; FStar_Syntax_Syntax.lbdef = uu___222_8595.FStar_Syntax_Syntax.lbdef})))))
in (((Prims.fst lbs)), (_0_700)))
end
| uu____8600 -> begin
lbs
end))
in (

let s = FStar_Syntax_Syntax.Sig_let ((let _0_701 = (FStar_All.pipe_right fvs (FStar_List.map (fun fv -> fv.FStar_Syntax_Syntax.fv_name.FStar_Syntax_Syntax.v)))
in ((lbs), (d.FStar_Parser_AST.drange), (_0_701), (quals), (attrs))))
in (

let env = (FStar_ToSyntax_Env.push_sigelt env s)
in ((env), ((s)::[]))))))))
end
| uu____8617 -> begin
(failwith "Desugaring a let did not produce a let")
end))))
end
| uu____8620 -> begin
(

let uu____8621 = (match (lets) with
| ((pat, body))::[] -> begin
((pat), (body))
end
| uu____8632 -> begin
(failwith "expand_toplevel_pattern should only allow single definition lets")
end)
in (match (uu____8621) with
| (pat, body) -> begin
(

let fresh_toplevel_name = (FStar_Ident.gen FStar_Range.dummyRange)
in (

let fresh_pat = (

let var_pat = (FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatVar (((fresh_toplevel_name), (None)))) FStar_Range.dummyRange)
in (match (pat.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (pat, ty) -> begin
(

let uu___224_8648 = pat
in {FStar_Parser_AST.pat = FStar_Parser_AST.PatAscribed (((var_pat), (ty))); FStar_Parser_AST.prange = uu___224_8648.FStar_Parser_AST.prange})
end
| uu____8649 -> begin
var_pat
end))
in (

let main_let = (desugar_decl env (

let uu___225_8653 = d
in {FStar_Parser_AST.d = FStar_Parser_AST.TopLevelLet (((isrec), ((((fresh_pat), (body)))::[]))); FStar_Parser_AST.drange = uu___225_8653.FStar_Parser_AST.drange; FStar_Parser_AST.doc = uu___225_8653.FStar_Parser_AST.doc; FStar_Parser_AST.quals = (FStar_Parser_AST.Private)::d.FStar_Parser_AST.quals; FStar_Parser_AST.attrs = uu___225_8653.FStar_Parser_AST.attrs}))
in (

let build_projection = (fun uu____8672 id -> (match (uu____8672) with
| (env, ses) -> begin
(

let main = (let _0_702 = FStar_Parser_AST.Var ((FStar_Ident.lid_of_ids ((fresh_toplevel_name)::[])))
in (FStar_Parser_AST.mk_term _0_702 FStar_Range.dummyRange FStar_Parser_AST.Expr))
in (

let lid = (FStar_Ident.lid_of_ids ((id)::[]))
in (

let projectee = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Var (lid)) FStar_Range.dummyRange FStar_Parser_AST.Expr)
in (

let body = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Match (((main), ((((pat), (None), (projectee)))::[])))) FStar_Range.dummyRange FStar_Parser_AST.Expr)
in (

let bv_pat = (FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatVar (((id), (None)))) FStar_Range.dummyRange)
in (

let id_decl = (FStar_Parser_AST.mk_decl (FStar_Parser_AST.TopLevelLet (((FStar_Parser_AST.NoLetQualifier), ((((bv_pat), (body)))::[])))) FStar_Range.dummyRange [])
in (

let uu____8712 = (desugar_decl env id_decl)
in (match (uu____8712) with
| (env, ses') -> begin
((env), ((FStar_List.append ses ses')))
end))))))))
end))
in (

let bvs = (let _0_703 = (gather_pattern_bound_vars pat)
in (FStar_All.pipe_right _0_703 FStar_Util.set_elements))
in (FStar_List.fold_left build_projection main_let bvs))))))
end))
end)))))
end
| FStar_Parser_AST.Main (t) -> begin
(

let e = (desugar_term env t)
in (

let se = FStar_Syntax_Syntax.Sig_main (((e), (d.FStar_Parser_AST.drange)))
in ((env), ((se)::[]))))
end
| FStar_Parser_AST.Assume (id, t) -> begin
(

let f = (desugar_formula env t)
in (let _0_706 = (let _0_705 = FStar_Syntax_Syntax.Sig_assume ((let _0_704 = (FStar_ToSyntax_Env.qualify env id)
in ((_0_704), (f), ((FStar_Syntax_Syntax.Assumption)::[]), (d.FStar_Parser_AST.drange))))
in (_0_705)::[])
in ((env), (_0_706))))
end
| FStar_Parser_AST.Val (id, t) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (

let t = (let _0_707 = (close_fun env t)
in (desugar_term env _0_707))
in (

let quals = (match ((env.FStar_ToSyntax_Env.iface && env.FStar_ToSyntax_Env.admitted_iface)) with
| true -> begin
(FStar_Parser_AST.Assumption)::quals
end
| uu____8744 -> begin
quals
end)
in (

let se = FStar_Syntax_Syntax.Sig_declare_typ ((let _0_709 = (FStar_ToSyntax_Env.qualify env id)
in (let _0_708 = (FStar_List.map (trans_qual None) quals)
in ((_0_709), ([]), (t), (_0_708), (d.FStar_Parser_AST.drange)))))
in (

let env = (FStar_ToSyntax_Env.push_sigelt env se)
in ((env), ((se)::[])))))))
end
| FStar_Parser_AST.Exception (id, None) -> begin
(

let uu____8752 = (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_lid env) FStar_Syntax_Const.exn_lid)
in (match (uu____8752) with
| (t, uu____8760) -> begin
(

let l = (FStar_ToSyntax_Env.qualify env id)
in (

let se = FStar_Syntax_Syntax.Sig_datacon (((l), ([]), (t), (FStar_Syntax_Const.exn_lid), ((Prims.parse_int "0")), ((FStar_Syntax_Syntax.ExceptionConstructor)::[]), ((FStar_Syntax_Const.exn_lid)::[]), (d.FStar_Parser_AST.drange)))
in (

let se' = FStar_Syntax_Syntax.Sig_bundle ((((se)::[]), ((FStar_Syntax_Syntax.ExceptionConstructor)::[]), ((l)::[]), (d.FStar_Parser_AST.drange)))
in (

let env = (FStar_ToSyntax_Env.push_sigelt env se')
in (

let data_ops = (mk_data_projector_names [] env (([]), (se)))
in (

let discs = (mk_data_discriminators [] env FStar_Syntax_Const.exn_lid [] FStar_Syntax_Syntax.tun ((l)::[]))
in (

let env = (FStar_List.fold_left FStar_ToSyntax_Env.push_sigelt env (FStar_List.append discs data_ops))
in ((env), ((FStar_List.append ((se')::discs) data_ops))))))))))
end))
end
| FStar_Parser_AST.Exception (id, Some (term)) -> begin
(

let t = (desugar_term env term)
in (

let t = (let _0_713 = (let _0_710 = (FStar_Syntax_Syntax.null_binder t)
in (_0_710)::[])
in (let _0_712 = (let _0_711 = (Prims.fst (FStar_ToSyntax_Env.fail_or env (FStar_ToSyntax_Env.try_lookup_lid env) FStar_Syntax_Const.exn_lid))
in (FStar_All.pipe_left FStar_Syntax_Syntax.mk_Total _0_711))
in (FStar_Syntax_Util.arrow _0_713 _0_712)))
in (

let l = (FStar_ToSyntax_Env.qualify env id)
in (

let se = FStar_Syntax_Syntax.Sig_datacon (((l), ([]), (t), (FStar_Syntax_Const.exn_lid), ((Prims.parse_int "0")), ((FStar_Syntax_Syntax.ExceptionConstructor)::[]), ((FStar_Syntax_Const.exn_lid)::[]), (d.FStar_Parser_AST.drange)))
in (

let se' = FStar_Syntax_Syntax.Sig_bundle ((((se)::[]), ((FStar_Syntax_Syntax.ExceptionConstructor)::[]), ((l)::[]), (d.FStar_Parser_AST.drange)))
in (

let env = (FStar_ToSyntax_Env.push_sigelt env se')
in (

let data_ops = (mk_data_projector_names [] env (([]), (se)))
in (

let discs = (mk_data_discriminators [] env FStar_Syntax_Const.exn_lid [] FStar_Syntax_Syntax.tun ((l)::[]))
in (

let env = (FStar_List.fold_left FStar_ToSyntax_Env.push_sigelt env (FStar_List.append discs data_ops))
in ((env), ((FStar_List.append ((se')::discs) data_ops))))))))))))
end
| FStar_Parser_AST.NewEffect (FStar_Parser_AST.RedefineEffect (eff_name, eff_binders, defn)) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (desugar_redefine_effect env d trans_qual quals eff_name eff_binders defn (fun ed range -> FStar_Syntax_Syntax.Sig_new_effect (((ed), (range))))))
end
| FStar_Parser_AST.NewEffectForFree (FStar_Parser_AST.RedefineEffect (eff_name, eff_binders, defn)) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (desugar_redefine_effect env d trans_qual quals eff_name eff_binders defn (fun ed range -> FStar_Syntax_Syntax.Sig_new_effect_for_free (((ed), (range))))))
end
| FStar_Parser_AST.NewEffectForFree (FStar_Parser_AST.DefineEffect (eff_name, eff_binders, eff_kind, eff_decls, actions)) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (desugar_effect env d quals eff_name eff_binders eff_kind eff_decls actions true))
end
| FStar_Parser_AST.NewEffect (FStar_Parser_AST.DefineEffect (eff_name, eff_binders, eff_kind, eff_decls, actions)) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (desugar_effect env d quals eff_name eff_binders eff_kind eff_decls actions false))
end
| FStar_Parser_AST.SubEffect (l) -> begin
(

let lookup = (fun l -> (

let uu____8855 = (FStar_ToSyntax_Env.try_lookup_effect_name env l)
in (match (uu____8855) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((let _0_716 = (let _0_715 = (let _0_714 = (FStar_Syntax_Print.lid_to_string l)
in (Prims.strcat _0_714 " not found"))
in (Prims.strcat "Effect name " _0_715))
in ((_0_716), (d.FStar_Parser_AST.drange))))))
end
| Some (l) -> begin
l
end)))
in (

let src = (lookup l.FStar_Parser_AST.msource)
in (

let dst = (lookup l.FStar_Parser_AST.mdest)
in (

let uu____8860 = (match (l.FStar_Parser_AST.lift_op) with
| FStar_Parser_AST.NonReifiableLift (t) -> begin
(let _0_718 = Some ((let _0_717 = (desugar_term env t)
in (([]), (_0_717))))
in ((_0_718), (None)))
end
| FStar_Parser_AST.ReifiableLift (wp, t) -> begin
(let _0_722 = Some ((let _0_719 = (desugar_term env wp)
in (([]), (_0_719))))
in (let _0_721 = Some ((let _0_720 = (desugar_term env t)
in (([]), (_0_720))))
in ((_0_722), (_0_721))))
end
| FStar_Parser_AST.LiftForFree (t) -> begin
(let _0_724 = Some ((let _0_723 = (desugar_term env t)
in (([]), (_0_723))))
in ((None), (_0_724)))
end)
in (match (uu____8860) with
| (lift_wp, lift) -> begin
(

let se = FStar_Syntax_Syntax.Sig_sub_effect ((({FStar_Syntax_Syntax.source = src; FStar_Syntax_Syntax.target = dst; FStar_Syntax_Syntax.lift_wp = lift_wp; FStar_Syntax_Syntax.lift = lift}), (d.FStar_Parser_AST.drange)))
in ((env), ((se)::[])))
end)))))
end)))


let desugar_decls : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.decl Prims.list  ->  (FStar_ToSyntax_Env.env * FStar_Syntax_Syntax.sigelts) = (fun env decls -> (FStar_List.fold_left (fun uu____8966 d -> (match (uu____8966) with
| (env, sigelts) -> begin
(

let uu____8978 = (desugar_decl env d)
in (match (uu____8978) with
| (env, se) -> begin
((env), ((FStar_List.append sigelts se)))
end))
end)) ((env), ([])) decls))


let open_prims_all : (FStar_Parser_AST.decoration Prims.list  ->  FStar_Parser_AST.decl) Prims.list = ((FStar_Parser_AST.mk_decl (FStar_Parser_AST.Open (FStar_Syntax_Const.prims_lid)) FStar_Range.dummyRange))::((FStar_Parser_AST.mk_decl (FStar_Parser_AST.Open (FStar_Syntax_Const.all_lid)) FStar_Range.dummyRange))::[]


let desugar_modul_common : FStar_Syntax_Syntax.modul Prims.option  ->  FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.modul  ->  (env_t * FStar_Syntax_Syntax.modul * Prims.bool) = (fun curmod env m -> (

let env = (match (curmod) with
| None -> begin
env
end
| Some (prev_mod) -> begin
(FStar_ToSyntax_Env.finish_module_or_interface env prev_mod)
end)
in (

let uu____9020 = (match (m) with
| FStar_Parser_AST.Interface (mname, decls, admitted) -> begin
(let _0_725 = (FStar_ToSyntax_Env.prepare_module_or_interface true admitted env mname)
in ((_0_725), (mname), (decls), (true)))
end
| FStar_Parser_AST.Module (mname, decls) -> begin
(let _0_726 = (FStar_ToSyntax_Env.prepare_module_or_interface false false env mname)
in ((_0_726), (mname), (decls), (false)))
end)
in (match (uu____9020) with
| ((env, pop_when_done), mname, decls, intf) -> begin
(

let uu____9062 = (desugar_decls env decls)
in (match (uu____9062) with
| (env, sigelts) -> begin
(

let modul = {FStar_Syntax_Syntax.name = mname; FStar_Syntax_Syntax.declarations = sigelts; FStar_Syntax_Syntax.exports = []; FStar_Syntax_Syntax.is_interface = intf}
in ((env), (modul), (pop_when_done)))
end))
end))))


let desugar_partial_modul : FStar_Syntax_Syntax.modul Prims.option  ->  FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.modul  ->  (FStar_ToSyntax_Env.env * FStar_Syntax_Syntax.modul) = (fun curmod env m -> (

let m = (

let uu____9087 = ((FStar_Options.interactive ()) && (let _0_727 = (FStar_Util.get_file_extension (FStar_List.hd (FStar_Options.file_list ())))
in (_0_727 = "fsti")))
in (match (uu____9087) with
| true -> begin
(match (m) with
| FStar_Parser_AST.Module (mname, decls) -> begin
FStar_Parser_AST.Interface (((mname), (decls), (true)))
end
| FStar_Parser_AST.Interface (mname, uu____9094, uu____9095) -> begin
(failwith (Prims.strcat "Impossible: " mname.FStar_Ident.ident.FStar_Ident.idText))
end)
end
| uu____9098 -> begin
m
end))
in (

let uu____9099 = (desugar_modul_common curmod env m)
in (match (uu____9099) with
| (x, y, uu____9107) -> begin
((x), (y))
end))))


let desugar_modul : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.modul  ->  (FStar_ToSyntax_Env.env * FStar_Syntax_Syntax.modul) = (fun env m -> (

let uu____9118 = (desugar_modul_common None env m)
in (match (uu____9118) with
| (env, modul, pop_when_done) -> begin
(

let env = (FStar_ToSyntax_Env.finish_module_or_interface env modul)
in ((

let uu____9129 = (FStar_Options.dump_module modul.FStar_Syntax_Syntax.name.FStar_Ident.str)
in (match (uu____9129) with
| true -> begin
(let _0_728 = (FStar_Syntax_Print.modul_to_string modul)
in (FStar_Util.print1 "%s\n" _0_728))
end
| uu____9130 -> begin
()
end));
(let _0_729 = (match (pop_when_done) with
| true -> begin
(FStar_ToSyntax_Env.export_interface modul.FStar_Syntax_Syntax.name env)
end
| uu____9131 -> begin
env
end)
in ((_0_729), (modul)));
))
end)))


let desugar_file : FStar_ToSyntax_Env.env  ->  FStar_Parser_AST.file  ->  (FStar_ToSyntax_Env.env * FStar_Syntax_Syntax.modul Prims.list) = (fun env f -> (

let uu____9141 = (FStar_List.fold_left (fun uu____9148 m -> (match (uu____9148) with
| (env, mods) -> begin
(

let uu____9160 = (desugar_modul env m)
in (match (uu____9160) with
| (env, m) -> begin
((env), ((m)::mods))
end))
end)) ((env), ([])) f)
in (match (uu____9141) with
| (env, mods) -> begin
((env), ((FStar_List.rev mods)))
end)))


let add_modul_to_env : FStar_Syntax_Syntax.modul  ->  FStar_ToSyntax_Env.env  ->  FStar_ToSyntax_Env.env = (fun m en -> (

let uu____9184 = (FStar_ToSyntax_Env.prepare_module_or_interface false false en m.FStar_Syntax_Syntax.name)
in (match (uu____9184) with
| (en, pop_when_done) -> begin
(

let en = (FStar_List.fold_left FStar_ToSyntax_Env.push_sigelt (

let uu___226_9190 = en
in {FStar_ToSyntax_Env.curmodule = Some (m.FStar_Syntax_Syntax.name); FStar_ToSyntax_Env.curmonad = uu___226_9190.FStar_ToSyntax_Env.curmonad; FStar_ToSyntax_Env.modules = uu___226_9190.FStar_ToSyntax_Env.modules; FStar_ToSyntax_Env.scope_mods = uu___226_9190.FStar_ToSyntax_Env.scope_mods; FStar_ToSyntax_Env.exported_ids = uu___226_9190.FStar_ToSyntax_Env.exported_ids; FStar_ToSyntax_Env.trans_exported_ids = uu___226_9190.FStar_ToSyntax_Env.trans_exported_ids; FStar_ToSyntax_Env.includes = uu___226_9190.FStar_ToSyntax_Env.includes; FStar_ToSyntax_Env.sigaccum = uu___226_9190.FStar_ToSyntax_Env.sigaccum; FStar_ToSyntax_Env.sigmap = uu___226_9190.FStar_ToSyntax_Env.sigmap; FStar_ToSyntax_Env.iface = uu___226_9190.FStar_ToSyntax_Env.iface; FStar_ToSyntax_Env.admitted_iface = uu___226_9190.FStar_ToSyntax_Env.admitted_iface; FStar_ToSyntax_Env.expect_typ = uu___226_9190.FStar_ToSyntax_Env.expect_typ}) m.FStar_Syntax_Syntax.exports)
in (

let env = (FStar_ToSyntax_Env.finish_module_or_interface en m)
in (match (pop_when_done) with
| true -> begin
(FStar_ToSyntax_Env.export_interface m.FStar_Syntax_Syntax.name env)
end
| uu____9192 -> begin
env
end)))
end)))




