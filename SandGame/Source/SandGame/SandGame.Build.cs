using UnrealBuildTool;

public class SandGame : ModuleRules
{
	public SandGame(ReadOnlyTargetRules Target) : base(Target)
	{
		PCHUsage = PCHUsageMode.UseExplicitOrSharedPCHs;

		PublicDependencyModuleNames.AddRange(new string[]
		{
			"Core",
			"CoreUObject",
			"Engine",
			"InputCore",
			"EnhancedInput",
			"AIModule",
			"NavigationSystem",
			"GameplayTasks",
			"UMG",
			"Slate",
			"SlateCore",
		});

		PrivateDependencyModuleNames.AddRange(new string[]
		{
			"Niagara",
		});
	}
}
