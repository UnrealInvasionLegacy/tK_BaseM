class SMPTentacleProj extends Projectile;

simulated function PostBeginPlay()
{
    if (bDeleteMe || IsInState('Dying'))
        return;
    Velocity = (speed + Rand(MaxSpeed - speed)) * vector(Rotation);
    PlaySound(SpawnSound);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
    if (Other != instigator)
    {
        if (Role == ROLE_Authority)
            Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
    }
    Explode(HitLocation, vect(0,0,1));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    if (EffectIsRelevant(Location,false))
        Spawn(class'WallSparks',,, HitLocation, rotator(HitNormal));
    PlaySound(ImpactSound);
    Destroy();
}

defaultproperties
{
     Speed=800.000000
     MaxSpeed=800.000000
     Damage=22.000000
     MomentumTransfer=10000.000000
     SpawnSound=Sound'tK_BaseM.Tentacle.TentSpawn'
     ImpactSound=Sound'tK_BaseM.Tentacle.TentImpact'
     LifeSpan=15.000000
     Mesh=VertMesh'tK_BaseM.TentProjectile'
     AmbientGlow=255
     Mass=2.000000
}
