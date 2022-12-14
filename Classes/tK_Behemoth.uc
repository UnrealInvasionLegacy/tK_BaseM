class tK_Behemoth extends tK_Brute;

function RangedAttack(Actor A)
{
    if ( bShotAnim )
        return;
    if ( Controller.InLatentExecution(Controller.LATENT_MOVETOWARD) )
    {
        SetAnimAction('WalkFire');
        bShotAnim = true;
        return;
    }
    Super.RangedAttack(A);
}

defaultproperties
{
     MonsterName="Behemoth"
     ScoringValue=6
     bCanStrafe=True
     Health=260
     Skins(0)=Texture'SkaarjPackSkins.Skins.jBrute2'
}
