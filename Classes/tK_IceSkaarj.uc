class tK_IceSkaarj extends tK_Skaarj;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    MyAmmo.ProjectileClass = class'IceSkaarjProjectile';
}

defaultproperties
{
     MonsterName="Ice Skaarj"
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.Skaarjw2'
}
