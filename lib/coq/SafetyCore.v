(*
 * SafetyCore.v - Standalone safety module
 *)

Require Import Reals.
Require Import List.
Require Import String.
Require Import Lra.

Open Scope R_scope.
Open Scope string_scope.

Module SafetyCore.

(* Basic safety constants *)
Definition safety_margin : R := 1.0e-6.
Definition safety_precision_requirement : R := 1.0e-9.  (* This was missing! *)

(* Simple boundary record *)
Record SimpleBoundary := {
  lower_bound : R;
  upper_bound : R;
  name : string
}.

(* Safety property *)
Definition safety_critical (measurement boundary : R) : Prop :=
  Rabs (measurement - boundary) < safety_margin.

(* Basic theorems *)
Theorem safety_margin_positive : safety_margin > 0.
Proof.
  unfold safety_margin.
  lra.
Qed.

Theorem safety_precision_positive : safety_precision_requirement > 0.
Proof.
  unfold safety_precision_requirement.
  lra.
Qed.

End SafetyCore.
