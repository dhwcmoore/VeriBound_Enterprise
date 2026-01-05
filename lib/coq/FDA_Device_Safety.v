Require Import SafetyCore.
Require Import Reals.
Require Import Lra.

Open Scope R_scope.

Module FDA_Medical_Device.
  Import SafetyCore.
  
  Definition fda_precision_requirement : R := 1.0e-12.
  
  Theorem fda_precision_stricter : 
    fda_precision_requirement < SafetyCore.safety_precision_requirement.
  Proof.
    unfold fda_precision_requirement, SafetyCore.safety_precision_requirement.
    lra.
  Qed.
  
End FDA_Medical_Device.
