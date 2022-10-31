class SMPQueenProjectile extends SkaarjProjectile;

simulated function PostBeginPlay()
{
    Super(Projectile).PostBeginPlay();

    if (Level.NetMode != NM_DedicatedServer)
    {
        SparkleTrail = Spawn(class'SMPSkaarjSparkles', self);
        SparkleTrail.Skins[0] = Texture;
        SparkleTrail.SetDrawScale(0.8);
    }

    Velocity = (Speed + Rand(MaxSpeed - Speed)) * Vector(Rotation);
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    local Vector X, RefNormal, RefDir;

    if (Other == Instigator || Other == Owner || Other == None)
        return;

    if (xPawn(Other) != None && xPawn(Other).CheckReflect(HitLocation, RefNormal, Damage*0.5))
    {
        if (Role == ROLE_Authority)
        {
            X = Normal(Velocity);
            RefDir = X - 2.0*RefNormal*(X dot RefNormal);
            RefDir = RefNormal;
            Spawn(Class, Other,, HitLocation+RefDir*20, Rotator(RefDir));
        }
        DestroyTrails();
        Destroy();
    }
    else if ( !Other.IsA('SMPQueenProjectile') || Other.bProjTarget )
    {
        Other.TakeDamage(Damage,instigator,HitLocation,MomentumTransfer*Normal(Other.Location - Location),MyDamageType);
        Destroy();
    }
}

defaultproperties
{
     MaxSpeed=2000.000000
     Damage=40.000000
     MomentumTransfer=700.000000
     MyDamageType=Class'tK_BaseM.SMPDamTypeQueenProj'
     LightRadius=2.000000
     DrawScale=0.100000
     SoundRadius=20.000000
}
