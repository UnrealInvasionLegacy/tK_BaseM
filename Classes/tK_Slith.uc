class tK_Slith extends tK_Monster;

var() int ClawDamage;
var() sound slick, slash, slice;
var() sound slither, swim, dive;
var() sound surface, scratch, charge;

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.9 * CollisionRadius * X + 0.8 * CollisionRadius * Z;
}

function ShootTarget()
{
    FireProjectile();
}

event PhysicsVolumeChange(PhysicsVolume NewVolume)
{
    super.PhysicsVolumeChange(NewVolume);

    if (NewVolume.bWaterVolume)
        SetAnimAction('Dive');
    else
        SetAnimAction('Surface');
}

function ClawDamageTarget()
{
    if (MeleeDamageTarget(ClawDamage, ClawDamage * 1000.0 * Normal(Controller.Target.Location - Location)))
    {}
}

function PlayVictory()
{
    if (Physics != PHYS_Swimming)
    {
        PlayAnim('ChargeUp', 0.3, 0.1);
        PlaySound(Charge, SLOT_Interact);
    }
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    if (Physics == PHYS_Swimming)
        TweenAnim('WTakeHit', 0.05);
    else
        TweenAnim('LTakeHit', 0.05);
}

function PlayDyingSound()
{
    if (bGibbed)
    {
        PlaySound(GibGroupClass.static.GibSound(), SLOT_Pain,2.5*TransientSoundVolume,true,500);
        return;
    }

    if (PhysicsVolume.bWaterVolume)
        PlaySound(DeathSound[1], SLOT_Pain,2.5*TransientSoundVolume, true,500);
    else
        PlaySound(DeathSound[0], SLOT_Pain,2.5*TransientSoundVolume, true,500);
}

function RangedAttack(Actor A)
{
    local float decision;

    if (bShotAnim)
        return;

    bShotAnim = true;
    decision = FRand();

    if (Physics == PHYS_Swimming)
    {
        if (VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius)
        {
            if (decision < 0.5)
                SetAnimAction('Claw1');
            else
                SetAnimAction('Claw2');
        }
        else if (VSize(A.Location - Location) < 1000 + CollisionRadius + A.CollisionRadius)
        {
            SetAnimAction('Shoot2');
        }
    }
    else if (VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius)
    {
        if (decision < 0.5)
            SetAnimAction('Punch');
        else
            SetAnimAction('Slash');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else
    {
        SetAnimAction('Shoot1');
    }

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
    if (PhysicsVolume.bWaterVolume)
    {
        PlayAnim('Dead2',1.2,0.05);
    }
    else
    {
        SetPhysics(PHYS_Falling);
        PlayAnim('Dead1',1.2,0.05);
    }
}

simulated function AnimEnd(int Channel)
{
    local float decision;

    if (Channel == 0)
    {
        decision = FRand();
        if (Physics == PHYS_Swimming)
            IdleWeaponAnim = 'Swim';
        else if (decision < 0.8)
            IdleWeaponAnim = 'Breath';
        else if (decision < 0.9)
            IdleWeaponAnim = 'Slick';
        else
            IdleWeaponAnim = 'Scratch';
    }
    Super.AnimEnd(Channel);
}

defaultproperties
{
     ClawDamage=25
     slash=Sound'tK_BaseM.Slith.yell4sl'
     slither=Sound'tK_BaseM.Slith.slithr1sl'
     swim=Sound'tK_BaseM.Slith.swim1sl'
     dive=Sound'tK_BaseM.Slith.dive2sl'
     surface=Sound'tK_BaseM.Slith.surf1sl'
     scratch=Sound'tK_BaseM.Slith.scratch1sl'
     ReducedDamTypes(0)=Class'Gameplay.Corroded'
     ReducedDamPct=0.000000
     MonsterName="Slith"
     bCanDodge=False
     HitSound(0)=Sound'tK_BaseM.Slith.injur1sl'
     HitSound(1)=Sound'tK_BaseM.Slith.injur2sl'
     DeathSound(0)=Sound'tK_BaseM.Slith.deathLsl'
     DeathSound(1)=Sound'tK_BaseM.Slith.deathWsl'
     AmmunitionClass=Class'tK_BaseM.tK_SlithAmmo'
     ScoringValue=6
     bCanStrafe=False
     Visibility=150
     SightRadius=2000.000000
     MeleeRange=50.000000
     GroundSpeed=370.000000
     WaterSpeed=350.000000
     AccelRate=1400.000000
     JumpZ=120.000000
     Health=210
     UnderWaterTime=-1.000000
     MovementAnims(0)="SLITHER"
     MovementAnims(1)="SLITHER"
     MovementAnims(2)="SLITHER"
     MovementAnims(3)="SLITHER"
     TurnLeftAnim="SLITHER"
     TurnRightAnim="SLITHER"
     SwimAnims(0)="Swim"
     SwimAnims(1)="Swim"
     SwimAnims(2)="Swim"
     SwimAnims(3)="Swim"
     CrouchAnims(0)="SLITHER"
     CrouchAnims(1)="SLITHER"
     CrouchAnims(2)="SLITHER"
     CrouchAnims(3)="SLITHER"
     WalkAnims(0)="SLITHER"
     WalkAnims(1)="SLITHER"
     WalkAnims(2)="SLITHER"
     WalkAnims(3)="SLITHER"
     AirAnims(0)="Breath"
     AirAnims(1)="Breath"
     AirAnims(2)="Breath"
     AirAnims(3)="Breath"
     TakeoffAnims(0)="DIVE"
     TakeoffAnims(1)="DIVE"
     TakeoffAnims(2)="DIVE"
     TakeoffAnims(3)="DIVE"
     LandAnims(0)="Breath"
     LandAnims(1)="Breath"
     LandAnims(2)="Breath"
     LandAnims(3)="Breath"
     DoubleJumpAnims(0)="DIVE"
     DoubleJumpAnims(1)="DIVE"
     DoubleJumpAnims(2)="DIVE"
     DoubleJumpAnims(3)="DIVE"
     DodgeAnims(0)="DIVE"
     DodgeAnims(1)="DIVE"
     DodgeAnims(2)="DIVE"
     DodgeAnims(3)="DIVE"
     AirStillAnim="Falling"
     TakeoffStillAnim="Surface"
     CrouchTurnRightAnim="SLITHER"
     CrouchTurnLeftAnim="SLITHER"
     IdleCrouchAnim="SLITHER"
     IdleWeaponAnim="SCRATCH"
     IdleRestAnim="Breath"
     AmbientSound=Sound'tK_BaseM.Slith.amb1sl'
     Mesh=VertMesh'tK_BaseM.Slith1'
     Skins(0)=Texture'tK_BaseM.Skins.JSlith1'
     Skins(1)=Texture'tK_BaseM.Skins.JSlith1'
     CollisionRadius=48.000000
     CollisionHeight=47.000000
     Mass=200.000000
     Buoyancy=200.000000
}
