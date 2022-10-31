class SMPNaliFighter extends SMPMonster
    config(tK_BaseM);

var() config array<string> WeaponClassName;
var() config bool bNoThrowWeapon;
var() float FireRateScale;

function PostBeginPlay()
{
    local class<Weapon> WeaponClass;
    local int x;

    Super.PostBeginPlay();

    x = Rand(WeaponClassName.Length);

    WeaponClass = Class<Weapon>(DynamicLoadObject(WeaponClassName[x],class'class'));
    if (WeaponClass != None)
        Weapon = spawn(WeaponClass,self);

    if (Weapon == None)
        return;

    Weapon.GiveTo(self);
    Weapon.AttachToPawn(self);

    if ( !SavedFireProperties.bInitialized )
    {
        SavedFireProperties.AmmoClass = Weapon.AmmoClass[0];
        SavedFireProperties.ProjectileClass = Weapon.AmmoClass[0].default.ProjectileClass;
        SavedFireProperties.WarnTargetPct = Weapon.AmmoClass[0].default.WarnTargetPct;
        SavedFireProperties.MaxRange = Weapon.AmmoClass[0].default.MaxRange;
        SavedFireProperties.bTossed = Weapon.AmmoClass[0].default.bTossed;
        SavedFireProperties.bTrySplash = Weapon.AmmoClass[0].default.bTrySplash;
        SavedFireProperties.bLeadTarget = Weapon.AmmoClass[0].default.bLeadTarget;
        SavedFireProperties.bInstantHit = Weapon.AmmoClass[0].default.bInstantHit;
        SavedFireProperties.bInitialized = true;
    }

    if (Weapon.bSniping)
        bMeleeFighter = false;

    Weapon.ClientState = WS_ReadyToFire;
    Weapon.GetFireMode(0).FireRate *= FireRateScale;
    Weapon.GetFireMode(1).FireRate *= FireRateScale;
    Weapon.GetFireMode(0).AmmoPerFire = 0;
    Weapon.GetFireMode(1).AmmoPerFire = 0;
}

function RangedAttack(Actor A)
{
    if (Weapon != None && Controller.Enemy != None && Weapon.CanAttack(Controller.Enemy) && Controller.Enemy.Health > 0)
    {
        Weapon.BotFire(false);
    }
    else
    {
        if (Weapon.IsFiring())
        {
            Weapon.StopFire(0);
            Weapon.StopFire(1);
        }
    }
}

function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
}

function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{
    return super(xPawn).IsHeadShot(loc, ray, AdditionalScale);
}

function TossWeapon(Vector TossVel)
{
    if (bNoThrowWeapon)
        return;
    Super.TossWeapon(TossVel);
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    Super(xPawn).PlayDying(DamageType, HitLoc);
}

simulated function ProcessHitFX()
{
    Super(xPawn).ProcessHitFX();
}

defaultproperties
{
     bNoThrowWeapon=True
     FireRateScale=3.000000
     HitSound(0)=Sound'tK_BaseM.Nali.injur1n'
     HitSound(1)=Sound'tK_BaseM.Nali.injur2n'
     HitSound(2)=Sound'tK_BaseM.Nali.injur1n'
     HitSound(3)=Sound'tK_BaseM.Nali.injur2n'
     DeathSound(0)=Sound'tK_BaseM.Nali.death1n'
     DeathSound(1)=Sound'tK_BaseM.Nali.death2n'
     ScoringValue=3
     SoundFootsteps(0)=Sound'tK_BaseM.Nali.walkC'
     SoundFootsteps(1)=Sound'tK_BaseM.Nali.walkC'
     SoundFootsteps(2)=Sound'tK_BaseM.Nali.walkC'
     SoundFootsteps(3)=Sound'tK_BaseM.Nali.walkC'
     SoundFootsteps(4)=Sound'tK_BaseM.Nali.walkC'
     SoundFootsteps(5)=Sound'tK_BaseM.Nali.walkC'
     IdleHeavyAnim="Idle_Biggun"
     IdleRifleAnim="Idle_Rifle"
     RagdollOverride="Male2"
     Health=70
     ControllerClass=Class'tK_BaseM.SMPNaliFighterController'
     TurnLeftAnim="TurnL"
     TurnRightAnim="TurnR"
     CrouchAnims(0)="CrouchF"
     CrouchAnims(1)="CrouchB"
     CrouchAnims(2)="CrouchL"
     CrouchAnims(3)="CrouchR"
     AirAnims(0)="JumpF_Mid"
     AirAnims(1)="JumpB_Mid"
     AirAnims(2)="JumpL_Mid"
     AirAnims(3)="JumpR_Mid"
     TakeoffAnims(0)="JumpF_Takeoff"
     TakeoffAnims(1)="JumpB_Takeoff"
     TakeoffAnims(2)="JumpL_Takeoff"
     TakeoffAnims(3)="JumpR_Takeoff"
     LandAnims(0)="JumpF_Land"
     LandAnims(1)="JumpB_Land"
     LandAnims(2)="JumpL_Land"
     LandAnims(3)="JumpR_Land"
     DoubleJumpAnims(0)="DoubleJumpF"
     DoubleJumpAnims(1)="DoubleJumpB"
     DoubleJumpAnims(2)="DoubleJumpL"
     DoubleJumpAnims(3)="DoubleJumpR"
     DodgeAnims(0)="DodgeF"
     DodgeAnims(1)="DodgeB"
     DodgeAnims(2)="DodgeL"
     DodgeAnims(3)="DodgeR"
     AirStillAnim="Jump_Mid"
     TakeoffStillAnim="Jump_Takeoff"
     CrouchTurnRightAnim="Crouch_TurnR"
     CrouchTurnLeftAnim="Crouch_TurnL"
     IdleWeaponAnim="Idle_Rifle"
     Mesh=SkeletalMesh'tK_BaseM.Nali1'
     Skins(0)=Texture'tK_BaseM.Skins.JNali1'
     Skins(1)=Texture'tK_BaseM.Skins.JNali1'
}
