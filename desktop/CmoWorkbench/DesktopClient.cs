using System.Collections.Concurrent;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.Json;

namespace CmoWorkbench;

public sealed class DesktopClient : IDisposable
{
    private readonly Process process;
    private readonly ConcurrentDictionary<string, TaskCompletionSource<JsonElement>> pending = new();
    private readonly SemaphoreSlim writer = new(1, 1);
    private readonly Task reader;
    private bool disposed;
    public DesktopClient(string? dataDirectory = null)
    {
        var start = new ProcessStartInfo
        {
            FileName = Environment.GetEnvironmentVariable("CMO_DESKTOP_NODE") ?? "node.exe",
            UseShellExecute = false, CreateNoWindow = true,
            RedirectStandardInput = true, RedirectStandardOutput = true, RedirectStandardError = true,
            StandardInputEncoding = new UTF8Encoding(false), StandardOutputEncoding = Encoding.UTF8,
            WorkingDirectory = AppContext.BaseDirectory
        };
        start.ArgumentList.Add(Path.Combine(AppContext.BaseDirectory, "runtime", "desktop", "worker.mjs"));
        start.ArgumentList.Add("--data-dir");
        start.ArgumentList.Add(dataDirectory ?? Environment.GetEnvironmentVariable("CMO_DESKTOP_DATA") ?? Path.Combine(AppContext.BaseDirectory, "workspace"));
        process = Process.Start(start) ?? throw new InvalidOperationException("Node.js를 시작할 수 없습니다.");
        process.ErrorDataReceived += (_, _) => { }; // Never surface raw provider diagnostics.
        process.BeginErrorReadLine();
        reader = ReadResponses();
    }
    private async Task ReadResponses()
    {
        try
        {
            while (await process.StandardOutput.ReadLineAsync() is { } line)
            {
                using var document = JsonDocument.Parse(line);
                var root = document.RootElement;
                if (!root.TryGetProperty("id", out var id) || id.ValueKind != JsonValueKind.String) continue;
                if (!pending.TryRemove(id.GetString()!, out var completion)) continue;
                if (root.GetProperty("ok").GetBoolean()) completion.TrySetResult(root.GetProperty("result").Clone());
                else completion.TrySetException(new InvalidOperationException(root.GetProperty("error").GetString()));
            }
        }
        catch (Exception) { }
        finally
        {
            foreach (var item in pending) if (pending.TryRemove(item.Key, out var completion))
                completion.TrySetException(new IOException("로컬 작업 프로세스가 종료되었습니다. 앱을 다시 시작하세요."));
        }
    }
    public async Task<JsonElement> Call(string method, object? input = null, string? sessionId = null, string? prompt = null, string? content = null, string? executable = null)
    {
        ObjectDisposedException.ThrowIf(disposed, this);
        if (process.HasExited) throw new IOException("로컬 작업 프로세스가 종료되었습니다.");
        var id = Guid.NewGuid().ToString();
        var completion = new TaskCompletionSource<JsonElement>(TaskCreationOptions.RunContinuationsAsynchronously);
        pending[id] = completion;
        try
        {
            await writer.WaitAsync();
            try
            {
                await process.StandardInput.WriteLineAsync(JsonSerializer.Serialize(new { id, method, input, sessionId, prompt, content, executable }));
                await process.StandardInput.FlushAsync();
            }
            finally { writer.Release(); }
            return await completion.Task.WaitAsync(TimeSpan.FromMinutes(5));
        }
        finally { pending.TryRemove(id, out _); }
    }
    public void Dispose()
    {
        if (disposed) return;
        disposed = true;
        try { if (!process.HasExited) process.Kill(entireProcessTree: true); } catch (InvalidOperationException) { }
        process.Dispose();
    }
}
