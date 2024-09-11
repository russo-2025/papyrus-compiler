Scriptname Ammo extends Form Hidden

; SKSE additions built 2015-05-24 00:46:48.937000 UTC

; Returns whether this ammo is a bolt
bool Function IsBolt() native

; Returns the projectile associated with this ammo
Projectile Function GetProjectile() native

; Returns the base damage of this ammo
float Function GetDamage() native
