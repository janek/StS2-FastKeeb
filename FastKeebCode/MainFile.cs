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
        // Keep initialization minimal: no overlays, no banners, no game hooks.
        Logger.Info("=== FastKeeb loaded ===");

        // Retain Harmony initialization in case future patches are added.
        // If there are no patch classes, this is effectively a no-op.
        Harmony harmony = new(ModId);
        harmony.PatchAll();

        Logger.Info("=== FastKeeb initialized, Harmony patches applied ===");
    }
}
