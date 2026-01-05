Require Import Reals List String Recdef.
Require Import Lra.
Import ListNotations.
Open Scope R_scope.

(* === Type Definitions === *)
Record ClassBoundary := mkBoundary {
  lower : R;
  upper : R;
  category : string
}.

Definition ClassDomain := list ClassBoundary.

(* === Helper Functions === *)

Definition in_interval (x : R) (b : ClassBoundary) : Prop :=
  (lower b <= x < upper b)%R.

Definition adjacent (b1 b2 : ClassBoundary) : Prop :=
  (upper b1 = lower b2)%R.

Function classdomain_length (cd : ClassDomain) : nat := List.length cd.

Function sorted (dom : ClassDomain) {measure classdomain_length dom} : Prop :=
  match dom with
  | [] => True
  | [b] => True
  | b1 :: b2 :: rest => (lower b1 <= lower b2)%R /\ sorted (b2 :: rest)
  end.
Proof.
  intros. simpl. apply Nat.lt_succ_diag_r.
Defined.

Function no_gaps (dom : ClassDomain) {measure classdomain_length dom} : Prop :=
  match dom with
  | [] => True
  | [b] => True
  | b1 :: b2 :: rest => adjacent b1 b2 /\ no_gaps (b2 :: rest)
  end.
Proof.
  intros. simpl. apply Nat.lt_succ_diag_r.
Defined.

(* === Example === *)

Definition example_dom : ClassDomain :=
  [ mkBoundary 0 2 "A";
    mkBoundary 2 5 "B";
    mkBoundary 5 8 "C"
  ].

Example in_example : in_interval 3 (mkBoundary 1 5 "OK").
Proof. 
  unfold in_interval. simpl.
  split.
  - compute. lra.
  - compute. lra.
Qed.

Example ex_sorted : sorted example_dom.
Proof. 
  unfold example_dom, sorted. simpl.
  repeat split.
  - compute. lra.
  - compute. lra.  
Qed.

Example ex_no_gaps : no_gaps example_dom.
Proof. simpl. repeat split; try reflexivity. Qed.
