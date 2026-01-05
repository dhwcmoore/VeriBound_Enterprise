(* FlocqTypes.v *)
Require Import Flocq.Appli.Fappli_IEEE.
Require Import Flocq.Appli.Fappli_IEEE_bits.

Open Scope binary_float_scope.

(* Define IEEE 754 double precision parameters *)
Definition float64 := binary64.

Record VerifiedBoundary := {
  lower_float : float64;
  upper_float : float64;
  category : string
}.
