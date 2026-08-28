# ShadowControl

# ShadowControl

**ShadowControl** is a compact utility for system administrators that simplifies connecting to remote desktops (RDP) in shadow session mode with session control capabilities.

The utility allows you to quickly connect to any computer in the domain, using autocompletion from Active Directory, ICMP (ping) availability check.

---

## 📋 Requirements

- Operating system Windows 10 / Windows Server 2016 or higher.
- Installed `ActiveDirectory` module for computer name autocompletion (optional).
- Administrator privileges on the target computer for shadow connection.
- Domain administrator rights to read the computer list from AD (if autocompletion is used).

---

## ⚙️ Group Policy Configuration (GPO)

For the utility to work, you must allow shadow connections **on the target computer**. This is done via local or domain Group Policy.

### GPO Path:
Computer Configuration → Administrative Templates → Windows Components → Remote Desktop Services → Remote Desktop Session Host → Connections

**Policy:**  
`Set rules for remote control of Remote Desktop Services user sessions`

**Set to:**  
`Enabled` → `Full Control without user's permission`

After applying the policy, update Group Policy on target computers (`gpupdate /force`).

---

## 🚀 Usage

1. Download the `ShadowControl.ps1` file or the compiled `.exe`.
2. Run the script via PowerShell (if running `.ps1`):

   ```powershell
   powershell -ExecutionPolicy Bypass -File ShadowControl.ps1

3. Enter the IP address or computer name (AD autocompletion will suggest available domain names).

4. Specify the session ID (usually 1).

5. Select the desired connection options (/control, /multimon, /span, /prompt, ping check).

6. Click "Connect" or press Enter.

## 📦 Build to .exe via PowerShell (optional)
If you want to get a single executable file, use the PS2EXE utility:

powershell
Install-Module -Name ps2exe -Force -Scope CurrentUser
powershell
Invoke-PS2EXE .\ShadowControl.ps1 .\ShadowControl.exe -NoConsole -NoError -IconFile .\icon.ico
📝 License
The project is distributed under the MIT License – you are free to use, modify, and distribute the code.

## 🤝 Contributing
If you find a bug or want to suggest an improvement – create an Issue or Pull Request. We will be happy to develop the project together!

---

**ShadowControl** – это компактная утилита для системных администраторов, которая упрощает подключение к удалённым рабочим столам (RDP) в режиме теневого управления (Shadow Session) с возможностью управления сеансом.

Утилита позволяет быстро подключаться к любому компьютеру в домене, используя автодополнение из Active Directory, проверку доступности по ICMP (ping).

---

## 📋 Требования

- Операционная система Windows 10 / Windows Server 2016 и выше.
- Установленный модуль `ActiveDirectory` для автодополнения имён компьютеров (опционально).
- Права администратора на целевом компьютере для теневого подключения.
- Права администратора домена для чтения списка компьютеров из AD (если используется автодополнение).

---

## ⚙️ Настройка групповой политики (GPO)

Для работы утилиты необходимо разрешить теневые подключения **на целевом компьютере**. Это делается через локальную или доменную групповую политику.

### Путь в GPO:
Конфигурация компьютера → Административные шаблоны → Компоненты Windows → Службы удаленных рабочих столов → Узел сеансов удаленных рабочих столов → Подключения

**Параметр:**  
`Устанавливает правила удаленного управления для пользовательских сеансов служб удаленных рабочих столов`

**Установите значение:**  
`Включено` → `Полный контроль без разрешения пользователя`

После применения политики обновите групповые политики на целевых компьютерах (`gpupdate /force`).

---

## 🚀 Запуск

1. Скачайте файл `ShadowControl.ps1` или скомпилированный `.exe`.
2. Запустите скрипт через PowerShell (если запускаете `.ps1`):

   ```powershell
   powershell -ExecutionPolicy Bypass -File ShadowControl.ps1

4. Введите IP-адрес или имя компьютера (автодополнение из AD подскажет доступные имена).
5. Укажите ID сессии (обычно 1).
6. Выберите нужные параметры подключения (/control, /multimon, /span, /prompt, проверка ping).
7. Нажмите «Подключиться» или клавишу Enter.

## 📦 Сборка в .exe через powershell (опционально)
Если вы хотите получить единый исполняемый файл, используйте утилиту PS2EXE:

Install-Module -Name ps2exe -Force -Scope CurrentUser

Invoke-PS2EXE .\ShadowControl.ps1 .\ShadowControl.exe -NoConsole -NoError -IconFile .\icon.ico

## 📝 Лицензия
Проект распространяется под лицензией MIT – вы можете свободно использовать, модифицировать и распространять код.

## 🤝 Вклад
Если вы нашли ошибку или хотите предложить улучшение – создавайте Issue или Pull Request. Будем рады развитию проекта вместе!
