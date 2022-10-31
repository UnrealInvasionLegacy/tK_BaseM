class SMPGiantGasbag extends Gasbag;

var int numChildren;
var() int MaxChildren;
var() byte PunchDamage, PoundDamage;

function PostBeginPlay()
{
	super.PostBeginPlay();
	MyAmmo.ProjectileClass = class'SMPGiantGasBagBelch';
}

function SpawnBelch()
{
	local SMPChildGasbag G;
	local vector X,Y,Z, FireStart;

	GetAxes(Rotation,X,Y,Z);
	FireStart = Location + 0.5 * CollisionRadius * X - 0.3 * CollisionHeight * Z;
	if ((numChildren >= MaxChildren) || (FRand() > 0.2) ||(DrawScale == 1))
	{
		if (Controller != None)
		{
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
			Spawn(MyAmmo.ProjectileClass,,,FireStart,Controller.AdjustAim(SavedFireProperties,FireStart,600));
			PlaySound(FireSound,SLOT_Interact);
		}
	}
	else
	{
		G = spawn(class'SMPChildGasbag',self,,FireStart + (0.6 * CollisionRadius + class'SMPGiantGasbag'.default.CollisionRadius) * X);
		if (G != None)
		{
			G.ParentBag = self;
			numChildren++;
		}
	}
}

function PunchDamageTarget()
{
	if (Controller == None || Controller.Target == None)
		return;

	if (MeleeDamageTarget(PunchDamage, (39000 * Normal(Controller.Target.Location - Location))))
		PlaySound(sound'Hit1g', SLOT_Interact);
}

function PoundDamageTarget()
{
	if (Controller == None || Controller.Target == None)
		return;

	if (MeleeDamageTarget(PoundDamage, (24000 * Normal(Controller.Target.Location - Location))))
		PlaySound(sound'Hit1g', SLOT_Interact);
}

defaultproperties
{
     MaxChildren=2
     PunchDamage=50
     PoundDamage=75
     bBoss=True
     ScoringValue=8
     Health=600
     DrawScale=3.000000
     CollisionRadius=160.000000
     CollisionHeight=90.000000
}