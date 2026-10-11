using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;

namespace CmoWorkbench;
public sealed class NewSessionWindow : Window
{
    public object? Result { get; private set; }
    public NewSessionWindow()
    {
        Title = "새 작업 공간"; Width = 450; Height = 485; ResizeMode = ResizeMode.NoResize;
        WindowStartupLocation = WindowStartupLocation.CenterOwner;
        Background = new SolidColorBrush(Color.FromRgb(22, 34, 48));
        var panel = new StackPanel { Margin = new Thickness(24) };
        panel.Children.Add(new TextBlock { Text = "작업 종류와 관측 범위를 정하세요.", FontSize = 18, Margin = new Thickness(0, 0, 0, 18) });
        TextBox Field(string title, string value)
        {
            panel.Children.Add(new TextBlock { Text = title, Margin = new Thickness(0, 8, 0, 5) });
            var field = new TextBox { Text = value, MaxLength = 160 }; panel.Children.Add(field); return field;
        }
        var name = Field("이름", "새 작업 공간");
        var scenario = Field("시나리오 식별자", "scenario-1");
        panel.Children.Add(new TextBlock { Text = "작업 종류", Margin = new Thickness(0, 8, 0, 5) });
        var mode = new ComboBox { ItemsSource = new[] { "시나리오 제작", "Lua 작성 보조", "플레이 조언" }, SelectedIndex = 0 }; panel.Children.Add(mode);
        var textFactory = new FrameworkElementFactory(typeof(TextBlock));
        textFactory.SetBinding(TextBlock.TextProperty, new System.Windows.Data.Binding());
        textFactory.SetValue(TextBlock.ForegroundProperty, new SolidColorBrush(Color.FromRgb(19, 32, 45)));
        mode.ItemTemplate = new DataTemplate { VisualTree = textFactory };
        var side = Field("세력 식별자 · 플레이 조언에서 필수", "");
        var submit = new Button { Content = "만들기", Margin = new Thickness(0, 20, 0, 0), IsDefault = true };
        submit.Click += (_, _) =>
        {
            if (string.IsNullOrWhiteSpace(name.Text) || string.IsNullOrWhiteSpace(scenario.Text) || (mode.SelectedIndex == 2 && string.IsNullOrWhiteSpace(side.Text)))
            { MessageBox.Show(this, "이름·시나리오와 필요한 세력 식별자를 입력하세요."); return; }
            Result = new { name = name.Text.Trim(), scenarioId = scenario.Text.Trim(), sideId = mode.SelectedIndex == 2 ? side.Text.Trim() : "", mode = new[] { "authoring", "lua", "advice" }[mode.SelectedIndex] };
            DialogResult = true;
        };
        panel.Children.Add(submit); Content = panel;
    }
}
