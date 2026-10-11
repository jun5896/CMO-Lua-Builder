using System.IO;
using System.Windows;

namespace CmoWorkbench;
public partial class App : Application
{
    private Mutex? instance;
    protected override async void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        var smoke = e.Args.Contains("--smoke-test");
        if (!smoke)
        {
            instance = new Mutex(true, "Local\\CMO-Workbench-" + Environment.UserName, out var created);
            if (!created) { MessageBox.Show("CMO Workbench가 이미 실행 중입니다."); instance.Dispose(); instance = null; Shutdown(); return; }
        }
        var window = new MainWindow();
        MainWindow = window;
        if (!smoke) { window.Show(); return; }
        ShutdownMode = ShutdownMode.OnExplicitShutdown;
        try
        {
            var index = Array.IndexOf(e.Args, "--smoke-test");
            var directory = index + 1 < e.Args.Length ? e.Args[index + 1] : Path.Combine(Path.GetTempPath(), "cmo-desktop-smoke");
            await window.RunSmokeTest(directory);
            Shutdown(0);
        }
        catch (Exception error)
        {
            var output = Path.Combine(Path.GetTempPath(), "cmo-desktop-smoke-error.txt");
            File.WriteAllText(output, error.ToString());
            Shutdown(1);
        }
    }
    protected override void OnExit(ExitEventArgs e)
    {
        instance?.ReleaseMutex(); instance?.Dispose();
        base.OnExit(e);
    }
}
