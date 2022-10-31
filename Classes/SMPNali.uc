class SMPNali extends SMPMonster;

const TargetRadius = 1200;
var bool bCringing;

simulated function Timer()
{
 	local Monster other;

	foreach VisibleCollidingActors(class'Monster', Other, TargetRadius, Location)
	{
		if (!Other.bAmbientCreature && Other.Controller != None)
			Other.Controller.Trigger(none, self);
	}
}

function Step()
{
	PlaySound(sound'WalkC', SLOT_Interact);
}

function RangedAttack(Actor A)
{
	if (bShotAnim || !bCringing)
		return;

	if (Controller.Enemy == None)
	{
		bCringing=false;
		return;
	}

	bShotAnim = true;
	if (0.4 > FRand())
	{
		SetAnimAction('Cringe');
		PlaySound(sound'cringe2n', SLOT_Pain,2*TransientSoundVolume,,400);
		Controller.bPreparingMove = true;
		Acceleration = vect(0,0,0);
	}
	else
	{
		SetAnimAction('Backup');
		Acceleration = vector(Rotation)*-100;
	}
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
	local Vector X,Y,Z, Dir;

	bCringing = true;

	GetAxes(Rotation, X,Y,Z);
	HitLoc.Z = Location.Z;
	if (VSize(Location - HitLoc) < 1.0)
		Dir = VRand();
	else
		Dir = -Normal(Location - HitLoc);

	if (Dir Dot X > 0.7 || Dir == vect(0,0,0))
		PlayAnim('HeadHit',, 0.1);
	else if (Dir Dot X < -0.7)
		PlayAnim('GutHit',, 0.1);
	else if (Dir Dot Y > 0)
		PlayAnim('RightHit',, 0.1);
	else
		PlayAnim('LeftHit',, 0.1);
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
	local Vector X,Y,Z, Dir;

	GetAxes(Rotation, X,Y,Z);
	HitLoc.Z = Location.Z;

	if (VSize(Velocity) < 10.0 && VSize(Location - HitLoc) < 1.0)
		Dir = VRand();
	else if (VSize(Velocity) > 0.0)
		Dir = Normal(Velocity*Vect(1,1,0));
	else
		Dir = -Normal(Location - HitLoc);

	if (Dir dot X > 0.7 || Dir == vect(0,0,0))
		PlayAnim('Dead',, 0.2);
	else if (Dir Dot X < -0.7)
		PlayAnim('Dead',, 0.2);
	else if (Dir dot Y > 0)
		PlayAnim('Dead2',, 0.2);
	else if (Dir dot Z > 0.8)
		PlayAnim('Dead3',, 0.2);
	else
		PlayAnim('Dead4',, 0.2);
}

defaultproperties
{
     bMeleeFighter=False
     bCanDodge=False
     HitSound(0)=Sound'tK_BaseM.Nali.injur1n'
     HitSound(1)=Sound'tK_BaseM.Nali.injur2n'
     HitSound(2)=Sound'tK_BaseM.Nali.injur1n'
     HitSound(3)=Sound'tK_BaseM.Nali.injur2n'
     DeathSound(0)=Sound'tK_BaseM.Nali.death1n'
     DeathSound(1)=Sound'tK_BaseM.Nali.death2n'
     IdleHeavyAnim="Sweat"
     IdleRifleAnim="spell"
     bCanStrafe=False
     bAmbientCreature=True
     Health=50
     MovementAnims(0)="Run"
     MovementAnims(1)="Backup"
     MovementAnims(2)="Backup"
     MovementAnims(3)="Backup"
     SwimAnims(0)="Swim"
     SwimAnims(1)="Swim"
     SwimAnims(2)="Swim"
     SwimAnims(3)="Swim"
     WalkAnims(0)="Walk"
     WalkAnims(1)="Backup"
     WalkAnims(2)="Backup"
     WalkAnims(3)="Backup"
     AirAnims(0)="Drowning"
     AirAnims(1)="Drowning"
     AirAnims(2)="Drowning"
     AirAnims(3)="Drowning"
     TakeoffAnims(0)="Drowning"
     TakeoffAnims(1)="Drowning"
     TakeoffAnims(2)="Drowning"
     TakeoffAnims(3)="Drowning"
     LandAnims(0)="Landed"
     LandAnims(1)="Landed"
     LandAnims(2)="Landed"
     LandAnims(3)="Landed"
     DodgeAnims(0)="Drowning"
     DodgeAnims(1)="Drowning"
     DodgeAnims(2)="Drowning"
     DodgeAnims(3)="Drowning"
     AirStillAnim="Drowning"
     TakeoffStillAnim="Drowning"
     IdleWeaponAnim="levitate"
     IdleRestAnim="Breath"
     Mesh=VertMesh'tK_BaseM.Nali2'
     Skins(0)=Texture'tK_BaseM.Skins.JNali1'
     Skins(1)=Texture'tK_BaseM.Skins.JNali1'
}