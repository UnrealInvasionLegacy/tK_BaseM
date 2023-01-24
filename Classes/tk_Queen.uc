class tk_Queen extends tk_Monster
    config(tk_BaseM);

var() name ScreamEvent;
var ColorModifier QueenFadeOutSkin;

var vector TelepDest;
var byte row;
var byte AChannel;
var tk_QueenShield Shield;

var bool bJustScreamed;
var() int ClawDamage, StabDamage;

var() sound Acquire, Fear, Roam, FootStepSound;
var() sound ScreamSound, Stab, Shoot, Claw, Threaten;

var float LastTelepoTime;
var bool bTeleporting;
var int numChildren;
var() config int MaxChildren;

replication
{
    reliable if (Role == ROLE_Authority)
        bTeleporting;
}

simulated function Tick(float DeltaTime)
{
    if (bTeleporting)
        AChannel -= 300 * DeltaTime;
    else
        AChannel = 255;

    QueenFadeOutSkin.Color.A = AChannel;
    if (MonsterController(Controller) != None && Controller.Enemy == None)
    {
        if (MonsterController(Controller).FindNewEnemy())
        {
            SetAnimAction('Meditate');
            GotoState('Teleporting');
            bJustScreamed = false;
        }
    }

    super.Tick(DeltaTime);
}

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    GroundSpeed = GroundSpeed * (1 + 0.1 * MonsterController(Controller).Skill);
    QueenFadeOutSkin = ColorModifier(Level.ObjectPool.AllocateObject(class'ColorModifier'));
    QueenFadeOutSkin.Material = Skins[0];
    Skins[0] = QueenFadeOutSkin;

    // assume the allocated object is dirty
    QueenFadeOutSkin.Color.R = 255;
    QueenFadeOutSkin.Color.G = 255;
    QueenFadeOutSkin.Color.B = 255;
    QueenFadeOutSkin.RenderTwoSided = true;
    QueenFadeOutSkin.AlphaBlend = true;
    QueenFadeOutSkin.MaterialType = 9;
}

simulated function Destroyed()
{
    Level.ObjectPool.FreeObject(QueenFadeOutSkin);
    if (Shield != None)
        Shield.Destroy();

    Super.Destroyed();
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, vector momentum, class<DamageType> damageType)
{
    local vector HitNormal;

    if (CheckReflect(HitLocation, HitNormal, Damage))
        Damage *= 0;

    super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

function PlayVictory()
{
    if (Controller != None)
    {
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        bShotAnim = true;
        PlaySound(Threaten,SLOT_Interact);
        SetAnimAction('ThreeHit');
        Controller.Destination = Location;
        Controller.GotoState('TacticalMove','WaitForAnim');
    }
}

function Scream()
{
    local Actor A;
    local int EventNum;

    PlaySound(ScreamSound, SLOT_None, 3 * TransientSoundVolume);
    SetAnimAction('Scream');
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bJustScreamed = true;

    if (ScreamEvent == '')
        return;

    foreach DynamicActors(class 'Actor', A, ScreamEvent)
    {
        A.Trigger(self, Instigator);
        EventNum++;
    }

    if (EventNum == 0)
        SpawnChildren();
}

function SpawnChildren()
{
    local NavigationPoint N;
    local tk_ChildPupae P;

    for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
    {
        if (numChildren >= MaxChildren)
        {
            return;
        }
        else if (VSize(N.Location - Location) < 2000 && FastTrace(N.Location, Location))
        {
            P = spawn(class'tk_ChildPupae',self,,N.Location);
            if (P != None)
            {
                P.LifeSpan = 20 + Rand(10);
                numChildren++;
            }
        }
    }
}

function SpawnShield()
{
    if (Shield != None)
        Shield.Destroy();

    Shield = Spawn(class'tk_QueenShield',,,Location);
    if (Shield != None)
    {
        Shield.SetDrawScale(Shield.DrawScale*(drawscale/default.DrawScale));
        Shield.AimedOffset.X = CollisionRadius;
        Shield.AimedOffset.Y = CollisionRadius;
        Shield.SetCollisionSize(CollisionRadius*1.2,CollisionHeight*1.2);
    }
}

function SpawnShot()
{
    local vector X,Y,Z, FireStart;

    if (Controller == None)
        return;

    GetAxes(Rotation,X,Y,Z);

    if (row == 0)
        MakeNoise(1.0);
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

    FireStart = Location + 1 * CollisionRadius * X + ( 0.7 - 0.2 * row) * CollisionHeight * Z + 0.2 * CollisionRadius * Y;
    Spawn(MyAmmo.ProjectileClass ,self,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,600));

    FireStart = Location + 1 * CollisionRadius * X + ( 0.7 - 0.2 * row) * CollisionHeight * Z - 0.2 * CollisionRadius * Y;
    Spawn(MyAmmo.ProjectileClass ,self,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,600));
    row++;
}

function RangedAttack(Actor A)
{
    local float decision;

    if (bShotAnim)
        return;

    decision = FRand();
    if (VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius)
    {
        if (decision < 0.4)
        {
            PlaySound(Stab, SLOT_Interact);
            SetAnimAction('Stab');
        }
        else if (decision < 0.7)
        {
            PlaySound(Claw, SLOT_Interact);
            SetAnimAction('Claw');
        }
        else
        {
            PlaySound(Claw, SLOT_Interact);
            SetAnimAction('Gouge');
        }
    }
    else if (!Controller.bPreparingMove && Controller.InLatentExecution(Controller.LATENT_MOVETOWARD) )
    {
        SetAnimAction(MovementAnims[0]);
        bShotAnim = true;
        return;
    }
    else if (VSize(A.Location - Location) > 7000 && (decision < 0.70))
    {
        SetAnimAction('Meditate');
        GotoState('Teleporting');
        bJustScreamed = false;
    }
    else if (!bJustScreamed && (decision < 0.15))
    {
        Scream();
    }
    else if ((Shield != None) && (decision < 0.5) && (((A.Location - Location) dot (Shield.Location - Location)) > 0))
    {
        Scream();
    }
    else if ((decision < 0.8 && Shield != None) || decision < 0.4)
    {
        if (Shield != None)
            Shield.Destroy();
        row = 0;
        bJustScreamed = false;
        SetAnimAction('Shoot1');
        PlaySound(Shoot, SLOT_Interact);
    }
    else if (Shield == None && (decision < 0.9))
    {
        SetAnimAction('Shield');
    }
    else if (!IsInState('Teleporting') && (decision < 0.6))
    {
        SetAnimAction('Meditate');
        GotoState('Teleporting');
    }
    else
    {
        if (Shield != None)
            Shield.Destroy();
        row = 0;
        bJustScreamed = false;
        SetAnimAction('Shoot1');
        PlaySound(Shoot, SLOT_Interact);
    }
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
}

function ClawDamageTarget()
{
    if (Controller == None || Controller.Target == None)
        return;

    if ( MeleeDamageTarget(ClawDamage, (50000.0 * (Normal(Controller.Target.Location - Location)))) )
        PlaySound(Claw, SLOT_Interact);
}

function StabDamageTarget()
{
    local vector X,Y,Z;

    if (Controller == None || Controller.Target == None)
        return;

    GetAxes(Rotation,X,Y,Z);
    if ( MeleeDamageTarget(StabDamage, (15000.0 * (Y + vect(0,0,1)))) )
        PlaySound(Stab, SLOT_Interact);
}

simulated function FootStep()
{
    PlaySound(FootStepSound, SLOT_Interact, 8);
}

function ThrowOther(Pawn Other, int Power)
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

function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    if (Damage > 80)
        PlayDirectionalHit(HitLocation);

    if (Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds)
        return;

    LastPainSound = Level.TimeSeconds;
    PlaySound(HitSound[Rand(4)], SLOT_Pain,2*TransientSoundVolume,,400);
}

function PlayDirectionalHit(Vector HitLoc)
{
    TweenAnim('TakeHit', 0.05);
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
    if (Shield != None)
        Shield.Destroy();
    GotoState('Dying');

    Velocity += TearOffMomentum;
    BaseEyeHeight = Default.BaseEyeHeight;
    SetPhysics(PHYS_Falling);

    PlayAnim('OutCold',0.7, 0.1);
}

function bool CheckReflect(Vector HitLocation, out Vector RefNormal, int Damage)
{
    local Vector HitDir;
    local Vector FaceDir;

    FaceDir = vector(Rotation);
    HitDir = Normal(Location - HitLocation + Vect(0,0,8));
    RefNormal = FaceDir;
    if (FaceDir dot HitDir < -0.26 && Shield != None)
    {
        Shield.Flash(Damage);
        return true;
    }
    return false;
}

function Teleport()
{
    local rotator EnemyRot;

    if (Role == ROLE_Authority)
        ChooseDestination();
    SetLocation(TelepDest + vect(0,0,1) * CollisionHeight/2);
    if (Controller.Enemy != None)
        EnemyRot = rotator(Controller.Enemy.Location - Location);
    EnemyRot.Pitch = 0;
    SetRotation(EnemyRot);
    PlaySound(sound'Teleport1', SLOT_Interface);
}

function ChooseDestination()
{
    local NavigationPoint N;
    local vector ViewPoint, Best;
    local float rating, newrating;
    local Actor jActor;

    Best = Location;
    TelepDest = Location;
    rating = 0;

    if (Controller.Enemy == None)
        return;

    for(N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
    {
        newrating = 0;
        ViewPoint = N.Location + vect(0,0,1) * CollisionHeight/2;
        if (FastTrace(Controller.Enemy.Location,ViewPoint))
            newrating += 20000;

        newrating -= VSize(N.Location - Controller.Enemy.Location) + 1000 * FRand();
        foreach N.VisibleCollidingActors(class'Actor', jActor, CollisionRadius, ViewPoint)
            newrating -= 30000;

        if (newrating > rating)
        {
            rating = newrating;
            Best = N.Location;
        }
    }
    TelepDest = Best;
}

state Teleporting
{
    function Tick(float DeltaTime)
    {
        if (AChannel < 20)
        {
            if (Role == ROLE_Authority)
                Teleport();
            GotoState('');
        }
        Global.Tick(DeltaTime);
    }

    function RangedAttack(Actor A)
    {
        return;
    }

    function BeginState()
    {
        if (Controller.Enemy == None)
        {
            GotoState('');
            return;
        }
        bTeleporting = true;
        Acceleration = Vect(0,0,0);
        bUnlit = true;
        AChannel = 255;
        Spawn(class'tk_QueenTeleportEffect',,,Location);
    }

    function EndState()
    {
        bTeleporting = false;
        bUnlit = false;
        AChannel = 255;
        LastTelepoTime = Level.TimeSeconds;
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
     ScreamEvent="QScream"
     ClawDamage=70
     StabDamage=90
     AChannel=255
     Acquire=Sound'tk_BaseM.Queen.yell1Q'
     Fear=Sound'tk_BaseM.Queen.yell2Q'
     Roam=Sound'tk_BaseM.Queen.nearby2Q'
     footstepSound=Sound'tk_BaseM.Titan.step1t'
     ScreamSound=Sound'tk_BaseM.Queen.yell3Q'
     Stab=Sound'tk_BaseM.Queen.stab1Q'
     Shoot=Sound'tk_BaseM.Queen.shoot1Q'
     Claw=Sound'tk_BaseM.Queen.claw1Q'
     Threaten=Sound'tk_BaseM.Queen.yell2Q'
     MaxChildren=2
     InvalidityMomentumSize=100000.000000
     MonsterName="Queen"
     bNoTeleFrag=True
     bNoCrushVehicle=True
     bBoss=True
     HitSound(0)=Sound'tk_BaseM.Queen.yell2Q'
     HitSound(1)=Sound'tk_BaseM.Queen.yell2Q'
     HitSound(2)=Sound'tk_BaseM.Queen.yell2Q'
     HitSound(3)=Sound'tk_BaseM.Queen.yell2Q'
     DeathSound(0)=Sound'tk_BaseM.Queen.outcoldQ'
     DeathSound(1)=Sound'tk_BaseM.Queen.outcoldQ'
     DeathSound(2)=Sound'tk_BaseM.Queen.outcoldQ'
     DeathSound(3)=Sound'tk_BaseM.Queen.outcoldQ'
     AmmunitionClass=Class'tk_BaseM.tk_QueenAmmo'
     ScoringValue=14
     bCanSwim=False
     MeleeRange=120.000000
     GroundSpeed=600.000000
     AccelRate=1600.000000
     JumpZ=800.000000
     Health=800
     MovementAnims(0)="Run"
     MovementAnims(1)="Run"
     MovementAnims(2)="Run"
     MovementAnims(3)="Run"
     TurnLeftAnim="Walk"
     TurnRightAnim="Walk"
     WalkAnims(0)="Walk"
     WalkAnims(1)="Walk"
     WalkAnims(2)="Walk"
     WalkAnims(3)="Walk"
     IdleWeaponAnim="Meditate"
     IdleRestAnim="Meditate"
     AmbientSound=Sound'tk_BaseM.Queen.amb1Q'
     Mesh=VertMesh'tk_BaseM.SkQueen'
     Skins(0)=Texture'tk_BaseM.Skins.JQueen1'
     Skins(1)=Texture'tk_BaseM.Skins.JQueen1'
     TransientSoundVolume=16.000000
     CollisionRadius=90.000000
     CollisionHeight=106.000000
     Mass=1000.000000
}