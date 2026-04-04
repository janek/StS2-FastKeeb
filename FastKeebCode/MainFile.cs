using Godot;
using HarmonyLib;
using MegaCrit.Sts2.Core.Modding;

namespace FastKeeb.FastKeebCode;

[ModInitializer(nameof(Initialize))]
public partial class MainFile : Node
{
    public const string ModId = "FastKeeb";

    public static MegaCrit.Sts2.Core.Logging.Logger Logger { get; } = new(ModId, MegaCrit.Sts2.Core.Logging.LogType.Generic);

    public static void Initialize()
    {
        Logger.LogMessage("=== FastKeeb loaded ===");

        Harmony harmony = new(ModId);
        harmony.PatchAll();

        Logger.LogMessage("=== FastKeeb initialized, Harmony patches applied ===");
    }
}
