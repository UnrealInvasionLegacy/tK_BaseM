class SMPSkaarjTrooper extends Skaarj;

var() bool bUseShield;
var() class<Projectile> ProjectileClass;
var() bool bTwoShot;
var bool Shielding;

var float duckTime, LastAttackTime;
var() float smpRefireRate;

replication
{
    reliable if (Role == ROLE_Authority)
        Shielding;
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, vector momentum, class<DamageType> damageType)
{
    local vector HitNormal;

    if (CheckReflect(HitLocation, HitNormal, Damage))
        Damage *= 0.2;

    Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

function PlayVictory()
{
    if (Controller == None)
        return;
    Controller.bPreparingMove = true;
    Acceleration = vect(0,0,0);
    bShotAnim = true;
    SetAnimAction('Shield');
    Controller.Destination = Location;
    Controller.GotoState('TacticalMove','WaitForAnim');
}

function SpawnTwoShots()
{
    local vector X,Y,Z, FireStart;
    local rotator FireRotation;

    GetAxes(Rotation,X,Y,Z);
    FireStart = GetFireStart(X,Y,Z);

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
    Spawn(MyAmmo.ProjectileClass,self,,FireStart,FireRotation);

    if (bTwoShot)
    {
        FireStart = FireStart - 1.8 * CollisionRadius * Y;
        FireRotation.Yaw += 400;
        Spawn(MyAmmo.ProjectileClass,,,FireStart, FireRotation);
    }
    LastAttackTime = Level.TimeSeconds;
}

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int Damage )
{
    local Vector HitDir;
    local Vector FaceDir;
    local rotator FaceRot;
    local name AnimName;

    AnimName = GetAnimSequence();
    if (AnimName != 'ShldFire' && AnimName != 'HoldShield' && AnimName != 'Shldland' && AnimName != 'ShldTest'
       && AnimName != 'ShldUp' && AnimName != 'ShldDown' && AnimName != 'Shield')
        return false;

    FaceRot = Rotation;
    if (AnimName == 'ShldFire')
        FaceRot.Yaw += 10000;

    FaceDir = vector(FaceRot);
    HitDir = Normal(Location - HitLocation + Vect(0,0,8));
    RefNormal = FaceDir;
    if (FaceDir dot HitDir < -0.30)
        return true;

    return false;
}

function vector GetFireStart(vector X, vector Y, vector Z)
{
    return Location + 0.9 * CollisionRadius * X - 0.9 * CollisionRadius * Y + 0.2 * CollisionHeight * Z;
}

function RangedAttack(Actor A)
{
    local name Anim;
    local float frame,rate;

    if (bShotAnim)
        return;

    bShotAnim = true;

    if (VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius)
    {
        if (FRand() < 0.7)
        {
            SetAnimAction('Spin');
            PlaySound(sound'Spin1s', SLOT_Interact);
            Acceleration = AccelRate * Normal(A.Location - Location);
            return;
        }
        SetAnimAction('Claw');
        PlaySound(sound'Claw2s', SLOT_Interact);
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
    }
    else if (Level.TimeSeconds - LastAttackTime < smpRefireRate)
    {
        bShotAnim = false;
        return;
    }
    else if (bUseShield && FRand() < 0.2 && Physics != PHYS_Falling)
    {
        Gotostate('ShldUp');
    }
    else if (Velocity == vect(0,0,0))
    {
        SetAnimAction('Firing');
        Controller.bPreparingMove = true;
        Acceleration = vect(0,0,0);
        SpawnTwoShots();
    }
    else
    {
        GetAnimParams(0,Anim,frame,rate);
        if (Anim == 'StrafeLeft')
            SetAnimAction('StrafeLeftFr');
        else if (Anim == 'StrafeRight')
            SetAnimAction('StrafeRightFr');
        else
            SetAnimAction('JogFire');
    }
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;

    if (VSize(Location - HitLoc) < 1.0)
        Dir = VRand();
    else
        Dir = -Normal(Location - HitLoc);

    if (Dir dot X > 0.7 || Dir == vect(0,0,0))
    {
        if ((HitLoc.Z > Location.Z + 0.75 * CollisionHeight) && (FRand() > 0.5))
            PlayAnim('HeadHit',, 0.1);
        else
            PlayAnim('GutHit',, 0.1);
    }
    else if (Dir dot X < -0.7)
    {
        PlayAnim('GutHit',, 0.1);
    }
    else if (Dir Dot Y > 0)
    {
        PlayAnim('RightHit',, 0.1);
    }
    else
    {
        PlayAnim('LeftHit',, 0.1);
    }
}

simulated function AnimEnd(int Channel)
{
    Super.AnimEnd(Channel);

    if (!bShotAnim && Shielding)
        SetAnimAction('HoldShield');
}

state ShldUp
{
    function RangedAttack(Actor A)
    {
        if (bShotAnim)
            return;

        if (Level.TimeSeconds - LastAttackTime < smpRefireRate)
        {
            bShotAnim = false;
            return;
        }
        TweenAnim('ShldFire', 0.20);
        Acceleration = vect(0,0,0);
        Controller.bPreparingMove = true;
        SpawnTwoShots();

        bShotAnim = true;
    }

    simulated function PlayDirectionalHit(Vector HitLoc)
    {}

    simulated function BeginState()
    {
        Acceleration = vect(0,0,0);
        Controller.bPreparingMove = true;
        SetAnimAction('ShldUp');
        bShotAnim = true;
        GroundSpeed = 0;
        smpRefireRate = 1.7;
        Shielding = true;
    }

    simulated function EndState()
    {
        SetAnimAction('ShldDown');
        bShotAnim = true;
        GroundSpeed = default.GroundSpeed;
        smpRefireRate = default.smpRefireRate;
        Shielding = false;
    }
Begin:
    if (Controller != None && Controller.Target != None && ProjectileClass != None)
        duckTime = (VSize(Controller.Target.Location - Location) / ProjectileClass.default.Speed);
    Sleep(duckTime + FRand()*5);
    Gotostate('');
}

defaultproperties
{
     bUseShield=True
     ProjectileClass=Class'SkaarjPack.SkaarjProjectile'
     smpRefireRate=0.400000
     Health=200
     MovementAnims(0)="Jog"
     MovementAnims(1)="StrafeRight"
     MovementAnims(2)="StrafeRight"
     MovementAnims(3)="StrafeLeft"
     TurnLeftAnim="Breath"
     TurnRightAnim="Breath"
     WalkAnims(0)="Walk"
     WalkAnims(1)="Walk"
     WalkAnims(2)="Walk"
     WalkAnims(3)="Walk"
     DodgeAnims(0)="Lunge"
     DodgeAnims(1)="Jump"
     DodgeAnims(2)="RightDodge"
     DodgeAnims(3)="LeftDodge"
     bReplicateAnimations=True
     Mesh=VertMesh'tK_BaseM.sktrooper'
     Skins(0)=Texture'tK_BaseM.Skins.sktrooper1'
     Skins(1)=FinalBlend'XEffectMat.Shield.BlueShell'
     CollisionHeight=42.000000
}
