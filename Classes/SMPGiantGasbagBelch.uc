class SMPGiantGasBagBelch extends GasBagBelch;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    SmokeTrail.SetDrawScale(SmokeTrail.DrawScale * 2.5);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Actor A;

    PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    A = spawn(class'FlakExplosion',,,HitLocation + HitNormal*16);
    if (A != None)
    {
        A.SetDrawScale(A.DrawScale*2);
        A = None;
    }

    A = spawn(class'FlashExplosion',,,HitLocation + HitNormal*16);
    if (A != None)
    {
        A.SetDrawScale(A.DrawScale*2);
        A = None;
    }

    if ((ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer))
        A = Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));

    if (A != None)
    {
        A.SetDrawScale(A.DrawScale*2);
        A = None;
    }

    BlowUp(HitLocation);
    Destroy();
}

defaultproperties
{
     Damage=50.000000
     DamageRadius=230.000000
     DrawScale=0.600000
}
