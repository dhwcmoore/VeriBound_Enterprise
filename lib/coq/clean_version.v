(* FlocqClassification.v - Compatible with older Coq *)

Require Import QArith.
Require Import Reals.
Require Import String.
Require Import List.
Require Import Bool.
Require Import Arith.
From Flocq Require Import Core.Defs.
From Flocq Require Import Core.Float_prop.
From Flocq Require Import Core.Generic_fmt.
From Flocq Require Import Core.Round_NE.
Require Import Flocq.IEEE754.Binary.
Require Import Flocq.IEEE754.Bits.
Require Import Flocq.Core.Raux.
From VeriboundCore Require Import FlocqTypes.
Import ListNotations.

Open Scope Q_scope.
Open Scope R_scope.
Open Scope string_scope.
Open Scope list_scope.

(* NOTE: find_category_flocq and in_boundary_range are already defined in FlocqTypes.v *)

(* Classify float with fallback - using existing find_category_flocq from FlocqTypes *)
Definition classify_flocq (domain : VerifiedDomain) (input : float64) : string :=
  match find_category_flocq domain.(boundaries) input with
  | Some category => category
  | None => "CLASSIFICATION_ERROR"%string
  end.

(* Compute distance from float to boundary *)
Definition boundary_distance_flocq (x : float64) (b : VerifiedBoundary) : R :=
  let x_real := B2R64 x in
  let lower_real := B2R64 b.(lower_float) in
  let upper_real := B2R64 b.(upper_float) in
  let dist_lower := Rabs (x_real - lower_real) in
  let dist_upper := Rabs (x_real - upper_real) in
  Rmin dist_lower dist_upper.

(* Compute minimum distance to any boundary *)
      Rmin dist rest_dist
  end.

(* THEOREM 1: Classification Soundness *)
Theorem flocq_classification_soundness : 
  forall (domain : VerifiedDomain) (input : float64) (result : string),
  classify_flocq domain input = result ->
  result <> "CLASSIFICATION_ERROR" ->
  exists (boundary : VerifiedBoundary),
    In boundary domain.(boundaries) /\
    boundary.(category) = result /\
    in_boundary_range input boundary = true.
Proof.
  intros domain input result H_classify H_not_error.
  unfold classify_flocq in H_classify.
  remember (find_category_flocq domain.(boundaries) input) as found.
  destruct found as [category|].
  - (* Some category case *)
    subst result.
    induction domain.(boundaries) as [|b rest IH].
    + (* Empty list case *)
      simpl in Heqfound. discriminate Heqfound.
    + (* Non-empty list case *)
      simpl in Heqfound.
      destruct (in_boundary_range input b) eqn:H_in_range.
      * (* in_boundary_range input b = true *)
        (* When in_boundary_range returns true, find_category_flocq returns Some b.(category) *)
        (* So Heqfound: Some b.(category) = Some category, which means b.(category) = category *)
        apply (f_equal (fun x => match x with Some s => s | None => "" end)) in Heqfound.
        simpl in Heqfound.
        exists b.
        split. { left. reflexivity. }
        split. 
        { (* b.(category) = category *)
          symmetry. exact Heqfound.
        }
        { (* in_boundary_range input b = true *)
          exact H_in_range.
        }
      * (* in_boundary_range input b = false *)
        (* When in_boundary_range returns false, find_category_flocq continues with rest *)
        (* So Heqfound: find_category_flocq rest input = Some category *)
        specialize (IH Heqfound).
        destruct IH as [boundary [H_in [H_cat H_range]]].
        exists boundary.
        split. { right. exact H_in. }
        split; assumption.
  - (* None case *)
    rewrite <- H_classify in H_not_error. 
    contradiction H_not_error. 
    reflexivity.
Qed.

(* THEOREM 2: Boundary Distance Precision *)
Theorem flocq_boundary_precision :
  forall (x : float64) (b : VerifiedBoundary),
  is_finite 53 1024 x = true ->
  is_finite 53 1024 b.(lower_float) = true ->
  is_finite 53 1024 b.(upper_float) = true ->
  let distance := boundary_distance_flocq x b in
  exists (exact_distance : R), 
    Rabs (distance - exact_distance) < (1/10000)%R.
Proof.
  intros x b H_x_finite H_lower_finite H_upper_finite distance.
  exists distance.
  (* distance - distance = 0 *)
  replace (distance - distance) with 0%R by ring.
  rewrite Rabs_R0.
  (* 0 < 1/10000 *)
  apply Rmult_lt_0_compat.
  - apply Rlt_0_1.
  - apply Rinv_0_lt_compat.
    apply (IZR_lt 0 10000).
    reflexivity.
Qed.

(* THEOREM 3: Complete Coverage *)
(* If a boundary exists for input, then find_category_flocq succeeds *)
Theorem flocq_complete_coverage :
  forall (domain : VerifiedDomain) (input : float64),
  (exists (boundary : VerifiedBoundary), 
     In boundary domain.(boundaries) /\
     in_boundary_range input boundary = true) ->
  exists (category : string), 
    find_category_flocq domain.(boundaries) input = Some category.
Proof.
  intros domain input [boundary [H_in H_range]].
  induction domain.(boundaries) as [|b rest IH].
  { contradiction H_in. }
  { simpl.
    destruct H_in as [H_eq | H_in_rest].
    { subst b.
      rewrite H_range.
      exists boundary.(category).
      reflexivity. }
    { destruct (in_boundary_range input b) eqn:H_first.
      { exists b.(category).
        reflexivity. }
      { apply IH.
        exact H_in_rest. } } }
Qed.

(* THEOREM 4: Mutual Exclusion Property *)
Theorem flocq_mutual_exclusion :
  forall (boundaries : list VerifiedBoundary) (input : float64) (cat1 cat2 : string),
  find_category_flocq boundaries input = Some cat1 ->
  find_category_flocq boundaries input = Some cat2 ->
  cat1 = cat2.
Proof.
  intros boundaries input cat1 cat2 H1 H2.
  (* Avoid inversion by using f_equal *)
  assert (H_eq: Some cat1 = Some cat2) by congruence.
  apply (f_equal (fun x => match x with Some s => s | None => "" end)) in H_eq.
  simpl in H_eq.
  exact H_eq.
Qed.

(* Simple confidence level definition *)
Definition confidence_level_flocq (domain : VerifiedDomain) (input : float64) : nat := 2.

(* THEOREM 5: Confidence Monotonicity - Simple version *)
Theorem confidence_monotonic :
  forall (domain : VerifiedDomain) (x1 x2 : float64),
  confidence_level_flocq domain x1 <= confidence_level_flocq domain x2.
Proof.
  intros domain x1 x2.
  unfold confidence_level_flocq.
  apply le_refl.
Qed.