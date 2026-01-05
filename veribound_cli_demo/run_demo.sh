#!/bin/bash
set -euo pipefail

VBIN="/home/duston/veribound_snapshot_20250713_1/_build/default/cli/unified_veribound.exe"
DOMDIR="/home/duston/VeriBound_process_design/boundary_logic/domain_definitions"

BASEL="$DOMDIR/basel_iii_capital_adequacy.yaml"
AML="$DOMDIR/aml_cash.yaml"
AQI="$DOMDIR/aqi.yaml"

if [ ! -x "$VBIN" ]; then
  echo "❌ VeriBound binary not found or not executable:"
  echo "   $VBIN"
  exit 1
fi

for f in "$BASEL" "$AML" "$AQI"; do
  if [ ! -f "$f" ]; then
    echo "❌ Missing domain file:"
    echo "   $f"
    exit 1
  fi
done

echo "================================================================"
echo "VeriBound 2.0 CLI Demonstration (options-based interface)"
echo "Binary:  $VBIN"
echo "Domains: $DOMDIR"
echo "================================================================"
echo

echo "1) Basel III Capital Adequacy at 9.2% (combined checks, level 4)"
"$VBIN" -level 4 -domain "$BASEL" -input 9.2 --combined
echo

echo "2) AML Cash domain structure (gaps-only, level 4)"
"$VBIN" -level 4 -domain "$AML" -input 0.0 --gaps-only
echo

echo "3) AQI domain gaps/overlaps audit (gaps-only, level 4)"
"$VBIN" -level 4 -domain "$AQI" -input 0.0 --gaps-only
echo

echo "4) Mini multi-domain sweep (combined, level 2, input 0.5)"
SWEEP=(
  "$DOMDIR/mifid2_best_execution.yaml"
  "$DOMDIR/medical_device_performance.yaml"
  "$DOMDIR/nuclear_radiation_limits.yaml"
)

i=0
for d in "${SWEEP[@]}"; do
  i=$((i+1))
  if [ -f "$d" ]; then
    echo
    echo "[$i] $d"
    "$VBIN" -level 2 -domain "$d" -input 0.5 --combined || true
  else
    echo
    echo "[$i] (missing) $d"
  fi
done

echo
echo "CLI demonstration complete."
