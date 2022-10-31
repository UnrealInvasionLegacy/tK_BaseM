class SMPGiantRazorFly extends RazorFly;

function RangedAttack(Actor A)
{
    if (VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius)
    {
        bShotAnim = true;
        PlayAnim('Shoot1');
        if (MeleeDamageTarget(50, (15000.0 * Normal(A.Location - Location))))
            PlaySound(sound'injur1rf', SLOT_Talk);

        Controller.Destination = Location + 110 * (Normal(Location - A.Location) + VRand());
        Controller.Destination.Z = Location.Z + 70;
        Velocity = AirSpeed * normal(Controller.Destination - Location);
        Controller.GotoState('TacticalMove', 'DoMove');
    }
}

defaultproperties
{
     MeleeRange=100.000000
     AirSpeed=2000.000000
     AccelRate=2000.000000
     Health=200
     DrawScale=5.000000
     CollisionRadius=90.000000
     CollisionHeight=55.000000
}
