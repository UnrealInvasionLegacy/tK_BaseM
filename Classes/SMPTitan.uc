class SMPTitan extends SMPMonster;

var name DeathAnim[3];

var() int SlapDamage, PunchDamage;
var bool bStomped, bThrowed;
var int ThrowCount;

var() name StompEvent;
var() name StepEvent;
var() sound Step, StompSound, slap, swing, throw;
var() float ProjectileSpeed, ProjectileMaxSpeed;

singular event BaseChange()
{
    local float decorMass;

    if (bInterpolating)
        return;

    if ((Base == None) && (Physics == PHYS_None))
    {
        SetPhysics(PHYS_Falling);
    }
    else if (Pawn(Base) != None)
    {
        if ( !Pawn(Base).bCanBeBaseForPawns )
        {
            Base.TakeDamage( 50000, Self,Location,0.5 * Velocity , class'Crushed');
            JumpOffPawn();
            SetPhysics(PHYS_Falling);
        }
    }
    else if ((Decoration(Base) != None) && (Velocity.Z < -400))
    {
        decorMass = FMax(Decoration(Base).Mass, 1);
        Base.TakeDamage((-2* Mass/decorMass * Velocity.Z/4), Self, Location, 0.5 * Velocity, class'Crushed');
    }
}

function Landed(vector HitNormal)
{
    local Pawn Thrown;

    if (Velocity.Z < -10)
    {
        foreach CollidingActors(class 'Pawn', Thrown, Mass)
            ThrowOther(Thrown,Mass/12+(-0.5*Velocity.Z));
    }
    super.Landed(HitNormal);
}

function bool SameSpeciesAs(Pawn P)
{
    return (Monster(P) != None && P.IsA('Monster'));
}

function PlayVictory()
{
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    PlaySound(sound'chestB2Ti',SLOT_Interact);
    SetAnimAction('TChest');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}

function PunchDamageTarget()
{
    if (Controller == None || Controller.Target == None)
        return;

    if (MeleeDamageTarget(PunchDamage, (70000.0 * Normal(Controller.Target.Location - Location))))
    {
        PlaySound(Slap, SLOT_Interact);
        PlaySound(Slap, SLOT_Misc);
    }
}

function SlapDamageTarget()
{
    local vector X,Y,Z;

    if (Controller == None || Controller.Target == None)
        return;

    GetAxes(Rotation,X,Y,Z);
    if (MeleeDamageTarget(SlapDamage, (70000.0 * (Y + vect(0,0,1)))))
    {
        PlaySound(Slap, SLOT_Interact);
        PlaySound(Slap, SLOT_Misc);
    }
}

function RangedAttack(Actor A)
{
    local float decision;

    if (bShotAnim)
        return;

    bShotAnim = true;
    decision = FRand();

    if (VSize(A.Location - Location) < MeleeRange*CollisionRadius/default.CollisionRadius + CollisionRadius + A.CollisionRadius)
    {
        if (decision < 0.6)
        {
            SetAnimAction('TSlap001');
            PlaySound(sound'Punch1Ti', SLOT_Interact);
            PlaySound(sound'Punch1Ti', SLOT_Misc);
        }
        else
        {
            SetAnimAction('TPunc001');
            PlaySound(swing, SLOT_Interact);
            PlaySound(swing, SLOT_Misc);
        }
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        bStomped = false;
    }
    else if (Controller.InLatentExecution(Controller.LATENT_MOVETOWARD))
    {
        SetAnimAction(MovementAnims[0]);
        bThrowed = false;
        return;
    }
    else if (decision < 0.70 || bStomped)
    {
        SetAnimAction('TThro001');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        PlaySound(throw, SLOT_Interact);
    }
    else
    {
        SetAnimAction('TStom001');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        PlaySound(StompSound, SLOT_Interact);
    }
}

function Stomp()
{
    local Pawn Thrown;

    TriggerEvent(StompEvent,Self, Instigator);
    Mass = default.Mass*(CollisionRadius/default.CollisionRadius);
    foreach CollidingActors(class 'Pawn', Thrown, Mass)
        ThrowOther(Thrown,Mass/4);

    PlaySound(Step, SLOT_Interact, 24);
    bStomped = true;
}

function FootStep()
{
    local Pawn Thrown;

    TriggerEvent(StepEvent,Self, Instigator);
    foreach CollidingActors( class 'Pawn', Thrown,Mass*0.5)
        ThrowOther(Thrown,Mass/12);

    PlaySound(Step, SLOT_Interact, 24);
}

function ThrowOther(Pawn Other,int Power)
{
    local float dist, shake;
    local vector Momentum;

    if (Other.Mass >= Mass)
        return;

    if (xPawn(Other) == None)
    {
        if (Power < 400 || (Other.Physics != PHYS_Walking))
            return;
        dist = VSize(Location - Other.Location);
        if (dist > Mass)
            return;
    }
    else
    {
        dist = VSize(Location - Other.Location);
        shake = 0.4*FMax(500, Mass - dist);
        shake = FMin(2000,shake);
        if (dist > Mass)
            return;
        if (Other.Controller != None)
            Other.Controller.ShakeView(vect(0.0,0.02,0.0)*shake, vect(0,1000,0),0.003*shake, vect(0.02,0.02,0.02)*shake, vect(1000,1000,1000),0.003*shake);

        if (Other.Physics != PHYS_Walking)
            return;
    }

    Momentum = 100 * VRand();
    Momentum.Z = FClamp(0,Power,Power - (0.4 * dist + Max(10,Other.Mass)*10));
    Other.AddVelocity(Momentum);
}

function PlayDirectionalHit(Vector HitLoc)
{
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    AmbientSound = None;
    bCanTeleport = false;
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

    HitDamageType = DamageType;
    TakeHitLocation = HitLoc;
    LifeSpan = RagdollLifeSpan;

    GotoState('Dying');

    Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetPhysics(PHYS_Falling);

    if ( (DamageType == class'DamTypeSniperHeadShot') || ((HitLoc.Z > Location.Z + 0.75 * CollisionHeight) && (FRand() > 0.5)
         && (DamageType != class'DamTypeAssaultBullet') && (DamageType != class'DamTypeMinigunBullet') && (DamageType != class'DamTypeFlakChunk')) )
    {
        PlayAnim('TDeat003',1,0.05);
        CreateGib('head',DamageType,Rotation);
        return;
    }

    if (Velocity.Z > 300)
    {
        if (FRand() < 0.5)
            PlayAnim('TDeat001',1.2,0.05);
        else
            PlayAnim('TDeat002',1.2,0.05);
        return;
    }
    PlayAnim(DeathAnim[Rand(3)],1.2,0.05);
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 1.2*CollisionRadius * X + 0.4 * CollisionHeight * Z;
}

function SpawnRock()
{
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;
    local Projectile Proj;

    GetAxes(Rotation,X,Y,Z);
    FireStart = Location + 1.2*CollisionRadius * X + 0.4 * CollisionHeight * Z;
    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = MyAmmo.Class;
        SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
        SavedFireProperties.WarnTargetPct = MyAmmo.WarnTargetPct;
        SavedFireProperties.MaxRange = MyAmmo.MaxRange;
        SavedFireProperties.bTossed = MyAmmo.bTossed;
        SavedFireProperties.bTrySplash = MyAmmo.bTrySplash;
        SavedFireProperties.bLeadTarget = MyAmmo.bLeadTarget;
        SavedFireProperties.bInstantHit = MyAmmo.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }

    FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,600);
    if (FRand() < 0.4)
    {
        Proj = Spawn(class'SMPTitanBoulder',,,FireStart,FireRotation);
        if (Proj != None)
        {
            Proj.SetPhysics(PHYS_Projectile);
            Proj.setDrawScale(Proj.DrawScale*DrawScale/default.DrawScale);
            Proj.SetCollisionSize(Proj.CollisionRadius*DrawScale/default.DrawScale,Proj.CollisionHeight*DrawScale/default.DrawScale);
            Proj.Velocity = (ProjectileSpeed+Rand(ProjectileMaxSpeed-ProjectileSpeed)) *vector(Proj.Rotation)*DrawScale/default.DrawScale;
        }
        return;
    }

    Proj = Spawn(MyAmmo.ProjectileClass,,,FireStart,FireRotation);
    if (Proj != None)
    {
        Proj.SetPhysics(PHYS_Projectile);
        Proj.setDrawScale(Proj.DrawScale*DrawScale/default.DrawScale);
        Proj.SetCollisionSize(Proj.CollisionRadius*DrawScale/default.DrawScale,Proj.CollisionHeight*DrawScale/default.DrawScale);
        Proj.Velocity = (ProjectileSpeed+Rand(ProjectileMaxSpeed-ProjectileSpeed)) *vector(Proj.Rotation)*DrawScale/default.DrawScale;
    }

    FireStart = Location + 1.2*CollisionRadius * X -40*Y+ 0.4 * CollisionHeight * Z;
    Proj = Spawn(MyAmmo.ProjectileClass,,,FireStart,FireRotation);
    if (Proj != None)
    {
        Proj.SetPhysics(PHYS_Projectile);
        Proj.setDrawScale(Proj.DrawScale*DrawScale/default.DrawScale);
        Proj.SetCollisionSize(Proj.CollisionRadius*DrawScale/default.DrawScale,Proj.CollisionHeight*DrawScale/default.DrawScale);
        Proj.Velocity = (ProjectileSpeed + Rand(ProjectileMaxSpeed - ProjectileSpeed)) *vector(Proj.Rotation)*DrawScale/default.DrawScale;
    }
    bStomped = false;
    ThrowCount++;
    if (ThrowCount >= 2)
    {
        bThrowed = true;
        ThrowCount = 0;
    }
}

state Dying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;
    simulated function ProcessHitFX()
    {}
}

defaultproperties
{
     DeathAnim(0)="TDeat001"
     DeathAnim(1)="TDeat002"
     DeathAnim(2)="TDeat003"
     SlapDamage=85
     PunchDamage=80
     StompEvent="TitanStep"
     StepEvent="TitanStep"
     Step=Sound'tK_BaseM.Titan.step1t'
     StompSound=Sound'tK_BaseM.Titan.stomp4t'
     Slap=Sound'tK_BaseM.Titan.slaphit1Ti'
     swing=Sound'tK_BaseM.Titan.Swing1t'
     Throw=Sound'tK_BaseM.Titan.Throw1t'
     ProjectileSpeed=900.000000
     ProjectileMaxSpeed=1000.000000
     InvalidityMomentumSize=100000.000000
     MonsterName="Titan"
     bNoTeleFrag=True
     bNoCrushVehicle=True
     bCanDodge=False
     bBoss=True
     HitSound(0)=Sound'tK_BaseM.Titan.injur1t'
     HitSound(1)=Sound'tK_BaseM.Titan.injur1t'
     HitSound(2)=Sound'tK_BaseM.Titan.injur2t'
     HitSound(3)=Sound'tK_BaseM.Titan.injur2t'
     DeathSound(0)=Sound'tK_BaseM.Titan.death1t'
     DeathSound(1)=Sound'tK_BaseM.Titan.death1t'
     AmmunitionClass=Class'tK_BaseM.SMPTitanAmmo'
     ScoringValue=16
     bCanSwim=False
     MeleeRange=150.000000
     GroundSpeed=500.000000
     AccelRate=2000.000000
     JumpZ=0.000000
     Health=900
     MovementAnims(0)="TWalk001"
     MovementAnims(1)="TWalk001"
     MovementAnims(2)="TWalk001"
     MovementAnims(3)="TWalk001"
     TurnLeftAnim="TWalk001"
     TurnRightAnim="TWalk001"
     WalkAnims(0)="TWalk001"
     WalkAnims(1)="TWalk001"
     WalkAnims(2)="TWalk001"
     WalkAnims(3)="TWalk001"
     AirAnims(0)="TBrea001"
     AirAnims(1)="TBrea001"
     AirAnims(2)="TBrea001"
     AirAnims(3)="TBrea001"
     TakeoffAnims(0)="TBrea001"
     TakeoffAnims(1)="TBrea001"
     TakeoffAnims(2)="TBrea001"
     TakeoffAnims(3)="TBrea001"
     LandAnims(0)="TBrea001"
     LandAnims(1)="TBrea001"
     LandAnims(2)="TBrea001"
     LandAnims(3)="TBrea001"
     DodgeAnims(0)="TBrea001"
     DodgeAnims(1)="TBrea001"
     DodgeAnims(2)="TBrea001"
     DodgeAnims(3)="TBrea001"
     AirStillAnim="TBrea001"
     TakeoffStillAnim="TBrea001"
     IdleCrouchAnim="TSit"
     IdleWeaponAnim="TBrea001"
     IdleRestAnim="TBrea001"
     AmbientSound=Sound'tK_BaseM.Titan.amb1Ti'
     Mesh=VertMesh'tK_BaseM.Titan1'
     Skins(0)=Texture'tK_BaseM.Skins.Jtitan1'
     Skins(1)=Texture'tK_BaseM.Skins.Jtitan1'
     CollisionRadius=110.000000
     CollisionHeight=115.000000
     Mass=2000.000000
     RotationRate=(Yaw=60000)
}
