class tK_QueenTeleportEffect extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         UniformMeshScale=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.200000,Color=(G=70,R=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(G=20,R=255))
         FadeOutStartTime=0.800000
         MaxParticles=50
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=16.000000,Max=16.000000)
         MeshSpawningStaticMesh=StaticMesh'ParticleMeshes.Simple.ParticleSphere3'
         MeshSpawning=PTMS_Random
         MeshScaleRange=(X=(Min=0.750000,Max=0.750000),Y=(Min=0.750000,Max=0.750000),Z=(Min=0.750000,Max=0.750000))
         RevolutionsPerSecondRange=(Z=(Min=0.200000,Max=0.200000))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         InitialParticlesPerSecond=300.000000
         Texture=Texture'EpicParticles.Flares.Sharpstreaks2'
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRadialRange=(Min=100.000000,Max=100.000000)
         VelocityLossRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=0.100000,Max=0.100000),Z=(Min=0.600000,Max=0.600000))
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(0)=SpriteEmitter'tK_BaseM.tK_QueenTeleportEffect.SpriteEmitter1'

     AutoDestroy=True
     LightType=LT_Pulse
     LightBrightness=255.000000
     LightRadius=22.000000
     LightPeriod=20
     bNoDelete=False
     bDynamicLight=True
     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     DrawScale=3.000000
}
