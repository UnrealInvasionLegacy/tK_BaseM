class tk_DevilFish extends tk_Monster
    config(tk_BaseM);

var float AirTime;
var() byte BiteDamage, RipDamage;
var() config bool bCheckWater;

var bool bFlopping;

replication
{
    unreliable if (Role == ROLE_Authority)
        bFlopping;
}

event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (!CheckWater())
        Destroy();
}

function bool CheckWater()
{
    local PhysicsVolume PV;
    local vector HitLoc,HitNorm;

    if (!bCheckWater || PhysicsVolume.bWaterVolume)
        return true;

    foreach TraceActors(class'PhysicsVolume', PV, HitLoc, HitNorm, Location + vect(0,0,-1)*700, Location + vect(0,0,-1)*CollisionHeight/2)
    {
        if (PV != None && PV.bWaterVolume)
        {
            if (FastTrace(Location, HitLoc))
            {
                if (SetLocation(HitLoc));
                    return true;
            }
        }
    }

    return false;
}

function RangedAttack(Actor A)
{
    local float Dist, decision;

    if (bShotAnim)
        return;

    Dist = VSize(Location - A.Location);
    if (Dist > MeleeRange + CollisionRadius + A.CollisionRadius)
        return;

    bShotAnim = true;
    if (GetAnimSequence() == 'Grab1')
    {
        PlayAnim('ripper', 0.5 + 0.5 * FRand());
        PlaySound(sound'tear1fs',SLOT_Interact,,,500);
        MeleeDamageTarget(RipDamage, vect(0,0,0));
        Disable('Bump');
        return;
    }

    decision = FRand();
    if (decision < 0.3)
    {
        Disable('Bump');
        SetAnimAction('Grab1');
        return;
    }

    Enable('Bump');
    if (decision < 0.55)
    {
        SetAnimAction('Bite1');
    }
    else if (decision < 0.8)
    {
        SetAnimAction('Bite2');
    }
    else
    {
        SetAnimAction('Bite3');
    }
    MeleeDamageTarget(BiteDamage, (BiteDamage * 1000.0 * Normal(Controller.Target.Location - Location)));
}

simulated event SetAnimAction(name NewAction)
{
    if ( !bWaitForAnim || (Level.NetMode == NM_Client) )
    {
        AnimAction = NewAction;
        if (PlayAnim(AnimAction,,0.3))
        {
            if (Physics != PHYS_None)
                bWaitForAnim = true;
        }
    }
}

singular function Bump(actor Other)
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

    if (PhysicsVolume.bWaterVolume)
    {
        PlaySound(sound'death1fs', SLOT_Talk, 4 * TransientSoundVolume);
        PlayAnim('Dead1', 0.7, 0.1);
    }
    else
    {
        TweenAnim('Breathing', 0.35);
    }
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    TweenAnim('TakeHit', 0.05);
}

function Landed(vector HitNormal)
{
    if (PhysicsVolume.bWaterVolume)
        return;
    GotoState('Flopping');
    Landed(HitNormal);
}

function PlayVictory()
{
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    PlayAnim('ripper', 0.6, 0.1);
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}

function SetMovementPhysics()
{
    SetPhysics(PHYS_Swimming);
}

simulated function AnimEnd(int Channel)
{
    if (bFlopping)
    {
        if (Physics == PHYS_None)
        {
            if (GetAnimSequence() == 'Breathing')
            {
                PlaySound(sound'breath1fs',SLOT_Interact,,,300);
                PlayAnim('Breathing');
            }
            else
		{
                TweenAnim('Breathing', 0.2);
		}
        }
        else
	  {
            PlayAnim('Flopping', 0.7);
	  }
    }
    super.AnimEnd(Channel);
}

state Flopping
{
ignores seeplayer, hearnoise, enemynotvisible, hitwall;

    function Timer()
    {
        AirTime += 1;
        if (AirTime > 25 + 15 * FRand())
        {
            Health = -1;
            Died(None, class'Drowned', Location);
            return;
        }
        SetPhysics(PHYS_Falling);
        Velocity = 200 * VRand();
        Velocity.Z = 200 + 200 * FRand();
        DesiredRotation.Pitch = Rand(8192) - 4096;
        DesiredRotation.Yaw = Rand(65535);
        SetAnimAction('Flopping');
    }

    function RangedAttack(Actor A)
    {}

    event PhysicsVolumeChange(PhysicsVolume NewVolume)
    {
        local rotator newRotation;

        if (NewVolume.bWaterVolume)
        {
            newRotation = Rotation;
            newRotation.Roll = 0;
            SetRotation(newRotation);
            SetPhysics(PHYS_Swimming);
            AirTime = 0;
            GotoState(initialstate);
        }
        else
	  {
            SetPhysics(PHYS_Falling);
	  }
    }

    function Landed(vector HitNormal)
    {
        local rotator newRotation;
        SetPhysics(PHYS_none);
        SetTimer(0.3 + 0.3 * AirTime * FRand(), false);
        newRotation = Rotation;
        newRotation.Pitch = 0;
        newRotation.Roll = Rand(16384) - 8192;
        DesiredRotation.Pitch = 0;
        SetRotation(newRotation);
        PlaySound(sound'flop1fs',SLOT_Interact,,,400);
        TweenAnim('Breathing', 0.3);
    }

    simulated event SetAnimAction(name NewAction)
    {
        if ( !bWaitForAnim || (Level.NetMode == NM_Client) )
        {
            AnimAction = NewAction;
            if (PlayAnim(AnimAction,,0.1))
            {
                if (Physics != PHYS_None)
                    bWaitForAnim = true;
            }
        }
    }

    simulated function BeginState()
    {
        bFlopping = true;
    }

    simulated function EndState()
    {
        bFlopping = false;
    }
}

defaultproperties
{
     BiteDamage=15
     RipDamage=20
     bCheckWater=True
     ReducedDamTypes(0)=Class'Gameplay.Corroded'
     ReducedDamPct=0.000000
     bCrawler=True
     bCanJump=False
     bCanWalk=False
     bCanStrafe=False
     MeleeRange=14.000000
     WaterSpeed=250.000000
     Health=70
     UnderWaterTime=-1.000000
     MovementAnims(0)="Swimming"
     MovementAnims(1)="Swimming"
     MovementAnims(2)="Swimming"
     MovementAnims(3)="Swimming"
     SwimAnims(0)="Swimming"
     SwimAnims(1)="Swimming"
     SwimAnims(2)="Swimming"
     SwimAnims(3)="Swimming"
     WalkAnims(0)="Swimming"
     WalkAnims(1)="Swimming"
     WalkAnims(2)="Swimming"
     WalkAnims(3)="Swimming"
     AirAnims(0)="Swimming"
     AirAnims(1)="Swimming"
     AirAnims(2)="Swimming"
     AirAnims(3)="Swimming"
     TakeoffAnims(0)="Swimming"
     TakeoffAnims(1)="Swimming"
     TakeoffAnims(2)="Swimming"
     TakeoffAnims(3)="Swimming"
     LandAnims(0)="breathing"
     LandAnims(1)="breathing"
     LandAnims(2)="breathing"
     LandAnims(3)="breathing"
     AirStillAnim="Swimming"
     TakeoffStillAnim="Swimming"
     IdleSwimAnim="Swimming"
     AmbientSound=Sound'tk_BaseM.Razorfish.ambfs'
     Mesh=VertMesh'tk_BaseM.fish'
     Skins(0)=Texture'tk_BaseM.Skins.Jfish1'
     Skins(1)=Texture'tk_BaseM.Skins.Jfish1'
     CollisionRadius=35.000000
     CollisionHeight=20.000000
     Mass=60.000000
     Buoyancy=60.000000
}