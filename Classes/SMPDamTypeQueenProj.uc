class SMPDamTypeQueenProj extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth)
{
	HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
     DeathString="%o was scorched by a Queen."
     FemaleSuicide="%o was scorched by a Queen."
     MaleSuicide="%o was scorched by a Queen."
     bDetonatesGoop=True
     KDamageImpulse=10000.000000
}