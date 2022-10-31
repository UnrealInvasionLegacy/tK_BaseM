class tK_Tentacle extends tK_Monster;

var bool bSetLocation;
var int LocationChangeCount;

event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if (!bSetLocation)
    {
        LocationChangeCount++;
        if (SetTentacleLocation())
            bSetLocation = true;
    }

    if (LocationChangeCount > 20)
        Destroy();
}

function bool SetTentacleLocation()
{
    local Actor Other;
    local vector HitLoc, HitNorm;

    foreach TraceActors(class'Actor', Other, HitLoc, HitNorm, Location + vect(0,0,1)*5000, Location)
    {
        if (Other.bWorldGeometry && Other.bBlockActors)
        {
            SetPhysics(PHYS_None);
            SetBase(Other, HitLoc - vect(0,0,1) * (CollisionHeight));
            if (SetLocation(HitLoc - vect(0,0,1) * (CollisionHeight)))
                return true;
            else
                return false;
        }
    }
    return false;
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    TweenAnim('TakeHit', 0.05);
}

singular function Falling()
{
    //SetMovementPhysics();
}

simulated function SetMovementPhysics()
{
    SetPhysics(PHYS_None);
}

function PlayWaiting()
{
    TweenAnim('Hide', 5.0);
}

function PlayVictory()
{
    PlaySound(Sound'strike2tn', SLOT_Interact);
    PlayAnim('Smack', 0.6, 0.1);
}

simulated function AddVelocity(vector NewVelocity)
{
    if (Physics == PHYS_Rotating || Physics == PHYS_None)
        Velocity = vect(0,0,0);
    else
        Velocity += NewVelocity;
}

function RangedAttack(Actor A)
{
    local rotator tmpRotation;

    tmpRotation = rotator(Controller.Target.Location - Location);
    tmpRotation.Pitch = 0;
    setRotation(tmpRotation);
    Controller.setRotation(tmpRotation);

    if (bShotAnim)
        return;

    if (VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius)
    {
        PlaySound(Sound'strike2tn', SLOT_Interact);
        SetAnimAction('Smack');
    }
    else
        SetAnimAction('Shoot');

    bShotAnim = true;
}

function Shoot()
{
    FireProjectile();
}

function SmackTarget()
{
    if (MeleeDamageTarget(28, 25000 * Normal(Controller.Target.Location - Location)))
        PlaySound(Sound'splat2tn', SLOT_Interact);
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
    local vector HitLocation, HitNormal;
    local actor HitActor;

    if ((Controller.Target != None) && (VSize(Controller.Target.Location - Location) <= MeleeRange * 1.5 + Controller.Target.CollisionRadius + CollisionRadius))
    {
        HitActor = Trace(HitLocation, HitNormal, Controller.Target.Location, Location, false);
        if (HitActor != None)
            return false;
        Controller.Target.TakeDamage(hitdamage, self, HitLocation, pushdir, class'MeleeDamage');
        return true;
    }
    return false;
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + CollisionHeight * vect(0,0,-1.2);
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    SetPhysics(PHYS_Falling);
    AmbientSound = None;
    bCanTeleport = false;
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;
        LifeSpan = RagdollLifeSpan;
    Velocity = vect(0,0,800);

    GotoState('Dying');
    if (Velocity.Z > 200)
        PlayAnim('Dead2', 0.7, 0.1);
    else
        PlayAnim('Dead1', 0.7, 0.1);
}

defaultproperties
{
     MonsterName="Tentacle"
     AmmunitionClass=Class'tK_BaseM.tK_TentacleAmmo'
     bCanJump=False
     bCanWalk=False
     MeleeRange=70.000000
     GroundSpeed=0.000000
     AirSpeed=0.000000
     Health=50
     MovementAnims(0)="Move2"
     MovementAnims(1)="Move2"
     MovementAnims(2)="Move2"
     MovementAnims(3)="Move2"
     WalkAnims(0)="Move1"
     WalkAnims(1)="Move1"
     WalkAnims(2)="Move1"
     WalkAnims(3)="Move1"
     AirAnims(0)="Dead1"
     AirAnims(1)="Dead1"
     AirAnims(2)="Dead1"
     AirAnims(3)="Dead1"
     LandAnims(0)="Dead2"
     LandAnims(1)="Dead2"
     LandAnims(2)="Dead2"
     LandAnims(3)="Dead2"
     Mesh=VertMesh'tK_BaseM.Tentacle1'
     Skins(0)=Texture'tK_BaseM.Skins.JTentacle1'
     Skins(1)=None
     CollisionRadius=28.000000
     CollisionHeight=36.000000
     RotationRate=(Pitch=0,Yaw=30000,Roll=0)
}
