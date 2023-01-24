class tk_MercenaryAmmo extends Ammunition;

function WarnTarget(Actor Target, Pawn P, vector FireDir)
{
    return;
}

defaultproperties
{
     PickupClass=Class'XWeapons.MinigunAmmoPickup'
}