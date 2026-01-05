(Require Import Reals.
Require Import List.
Require Import String.

Import ListNotations.
Open Scope R_scope.

(* === Classification boundary structure === *)
Record ClassBoundary := mkBoundary {
  lower : R;
  upper : R;
  category : string
}.

Definition ClassDomain := list ClassBoundary.

(* === Dummy classification logic === *)
Definition classify_value (x : R) (domain : ClassDomain) : option string :=
  let in_bounds b :=
    (lower b <= x < upper b)%R in
  match find in_bounds domain with
  | Some b => Some (category b)
  | None => None
  end.)

