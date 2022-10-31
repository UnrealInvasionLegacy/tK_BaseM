class SMPTitanBoulder extends SMPTitanBigRock;

function MakeSound()
{
    local float soundRad;

    soundRad = 90 * DrawScale;
    PlaySound(ImpactSound, SLOT_Misc, DrawScale/20,,soundRad);
}

simulated function HitWall (vector HitNormal, actor Wall)
{
    Velocity = 0.75 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
    SetRotation(rotator(HitNormal));
    setDrawScale(DrawScale* 0.7);
    SpawnChunks(8);
    Destroy();
}

defaultproperties
{
     Speed=1300.000000
     MaxSpeed=1300.000000
     Mesh=VertMesh'tK_BaseM.BoulderM'
     DrawScale=15.000000
     CollisionRadius=60.000000
     CollisionHeight=60.000000
}
