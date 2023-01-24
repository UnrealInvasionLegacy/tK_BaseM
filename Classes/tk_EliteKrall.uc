class tk_EliteKrall extends tk_Krall;

event PostBeginPlay()
{
    Super.PostBeginPlay();

    MyAmmo.ProjectileClass = class'EliteKrallBolt';
}

defaultproperties
{
     MonsterName="Elite Krall"
     ScoringValue=3
     Skins(0)=FinalBlend'SkaarjPackSkins.Skins.ekrall'
     Skins(1)=FinalBlend'SkaarjPackSkins.Skins.ekrall'
}