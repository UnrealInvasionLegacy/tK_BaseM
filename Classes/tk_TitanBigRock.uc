class tk_TitanBigRock extends Projectile;

var float lastBoundTime;
var byte Bounces;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        Bounces;
}

simulated function PostBeginPlay()
{
    local vector Dir;
    local float decision;

    if (bDeleteMe || IsInState('Dying'))
        return;

    Dir = vector(Rotation);
    Velocity = (speed + Rand(MaxSpeed - speed)) * Dir;

    DesiredRotation.Pitch = Rotation.Pitch + Rand(2000) - 1000;
    DesiredRotation.Roll = Rotation.Roll + Rand(2000) - 1000;
    DesiredRotation.Yaw = Rotation.Yaw + Rand(2000) - 1000;
    decision = FRand();

    if (decision < 0.25)
        SetStaticMesh(StaticMesh'TitanBigRock2');
    else if (decision < 0.5)
        SetStaticMesh(StaticMesh'TitanBigRock3');
    else if (decision < 0.75)
        SetStaticMesh(StaticMesh'TitanBigRock4');

    if (FRand() < 0.5)
        RotationRate.Pitch = Rand(180000);
    if ((RotationRate.Pitch == 0) || (FRand() < 0.8))
        RotationRate.Roll = Max(0, 50000 + Rand(200000) - RotationRate.Pitch);
}

function ProcessTouch(Actor Other, Vector HitLocation)
{
    local int hitdamage;

    if (Other == None || Other == instigator)
        return;

    PlaySound(ImpactSound, SLOT_Interact, DrawScale/10);
    if (Projectile(Other) != None)
    {
        Other.Destroy();
    }
    else if(tk_TitanBigRock(Other) == None)
    {
        Hitdamage = Damage * 0.00002 * (DrawScale**3) * speed;
        if ((HitDamage > 3) && (speed > 150) && (Role == ROLE_Authority))
            Other.TakeDamage(hitdamage, instigator, HitLocation, (35000.0 * Normal(Velocity)*DrawScale), MyDamageType);
    }
}

simulated function Landed(vector HitNormal)
{
    SetPhysics(PHYS_None);
    LifeSpan = 2.0;
}

simulated function HitWall (vector HitNormal, actor Wall)
{
    local vector RealHitNormal;
    local int HitDamage;

    if ( !Wall.bStatic && !Wall.bWorldGeometry && ((Mover(Wall) == None) || Mover(Wall).bDamageTriggered) )
    {
        if (Level.NetMode != NM_Client)
        {
            Hitdamage = Damage * 0.00002 * (DrawScale**3) * speed;
            if (Instigator == None || Instigator.Controller == None)
                Wall.SetDelayedDamageInstigatorController(InstigatorController);
            Wall.TakeDamage(Hitdamage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
        }
    }

    speed = VSize(velocity);
    if (Bounces > 0 && speed > 100)
    {
        MakeSound();
        SetPhysics(PHYS_Falling);
        RealHitNormal = HitNormal;
        if (FRand() < 0.5)
            RotationRate.Pitch = Max(RotationRate.Pitch, 100000);
        else
            RotationRate.Roll = Max(RotationRate.Roll, 100000);
        HitNormal = Normal(HitNormal + 0.5 * VRand());
        if ((RealHitNormal Dot HitNormal) < 0)
            HitNormal.Z *= -0.7;
        Velocity = 0.7 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
        DesiredRotation = rotator(HitNormal);

        if (speed > 250)
            SpawnChunks(4);
        Bounces = Bounces - 1;
        return;
    }
    bFixedRotationDir=false;
    bBounce = false;
}

function MakeSound()
{
    local float soundRad;

    if (Drawscale > 5.0)
        soundRad = 80 * DrawScale;
    else
        soundRad = 40* DrawScale;
    PlaySound(ImpactSound, SLOT_Misc, DrawScale/20,,soundRad);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    if (instigatedBy == None)
        return;

    if (Damage < 10)
        return;

    Velocity += Momentum/(DrawScale * 10);
    if (Physics == PHYS_None)
    {
        SetPhysics(PHYS_Falling);
        Velocity.Z += 0.4 * VSize(momentum);
    }

    if (2 < DrawScale)
        SpawnChunks(4);
}

function InitFrag(tk_TitanBigRock myParent, float Pscale)
{
    RotationRate = RotRand();
    Pscale *= (0.5 + FRand());
    SetDrawScale(Pscale * myParent.DrawScale);
    if (DrawScale <= 2)
    {
        SetCollisionSize(0,0);
        RemoteRole = ROLE_None;
        bNotOnDedServer = True;
    }
    else
        SetCollisionSize(CollisionRadius * DrawScale/Default.DrawScale, CollisionHeight * DrawScale/Default.DrawScale);

    Velocity = Normal(VRand() + myParent.Velocity/myParent.speed) * (myParent.speed * (0.4 + 0.3 * (FRand() + FRand())));
}

function SpawnChunks(int num)
{
    local int NumChunks, i;
    local tk_TitanBigRock TempRock;
    local float pscale;

    if (DrawScale < 2 + FRand() * 2)
        return;
    if (Invasion(Level.Game) != None && DrawScale < 4 + FRand() * 2)
        return;

    NumChunks = 1 + Rand(num);
    pscale = sqrt(0.52/NumChunks);
    if (pscale * DrawScale < 1)
    {
        NumChunks *= pscale * DrawScale;
        pscale = 1/DrawScale;
    }
    speed = VSize(Velocity);
    for (i = 0; i < NumChunks; i++)
    {
        TempRock = Spawn(class'tk_TitanBigRock');
        if (TempRock != None)
            TempRock.InitFrag(self, pscale);
    }
    InitFrag(self, 0.5);
}

defaultproperties
{
     Bounces=4
     Speed=900.000000
     MaxSpeed=900.000000
     Damage=40.000000
     MyDamageType=Class'tk_BaseM.tk_DamTypeTitanRock'
     ImpactSound=Sound'tk_BaseM.Titan.Rockhit'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'tk_BaseM.TitanBigRock1'
     Physics=PHYS_Falling
     LifeSpan=20.000000
     DrawScale=7.000000
     CollisionRadius=30.000000
     CollisionHeight=30.000000
     bUseCylinderCollision=False
     bBounce=True
     bFixedRotationDir=True
}