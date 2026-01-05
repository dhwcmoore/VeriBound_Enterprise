Require Import Reals List String.
Require Import Lra.
Import ListNotations.
Open Scope R_scope.

(* Import your existing boundary helpers *)
Require Import VerifiedBoundaryHelpers.

Require Import Ascii String.

Definition catA : string := String.String (Ascii.Ascii true false false false false false true false) EmptyString.
Definition catC : string := String.String (Ascii.Ascii true true false false false false true false) EmptyString.

(* Re introduce the domain alias if the helper file uses it locally *)
Definition ClassDomain := list ClassBoundary.

(* Your helpers already define:
   - in_interval : R -> ClassBoundary -> Prop
   - adjacent    : ClassBoundary -> ClassBoundary -> Prop
   - sorted      : ClassDomain -> Prop
   - no_gaps     : ClassDomain -> Prop
*)

(* A convenient bundled notion, matching your earlier helper file. *)
Definition full_coverage (dom : ClassDomain) : Prop :=
  sorted dom /\ no_gaps dom.

(* Naive classifier: returns the first matching category, otherwise None.
   This models a very common “best effort” classification behaviour.
*)
Fixpoint classify_first (x : R) (dom : ClassDomain) : option string :=
  match dom with
  | [] => None
  | b :: rest =>
      if Rlt_dec x (lower b) then None
      else if Rlt_dec x (upper b) then Some (category b)
      else classify_first x rest
  end.

(* The intended classification space, gap free. *)
Definition expected_dom : ClassDomain :=
  [ mkBoundary 0 2 catA;
    mkBoundary 2 5 "B";
    mkBoundary 5 8 catC
  ].

(* The observed domain under partial observability: we “lose” the middle bucket.
   This is the formal analogue of a missing source, missing rule, or missing segment.
*)
Definition observed_dom : ClassDomain :=
  [ mkBoundary 0 2 catA;
    mkBoundary 5 8 catC
  ].

(* 1) The observed domain is still sorted (so a naive pipeline can consider it “well formed”). *)
Lemma observed_sorted : sorted observed_dom.
Proof.
  unfold observed_dom, sorted. simpl.
  split.
  - compute. lra.
  - trivial.
Qed.

  (* 2) But it is not gap free. *)
  Lemma observed_not_no_gaps : ~ no_gaps observed_dom.
  Proof.
    intro H.
    simpl in H.
    destruct H as [Hadj _].
    unfold adjacent in Hadj. simpl in Hadj.
    lra.
  Qed.

  (* 3) Therefore full coverage fails. *)
Theorem observed_not_full_coverage : ~ full_coverage observed_dom.
Proof.
  unfold full_coverage. intro H.
  destruct H as [_ Hng].
  apply observed_not_no_gaps in Hng.
  exact Hng.
Qed.

(* 4) Nonetheless, the naive classifier returns a determinate output on an input inside A. *)
Example determinate_output_under_incomplete_boundaries :
  classify_first 1 observed_dom = Some catA.
Proof.
  simpl.
  (* Evaluate the two comparisons against boundary A = [0,2) *)
  destruct (Rlt_dec 1 0) as [Hlt0 | Hnlt0].
  - lra.
  - destruct (Rlt_dec 1 2) as [Hlt2 | Hnlt2].
    + reflexivity.
    + lra.
Qed.

(* 5) Combine (3) and (4) into the “witness” statement. *)
Theorem witness_partial_observability_failure :
  classify_first 1 observed_dom = Some catA /\ ~ full_coverage observed_dom.
Proof.
  split.
  - apply determinate_output_under_incomplete_boundaries.
  - apply observed_not_full_coverage.
Qed.
