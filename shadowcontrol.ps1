# ===================================================================
# RDP Shadow – компактная обёртка для mstsc
# Версия: 3.2 (уменьшено пустое пространство)
# ===================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ---- Путь в реестре ----
$regPath = "HKCU:\Software\RDPShadow"

# ---- Функции реестра ----
function Get-Setting($name, $default) {
    if (Test-Path $regPath) {
        $val = (Get-ItemProperty -Path $regPath -Name $name -ErrorAction SilentlyContinue).$name
        if ($val -ne $null) { return $val }
    }
    return $default
}

function Set-Setting($name, $value) {
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name $name -Value $value -Type String -Force
}

# ---- Загрузка списка компьютеров из AD (если доступно) ----
$adComputers = @()
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    try {
        Import-Module ActiveDirectory -ErrorAction Stop
        $adComputers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
    } catch {
        # Игнорируем ошибки AD
    }
}

# ---- Основная функция подключения ----
function Connect-RDP {
    $computer = $comboBoxAddress.Text.Trim()
    $sessionId = $textBoxSession.Text.Trim()

    if ($computer -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Введите IP или имя компьютера", "Ошибка")
        return
    }

    if ($checkBoxPing.Checked) {
        $pingResult = Test-Connection -ComputerName $computer -Count 1 -Quiet
        if (-not $pingResult) {
            [System.Windows.Forms.MessageBox]::Show(
                "Компьютер $computer не отвечает на ping",
                "Предупреждение",
                "OK",
                "Warning"
            )
        }
    }

    $argsList = @("/v:$computer", "/shadow:$sessionId")
    if ($checkBoxControl.Checked)   { $argsList += "/control" }
    if ($checkBoxMultimon.Checked)  { $argsList += "/multimon" }
    if ($checkBoxSpan.Checked)      { $argsList += "/span" }
    if ($checkBoxPrompt.Checked)    { $argsList += "/prompt" }
    $argsList += "/noConsentPrompt"
    $arguments = $argsList -join " "

    # Сохраняем настройки
    Set-Setting "LastComputer" $computer
    Set-Setting "LastSession"  $sessionId
    Set-Setting "LastControl"  $checkBoxControl.Checked
    Set-Setting "LastMultimon" $checkBoxMultimon.Checked
    Set-Setting "LastSpan"     $checkBoxSpan.Checked
    Set-Setting "LastPrompt"   $checkBoxPrompt.Checked
    Set-Setting "LastPing"     $checkBoxPing.Checked

    Start-Process "mstsc" -ArgumentList $arguments

    # Закрываем форму
    $form.DialogResult = [System.Windows.Forms.DialogResult]::None
    $form.Close()
    $form.Dispose()
}

# ---- Создание формы ----
$form = New-Object System.Windows.Forms.Form
$form.Text = "RDP Shadow"
$form.Size = New-Object System.Drawing.Size(500, 400)   # уменьшена высота
$form.StartPosition = "CenterScreen"
$form.KeyPreview = $true
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 245)
$form.Add_FormClosing({ $_.Cancel = $false })

# ---- Группа "Подключение" ----
$groupMain = New-Object System.Windows.Forms.GroupBox
$groupMain.Text = "Подключение"
$groupMain.Location = New-Object System.Drawing.Point(15, 15)
$groupMain.Size = New-Object System.Drawing.Size(460, 120)
$groupMain.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($groupMain)

$y = 25

# Метка "IP или имя компьютера"
$labelAddress = New-Object System.Windows.Forms.Label
$labelAddress.Text = "IP или имя компьютера:"
$labelAddress.Location = New-Object System.Drawing.Point(10, $y)
$labelAddress.Size = New-Object System.Drawing.Size(150, 20)
$labelAddress.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$groupMain.Controls.Add($labelAddress)

# Поле ввода адреса (ComboBox)
$comboBoxAddress = New-Object System.Windows.Forms.ComboBox
$locX = 160
$locY = [int]($y - 2)
$comboBoxAddress.Location = New-Object System.Drawing.Point($locX, $locY)
$comboBoxAddress.Size = New-Object System.Drawing.Size(280, 22)
$comboBoxAddress.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
$comboBoxAddress.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# Подставляем последний адрес
$lastComputer = Get-Setting "LastComputer" ""
if ($lastComputer -ne "") {
    $comboBoxAddress.Text = $lastComputer
}

# Автодополнение из AD
if ($adComputers.Count -gt 0) {
    $autocomplete = New-Object System.Windows.Forms.AutoCompleteStringCollection
    $autocomplete.AddRange($adComputers)
    $comboBoxAddress.AutoCompleteMode = [System.Windows.Forms.AutoCompleteMode]::SuggestAppend
    $comboBoxAddress.AutoCompleteSource = [System.Windows.Forms.AutoCompleteSource]::CustomSource
    $comboBoxAddress.AutoCompleteCustomSource = $autocomplete
}
$groupMain.Controls.Add($comboBoxAddress)

$y += 35

# Метка "ID сессии"
$labelSession = New-Object System.Windows.Forms.Label
$labelSession.Text = "ID сессии (обычно 1):"
$labelSession.Location = New-Object System.Drawing.Point(10, $y)
$labelSession.Size = New-Object System.Drawing.Size(150, 20)
$labelSession.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$groupMain.Controls.Add($labelSession)

# Поле ввода ID сессии
$textBoxSession = New-Object System.Windows.Forms.TextBox
$locY = [int]($y - 2)
$textBoxSession.Location = New-Object System.Drawing.Point(160, $locY)
$textBoxSession.Size = New-Object System.Drawing.Size(280, 22)
$textBoxSession.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$textBoxSession.Text = Get-Setting "LastSession" "1"
$groupMain.Controls.Add($textBoxSession)

$y += 35

# Кнопка "Подключиться"
$buttonConnect = New-Object System.Windows.Forms.Button
$buttonConnect.Text = "Подключиться"
$locY = [int]($y - 5)
$buttonConnect.Location = New-Object System.Drawing.Point(160, $locY)
$buttonConnect.Size = New-Object System.Drawing.Size(120, 30)
$buttonConnect.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
$buttonConnect.ForeColor = [System.Drawing.Color]::White
$buttonConnect.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$buttonConnect.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$buttonConnect.Add_Click({ Connect-RDP })
$groupMain.Controls.Add($buttonConnect)

# ---- Группа "Параметры mstsc" (уменьшена высота) ----
$groupOptions = New-Object System.Windows.Forms.GroupBox
$groupOptions.Text = "Параметры mstsc"
$groupOptions.Location = New-Object System.Drawing.Point(15, 145)   # расстояние 10px от предыдущей группы
$groupOptions.Size = New-Object System.Drawing.Size(460, 200)      # уменьшена высота
$groupOptions.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($groupOptions)

$optY = 25
$checkDefs = @(
    @{ Name="Control";   Text="Разрешить управление (/control)";          Default=$true  },
    @{ Name="Multimon";  Text="Несколько мониторов (/multimon)";          Default=$false },
    @{ Name="Span";      Text="Растянуть на все мониторы (/span)";        Default=$false },
    @{ Name="Prompt";    Text="Запрашивать учётные данные (/prompt)";     Default=$false },
    @{ Name="Ping";      Text="Проверять ping перед подключением";        Default=$true  }
)

$checkBoxes = @{}
foreach ($def in $checkDefs) {
    $cb = New-Object System.Windows.Forms.CheckBox
    $cb.Text = $def.Text
    $cb.Location = New-Object System.Drawing.Point(15, $optY)
    $cb.Size = New-Object System.Drawing.Size(420, 25)
    $cb.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $cb.Checked = [bool](Get-Setting ("Last" + $def.Name) $def.Default)
    $groupOptions.Controls.Add($cb)
    $checkBoxes[$def.Name] = $cb
    $optY += 30   # уменьшен шаг до 30
}

$checkBoxControl   = $checkBoxes['Control']
$checkBoxMultimon  = $checkBoxes['Multimon']
$checkBoxSpan      = $checkBoxes['Span']
$checkBoxPrompt    = $checkBoxes['Prompt']
$checkBoxPing      = $checkBoxes['Ping']

# ---- Обработка клавиш ----
$comboBoxAddress.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Connect-RDP } })
$textBoxSession.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { Connect-RDP } })
$form.Add_KeyDown({ if ($_.KeyCode -eq "Escape") { $form.Close() } })

# ---- Запуск формы ----
$form.ShowDialog() | Out-Null
exit 0
