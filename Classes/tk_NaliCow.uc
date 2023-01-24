class tk_NaliCow extends tk_Monster;

var sound FootStep[2];
var name DeathAnim[3];
var name HitAnim[2];
const TargetRadius = 1200;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(1, true);
}

simulated function Timer()
{
    local Monster Other;

    foreach VisibleCollidingActors(class'Monster', Other, TargetRadius, Location)
    {
        if (!Other.bAmbientCreature && Other.Controller != None)
            Other.Controller.Trigger(none,self);
    }
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    if (FRand() < 0.6)
        TweenAnim('TakeHit', 0.05);
    else if (FRand() < 0.1)
        TweenAnim('BigHit', 0.05);
    else
        TweenAnim('TakeHit2', 0.05);
}

simulated function AnimEnd(int Channel)
{
    local name Anim;
    local float frame,rate;

    if (Channel == 0)
    {
        GetAnimParams(0, Anim,frame,rate);
        if (Anim == 'Root')
            IdleWeaponAnim = 'Chew';
        else if ((Anim == 'Chew') && (FRand() < 0.5))
            IdleWeaponAnim = 'Swish';
        else if ((Anim == 'Swish') && (FRand() < 0.5))
            IdleWeaponAnim = 'Poop';
        else
            IdleWeaponAnim = 'Root';
    }
    Super.AnimEnd(Channel);
}

simulated function Step()
{
    PlaySound(FootStep[Rand(2)], SLOT_Interact);
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

    if ((DamageType == class'DamTypeSniperHeadShot') || ((HitLoc.Z > Location.Z + 0.75 * CollisionHeight) && (FRand() > 0.5)
            && (DamageType != class'DamTypeAssaultBullet') && (DamageType != class'DamTypeMinigunBullet') && (DamageType != class'DamTypeFlakChunk')))
    {
        PlayAnim('Dead3',1,0.05);
        CreateGib('head',DamageType,Rotation);
        return;
    }

    if (Velocity.Z > 300)
    {
        if (FRand() < 0.5)
            PlayAnim('Dead',1.2,0.05);
        else
            PlayAnim('Dead2',1.2,0.05);
        return;
    }
    PlayAnim(DeathAnim[Rand(3)],1.2,0.05);
}

defaultproperties
{
     Footstep(0)=Sound'SkaarjPack_rc.Cow.walkC'
     Footstep(1)=Sound'SkaarjPack_rc.Cow.walkC'
     DeathAnim(0)="Dead"
     DeathAnim(1)="Dead2"
     DeathAnim(2)="Dead3"
     MonsterName="NaliCow"
     bMeleeFighter=False
     bCanDodge=False
     HitSound(0)=Sound'SkaarjPack_rc.Cow.injurC1c'
     HitSound(1)=Sound'SkaarjPack_rc.Cow.injurC2c'
     HitSound(2)=Sound'SkaarjPack_rc.Cow.injurC1c'
     HitSound(3)=Sound'SkaarjPack_rc.Cow.injurC2c'
     DeathSound(0)=Sound'SkaarjPack_rc.Cow.DeathC1c'
     DeathSound(1)=Sound'SkaarjPack_rc.Cow.DeathC2c'
     DeathSound(2)=Sound'SkaarjPack_rc.Cow.DeathC1c'
     DeathSound(3)=Sound'SkaarjPack_rc.Cow.DeathC2c'
     IdleHeavyAnim="Poop"
     IdleRifleAnim="Chew"
     bCanJump=False
     bAmbientCreature=True
     bNoWeaponFiring=True
     MeleeRange=0.000000
     Health=80
     ControllerClass=Class'tk_BaseM.tk_AnimalController'
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
     AirAnims(0)="Poop"
     AirAnims(1)="Poop"
     AirAnims(2)="Poop"
     AirAnims(3)="Poop"
     TakeoffAnims(0)="Poop"
     TakeoffAnims(1)="Poop"
     TakeoffAnims(2)="Poop"
     TakeoffAnims(3)="Poop"
     LandAnims(0)="Poop"
     LandAnims(1)="root"
     LandAnims(2)="Poop"
     LandAnims(3)="Chew"
     DoubleJumpAnims(0)="Poop"
     DoubleJumpAnims(1)="Poop"
     DoubleJumpAnims(2)="Poop"
     DoubleJumpAnims(3)="Poop"
     DodgeAnims(0)="Poop"
     DodgeAnims(1)="Poop"
     DodgeAnims(2)="Poop"
     DodgeAnims(3)="Poop"
     AirStillAnim="Poop"
     TakeoffStillAnim="Poop"
     IdleWeaponAnim="root"
     IdleRestAnim="Chew"
     TauntAnims(0)="Chew"
     TauntAnims(1)="Poop"
     TauntAnims(2)="root"
     TauntAnims(3)="Chew"
     TauntAnims(4)="Swish"
     TauntAnims(5)="Poop"
     TauntAnims(6)="root"
     TauntAnims(7)="Swish"
     Mesh=VertMesh'SkaarjPack_rc.NaliCow'
     Skins(0)=Texture'SkaarjPack_rc.Skins.JCow1'
     Skins(1)=Texture'SkaarjPack_rc.Skins.JCow1'
     SoundRadius=15.000000
     CollisionRadius=40.000000
     CollisionHeight=35.000000
     Mass=120.000000
}