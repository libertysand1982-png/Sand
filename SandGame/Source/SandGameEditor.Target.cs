using UnrealBuildTool;
using System.Collections.Generic;

public class SandGameEditorTarget : TargetRules
{
	public SandGameEditorTarget(TargetInfo Target) : base(Target)
	{
		Type = TargetType.Editor;
		DefaultBuildSettings = BuildSettingsVersion.V5;
		IncludeOrderVersion = EngineIncludeOrderVersion.Unreal5Latest;
		ExtraModuleNames.Add("SandGame");
	}
}
