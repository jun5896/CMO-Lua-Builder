using System.IO;
using System.Text;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using Microsoft.Win32;

namespace CmoWorkbench;
public record SessionRow(string Id, string Name, string Caption);
public record ModelRow(string Id);

public partial class MainWindow : Window
{
    private DesktopClient? client;
    private readonly Dictionary<string, JsonElement> sessions = new();
    private readonly HashSet<string> busy = new();
    private List<ModelRow> models = new();
    private string? selectedId;
    private bool binding;
    private bool initialized;
    private bool preparingRequest;
    private readonly Dictionary<string, string> pendingPrompts = new();
    public MainWindow()
    {
        InitializeComponent();
        Loaded += async (_, _) => { if (!initialized) await Guard(() => Initialize()); };
        Closing += async (_, e) =>
        {
            if (client is null || !initialized) return;
            e.Cancel = true;
            try { if (selectedId is not null && !busy.Contains(selectedId)) await SaveCurrent(); }
            catch (Exception error)
            {
                if (MessageBox.Show(this, $"저장하지 못했습니다: {error.Message}\n저장하지 않고 종료할까요?", "CMO Workbench", MessageBoxButton.YesNo) != MessageBoxResult.Yes) return;
            }
            client.Dispose(); client = null; initialized = false; Close();
        };
    }
    private DesktopClient Client => client ?? throw new InvalidOperationException("로컬 작업 프로세스가 준비되지 않았습니다. Node.js 설치를 확인하세요.");
    private JsonElement Current => sessions[selectedId ?? throw new InvalidOperationException("작업 공간을 선택하세요.")];
    private static string Text(JsonElement value, string key) => value.TryGetProperty(key, out var field) && field.ValueKind == JsonValueKind.String ? field.GetString() ?? "" : "";
    private static string ModeName(string mode) => mode switch { "authoring" => "시나리오 제작", "lua" => "Lua 작성 보조", _ => "플레이 조언" };
    private void Status(string message) => StatusText.Text = message;
    private async Task Guard(Func<Task> action)
    {
        try { await action(); } catch (Exception error) { Status(error.Message); }
    }
    private async Task Initialize(string? dataDirectory = null, bool seed = true)
    {
        client = new DesktopClient(dataDirectory);
        var state = await Client.Call("state");
        OmpPath.Text = Text(state.GetProperty("settings"), "ompExecutable");
        if (seed && state.GetProperty("sessions").GetArrayLength() == 0)
        {
            await Client.Call("create", new { name = "시나리오 설계", mode = "authoring", scenarioId = "scenario-1", sideId = "" });
            await Client.Call("create", new { name = "Lua 작업실", mode = "lua", scenarioId = "scenario-1", sideId = "" });
            await Client.Call("create", new { name = "Blue · 플레이 조언", mode = "advice", scenarioId = "scenario-1", sideId = "blue" });
            await Client.Call("create", new { name = "Red · 플레이 조언", mode = "advice", scenarioId = "scenario-1", sideId = "red" });
        }
        await Refresh();
        initialized = true;
        Status("작업 공간 준비 완료 · 모델 불러오기로 OMP에 연결하세요. 자료와 대화는 이 PC에 저장됩니다.");
    }
    private async Task Refresh(string? prefer = null)
    {
        var state = await Client.Call("state");
        sessions.Clear();
        foreach (var session in state.GetProperty("sessions").EnumerateArray()) sessions.Add(Text(session, "id"), session.Clone());
        binding = true;
        SessionList.ItemsSource = sessions.Values.Select(s => new SessionRow(Text(s, "id"), Text(s, "name"), ModeName(Text(s, "mode")) + (Text(s, "sideId") is { Length: > 0 } side ? $" · {side}" : ""))).ToList();
        selectedId = prefer ?? selectedId ?? sessions.Keys.FirstOrDefault();
        SessionList.SelectedItem = SessionList.Items.Cast<SessionRow>().FirstOrDefault(s => s.Id == selectedId);
        binding = false;
        if (selectedId is not null) BindSession();
    }
    private void BindSession()
    {
        var s = Current;
        var advice = Text(s, "mode") == "advice";
        SessionTitle.Text = Text(s, "name");
        SessionBinding.Text = $"{ModeName(Text(s, "mode"))}  /  {Text(s, "scenarioId")}  /  {(advice ? Text(s, "sideId") : "제작자 자료")}";
        ModeHint.Text = advice ? "이 세력이 알고 있는 관측 자료를 바탕으로 선택지와 불확실성을 검토합니다." : "초안을 만들고 검토하세요. 게임 파일에 자동 적용하지 않습니다.";
        ContextHint.Text = advice ? "이 세력 전용 cmo-side-observation/v1 JSON을 넣으세요. 실제 관측만 기입하고, 상대의 비공개 정보는 제외하세요. 전체 시나리오 자료는 받지 않습니다." : "기획 의도, 확인된 DBID·GUID, 게임 빌드, 이벤트 요구사항을 적으세요. 불러온 자료는 AI 요청에 포함됩니다.";
        ContextEditor.Text = Text(s, "context");
        LuaEditor.Text = Text(s, "draft");
        RequestLimit.Text = s.GetProperty("requestLimit").ToString();
        MaxTokens.Text = s.GetProperty("maxTokens").ToString();
        BindModels();
        LuaTab.Visibility = advice ? Visibility.Collapsed : Visibility.Visible;
        if (advice && WorkTabs.SelectedItem == LuaTab) WorkTabs.SelectedIndex = 0;
        var transcript = new StringBuilder();
        foreach (var turn in s.GetProperty("turns").EnumerateArray())
        {
            transcript.AppendLine(Text(turn, "role") == "user" ? "나" : $"AI · {Text(turn, "actualModel")}");
            transcript.AppendLine(Text(turn, "content"));
            transcript.AppendLine(); transcript.AppendLine("────────────────────────────"); transcript.AppendLine();
        }
        Conversation.Text = transcript.Length > 0 ? transcript.ToString() : advice
            ? "세력별로 자료와 대화 기록이 분리됩니다.\n\n1. 자료 · 관측 탭에서 해당 세력의 관측을 입력하세요.\n2. OMP 모델을 선택하세요.\n3. 검토할 상황이나 궁금한 점을 질문하세요."
            : "기획이나 Lua 초안을 자료 탭에 넣고 작업 목표를 입력하세요.\n\n생성된 Lua는 초안 탭에서 검토·검사·저장할 수 있습니다.";
        UpdateUsage(s);
        LuaStatus.Text = "텍스트 검사는 Lua 구문 검증이나 실행 샌드박스를 대신하지 않습니다.";
        UpdateBusy();
    }
    private void BindModels()
    {
        var chosen = Text(Current, "model");
        ModelPicker.ItemsSource = chosen.Length > 0 && !models.Any(m => m.Id == chosen) ? models.Append(new ModelRow(chosen)).ToList() : models;
        ModelPicker.SelectedValue = chosen;
    }
    private void UpdateUsage(JsonElement s)
    {
        long input = 0, output = 0; var reported = false;
        foreach (var turn in s.GetProperty("turns").EnumerateArray())
            if (turn.TryGetProperty("usage", out var usage))
            {
                if (usage.TryGetProperty("prompt_tokens", out var a) && a.TryGetInt64(out var n)) { input += n; reported = true; }
                if (usage.TryGetProperty("completion_tokens", out var b) && b.TryGetInt64(out var m)) { output += m; reported = true; }
            }
        UsageText.Text = $"요청 {s.GetProperty("requests")} / {s.GetProperty("requestLimit")}" + (reported ? $" · 보고된 토큰 {input:N0} 입력 / {output:N0} 출력" : " · 보고된 토큰 없음");
    }
    private void UpdateBusy()
    {
        var running = selectedId is not null && busy.Contains(selectedId);
        SendButton.IsEnabled = selectedId is not null && !running && busy.Count < 2;
        CancelButton.IsEnabled = running;
        ContextEditor.IsReadOnly = running; LuaEditor.IsReadOnly = running;
        ModelPicker.IsEnabled = !running; RequestLimit.IsReadOnly = running; MaxTokens.IsReadOnly = running;
        ConnectButton.IsEnabled = busy.Count == 0;
    }
    private async Task SaveCurrent()
    {
        if (selectedId is null || busy.Contains(selectedId)) return;
        var id = selectedId;
        if (!int.TryParse(RequestLimit.Text, out var limit) || !int.TryParse(MaxTokens.Text, out var tokens)) throw new InvalidOperationException("요청 상한과 출력 토큰은 정수로 입력하세요.");
        var saved = await Client.Call("update", new
        {
            model = ModelPicker.SelectedValue as string ?? Text(Current, "model"),
            context = ContextEditor.Text, draft = LuaEditor.Text, requestLimit = limit, maxTokens = tokens
        }, id);
        sessions[id] = saved;
    }
    private async void SessionList_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (binding || SessionList.SelectedItem is not SessionRow row || row.Id == selectedId) return;
        var previous = selectedId;
        SessionList.IsEnabled = false;
        try
        {
            if (previous is not null) pendingPrompts[previous] = PromptEditor.Text;
            await SaveCurrent(); selectedId = row.Id; BindSession();
            PromptEditor.Text = pendingPrompts.GetValueOrDefault(row.Id, "");
        }
        catch (Exception error)
        {
            Status(error.Message); binding = true;
            SessionList.SelectedItem = SessionList.Items.Cast<SessionRow>().FirstOrDefault(s => s.Id == previous);
            binding = false;
        }
        finally { SessionList.IsEnabled = true; }
    }
    private async void Save_Click(object sender, RoutedEventArgs e) => await Guard(async () => { await SaveCurrent(); Status("이 작업 공간을 저장했습니다."); });
    private async void Connect_Click(object sender, RoutedEventArgs e) => await Guard(async () =>
    {
        await SaveCurrent(); ConnectButton.IsEnabled = false; Status("OMP 모델 목록을 가져오는 중입니다. 생성 요청은 보내지 않습니다.");
        try
        {
            await Client.Call("configure", executable: OmpPath.Text);
            var catalog = await Client.Call("models");
            models = catalog.EnumerateArray().Where(m => Text(m, "kind") == "chat").Select(m => new ModelRow(Text(m, "id"))).ToList();
            BindModels();
            ModelStatus.Text = $"대화 모델 {models.Count}개 · 기타 {catalog.GetArrayLength() - models.Count}개\nJev 등 평가 전용 모델은 대화 목록에서 제외됩니다.";
            Status("OMP 연결 완료 · 모델을 선택하세요. 인증·계정 선택은 OMP 설정을 따릅니다.");
        }
        finally { UpdateBusy(); }
    });
    private void BrowseOmp_Click(object sender, RoutedEventArgs e)
    {
        var dialog = new OpenFileDialog { Filter = "OMP executable (*.exe)|*.exe", Title = "OMP 실행 파일 선택" };
        if (dialog.ShowDialog(this) == true) OmpPath.Text = dialog.FileName;
    }
    private async void NewSession_Click(object sender, RoutedEventArgs e) => await Guard(async () =>
    {
        await SaveCurrent();
        var dialog = new NewSessionWindow { Owner = this };
        if (dialog.ShowDialog() != true) return;
        var created = await Client.Call("create", dialog.Result);
        await Refresh(Text(created, "id")); PromptEditor.Text = "";
        Status("새 작업 공간을 만들었습니다. 세력·시나리오·작업 종류는 이 대화에 고정됩니다.");
    });
    private async void Send_Click(object sender, RoutedEventArgs e) => await Guard(Send);
    private async Task Send()
    {
        if (selectedId is null || busy.Contains(selectedId) || preparingRequest) return;
        var id = selectedId; var title = Text(Current, "name");
        var prompt = PromptEditor.Text.Trim();
        if (prompt.Length == 0) throw new InvalidOperationException("질문이나 작업 목표를 입력하세요.");
        if (ModelPicker.SelectedValue is not string) throw new InvalidOperationException("OMP에서 모델을 불러오고 이 작업 공간의 모델을 선택하세요.");
        preparingRequest = true;
        try { await SaveCurrent(); busy.Add(id); }
        finally { preparingRequest = false; }
        UpdateBusy(); Status($"{title}: AI 응답을 기다리고 있습니다. 다른 세력의 작업 공간을 사용할 수 있습니다.");
        try
        {
            var response = await Client.Call("chat", sessionId: id, prompt: prompt);
            sessions[id] = response.GetProperty("session").Clone();
            if (selectedId == id)
            {
                BindSession(); Conversation.ScrollToEnd();
                if (PromptEditor.Text.Trim() == prompt) PromptEditor.Clear();
                if (response.TryGetProperty("inspection", out var inspection) && inspection.ValueKind == JsonValueKind.Object)
                    LuaStatus.Text = inspection.GetProperty("ok").GetBoolean() ? "생성된 Lua가 텍스트 검사를 통과했습니다. 적용 전에 검토하세요." : "생성된 Lua에 금지 항목이 있어 초안에 자동 반영하지 않았습니다.";
            }
            pendingPrompts.Remove(id); Status($"{title}: 응답을 저장했습니다.");
        }
        finally
        {
            busy.Remove(id); UpdateBusy();
            // Refresh counters after failure without overwriting another session's edits.
            var state = await Client.Call("state");
            var updated = state.GetProperty("sessions").EnumerateArray().FirstOrDefault(s => Text(s, "id") == id);
            if (updated.ValueKind == JsonValueKind.Object) sessions[id] = updated.Clone();
            if (selectedId == id) UpdateUsage(sessions[id]);
        }
    }
    private async void Cancel_Click(object sender, RoutedEventArgs e) => await Guard(async () =>
    {
        await Client.Call("cancel", sessionId: selectedId); Status("취소 요청을 보냈습니다. 이미 처리된 공급자 사용량은 발생할 수 있습니다.");
    });
    private async void PromptEditor_PreviewKeyDown(object sender, KeyEventArgs e)
    {
        if (e.Key == Key.Enter && Keyboard.Modifiers.HasFlag(ModifierKeys.Control)) { e.Handled = true; await Guard(Send); }
    }
    private async void ClearHistory_Click(object sender, RoutedEventArgs e) => await Guard(async () =>
    {
        if (MessageBox.Show(this, "이 작업 공간의 대화 기록만 비울까요? 요청 횟수는 유지됩니다.", "대화 비우기", MessageBoxButton.YesNo) != MessageBoxResult.Yes) return;
        await SaveCurrent(); await Client.Call("clearHistory", sessionId: selectedId); await Refresh();
    });
    private async Task ImportText(TextBox editor, string filter, int maximum)
    {
        if (selectedId is not null && busy.Contains(selectedId)) throw new InvalidOperationException("진행 중인 요청이 끝난 뒤 자료를 바꾸세요.");
        var dialog = new OpenFileDialog { Filter = filter };
        if (dialog.ShowDialog(this) != true) return;
        if (new FileInfo(dialog.FileName).Length > maximum * 4L) throw new InvalidOperationException("파일이 너무 큽니다.");
        var content = await File.ReadAllTextAsync(dialog.FileName, new UTF8Encoding(false, true));
        if (content.Length > maximum || content.Contains('\0')) throw new InvalidOperationException("파일 길이 또는 텍스트 형식을 확인하세요.");
        editor.Text = content; await SaveCurrent(); Status("자료를 불러왔습니다. 선택한 모델에 보낼 내용을 검토하세요.");
    }
    private async void ImportContext_Click(object sender, RoutedEventArgs e) => await Guard(() => ImportText(ContextEditor, Text(Current, "mode") == "advice" ? "Side observation (*.json)|*.json" : "Context (*.txt;*.md;*.json;*.lua)|*.txt;*.md;*.json;*.lua", 80000));
    private async void ImportLua_Click(object sender, RoutedEventArgs e) => await Guard(() => ImportText(LuaEditor, "Lua source (*.lua)|*.lua", 320000));
    private void InsertTemplate_Click(object sender, RoutedEventArgs e)
    {
        if (selectedId is null || busy.Contains(selectedId)) return;
        if (ContextEditor.Text.Trim().Length > 0 && MessageBox.Show(this, "현재 자료를 빈 양식으로 바꿀까요?", "양식 넣기", MessageBoxButton.YesNo) != MessageBoxResult.Yes) return;
        ContextEditor.Text = Text(Current, "mode") == "advice" ? JsonSerializer.Serialize(new
        {
            schema = "cmo-side-observation/v1", scenarioId = Text(Current, "scenarioId"), sideId = Text(Current, "sideId"),
            observedAt = DateTimeOffset.UtcNow.ToString("O"), ownUnits = Array.Empty<object>(), contacts = Array.Empty<object>(), missionNotes = Array.Empty<string>()
        }, new JsonSerializerOptions { WriteIndented = true }) : "Game build:\nDatabase/version:\nScenario goal:\nSides:\nMissions:\nEvents / triggers / conditions:\nScoring / end conditions:\nConfirmed GUIDs and DBIDs:\nOpen questions:\n";
    }
    private async Task<bool> InspectLua()
    {
        var result = await Client.Call("inspectLua", content: LuaEditor.Text);
        var ok = result.GetProperty("ok").GetBoolean();
        LuaStatus.Text = ok ? "텍스트 검사 통과 · 구문·API 호환성·게임 내 동작은 별도 검증이 필요합니다." : string.Join(" · ", result.GetProperty("issues").EnumerateArray().Select(x => Text(x, "message")));
        return ok;
    }
    private async void InspectLua_Click(object sender, RoutedEventArgs e) => await Guard(async () => { await InspectLua(); });
    private async void ExportLua_Click(object sender, RoutedEventArgs e) => await Guard(async () =>
    {
        if (!await InspectLua()) return;
        var dialog = new SaveFileDialog { Filter = "Lua draft (*.lua)|*.lua", FileName = "cmo-draft.lua" };
        if (dialog.ShowDialog(this) != true) return;
        await File.WriteAllTextAsync(dialog.FileName, LuaEditor.Text, new UTF8Encoding(false));
        await SaveCurrent(); Status("검토용 Lua 파일을 저장했습니다. 게임 실행은 수행하지 않았습니다.");
    });
    private async void ExportConversation_Click(object sender, RoutedEventArgs e) => await Guard(async () =>
    {
        var dialog = new SaveFileDialog { Filter = "Text (*.txt)|*.txt", FileName = "cmo-conversation.txt" };
        if (dialog.ShowDialog(this) == true) await File.WriteAllTextAsync(dialog.FileName, $"{SessionTitle.Text}\n{SessionBinding.Text}\n\n{Conversation.Text}", new UTF8Encoding(false));
    });
    public async Task RunSmokeTest(string directory)
    {
        Directory.CreateDirectory(directory);
        await Initialize(Path.Combine(directory, "workspace"));
        await Client.Call("update", new { draft = "print('CMO draft')" }, sessions.Keys.First());
        await Refresh();
        if (!initialized || sessions.Count != 4 || SessionTitle.Text.Length == 0) throw new Exception("Session UI initialization failed.");
        LuaEditor.Text = "print('CMO draft')";
        if (!await InspectLua()) throw new Exception("Lua draft screening failed.");
        var advice = sessions.Values.First(s => Text(s, "sideId") == "blue");
        selectedId = Text(advice, "id"); BindSession();
        if (LuaTab.Visibility != Visibility.Collapsed || !ContextEditor.Text.Contains("cmo-side-observation/v1")) throw new Exception("Advice mode separation failed.");
        selectedId = sessions.Keys.First(); BindSession();
        ModelPicker.ItemsSource = new[] { new ModelRow("ui-test / offline preview") };
        ModelPicker.SelectedIndex = 0;
        Conversation.Text = "시나리오 제작 작업 공간\n\n기획 의도, 미션, 이벤트, 점수 조건을 함께 정리합니다.\n확인된 게임 빌드와 DBID를 자료 탭에 입력하세요.\n\n• OMP의 등록 모델 선택\n• 세력별 독립된 관측 자료와 대화\n• Lua 초안 검사와 파일 저장\n\n모델 연결 전에는 생성 요청이 전송되지 않습니다.";
        Status("UI smoke test · 모델 호출과 게임 실행 없이 로컬 기능을 확인했습니다.");
        // Render the detached native content: an unshown Window is invisible
        // and would produce a fully transparent bitmap in headless CI.
        var surface = (FrameworkElement)Content;
        Content = null;
        surface.Measure(new Size(1380, 900)); surface.Arrange(new Rect(0, 0, 1380, 900)); surface.UpdateLayout();
        var bitmap = new RenderTargetBitmap(1380, 900, 96, 96, PixelFormats.Pbgra32);
        bitmap.Render(surface);
        var encoder = new PngBitmapEncoder(); encoder.Frames.Add(BitmapFrame.Create(bitmap));
        using (var stream = File.Create(Path.Combine(directory, "desktop.png"))) encoder.Save(stream);
        client?.Dispose(); client = null;
        File.WriteAllText(Path.Combine(directory, "result.json"), "{\"ok\":true,\"sessions\":4,\"nativeUi\":true,\"luaScreen\":true,\"sideBinding\":true}");
    }
}
