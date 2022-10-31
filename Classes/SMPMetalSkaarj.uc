class SMPMetalSkaarj extends IceSkaarj;

function bool CheckReflect(Vector HitLocation, out Vector RefNormal, int Damage)
{
    RefNormal = normal(HitLocation - Location);
    if (FRand() > 0.2)
        return true;
    else
        return false;
}

defaultproperties
{
     ScoringValue=7
     GibGroupClass=Class'XEffects.xBotGibGroup'
     DodgeAnims(2)="DodgeR"
     DodgeAnims(3)="DodgeL"
     Skins(0)=FinalBlend'tK_BaseM.SMPMetalSkaarj.MetalSkinFinal'
     Skins(1)=None
     Mass=500.000000
}
