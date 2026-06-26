using UnrealBuildTool;

public class SandGameTarget : TargetRules
{
	public SandGameTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Game;
		DefaultBuildSettings = BuildSettingsVersion.V4;
		ExtraModuleNames.Add("SandGame");
	}
}
