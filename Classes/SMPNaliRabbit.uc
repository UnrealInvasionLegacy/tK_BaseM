class SMPNaliRabbit extends SMPNaliCow;

simulated function Tick(float DeltaTime)
{
	local Monster Other;

	Super.Tick(DeltaTime);

	if (Physics !=PHYS_Falling)
		Velocity.Z = 0;

	if (VSize(Velocity) > 70  && Physics != PHYS_Falling)
	{
		DoJump(true);
		foreach VisibleCollidingActors(class'Monster', Other, TargetRadius, Location)
		{
			if (!Other.bAmbientCreature && Other.Controller != None)
				Other.Controller.Trigger(none,self);
		}
	}
}

simulated function AnimEnd(int Channel)
{
	local name Anim;
	local float frame, rate;

	if (Channel == 0)
	{
		GetAnimParams(0, Anim,frame,rate);
		if (Anim == 'Call')
			IdleWeaponAnim = 'Looking';
		else if ((Anim == 'Looking') && (FRand() < 0.5))
			IdleWeaponAnim = 'Eat';
		else
			IdleWeaponAnim = 'Call';
	}
	Super(SMPMonster).AnimEnd(Channel);
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	AmbientSound = None;
	bCanTeleport = false;
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;

	HitDamageType = DamageType;
	TakeHitLocation = HitLoc;
	LifeSpan = RagdollLifeSpan;

	GotoState('Dying');

	Velocity += TearOffMomentum;
	BaseEyeHeight = Default.BaseEyeHeight;
	SetPhysics(PHYS_Falling);

	CreateGib('head',DamageType,Rotation);
}

defaultproperties
{
     HitSound(0)=None
     HitSound(1)=None
     HitSound(2)=None
     HitSound(3)=None
     DeathSound(0)=None
     DeathSound(1)=None
     DeathSound(2)=None
     DeathSound(3)=None
     IdleHeavyAnim="Call"
     IdleRifleAnim="Eat"
     bCanJump=True
     GroundSpeed=400.000000
     AccelRate=1500.000000
     JumpZ=200.000000
     AirControl=0.100000
     Health=5
     MovementAnims(0)="Jump"
     MovementAnims(1)="Jump"
     MovementAnims(2)="Jump"
     MovementAnims(3)="Jump"
     TurnLeftAnim="Looking"
     TurnRightAnim="Looking"
     WalkAnims(0)="Jump"
     WalkAnims(1)="Jump"
     WalkAnims(2)="Jump"
     WalkAnims(3)="Jump"
     AirAnims(0)="Jump"
     AirAnims(1)="Jump"
     AirAnims(2)="Jump"
     AirAnims(3)="Jump"
     TakeoffAnims(0)="Jump"
     TakeoffAnims(1)="Jump"
     TakeoffAnims(2)="Jump"
     TakeoffAnims(3)="Jump"
     LandAnims(0)="Land"
     LandAnims(1)="Land"
     LandAnims(2)="Land"
     LandAnims(3)="Land"
     DoubleJumpAnims(0)="Jump"
     DoubleJumpAnims(1)="Jump"
     DoubleJumpAnims(2)="Jump"
     DoubleJumpAnims(3)="Jump"
     DodgeAnims(0)="Jump"
     DodgeAnims(1)="Jump"
     DodgeAnims(2)="Jump"
     DodgeAnims(3)="Jump"
     AirStillAnim="Jump"
     TakeoffStillAnim="Jump"
     IdleWeaponAnim="Eat"
     IdleRestAnim="Looking"
     TauntAnims(0)="Call"
     TauntAnims(1)="Eat"
     TauntAnims(2)="Call"
     TauntAnims(3)="Eat"
     TauntAnims(4)="Call"
     TauntAnims(5)="Eat"
     TauntAnims(6)="Call"
     TauntAnims(7)="Eat"
     Mesh=VertMesh'tK_BaseM.Rabbit'
     Skins(0)=Texture'tK_BaseM.Skins.JRabbit1'
     Skins(1)=Texture'tK_BaseM.Skins.JRabbit1'
     CollisionRadius=18.299999
     CollisionHeight=13.300000
}