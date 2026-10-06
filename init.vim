" ────────────── 기본 설정 ──────────────
set number                " 줄 번호 표시
set encoding=utf-8        " UTF-8 인코딩

let s:is_windows = has('win32') || has('win64')
let mapleader = " "

" F5 및 플러그인의 && 명령을 Windows PowerShell 5에서도 실행 가능하게 한다.
if s:is_windows
  set shell=cmd.exe
  set shellcmdflag=/s\ /c
  set shellquote=
  set shellxquote=\"
  set shellredir=>%s\ 2>&1
  set shellpipe=>%s\ 2>&1
endif

" 24bit 색 활성화
set termguicolors  " 24-bit 색상 활성화(안 켜면 색이 탁해짐)

" 라이트 테마면 배경 힌트도 light로
set background=light

" ───────────────────────────────────────────────
" 🇰🇷 한글 입력 상태에서도 명령어 동작 (langmap)
" ───────────────────────────────────────────────
set langmap=ㅂq,ㅠw,ㅊe,ㄷr,ㅌt,ㄴy,ㅕu,ㅑi,ㅐo,ㅔp,ㅁa,ㄹs,ㄴd,ㅎf,ㅗg,ㅓh,ㅏj,ㅣk,ㅡl,ㅠz,ㅜx,ㅡc,ㅣv,ㅐb,ㅔn,ㅍm

" ==============================

"  Neovim plugin manager setup
" ==============================
if empty(globpath(&runtimepath, 'autoload/plug.vim'))
  echohl WarningMsg
  echom 'vim-plug is missing. Follow README.md to install it, then restart Neovim.'
  echohl None
  finish
endif
" macOS는 기존 설치 위치를 유지하고 Windows는 Neovim 데이터 폴더를 사용한다.
call plug#begin(s:is_windows ? stdpath('data') . '/plugged' : expand('~/.vim/plugged'))
Plug 'windwp/nvim-autopairs'

" Treesitter syntax highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'branch': 'master', 'do': ':TSUpdate'}

" LSP configuration helper
Plug 'neovim/nvim-lspconfig'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'nvim-lualine/lualine.nvim' 
" If you want to have icons in your statusline choose one of these 
Plug 'nvim-tree/nvim-web-devicons'

Plug 'preservim/nerdtree'

Plug 'preservim/tagbar'

Plug 'lewis6991/gitsigns.nvim' " OPTIONAL: for git status
Plug 'romgrk/barbar.nvim'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }

Plug 'NeogitOrg/neogit'
Plug 'nvim-lua/plenary.nvim'      " 필수
Plug 'sindrets/diffview.nvim'     " 선택: Diff 통합

Plug 'nvim-tree/nvim-tree.lua'
Plug 'mrjones2014/smart-splits.nvim'
Plug 'famiu/bufdelete.nvim'

" Colorschemes
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
Plug 'gruvbox-community/gruvbox'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'EdenEast/nightfox.nvim' " Vim-Plug

Plug 'ramojus/mellifluous.nvim'
Plug 'keaising/im-select.nvim'

" 1️⃣ 브라우저 미리보기 (iamcco/markdown-preview.nvim)
if s:is_windows
  Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }
else
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npx --yes yarn install' }
endif

" 2️⃣ 터미널 안에서 렌더링 (ellisonleao/glow.nvim)
Plug 'ellisonleao/glow.nvim', {'branch': 'main'}

" Java LSP
Plug 'mfussenegger/nvim-jdtls'

" LSP 설치 관리
Plug 'williamboman/mason.nvim'

" 자동완성
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'

call plug#end()

" 최초 설치 전에는 require() 오류 없이 :PlugInstall을 실행할 수 있다.
if !empty(filter(values(copy(g:plugs)), '!isdirectory(v:val.dir)'))
  echohl WarningMsg
  echom 'Plugins are missing. Run :PlugInstall, then restart Neovim.'
  echohl None
  finish
endif

" ==============================
"  Basic Treesitter settings
" ==============================
lua << EOF
local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

-- 괄호/따옴표 자동 완성 활성화. Enter는 기존 CoC/cmp 매핑을 유지한다.
require('nvim-autopairs').setup({ map_cr = false })

local has_c_compiler = false
for _, compiler in ipairs(require('nvim-treesitter.install').compilers) do
  if type(compiler) == 'string' and vim.fn.executable(compiler) == 1 then
    has_c_compiler = true
    break
  end
end

require'nvim-treesitter.configs'.setup {
  -- Windows는 수동 설치만 사용해 시작 시 설치와 :TSInstall의 경합을 피한다.
  -- macOS는 컴파일러가 있으면 기존처럼 자동 설치하며, 설치된 파서는 계속 사용한다.
  ensure_installed = (not is_windows and has_c_compiler) and { "lua", "python", "javascript", "html", "css" } or {},
  highlight = {
    enable = true,
  },
}

require("nvim-tree").setup({
  -- 🔽 파일 시스템 변화 감지(핵심)
  filesystem_watchers = {
    enable = true,
    debounce_delay = 50, -- 너무 잦은 갱신 방지(밀리초)
  },
  filters = {
    dotfiles = false,
    git_ignored = false,
    custom = {},
  },

  -- 파일/작업 폴더를 바꿔도 트리 루트와 커서가 자동으로 이동하지 않는다.
  sync_root_with_cwd = false,
  respect_buf_cwd = false,
  update_focused_file = {
    enable = false,
    update_root = false,
  },

  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- 기본 키맵 적용
    api.config.mappings.default_on_attach(bufnr)

    -- 추가: 현재 노드를 루트로 (하위로 내려가기 느낌)
    vim.keymap.set("n", "gr", api.tree.change_root_to_node, opts("CD to node"))

    -- 추가: 부모를 루트로 (위로)
    vim.keymap.set("n", "gR", api.tree.change_root_to_parent, opts("Up to parent"))
  end,
})

require('neogit').setup({
  integrations = { diffview = true }, -- Diffview 연동 추천
})
vim.keymap.set('n', '<leader>gg', function() require('neogit').open({ kind='replace' }) end,
  { desc='Neogit' })

require('gitsigns').setup {
  -- 사인(라인 옆 기호)
  signs = {
    add          = { text = '▎' },
    change       = { text = '▎' },
    delete       = { text = '' },
    topdelete    = { text = '' },
    changedelete = { text = '▎' },
    untracked    = { text = '┆' },
  },
  signcolumn = true,       -- 사인 열 표시
  numhl      = false,      -- 줄번호 하이라이트 (원하면 true)
  linehl     = false,      -- 라인 전체 하이라이트 (원하면 true)
  word_diff  = false,      -- 변경된 단어 단위 diff (원하면 true)

  current_line_blame = true, -- 현재 줄 blame 표시
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'eol', -- eol | overlay | right_align
    delay = 300,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> • <summary>',

  -- 프리뷰 팝업 창 모양
  preview_config = { border = 'rounded' },

  -- 성능/안전 옵션
  attach_to_untracked = true,
  max_file_length = 4000,     -- 너무 큰 파일엔 자동 비활성화
}

require('lualine').setup({
  sections = {
    lualine_b = { 'branch', 'diff', 'diagnostics' },
  }
})

require("diffview").setup({})
require('smart-splits').setup({})

-- require("nightfox").setup({
--   options = {
--     transparent = false,
--     styles = {
--       comments = "italic",
--       keywords = "bold",
--       types = "italic,bold",
--     },
--   },
--   palettes = {
--     all = {
--       red = "#ff0000",
--     },
--     nightfox = {
--       red = "#c94f6d",
--     },
--     dayfox = {
--       blue = { base = "#4d688e", bright = "#4e75aa", dim = "#485e7d" },
--     },
--     nordfox = {
--       bg1 = "#2e3440",
--
--       -- sel is different types of selection colors.
--       sel0 = "#3e4a5b", -- Popup bg, visual selection bg
--       sel1 = "#4f6074", -- Popup sel bg, search bg
--
--       -- comment is the definition of the comment color.
--       comment = "#60728a",   
--     },
--   },
--   specs = {
--     all = {
--       syntax = {
--         keyword = "magenta",
-- 	conditional = "magenta.bright",
-- 	number = "orange.dim",
--       },
--       git = {
--         changed = "#f4a261",
--       },
--     },
--     nightfox = {
--       syntax = {
--         operator = "orange",
--       },
--     },
--   },
--   groups = {
--     all = {
--       Whitespace = { link = "Comment" },
--       IncSearch = { bg = "palette.cyan" },
--     },
--     nightfox = {
--       PmenuSel = { bg = "#73daca", fg = "bg0" },
--     },
--   },
-- })
--
vim.o.background = "dark"
vim.cmd("colorscheme mellifluous")

require('im_select').setup({
  default_command = is_windows and 'im-select.exe' or 'im-select',
  default_im_select = is_windows and '1033' or 'com.apple.keylayout.ABC',
  -- 노멀/커맨드라인에서 영어로
  set_default_events = { 'VimEnter', 'InsertLeave', 'CmdlineLeave', 'FocusGained' },
  -- 인서트/커맨드라인 진입 시 직전 입력기 복원
  set_previous_events = { 'InsertEnter', 'CmdlineEnter' },
  keep_quiet_on_no_binary = true,
  async_switch_im = true,
})

require("mason").setup()

local cmp = require("cmp")

cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<M-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  }),

  sources = {
    { name = "nvim_lsp" },
  },
})

local jdtls = require("jdtls")

local root_markers = {
  ".git",
  ".project",
  "pom.xml",
  "build.gradle",
  "mvnw",
  "gradlew",
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",

  callback = function()
    local root_dir = jdtls.setup.find_root(root_markers)

    if not root_dir or root_dir == "" then
      root_dir = vim.fn.getcwd()
    end

    local project_name = vim.fn.fnamemodify(root_dir, ":t")

    local workspace_dir =
      vim.fn.stdpath("cache")
      .. "/jdtls/"
      .. project_name

    local capabilities =
      require("cmp_nvim_lsp").default_capabilities()

    local launcher = vim.fn.stdpath("data") .. "/mason/bin/"
      .. (is_windows and "jdtls.cmd" or "jdtls")
    if vim.fn.filereadable(launcher) == 0 then
      vim.notify("Java LSP: run :MasonInstall jdtls, then reopen the Java file.", vim.log.levels.WARN)
      return
    end
    local cmd = { launcher, "-data", workspace_dir }
    if is_windows then
      -- .cmd는 cmd.exe를 통해 실행하며, 공백이 있는 경로도 개별 인자로 전달한다.
      cmd = { "cmd.exe", "/c", launcher, "-data", workspace_dir }
    end

    jdtls.start_or_attach({
      cmd = cmd,

      root_dir = root_dir,
      capabilities = capabilities,
    })
  end,
})

EOF
" ==============================
" ⚙️ markdown-preview.nvim 설정
" ==============================
let g:mkdp_auto_start = 0          " 자동 실행 안 함
let g:mkdp_auto_close = 1          " 창 닫으면 미리보기 자동 종료
let g:mkdp_refresh_slow = 0
let g:mkdp_browser = ''      " mac이면 'safari' 도 가능
let g:mkdp_theme = 'dark'


" =========================
" 🔑 Keybindings (단축키)
" =========================

" 리더 키를 스페이스로 설정
let mapleader = " "

" ------------------------------
" 🔗 md 미리보기 단축키
" ------------------------------
nnoremap <leader>mp :MarkdownPreviewToggle<CR>  " 브라우저 미리보기 토글
nnoremap <leader>mg :Glow<CR>                   " 터미널 미리보기 열기

" ==============================
" ⚡ Glow 설정 (터미널 렌더링)
" ==============================
" brew install glow (macOS)
let g:glow_use_pager = 0
let g:glow_border = 'rounded'
let g:glow_style = 'dark'

" 📁 파일 탐색기
nnoremap <leader>e :NvimTreeToggle<CR>
nnoremap <leader>r :NvimTreeRefresh<CR>

" 저장 / 종료
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>bq :Bdelete<CR>
nnoremap <leader>ba :bufdo bdelete<CR>

" ───────────────────────────────────────────────
" 📋 클립보드 복사 단축키 (Space + y)
" ───────────────────────────────────────────────
nnoremap <leader>y "+y
vnoremap <leader>y "+y

" 🔍 파일/문자열 검색 (Telescope)
nnoremap <leader>ff :Telescope find_files<CR>
nnoremap <leader>fg :Telescope live_grep<CR>
nnoremap <leader>fb :Telescope buffers<CR>
nnoremap <leader>fh :Telescope help_tags<CR>

" 🔄 버퍼(탭) 이동
nnoremap <S-l> :bnext<CR>
nnoremap <S-h> :bprevious<CR>

" --- CoC 자동완성 Tab / Enter 매핑 ---
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <silent><expr> <S-TAB>
      \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" 🧩 Git
nnoremap <leader>gg :Neogit<CR>
nnoremap <leader>gd :DiffviewOpen<CR>
nnoremap <leader>gq :DiffviewClose<CR>

" 터미널 열기
nnoremap <leader>t :split<CR>:terminal<CR>
nnoremap <leader>vt :vsplit<CR>:terminal<CR>

nnoremap <silent> <leader>bd :enew <bar> bd#<CR>

" 창 크기 조절
nnoremap <M-Up>    :resize +2<CR>
nnoremap <M-Down>  :resize -2<CR>
nnoremap <M-Left>  :vertical resize -2<CR>
nnoremap <M-Right> :vertical resize +2<CR>

" 창 이동
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l


" ──────────────── smart-splits.nvim ────────────────
" 창 크기 조절 (Ctrl + 방향키)
nnoremap <C-Left>  :lua require('smart-splits').resize_left()<CR>
nnoremap <C-Right> :lua require('smart-splits').resize_right()<CR>
nnoremap <C-Up>    :lua require('smart-splits').resize_up()<CR>
nnoremap <C-Down>  :lua require('smart-splits').resize_down()<CR>

" 버퍼 스왑 (창 정렬 유지한 채 내용만 교환)
nnoremap <leader>H :lua require('smart-splits').swap_buf_left()<CR>
nnoremap <leader>L :lua require('smart-splits').swap_buf_right()<CR>
nnoremap <leader>K :lua require('smart-splits').swap_buf_up()<CR>
nnoremap <leader>J :lua require('smart-splits').swap_buf_down()<CR>

" --- Git (Gitsigns + Diffview + Neogit) ---
nnoremap <leader>gb :Gitsigns toggle_current_line_blame<CR>
nnoremap <leader>gp :Gitsigns preview_hunk<CR>
nnoremap <leader>vd :DiffviewOpen<CR>
nnoremap <leader>vq :DiffviewClose<CR>
nnoremap <leader>gg :Neogit<CR>

" --- LSP (coc.nvim 사용 중이라면) ---
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>ca <Plug>(coc-codeaction)
nmap <leader>gd <Plug>(coc-definition)
nmap <leader>gr <Plug>(coc-references)
nmap <leader>f  <Plug>(coc-format)

let g:term_follow = 0

function! ToggleTermFollow()
  if g:term_follow
    echo "터미널 자동 스크롤 OFF"
    augroup TermAutoScroll | autocmd! | augroup END
    let g:term_follow = 0
  else
    echo "터미널 자동 스크롤 ON"
    augroup TermAutoScroll
      autocmd!
      autocmd TermWrite * if bufname() =~# 'term://' | call feedkeys("G") | endif
    augroup END
    let g:term_follow = 1
  endif
endfunction

nnoremap <leader>tf :call ToggleTermFollow()<CR>

" --- 포맷팅 --- 
" --- TypeScript / TSX 전용 들여쓰기 설정 ---
autocmd FileType javascript,typescript,typescriptreact setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab

function! RunJavaCurrentFile()
  write

  let l:file = expand('%:p')
  let l:filename = expand('%:t:r')

  " macOS는 기존 작업 폴더에서 실행한다. Windows만 프로젝트 루트를 탐색한다.
  let l:dir = expand('%:p:h')
  let l:root = getcwd()
  if s:is_windows
    let l:root = l:dir
    while 1
      if isdirectory(l:dir . '/.git') || filereadable(l:dir . '/.git')
            \ || filereadable(l:dir . '/.project')
            \ || filereadable(l:dir . '/pom.xml')
            \ || filereadable(l:dir . '/build.gradle')
            \ || filereadable(l:dir . '/build.gradle.kts')
        let l:root = l:dir
        break
      endif
      if fnamemodify(l:dir, ':t') ==# 'src'
        let l:root = fnamemodify(l:dir, ':h')
        break
      endif
      let l:parent = fnamemodify(l:dir, ':h')
      if l:parent ==# l:dir
        break
      endif
      let l:dir = l:parent
    endwhile
  endif

  " package 선언 찾기
  let l:package = ''
  for l:line in getline(1, min([line('$'), 30]))
    if l:line =~# '^\s*package\s\+\S\+\s*;'
      let l:package = matchstr(l:line, 'package\s\+\zs[^;]\+')
      break
    endif
  endfor

  " 실행할 클래스명 결정
  if empty(l:package)
    let l:class = l:filename
  else
    let l:class = l:package . '.' . l:filename
  endif

  " Windows에서는 프로젝트 루트를 실행 위치로 사용한다.
  let l:cmd = 'javac -d bin ' . shellescape(l:file)
        \ . ' && java -cp bin ' . shellescape(l:class)

  belowright split
  resize 12
  if s:is_windows
    enew
    call termopen(l:cmd, {'cwd': l:root})
    startinsert
  else
    execute 'terminal ' . l:cmd
  endif
endfunction

nnoremap <F5> :call RunJavaCurrentFile()<CR>
