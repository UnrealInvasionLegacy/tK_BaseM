class tK_FireSkaarj extends tK_Skaarj;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    MyAmmo.ProjectileClass = class'FireSkaarjProjectile';
}

defaultproperties
{
     MonsterName="Fire Skaarj"
     ScoringValue=7
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.Skaarjw3'
}
