class tK_SkaarjSniperAmmo extends Ammunition;

function WarnTarget(Actor Target, Pawn P, vector FireDir)
{
    return;
}

defaultproperties
{
     bTryHeadShot=True
     PickupClass=Class'XWeapons.SniperAmmoPickup'
}
