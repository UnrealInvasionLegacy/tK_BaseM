class tk_SkaarjSniper extends tk_SkaarjTrooper;

var int DamageMin, DamageMax, NumArcs;
var float HeadShotRadius, HeadShotDamageMult, SecDamageMult;
var class<DamageType> DamageType, DamageTypeHeadShot;
var class<xEmitter> HitEmitterClass;
var class<xEmitter> SecHitEmitterClass;

var float SecTraceDist, TraceRange;
var xEmitter chargeEmitter;

event PostBeginPlay()
{
    Super.PostBeginPlay();
}

function SpawnTwoShots()
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, RefNormal;
    local Actor Other, mainArcHitTarget;
    local int Damage, ReflectNum, arcsRemaining;
    local bool bDoReflect;
    local xEmitter hitEmitter;
    local class<xEmitter> tmpHitEmitClass;
    local float tmpTraceRange, dist;
    local vector Start, arcEnd, mainArcHit;
    local rotator Dir;

    LastAttackTime = Level.TimeSeconds;

    GetAxes(Rotation,X,Y,Z);
    Start = GetFireStart(X,Y,Z);

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
    Dir = Controller.AdjustAim(SavedFireProperties,Start,600);

    arcEnd = GetFireStart(X,Y,Z);
    arcsRemaining = NumArcs;
    PlayOwnedSound(Sound'WeaponSounds.LightningGunChargeUp', SLOT_Misc,,,,1.1,false);

    tmpHitEmitClass = HitEmitterClass;
    tmpTraceRange = TraceRange;

    ReflectNum = 0;
    while (true)
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + tmpTraceRange * X;
        Other = Trace(HitLocation, HitNormal, End, Start, true);

        if (Other != None && (Other != Instigator || ReflectNum > 0))
        {
            if (xPawn(Other) != None && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = true;
            }
            else if (Other != mainArcHitTarget)
            {
                if ( !Other.bWorldGeometry )
                {
                    Damage = (DamageMin + Rand(DamageMax - DamageMin));
                    if ((Pawn(Other) != None) && (arcsRemaining == NumArcs) && Other.GetClosestBone(HitLocation, X, dist, 'head', HeadShotRadius) == 'head')
                    {
                        Other.TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, X, DamageTypeHeadShot);
                    }
                    else
                    {
                        if (arcsRemaining < NumArcs)
                            Damage *= SecDamageMult;
                         Other.TakeDamage(Damage, Instigator, HitLocation, X, DamageType);
                    }
                }
                else
                {
                    HitLocation = HitLocation + 2.0 * HitNormal;
                }
            }
        }
        else
        {
            HitLocation = End;
            HitNormal = Normal(Start - End);
        }
        hitEmitter = Spawn(tmpHitEmitClass,,, HitLocation, Rotator(HitNormal));
        if (hitEmitter != None)
            hitEmitter.mSpawnVecA = arcEnd;

        if (arcsRemaining == NumArcs)
        {
            mainArcHit = HitLocation + (HitNormal * 2.0);
            if (Other != None && !Other.bWorldGeometry)
                mainArcHitTarget = Other;
        }

        if (bDoReflect && ++ReflectNum < 4)
        {
            Start = HitLocation;
            Dir = Rotator(X - 2.0*RefNormal*(X dot RefNormal));
        }
        else if (arcsRemaining > 0)
        {
            arcsRemaining--;

            Start = mainArcHit;
            Dir = Rotator(VRand());
            tmpHitEmitClass = SecHitEmitterClass;
            tmpTraceRange = SecTraceDist;
            arcEnd = mainArcHit;
        }
        else
        {
            break;
        }
    }
}

defaultproperties
{
     DamageMin=55
     DamageMax=65
     NumArcs=4
     HeadShotRadius=8.000000
     HeadShotDamageMult=2.000000
     SecDamageMult=0.500000
     DamageType=Class'XWeapons.DamTypeSniperShot'
     DamageTypeHeadShot=Class'XWeapons.DamTypeSniperHeadShot'
     HitEmitterClass=Class'XEffects.LightningBolt'
     SecHitEmitterClass=Class'XEffects.ChildLightningBolt'
     SecTraceDist=300.000000
     TraceRange=10000.000000
     smpRefireRate=1.900000
     bMeleeFighter=False
     AmmunitionClass=Class'tk_BaseM.tk_SkaarjSniperAmmo'
     Skins(0)=Texture'tk_BaseM.Skins.sktrooper3'
}