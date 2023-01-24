class tk_AnimalController extends MonsterController;

function FightEnemy(bool bCanCharge)
{
    Target = None;
}

function bool FindNewEnemy()
{
    Target = None;
    return false;
}

function ChangeEnemy(Pawn NewEnemy, bool bCanSeeNewEnemy)
{
    Target = None;
}

function bool SetEnemy(Pawn NewEnemy, optional bool bHateMonster)
{
    return false;
}

function bool CheckFutureSight(float deltatime)
{
    Target = None;
    return false;
}

defaultproperties
{
}