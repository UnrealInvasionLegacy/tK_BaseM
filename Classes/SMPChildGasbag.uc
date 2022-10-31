class SMPChildGasbag extends Gasbag;

var SMPGiantGasBag ParentBag;
var() byte PunchDamage, PoundDamage;

simulated function PreBeginPlay()
{
    ParentBag = SMPGiantGasBag(Owner);
    if (ParentBag == None)
        Destroy();

    Super.PreBeginPlay();
}

function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (ParentBag == None || ParentBag.Controller == None || ParentBag.Controller.Enemy == self)
    {
        Destroy();
        return;
    }

    if (ParentBag.Controller != None && Controller != None && Health >= 0)
    {
        Controller.Enemy = ParentBag.Controller.Enemy;
        Controller.Target = ParentBag.Controller.Target;
    }
}

function PunchDamageTarget()
{
    if (Controller == None || Controller.Target == None)
        return;

    if (MeleeDamageTarget(PunchDamage, (39000 * Normal(Controller.Target.Location - Location))))
        PlaySound(sound'Hit1g', SLOT_Interact);
}

function PoundDamageTarget()
{
    if (Controller == None || Controller.Target == None)
        return;

    if (MeleeDamageTarget(PoundDamage, (24000 * Normal(Controller.Target.Location - Location))))
        PlaySound(sound'Hit1g', SLOT_Interact);
}

function Destroyed()
{
    if (ParentBag != None)
        ParentBag.numChildren--;
    Super.Destroyed();
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
    local vector HitLocation, HitNormal;
    local actor HitActor;

    if (ParentBag == None)
        return false;

    if ( (Controller.Target != None) && (VSize(Controller.Target.Location - Location) <= MeleeRange * 1.4 + Controller.Target.CollisionRadius + CollisionRadius)
        && ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Controller.Target.Location.Z)
            <= FMax(CollisionHeight, Controller.Target.CollisionHeight) + 0.5 * FMin(CollisionHeight, Controller.Target.CollisionHeight))) )
    {
        HitActor = Trace(HitLocation, HitNormal, Controller.Target.Location, Location, false);
        if (HitActor != None)
            return false;

        Controller.Target.TakeDamage(hitdamage, ParentBag, HitLocation, pushdir, class'MeleeDamage');
        return true;
    }
    return false;
}

simulated function SpawnGiblet(class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation)
{
    local Gib Giblet;
    local Vector Direction, Dummy;

    if ( (GibClass == None) || class'GameInfo'.static.UseLowGore() )
        return;

    Instigator = self;
    Giblet = Spawn(GibClass,,, Location, Rotation);

    if (Giblet == None)
        return;

    Giblet.SetDrawScale(Giblet.DrawScale * (CollisionRadius + CollisionHeight)/69);
    GibPerterbation *= 32768.0;
    Rotation.Pitch += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
    Rotation.Yaw += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;
    Rotation.Roll += (FRand() * 2.0 * GibPerterbation) - GibPerterbation;

    GetAxes(Rotation, Dummy, Dummy, Direction);
    Giblet.Velocity = Velocity + Normal(Direction) * 512.0;
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    Destroy();
}

defaultproperties
{
     PunchDamage=25
     PoundDamage=35
}
