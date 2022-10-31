class SMPQueenShield extends ShieldEffect3rdBLUE;

var int Health;

function Touch( actor Other )
{
    if(xPawn(Other) == None && Monster(Other) != None)
        Destroy();
}

simulated function Flash(int Drain)
{
    Super.Flash(Drain);

    Health -= Drain;
    if (Health < 0)
        Destroy();
}

defaultproperties
{
     Health=350
     AimedOffset=(X=40.000000,Y=40.000000)
     bHidden=False
     DrawScale=16.000000
     bCollideActors=True
}
