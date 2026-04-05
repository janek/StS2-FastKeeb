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
        LogAsciiBanner("FastKeeb loaded");

        Harmony harmony = new(ModId);
        harmony.PatchAll();

        LogAsciiBanner("FastKeeb initialized, Harmony patches applied");

        // Add our on-screen banner overlay
        try
        {
            Logger.Info("[FastKeeb] Attempting to attach BannerOverlay...");
            var tree = Engine.GetMainLoop() as SceneTree;
            if (tree != null && tree.Root != null)
            {
                var overlay = new BannerOverlay();
                // Defer to ensure the scene tree is fully ready on initialization
                tree.Root.CallDeferred("add_child", overlay);
                overlay.CallDeferred(nameof(BannerOverlay.EnableSceneWatch), true);
                overlay.CallDeferred(nameof(BannerOverlay.ShowBanner), "FASTKEEB READY!", 2.5);
                Logger.Info("[FastKeeb] BannerOverlay attach scheduled (deferred).");
            }
            else
            {
                Logger.Info("[FastKeeb] SceneTree not available; skipping BannerOverlay attach.");
            }
        }
        catch (System.Exception ex)
        {
            Logger.Info($"[FastKeeb] Failed to attach BannerOverlay: {ex.Message}");
        }
    }

    private static void LogAsciiBanner(string message)
    {
        // 10-line high ASCII banner with a centered message.
        const int width = 96; // including border
        string border = new string('#', width);
        string empty = "#" + new string(' ', width - 2) + "#";

        static string Center(string text, int totalWidth)
        {
            if (text.Length >= totalWidth) return text.Substring(0, totalWidth);
            int pad = (totalWidth - text.Length) / 2;
            return new string(' ', pad) + text + new string(' ', totalWidth - pad - text.Length);
        }

        string msg = ($"*** {message.ToUpperInvariant()} ***");
        string line2 = "#" + Center("/\\".PadRight(width - 2 - 2, ' ') + "\\/", width - 2) + "#";
        string line3 = "#" + Center("/\\  /\\".PadRight(width - 2 - 4, ' ') + "\\/  \\/", width - 2) + "#";
        string line4 = "#" + Center(msg, width - 2) + "#";
        string line5 = "#" + Center(new string('=', Math.Min(width - 4, msg.Length + 10)), width - 2) + "#";
        string line6 = "#" + Center(msg, width - 2) + "#";
        string line7 = "#" + Center("\\/  \\/".PadRight(width - 2 - 4, ' ') + "/\\  /\\", width - 2) + "#";
        string line8 = "#" + Center("\\/".PadRight(width - 2 - 2, ' ') + "/\\", width - 2) + "#";

        Logger.Info(border);
        Logger.Info(empty);
        Logger.Info(line2);
        Logger.Info(line3);
        Logger.Info(line4);
        Logger.Info(line5);
        Logger.Info(line6);
        Logger.Info(line7);
        Logger.Info(line8);
        Logger.Info(empty);
        Logger.Info(border);
    }
}
