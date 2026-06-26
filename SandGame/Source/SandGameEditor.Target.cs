using UnrealBuildTool;

public class SandGameEditorTarget : TargetRules
{
	public SandGameEditorTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Editor;
		DefaultBuildSettings = BuildSettingsVersion.V4;
		ExtraModuleNames.Add("SandGame");
	}
}
