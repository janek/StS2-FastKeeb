using System;
using Godot;

namespace FastKeeb.FastKeebCode;

public partial class BannerOverlay : CanvasLayer
{
    private Label label = null!;
    private Timer timer = null!;
    private Node? lastScene;
    private bool watchScenes;

    public override void _Ready()
    {
        PauseMode = Node.PauseModeEnum.Process;
        ProcessMode = Node.ProcessModeEnum.Always;

        var center = new Control
        {
            AnchorLeft = 0,
            AnchorTop = 0,
            AnchorRight = 1,
            AnchorBottom = 1,
            GrowHorizontal = Control.GrowDirection.Both,
            GrowVertical = Control.GrowDirection.Both
        };
        AddChild(center);

        label = new Label
        {
            HorizontalAlignment = HorizontalAlignment.Center,
            VerticalAlignment = VerticalAlignment.Center,
            AutowrapMode = TextServer.AutowrapMode.WordSmart,
            Visible = false,
            Text = string.Empty
        };
        label.AddThemeFontSizeOverride("font_size", 48);
        label.AddThemeColorOverride("font_color", Colors.White);
        label.AddThemeColorOverride("font_outline_color", Colors.Black);
        label.AddThemeConstantOverride("outline_size", 3);
        center.AddChild(label);

        // Slight drop shadow/outline effect via duplicate label (optional subtlety)
        // Not adding extra nodes to keep it minimal.

        timer = new Timer
        {
            OneShot = true,
            Autostart = false
        };
        AddChild(timer);
        timer.Timeout += HideBanner;
    }

    public override void _Process(double delta)
    {
        if (!watchScenes) return;
        var tree = GetTree();
        if (tree == null) return;
        var current = tree.CurrentScene;
        if (current == lastScene || current == null) return;
        lastScene = current;
        OnSceneChanged(current);
    }

    public void EnableSceneWatch(bool enabled)
    {
        watchScenes = enabled;
        if (enabled)
            lastScene = GetTree()?.CurrentScene;
    }

    public void ShowBanner(string text, double seconds = 2.5)
    {
        // Big, obvious banner text
        label.Text = $"\n\n*** {text} ***\n\n";
        label.Visible = true;
        timer.Stop();
        timer.WaitTime = Math.Max(0.1, seconds);
        timer.Start();
    }

    private void HideBanner()
    {
        label.Visible = false;
    }

    private void OnSceneChanged(Node newScene)
    {
        // Heuristic: show on menu and combat scenes by name (non-invasive, no gameplay hooks)
        string name = newScene.Name.ToString();
        MainFile.Logger.Info($"[FastKeeb] Scene changed to: {name}");

        var lowered = name.ToLowerInvariant();
        if (lowered.Contains("menu"))
        {
            ShowBanner("FASTKEEB READY!", 2.5);
            return;
        }
        if (lowered.Contains("combat") || lowered.Contains("battle") || lowered.Contains("fight"))
        {
            ShowBanner("COMBAT START!", 2.5);
            return;
        }
    }
}

