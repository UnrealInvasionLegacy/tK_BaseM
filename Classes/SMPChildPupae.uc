class SMPChildPupae extends SkaarjPupae;

var SMPQueen ParentQueen;

simulated function PreBeginPlay()
{
    ParentQueen = SMPQueen(Owner);
    if (ParentQueen == None)
        Destroy();

    Super.PreBeginPlay();
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
    if(SMPQueen(EventInstigator) != None)
        Destroy();
    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if (ParentQueen == None || ParentQueen.Controller == None || ParentQueen.Controller.Enemy == self)
    {
        Destroy();
        return;
    }

    if (ParentQueen.Controller != None && Controller != None && Health >= 0)
    {
        Controller.Enemy = ParentQueen.Controller.Enemy;
        Controller.Target = ParentQueen.Controller.Target;
    }
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
    Destroy();
}

function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
    local vector HitLocation, HitNormal;
    local actor HitActor;

    if (ParentQueen == None)
        return false;

    if ( (Controller.Target != None) && (VSize(Controller.Target.Location - Location) <= MeleeRange * 1.4 + Controller.Target.CollisionRadius + CollisionRadius)
        && ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Controller.Target.Location.Z)
            <= FMax(CollisionHeight, Controller.Target.CollisionHeight) + 0.5 * FMin(CollisionHeight, Controller.Target.CollisionHeight))) )
    {
        HitActor = Trace(HitLocation, HitNormal, Controller.Target.Location, Location, false);
        if (HitActor != None)
            return false;

        Controller.Target.TakeDamage(hitdamage, ParentQueen, HitLocation, pushdir, class'MeleeDamage');
        return true;
    }
    return false;
}

function Destroyed()
{
    if (ParentQueen != None)
        ParentQueen.numChildren--;
    Super.Destroyed();
}

function bool SameSpeciesAs(Pawn P)
{
    return false;
}

defaultproperties
{
     ScoringValue=0
}
