# macOS / Windows 공용 Neovim 설정

`init.vim`은 운영체제를 감지해 Windows의 플러그인 위치, 입력기 ID,
Java LSP 실행 파일 및 셸을 선택합니다. macOS의 기존 `~/.vim/plugged`와
입력기 설정은 유지합니다.

## Windows 설치

### 1. Neovim 설치

Windows Terminal에서 PowerShell을 열고 실행합니다.

```powershell
winget install --id Neovim.Neovim --exact --version 0.11.5
```

`winget`을 사용할 수 없으면 [Neovim 0.11.5 릴리스 페이지](https://github.com/neovim/neovim/releases/tag/v0.11.5)에서
일반적인 Intel/AMD 64비트 PC용 `nvim-win64.msi`를 내려받아 설치합니다.
ARM PC에서는 `nvim-win-arm64.msi`를 선택합니다.

설치 후 **PowerShell을 닫고 새로 열어** PATH를 반영한 뒤 확인합니다.

```powershell
nvim --version
git --version
node --version
```

Neovim은 `NVIM v0.11.5`가 표시되면 정상입니다. Git과 Node.js도 필요하므로
명령을 찾지 못하면 각각 [Git](https://git-scm.com/downloads/win)과
[Node.js](https://nodejs.org/)를 설치하고 PowerShell을 다시 엽니다.

기존 Treesitter 설정을 유지하기 위해 `master` 브랜치를 지정했으며,
이 설정은 Neovim 0.11 계열을 기준으로 합니다. Neovim 0.12 이상은
Treesitter의 새 API로 별도 마이그레이션이 필요합니다.

### 2. 설정 복사 및 vim-plug 설치

이 저장소 폴더로 이동합니다. 바탕 화면에 저장소를 둔 경우:

```powershell
cd "$env:USERPROFILE\Desktop\nvim-config"
```

아래 PowerShell 명령을 실행합니다. 기존 설정이 있다면 먼저 백업하세요.
설정 파일만 복사하며, macOS에서 설치한 플러그인이나 파서 바이너리는 복사하지 않습니다.

```powershell
# 실제 Neovim 설정/데이터 경로를 사용하므로 XDG 및 NVIM_APPNAME 설정도 반영됩니다.
$nvimConfigDir = (nvim --headless -u NONE -i NONE -c 'lua io.write(vim.fn.stdpath("config"))' -c 'qa!') -join ''
$nvimDataDir = (nvim --headless -u NONE -i NONE -c 'lua io.write(vim.fn.stdpath("data"))' -c 'qa!') -join ''
New-Item -ItemType Directory -Force -Path $nvimConfigDir | Out-Null
Copy-Item -LiteralPath .\init.vim, .\coc-settings.json -Destination $nvimConfigDir
New-Item -ItemType Directory -Force -Path "$nvimDataDir\site\autoload" | Out-Null
Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' -OutFile "$nvimDataDir\site\autoload\plug.vim"
nvim
```

기본 설정 위치는 `%LOCALAPPDATA%\nvim`, 데이터 위치는
`%LOCALAPPDATA%\nvim-data`입니다.

### 3. 플러그인 설치 및 재시작

처음 Neovim을 실행하면 기본 시작 화면 아래에 다음 안내가 표시됩니다.
이는 플러그인이 아직 설치되지 않았다는 정상적인 안내입니다.
이 단계에서는 테마를 포함한 Lua 설정을 실행하지 않습니다.

```text
Plugins are missing. Run :PlugInstall, then restart Neovim.
```

영어 입력 상태에서 Neovim 안에 다음 명령을 입력하고 Enter를 누릅니다.

```vim
:PlugInstall
```

플러그인 설치가 끝나면 다음 명령으로 Neovim을 종료합니다.

```vim
:qa
```

PowerShell에서 다시 실행합니다.

```powershell
nvim
```

설치 안내가 사라지고 테마와 플러그인 설정이 적용되면 기본 설정이 완료된 것입니다.
이 과정까지 Windows에서 사용자가 정상 실행을 확인했습니다.
기존 플러그인을 업데이트할 때에는 `:PlugUpdate`를 사용합니다.

이후 Neovim에서 `:checkhealth`와 `:CocInfo`로 기능별 추가 프로그램과 CoC 상태를 확인합니다.

### 줄바꿈 오류 해결 (`^M`, `E492`, `E116`)

`Not an editor command: ^M` 또는 `Invalid arguments for function plug#`가
연이어 나오면 `init.vim`에 CRLF와 LF 줄바꿈이 섞여 있는지 확인합니다.
이 저장소는 `.gitattributes`의 `*.vim text eol=lf`로 Vim 설정 파일을 LF로 유지합니다.
LF는 macOS와 Windows Neovim 모두 지원합니다.

이미 복사한 설정에서 같은 오류가 나면 Neovim을 종료하고 PowerShell에서
다음 명령으로 설치된 파일의 줄바꿈을 LF로 통일한 뒤 다시 실행합니다.

```powershell
$nvimConfigDir = (nvim --headless -u NONE -i NONE -c 'lua io.write(vim.fn.stdpath("config"))' -c 'qa!') -join ''
$nvimInitPath = Join-Path $nvimConfigDir 'init.vim'
$nvimInitText = [System.IO.File]::ReadAllText($nvimInitPath)
$nvimInitText = $nvimInitText.Replace("`r`n", "`n").Replace("`r", "`n")
[System.IO.File]::WriteAllText($nvimInitPath, $nvimInitText, [System.Text.UTF8Encoding]::new($false))
nvim
```

## 기능별 추가 프로그램

파일 트리는 파일이나 작업 폴더를 바꿔도 자동으로 루트/커서를 이동하지 않습니다.
트리 안에서 `gr`은 선택한 폴더를 루트로, `gR`은 부모 폴더를 루트로 바꿉니다.
이 트리 고정 설정은 macOS와 Windows 모두 적용됩니다.

- **파일 내용 검색** (`Space fg`): `rg` (ripgrep)를 PATH에 추가합니다.
- **Treesitter**: 아래 C 컴파일러 설치 절차를 따릅니다.
- **자동 입력기 전환**: Windows용 `im-select.exe`를 PATH에 추가하고
  영어(미국) 키보드를 설치합니다. `im-select.exe 1033`으로 전환을 확인합니다.
  바이너리가 없으면 자동 전환은 비활성화됩니다.
- **Java**: JDK 21 이상과 Python 3.9 이상을 PATH에 추가하고
  `:MasonInstall jdtls`를 실행합니다. `java -version`, `javac -version`,
  `python --version`으로 확인하세요. Windows의 F5는 현재 파일에서 프로젝트 루트를 찾아 그 폴더의 `bin`에
  현재 Java 파일을 컴파일하여 실행하며, Maven/Gradle 전체 빌드를 대신하지 않습니다.
  `.git`, `.project`, `pom.xml`, `build.gradle`, `build.gradle.kts` 또는 `src`의 부모 폴더를
  루트로 판단합니다. 실행 시 작업 폴더도 루트로 맞추므로 `res/...` 상대 경로를 사용할 수 있습니다.
  예를 들어 `swea/src/swea/d4/s1251/Solution.java`는 `swea`에서 실행되어
  `res/S1251/re_sample_input.txt`를 찾습니다. 루트 표시가 없으면 Java 파일이 있는 폴더를 사용합니다.
  macOS의 F5는 기존 설정처럼 Neovim의 현재 작업 폴더에서 실행합니다.
  따라서 macOS에서는 프로젝트 루트에서 Neovim을 열거나 `:cd`로 루트로 이동합니다.
  F5는 현재 파일 하나를 실행하는 기능이므로 외부 라이브러리나 프로젝트 전체 빌드가
  필요한 Java 프로젝트는 Maven/Gradle 등 프로젝트의 실행 명령을 사용하세요.
- **터미널 Markdown 미리보기** (`Space mg`): `glow` 실행 파일이 필요합니다.
- **Tagbar**: Universal Ctags가 필요합니다.
- **아이콘**: 터미널에 Nerd Font를 설정하면 파일/상태 표시줄 아이콘이 표시됩니다.
- **CoC 언어 지원**: 기존 맥에서 사용한 CoC 확장은 새 PC에서도 설치해야 합니다.
  예: `:CocInstall coc-tsserver coc-json coc-css coc-prettier coc-eslint`.

현재 CoC와 nvim-cmp가 함께 설정되어 있어 자동완성 키가 겹칠 수 있습니다.
또한 `coc-settings.json`의 Prettier 경로는 프로젝트의
`node_modules/prettier`와 `packages/config/prettier/.prettierrc`를 전제로 합니다.
다른 프로젝트에서는 해당 경로를 맞춰 주세요.

### Treesitter C 컴파일러 설치

`No C compiler found!`는 Treesitter 언어 파서를 빌드할 C 컴파일러가
PATH에 없다는 뜻입니다. Windows에서는 시작 시 파서를 자동 설치하지 않으며,
아래 수동 설치 명령을 사용합니다. 괄호 자동 완성 등 다른 기능은 사용할 수 있습니다.

Windows에서는 이 설정의 기존 Treesitter 빌드에 사용할 Zig 0.13.0을 설치할 수 있습니다.
PowerShell에서 실행합니다.

```powershell
winget install --id zig.zig --exact --version 0.13.0
```

Windows Terminal을 완전히 종료하고 다시 열어 PATH를 반영한 뒤 확인합니다.

```powershell
zig version
nvim
```

Neovim 안에서 필요한 파서를 설치합니다.

```vim
:TSInstallSync lua python javascript html css
```

설치가 끝나면 재시작합니다. 문제가 남으면 `:checkhealth nvim-treesitter`로 확인합니다.
macOS는 PATH에 `cc` 또는 `clang` 등 사용 가능한 컴파일러가 있으면 기존처럼 자동 설치합니다.

`tree-sitter-lua` 폴더의 `.git/index.lock` 등을 다른 프로세스가 사용 중이라는
오류가 나오면 모든 Neovim 인스턴스를 종료하고 진행 중인 파서 설치가 끝날 때까지 기다립니다.
시작 시 자동 설치와 수동 설치를 겹쳐 실행하거나 여러 Neovim에서 동시에 설치하지 마세요.
남은 Lua 파서 빌드 임시 폴더는 PowerShell에서 아래처럼 정리할 수 있습니다.
프로젝트 소스가 아닌 Neovim 데이터 폴더의 `tree-sitter-lua`만 대상으로 합니다.

```powershell
$nvimDataDir = (nvim --headless -u NONE -i NONE -c 'lua io.write(vim.fn.stdpath("data"))' -c 'qa!') -join ''
$nvimLuaBuildDir = Join-Path $nvimDataDir 'tree-sitter-lua'
if (Test-Path -LiteralPath $nvimLuaBuildDir) {
  Remove-Item -LiteralPath $nvimLuaBuildDir -Recurse -Force
}
nvim
```

Neovim을 하나만 열어 `:TSInstallSync lua python javascript html css`를 다시 실행합니다.
삭제 시에도 사용 중 오류가 나면 해당 프로세스가 아직 종료되지 않은 것이므로,
Windows를 재시작한 후 Neovim을 열기 전에 임시 폴더를 정리합니다.

- [Zig 0.13.0 winget 패키지](https://github.com/microsoft/winget-pkgs/tree/master/manifests/z/zig/zig/0.13.0)

## macOS 호환성

- Windows 전용 셸, 플러그인 경로, 입력기 ID 및 Java LSP 실행 파일 분기는 macOS에 적용하지 않습니다.
- Markdown 미리보기 설치 명령과 F5의 실행 작업 폴더는 macOS에서 기존 동작을 유지합니다.
- LF 줄바꿈은 양쪽 운영체제에서 사용 가능합니다.
- 괄호 자동 완성 초기화와 Gitsigns 옵션 위치 수정은 양쪽에 적용됩니다.
  Enter 매핑은 괄호 자동 완성 플러그인이 변경하지 않습니다.
- Treesitter는 기존 `nvim-treesitter.configs` API에 맞는 `master` 브랜치를 사용합니다.
  Neovim 0.11 계열 기준이며, 0.12 이상은 별도 마이그레이션이 필요합니다.
- 기존 CoC와 nvim-cmp의 자동완성 키 중복은 이번 변경 이전부터 있던 설정입니다.

Windows의 기본 실행과 Java F5 상대 경로 동작은 확인했습니다.
macOS에서 직접 실행한 검증은 없으므로 모든 플러그인의 macOS 동작까지 보장하지는 않습니다.

## 참고 문서

- [vim-plug 설치](https://github.com/junegunn/vim-plug#installation)
- [입력기 설정](https://github.com/keaising/im-select.nvim)
- [Treesitter 브랜치 및 요구사항](https://github.com/nvim-treesitter/nvim-treesitter)
- [Java LSP 요구사항](https://github.com/mfussenegger/nvim-jdtls#installation)
- [Markdown 미리보기 설치](https://github.com/iamcco/markdown-preview.nvim#installation--usage)

입력기 자동 전환과 Java LSP 등 추가 기능은 해당 프로그램을 설치한 뒤 별도로 확인합니다.
