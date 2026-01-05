(** AQI classification logic *)

Definition classify_aqi (aqi : Z) : string :=
  if (aqi <? 50)%Z then "Good" else
  if (aqi <? 100)%Z then "Moderate" else
  if (aqi <? 150)%Z then "Unhealthy for Sensitive Groups" else
  if (aqi <? 200)%Z then "Unhealthy" else
  if (aqi <? 300)%Z then "Very Unhealthy" else
  "Hazardous".
