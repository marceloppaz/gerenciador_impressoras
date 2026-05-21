# ============================================================
#   GERENCIADOR REMOTO DE IMPRESSORAS
#   Versão 2.0
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# ============================================================
# CORES / FONTES
# ============================================================
$corFundo        = [System.Drawing.Color]::FromArgb(240, 242, 245)
$corPainel       = [System.Drawing.Color]::White
$corAzul         = [System.Drawing.Color]::FromArgb(0, 120, 215)
$corAzulHover    = [System.Drawing.Color]::FromArgb(0, 100, 190)
$corVerde        = [System.Drawing.Color]::FromArgb(16, 124, 16)
$corVerdeHover   = [System.Drawing.Color]::FromArgb(10, 100, 10)
$corVermelho     = [System.Drawing.Color]::FromArgb(196, 43, 28)
$corVermelhoHover= [System.Drawing.Color]::FromArgb(160, 30, 20)
$corCinza        = [System.Drawing.Color]::FromArgb(96, 96, 96)
$corCinzaHover   = [System.Drawing.Color]::FromArgb(70, 70, 70)
$corTexto        = [System.Drawing.Color]::FromArgb(32, 32, 32)
$corSubtexto     = [System.Drawing.Color]::FromArgb(96, 96, 96)
$corBorda        = [System.Drawing.Color]::FromArgb(210, 212, 215)
$corHeader       = [System.Drawing.Color]::FromArgb(0, 90, 160)

$fontePadrao  = New-Object System.Drawing.Font("Segoe UI", 9.5)
$fonteNegrito = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$fonteTitulo  = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$fonteSmall   = New-Object System.Drawing.Font("Segoe UI", 8.5)
$fonteConsole = New-Object System.Drawing.Font("Consolas", 8.5)

$tecnico = $env:USERNAME

# ============================================================
# HELPERS DE BOTÃO
# ============================================================
function New-ActionButton {
    param(
        [string]$Text,
        [System.Drawing.Color]$BackColor,
        [System.Drawing.Color]$HoverColor,
        [int]$Width = 140,
        [int]$Height = 32
    )
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text        = $Text
    $btn.Size        = New-Object System.Drawing.Size($Width, $Height)
    $btn.BackColor   = $BackColor
    $btn.ForeColor   = [System.Drawing.Color]::White
    $btn.FlatStyle   = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.Font        = $fonteNegrito
    $btn.Cursor      = [System.Windows.Forms.Cursors]::Hand
    # Armazena cores no Tag — acessível via $this nos eventos (funciona no PS 5.1)
    $btn.Tag = @{ Back = $BackColor; Hover = $HoverColor }
    $btn.Add_MouseEnter({ $this.BackColor = $this.Tag.Hover })
    $btn.Add_MouseLeave({ $this.BackColor = $this.Tag.Back  })
    return $btn
}

# ============================================================
# FORM PRINCIPAL
# ============================================================
$form = New-Object System.Windows.Forms.Form
$form.Text            = "Gerenciador de Impressoras"
$form.Size            = New-Object System.Drawing.Size(1000, 720)
$form.StartPosition   = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox     = $false
$form.BackColor       = $corFundo
$form.Font            = $fontePadrao

# ============================================================
# HEADER
# ============================================================
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Size      = New-Object System.Drawing.Size(1000, 58)
$pnlHeader.Location  = New-Object System.Drawing.Point(0, 0)
$pnlHeader.BackColor = $corHeader
$form.Controls.Add($pnlHeader)

$lblTitulo = New-Object System.Windows.Forms.Label
$lblTitulo.Text      = "Gerenciador de Impressoras"
$lblTitulo.Font      = $fonteTitulo
$lblTitulo.ForeColor = [System.Drawing.Color]::White
$lblTitulo.Location  = New-Object System.Drawing.Point(16, 14)
$lblTitulo.AutoSize  = $true
$pnlHeader.Controls.Add($lblTitulo)

$lblUsuario = New-Object System.Windows.Forms.Label
$lblUsuario.Text      = "Técnico: $tecnico"
$lblUsuario.Font      = $fonteSmall
$lblUsuario.ForeColor = [System.Drawing.Color]::FromArgb(180, 210, 255)
$lblUsuario.AutoSize  = $true
$lblUsuario.Location  = New-Object System.Drawing.Point(830, 22)
$pnlHeader.Controls.Add($lblUsuario)

# ============================================================
# PAINEL ESQUERDO — CAMPO PC + LISTA
# ============================================================
$pnlMain = New-Object System.Windows.Forms.Panel
$pnlMain.Size      = New-Object System.Drawing.Size(960, 600)
$pnlMain.Location  = New-Object System.Drawing.Point(20, 70)
$pnlMain.BackColor = $corPainel
$pnlMain.BorderStyle = "None"
$form.Controls.Add($pnlMain)

# --- Linha: Computador Remoto ---
$lblPC = New-Object System.Windows.Forms.Label
$lblPC.Text     = "Computador:"
$lblPC.Location = New-Object System.Drawing.Point(0, 10)
$lblPC.AutoSize = $true
$lblPC.Font     = $fonteNegrito
$lblPC.ForeColor = $corTexto
$pnlMain.Controls.Add($lblPC)

$txtPC = New-Object System.Windows.Forms.TextBox
$txtPC.Location  = New-Object System.Drawing.Point(100, 7)
$txtPC.Width     = 200
$txtPC.Font      = $fontePadrao
$pnlMain.Controls.Add($txtPC)

$btnConectar = New-ActionButton -Text "Conectar" -BackColor $corAzul -HoverColor $corAzulHover -Width 110 -Height 28
$btnConectar.Location = New-Object System.Drawing.Point(312, 7)
$pnlMain.Controls.Add($btnConectar)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text      = "Nenhum computador conectado."
$lblStatus.Location  = New-Object System.Drawing.Point(435, 12)
$lblStatus.AutoSize  = $true
$lblStatus.Font      = $fonteSmall
$lblStatus.ForeColor = $corSubtexto
$pnlMain.Controls.Add($lblStatus)

$lblComoAdicionar = New-Object System.Windows.Forms.Label
$lblComoAdicionar.Text      = "Como adicionar novos drivers?"
$lblComoAdicionar.Font      = $fonteSmall
$lblComoAdicionar.ForeColor = $corSubtexto
$lblComoAdicionar.Cursor = [System.Windows.Forms.Cursors]::Hand
$lblComoAdicionar.add_MouseEnter({ $lblComoAdicionar.ForeColor = "Blue" })
$lblComoAdicionar.add_MouseLeave({ $lblComoAdicionar.ForeColor = "Black" })
$lblComoAdicionar.AutoSize  = $true
$lblComoAdicionar.Location  = New-Object System.Drawing.Point(780, 12)
$pnlMain.Controls.Add($lblComoAdicionar)

# Evento de clique na Label
$lblComoAdicionar.Add_Click({
    $caminhoPDF = Join-Path $BasePath "Como adicionar um novo driver.pdf"
    
    if (Test-Path $caminhoPDF) {
        Start-Process $caminhoPDF
        Add-Log "PDF Aberto: $caminhoPDF"
    } else {
        [System.Windows.Forms.MessageBox]::Show("Arquivo PDF não encontrado!`n`nCertifique-se de que o arquivo PDF esteja na mesma pasta do script. ", "PDF não encontrado", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error) | Out-Null 
        Add-Log "PDF não encontrado em: $caminhoPDF"
    }
})

# --- Separador ---
$sep1 = New-Object System.Windows.Forms.Panel
$sep1.Size      = New-Object System.Drawing.Size(960, 1)
$sep1.Location  = New-Object System.Drawing.Point(0, 45)
$sep1.BackColor = $corBorda
$pnlMain.Controls.Add($sep1)

# ============================================================
# LISTVIEW DE IMPRESSORAS
# ============================================================
$listView = New-Object System.Windows.Forms.ListView
$listView.Location    = New-Object System.Drawing.Point(0, 54)
$listView.Size        = New-Object System.Drawing.Size(960, 340)
$listView.View        = [System.Windows.Forms.View]::Details
$listView.FullRowSelect = $true
$listView.GridLines   = $true
$listView.MultiSelect = $false
$listView.Font        = $fontePadrao
$listView.BackColor   = $corPainel
$listView.BorderStyle = "FixedSingle"
$listView.HideSelection = $false

$colNome   = New-Object System.Windows.Forms.ColumnHeader; $colNome.Text   = "Nome da Impressora";  $colNome.Width   = 310
$colDriver = New-Object System.Windows.Forms.ColumnHeader; $colDriver.Text = "Driver";               $colDriver.Width = 330
$colPorta  = New-Object System.Windows.Forms.ColumnHeader; $colPorta.Text  = "Porta";                $colPorta.Width  = 140
$colPadrao = New-Object System.Windows.Forms.ColumnHeader; $colPadrao.Text = "Padrão";               $colPadrao.Width = 70

$listView.Columns.AddRange(@($colNome, $colDriver, $colPorta, $colPadrao))
$pnlMain.Controls.Add($listView)

# ============================================================
# MENU LISTVIEW
# ============================================================

$ctxMenu = New-Object System.Windows.Forms.ContextMenuStrip
$ctxMenu.Font = $fontePadrao

$ctxPaginaTeste = New-Object System.Windows.Forms.ToolStripMenuItem
$ctxPaginaTeste.Text = "Imprimir Página de Teste"

$ctxRenomear = New-Object System.Windows.Forms.ToolStripMenuItem
$ctxRenomear.Text = "Renomear"

$ctxSep = New-Object System.Windows.Forms.ToolStripSeparator

$ctxExcluir = New-Object System.Windows.Forms.ToolStripMenuItem
$ctxExcluir.Text = "Excluir"
$ctxExcluir.ForeColor = $corVermelho

$ctxMenu.Items.AddRange(@($ctxPaginaTeste, $ctxRenomear, $ctxSep, $ctxExcluir))
$listView.ContextMenuStrip = $ctxMenu

# ============================================================
# BARRA DE BOTÕES DE GERENCIAMENTO
# ============================================================
$pnlBotoes = New-Object System.Windows.Forms.Panel
$pnlBotoes.Size      = New-Object System.Drawing.Size(960, 48)
$pnlBotoes.Location  = New-Object System.Drawing.Point(0, 402)
$pnlBotoes.BackColor = [System.Drawing.Color]::FromArgb(248, 249, 251)
$pnlBotoes.BorderStyle = "None"
$pnlMain.Controls.Add($pnlBotoes)

$sep2 = New-Object System.Windows.Forms.Panel
$sep2.Size      = New-Object System.Drawing.Size(960, 1)
$sep2.Location  = New-Object System.Drawing.Point(0, 0)
$sep2.BackColor = $corBorda
$pnlBotoes.Controls.Add($sep2)

$btnAdicionar    = New-ActionButton -Text "+ Adicionar" -BackColor $corVerde     -HoverColor $corVerdeHover   -Width 115 -Height 30
$btnAlterarPorta = New-ActionButton -Text "Alterar Porta" -BackColor $corCinza     -HoverColor $corCinzaHover   -Width 120 -Height 30
$btnAlterarDriver= New-ActionButton -Text "Alterar Driver" -BackColor $corCinza     -HoverColor $corCinzaHover   -Width 120 -Height 30
$btnDefinirPadrao= New-ActionButton -Text "Def. Padrao" -BackColor $corAzul      -HoverColor $corAzulHover    -Width 125 -Height 30
$btnAtualizar    = New-ActionButton -Text "Atualizar" -BackColor $corCinza     -HoverColor $corCinzaHover   -Width 95  -Height 30
$btnLimparFila   = New-ActionButton -Text "Limpar Fila" -BackColor $corVermelho  -HoverColor $corVermelhoHover -Width 110 -Height 30

$botoesGerencia = @($btnAdicionar, $btnAlterarPorta, $btnAlterarDriver, $btnDefinirPadrao, $btnAtualizar, $btnLimparFila)

$xPos = 8
foreach ($btn in $botoesGerencia) {
    $btn.Location = New-Object System.Drawing.Point($xPos, 9)
    $pnlBotoes.Controls.Add($btn)
    $xPos += $btn.Width + 6
}

# ============================================================
# LOG
# ============================================================
$sep3 = New-Object System.Windows.Forms.Panel
$sep3.Size      = New-Object System.Drawing.Size(960, 1)
$sep3.Location  = New-Object System.Drawing.Point(0, 457)
$sep3.BackColor = $corBorda
$pnlMain.Controls.Add($sep3)

$lblLog = New-Object System.Windows.Forms.Label
$lblLog.Text     = "Log de Operações"
$lblLog.Location = New-Object System.Drawing.Point(0, 463)
$lblLog.AutoSize = $true
$lblLog.Font     = $fonteNegrito
$lblLog.ForeColor = $corSubtexto
$pnlMain.Controls.Add($lblLog)

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline    = $true
$txtLog.ScrollBars   = "Vertical"
$txtLog.Location     = New-Object System.Drawing.Point(0, 485)
$txtLog.Size         = New-Object System.Drawing.Size(960, 110)
$txtLog.ReadOnly     = $true
$txtLog.BackColor    = [System.Drawing.Color]::FromArgb(22, 22, 22)
$txtLog.ForeColor    = [System.Drawing.Color]::FromArgb(180, 255, 160)
$txtLog.Font         = $fonteConsole
$txtLog.BorderStyle  = "None"
$pnlMain.Controls.Add($txtLog)

# ============================================================
# FUNÇÕES AUXILIARES
# ============================================================
function Add-Log($msg) {
    $hora = Get-Date -Format "HH:mm:ss"
    $txtLog.AppendText("[$hora] $msg`r`n")
    $txtLog.ScrollToCaret()
}

function Get-SelectedPrinterName {
    if ($listView.SelectedItems.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "Selecione uma impressora na lista primeiro.",
            "Aviso",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return $null
    }
    return $listView.SelectedItems[0].Text
}

$script:SessionAtiva = $null

function Get-RemoteSession {
    param([string]$ComputerName)
    try {
        Add-Log "Testando conectividade com $ComputerName..."
        if (!(Test-Connection $ComputerName -Count 1 -Quiet)) {
            throw "Computador não responde na rede."
        }
        Add-Log "Verificando WinRM em $ComputerName..."
        $wsman = Test-WsMan $ComputerName -ErrorAction SilentlyContinue
        if (-not $wsman) {
            Add-Log "WinRM não ativo. Tentando habilitar via PsExec..."
            $PsExec = Join-Path $PSScriptRoot "PsExec.exe"
            if (!(Test-Path $PsExec)) { throw "PsExec.exe não encontrado na pasta do script." }
            & $PsExec -accepteula \\$ComputerName -s powershell -Command "Enable-PSRemoting -Force" | Out-Null
            $tentativas = 0
            do {
                Start-Sleep 2; $tentativas++
                $wsman = Test-WsMan $ComputerName -ErrorAction SilentlyContinue
                if ($wsman) { break }
                Add-Log "Aguardando WinRM... tentativa $tentativas"
            } while ($tentativas -lt 15)
            if (-not $wsman) { throw "WinRM não respondeu após habilitação." }
            Add-Log "WinRM habilitado com sucesso."
        } else {
            Add-Log "WinRM OK."
        }
        Add-Log "Criando sessão remota..."
        $tentativas = 0; $Session = $null
        do {
            try   { $Session = New-PSSession -ComputerName $ComputerName -ErrorAction Stop }
            catch { Start-Sleep 2; $tentativas++; Add-Log "Tentativa $tentativas de criar sessão..." }
        } while (-not $Session -and $tentativas -lt 5)
        if (-not $Session) { throw "Não foi possível criar sessão remota." }
        Add-Log "Sessão remota estabelecida."
        return $Session
    }
    catch {
        Add-Log "ERRO ao conectar: $_"
        return $null
    }
}

function Atualizar-Lista {
    $listView.Items.Clear()
    $ComputerName = $txtPC.Text.Trim()
    if (-not $ComputerName) { return }
    if (-not $script:SessionAtiva) { return }
    try {
        Add-Log "Carregando impressoras de $ComputerName..."
        $printers = Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
            $default = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows" -ErrorAction SilentlyContinue).Device
            $defaultName = if ($default) { ($default -split ",")[0] } else { "" }
            Get-Printer | Select-Object Name, DriverName, PortName | ForEach-Object {
                [PSCustomObject]@{
                    Name       = $_.Name
                    DriverName = $_.DriverName
                    PortName   = $_.PortName
                    IsDefault  = ($_.Name -eq $defaultName)
                }
            }
        }
        foreach ($p in $printers) {
            $item = New-Object System.Windows.Forms.ListViewItem($p.Name)
            $item.SubItems.Add($p.DriverName) | Out-Null
            $item.SubItems.Add($p.PortName)   | Out-Null
            $item.SubItems.Add($(if ($p.IsDefault) { "✔" } else { "" })) | Out-Null
            if ($p.IsDefault) {
                $item.Font = $fonteNegrito
                $item.ForeColor = $corVerde
            }
            $listView.Items.Add($item) | Out-Null
        }
        $count = $listView.Items.Count
        $lblStatus.Text = "✔  $ComputerName — $count impressora(s) encontrada(s)"
        $lblStatus.ForeColor = $corVerde
        Add-Log "$count impressora(s) carregada(s) de $ComputerName."
    }
    catch {
        Add-Log "ERRO ao listar impressoras: $_"
    }
}

# ============================================================
# CARREGAR DRIVERS JSON
# ============================================================
if ($PSScriptRoot) { $BasePath = $PSScriptRoot }
else { $BasePath = Split-Path -Parent ([System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName) }

$DriversPath = Join-Path $BasePath "drivers.json"
$Drivers = @()
if (Test-Path $DriversPath) {
    $Drivers = Get-Content $DriversPath -Raw | ConvertFrom-Json
    Add-Log "drivers.json carregado — $($Drivers.Count) drivers disponíveis."
} else {
    Add-Log "AVISO: drivers.json não encontrado. Instalação por JSON desabilitada."
}

# ============================================================
# EVENTO: CONECTAR
# ============================================================
$btnConectar.Add_Click({
    $ComputerName = $txtPC.Text.Trim()
    if (-not $ComputerName) {
        [System.Windows.Forms.MessageBox]::Show("Informe o nome do computador.", "Aviso",
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }
    if ($script:SessionAtiva) {
        try { Remove-PSSession $script:SessionAtiva -ErrorAction SilentlyContinue } catch {}
        $script:SessionAtiva = $null
    }
    $listView.Items.Clear()
    $lblStatus.Text = "Conectando a $ComputerName..."
    $lblStatus.ForeColor = $corSubtexto
    $form.Refresh()
    $script:SessionAtiva = Get-RemoteSession $ComputerName
    if ($script:SessionAtiva) {
        Atualizar-Lista
    } else {
        $lblStatus.Text = "✕  Falha ao conectar a $ComputerName."
        $lblStatus.ForeColor = $corVermelho
    }
})

# Enter no campo de PC também conecta
$txtPC.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Return) { $btnConectar.PerformClick() }
})

# ============================================================
# EVENTO: ATUALIZAR LISTA
# ============================================================
$btnAtualizar.Add_Click({
    if (-not $script:SessionAtiva) {
        [System.Windows.Forms.MessageBox]::Show("Conecte a um computador primeiro.", "Aviso",
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }
    Atualizar-Lista
})

# ============================================================
# EVENTO: RENOMEAR
# ============================================================

$ctxRenomear.Add_Click({
    $NomeAtual = Get-SelectedPrinterName
    if (-not $NomeAtual) { return }

    $fRenomear = New-Object System.Windows.Forms.Form
    $fRenomear.Text            = "Renomear Impressora"
    $fRenomear.Size            = New-Object System.Drawing.Size(400, 160)
    $fRenomear.StartPosition   = "CenterParent"
    $fRenomear.FormBorderStyle = "FixedDialog"
    $fRenomear.MaximizeBox     = $false; $fRenomear.MinimizeBox = $false
    $fRenomear.BackColor       = $corFundo; $fRenomear.Font = $fontePadrao

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Text = "Novo nome:"; $lbl.Location = New-Object System.Drawing.Point(20, 20); $lbl.AutoSize = $true
    $fRenomear.Controls.Add($lbl)

    $txtNovo = New-Object System.Windows.Forms.TextBox
    $txtNovo.Text = $NomeAtual; $txtNovo.Location = New-Object System.Drawing.Point(20, 42); $txtNovo.Width = 345
    $fRenomear.Controls.Add($txtNovo)

    $btnOK = New-ActionButton -Text "Confirmar" -BackColor $corAzul -HoverColor $corAzulHover -Width 100 -Height 28
    $btnOK.Location = New-Object System.Drawing.Point(140, 82)
    $fRenomear.Controls.Add($btnOK)
    $fRenomear.AcceptButton = $btnOK

    $btnOK.Add_Click({
        $NovoNome = $txtNovo.Text.Trim()
        if (-not $NovoNome -or $NovoNome -eq $NomeAtual) { $fRenomear.Close(); return }
        try {
            Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                param($Old, $New) Rename-Printer -Name $Old -NewName $New
            } -ArgumentList $NomeAtual, $NovoNome
            Add-Log "Impressora renomeada: '$NomeAtual' → '$NovoNome'"
            $fRenomear.Close()
            Atualizar-Lista
        }
        catch { Add-Log "ERRO ao renomear: $_"; [System.Windows.Forms.MessageBox]::Show("Erro ao renomear: $_") | Out-Null }
    })

    $fRenomear.ShowDialog($form) | Out-Null
})


# ============================================================
# EVENTO: PAGINA TESTE
# ============================================================

$ctxPaginaTeste.Add_Click({

     $PrinterName = Get-SelectedPrinterName
     if (-not $PrinterName) { return }
     $resp = [System.Windows.Forms.MessageBox]::Show("Enviar página de teste na impressora $PrinterName ?" , "Teste de Impressão",
                [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
     if ($resp -eq [System.Windows.Forms.DialogResult]::Yes) {
                Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                    param($PName, $tec)
                    $tempPath = "C:\Temp"
                    $f = Join-Path $tempPath "teste_impressao.txt"

                    if (-not (Test-Path $tempPath)) {
                        New-Item -Path $tempPath -ItemType Directory -Force | Out-Null
                    }

                    "Teste de impressão em $((Get-Date).ToString('dd/MM/yyyy HH:mm')) — Técnico: $tec" | Out-File $f -Encoding utf8
                    Get-Content $f | Out-Printer -Name $PName

                    Start-Sleep -Seconds 2

                } -ArgumentList $PrinterName, $tecnico

                Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                    Remove-Item "C:\Temp\" -Recurse -Force -ErrorAction SilentlyContinue
                }

                Add-Log "Página de teste enviada."
                Add-Log "Pasta temporaria limpa."
            }
            Atualizar-Lista
})

# ============================================================
# EVENTO: ALTERAR PORTA
# ============================================================
$btnAlterarPorta.Add_Click({
    $PrinterName = Get-SelectedPrinterName
    if (-not $PrinterName) { return }

    $fPorta = New-Object System.Windows.Forms.Form
    $fPorta.Text          = "Alterar Porta — $PrinterName"
    $fPorta.Size          = New-Object System.Drawing.Size(440, 230)
    $fPorta.StartPosition = "CenterParent"
    $fPorta.FormBorderStyle = "FixedDialog"
    $fPorta.MaximizeBox   = $false; $fPorta.MinimizeBox = $false
    $fPorta.BackColor     = $corFundo; $fPorta.Font = $fontePadrao

    $rbExistente = New-Object System.Windows.Forms.RadioButton
    $rbExistente.Text     = "Porta existente:"
    $rbExistente.Location = New-Object System.Drawing.Point(20, 18)
    $rbExistente.AutoSize = $true; $rbExistente.Checked = $true
    $fPorta.Controls.Add($rbExistente)

    $cbPortas = New-Object System.Windows.Forms.ComboBox
    $cbPortas.Location     = New-Object System.Drawing.Point(20, 42)
    $cbPortas.Width        = 390
    $cbPortas.DropDownStyle = "DropDownList"
    $fPorta.Controls.Add($cbPortas)

    # Carregar portas disponíveis
    try {
        $portas = Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
            Get-PrinterPort | Select-Object -ExpandProperty Name
        }
        foreach ($p in $portas) { $cbPortas.Items.Add($p) | Out-Null }
        if ($cbPortas.Items.Count -gt 0) { $cbPortas.SelectedIndex = 0 }
    } catch { Add-Log "Aviso: não foi possível listar portas existentes." }

    $rbNovo = New-Object System.Windows.Forms.RadioButton
    $rbNovo.Text     = "Novo IP:"
    $rbNovo.Location = New-Object System.Drawing.Point(20, 90)
    $rbNovo.AutoSize = $true
    $fPorta.Controls.Add($rbNovo)

    $txtNovoIP = New-Object System.Windows.Forms.TextBox
    $txtNovoIP.Location    = New-Object System.Drawing.Point(20, 114)
    $txtNovoIP.Width       = 390
    $txtNovoIP.Text = "Ex: 192.168.0.100"
    $txtNovoIP.ForeColor = [System.Drawing.Color]::Gray
    $txtNovoIP.Add_Enter({ if ($txtNovoIP.Text -eq "Ex: 192.168.0.100") { $txtNovoIP.Text = ""; $txtNovoIP.ForeColor = [System.Drawing.Color]::Black } })
    $txtNovoIP.Add_Leave({ if ($txtNovoIP.Text -eq "") { $txtNovoIP.Text = "Ex: 192.168.0.100"; $txtNovoIP.ForeColor = [System.Drawing.Color]::Gray } })
    $txtNovoIP.Enabled     = $false
    $fPorta.Controls.Add($txtNovoIP)

    $rbExistente.Add_CheckedChanged({ $cbPortas.Enabled = $rbExistente.Checked; $txtNovoIP.Enabled = $rbNovo.Checked })
    $rbNovo.Add_CheckedChanged({      $cbPortas.Enabled = $rbExistente.Checked; $txtNovoIP.Enabled = $rbNovo.Checked })

    $btnOK = New-ActionButton -Text "Aplicar" -BackColor $corAzul -HoverColor $corAzulHover -Width 100 -Height 28
    $btnOK.Location = New-Object System.Drawing.Point(160, 155)
    $fPorta.Controls.Add($btnOK)
    $fPorta.AcceptButton = $btnOK

    $btnOK.Add_Click({
        try {
            if ($rbNovo.Checked) {
                $IP = $txtNovoIP.Text.Trim()
                if (-not $IP) { [System.Windows.Forms.MessageBox]::Show("Informe o IP.") | Out-Null; return }
                $PortName = "IP_$IP"
                Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                    param($PortName, $IP)
                    if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)) {
                        Add-PrinterPort -Name $PortName -PrinterHostAddress $IP
                    }
                    Set-Printer -Name $using:PrinterName -PortName $PortName
                } -ArgumentList $PortName, $IP
                Add-Log "Porta da impressora '$PrinterName' alterada para $PortName ($IP)."
            } else {
                $PortaSel = $cbPortas.SelectedItem
                Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                    param($PName, $Port)
                    Set-Printer -Name $PName -PortName $Port
                } -ArgumentList $PrinterName, $PortaSel
                Add-Log "Porta da impressora '$PrinterName' alterada para '$PortaSel'."
            }
            $fPorta.Close()
            Atualizar-Lista
        }
        catch { Add-Log "ERRO ao alterar porta: $_"; [System.Windows.Forms.MessageBox]::Show("Erro: $_") | Out-Null }
    })

    $fPorta.ShowDialog($form) | Out-Null
})

# ============================================================
# EVENTO: ALTERAR DRIVER
# ============================================================
$btnAlterarDriver.Add_Click({
    $PrinterName = Get-SelectedPrinterName
    if (-not $PrinterName) { return }

    $fDriver = New-Object System.Windows.Forms.Form
    $fDriver.Text            = "Alterar Driver — $PrinterName"
    $fDriver.Size            = New-Object System.Drawing.Size(500, 370)
    $fDriver.StartPosition   = "CenterParent"
    $fDriver.FormBorderStyle = "FixedDialog"
    $fDriver.MaximizeBox     = $false; $fDriver.MinimizeBox = $false
    $fDriver.BackColor       = $corFundo; $fDriver.Font = $fontePadrao

    # ── Opção 1: JSON ──────────────────────────────────────────
    $rbJSON = New-Object System.Windows.Forms.RadioButton
    $rbJSON.Text = "Usar driver do JSON:"; $rbJSON.Location = New-Object System.Drawing.Point(20, 18)
    $rbJSON.AutoSize = $true; $rbJSON.Checked = $true
    $fDriver.Controls.Add($rbJSON)

    $lblMarca = New-Object System.Windows.Forms.Label
    $lblMarca.Text = "Marca:"; $lblMarca.Location = New-Object System.Drawing.Point(20, 50); $lblMarca.AutoSize = $true
    $fDriver.Controls.Add($lblMarca)

    $cbMarca = New-Object System.Windows.Forms.ComboBox
    $cbMarca.Location = New-Object System.Drawing.Point(90, 47); $cbMarca.Width = 180
    $cbMarca.DropDownStyle = "DropDownList"
    if ($Drivers.Count -gt 0) {
        $Drivers | Select-Object -ExpandProperty Marca -Unique | ForEach-Object { $cbMarca.Items.Add($_) | Out-Null }
    }
    $fDriver.Controls.Add($cbMarca)

    $lblModelo = New-Object System.Windows.Forms.Label
    $lblModelo.Text = "Modelo:"; $lblModelo.Location = New-Object System.Drawing.Point(20, 90); $lblModelo.AutoSize = $true
    $fDriver.Controls.Add($lblModelo)

    $cbModelo = New-Object System.Windows.Forms.ComboBox
    $cbModelo.Location = New-Object System.Drawing.Point(90, 87); $cbModelo.Width = 370
    $cbModelo.DropDownStyle = "DropDownList"
    $fDriver.Controls.Add($cbModelo)

    $cbMarca.Add_SelectedIndexChanged({
        $cbModelo.Items.Clear()
        $Drivers | Where-Object { $_.Marca -eq $cbMarca.SelectedItem } | ForEach-Object { $cbModelo.Items.Add($_.Modelo) | Out-Null }
    })

    # ── Separador ─────────────────────────────────────────────
    $sep = New-Object System.Windows.Forms.Panel
    $sep.Size = New-Object System.Drawing.Size(456, 1); $sep.Location = New-Object System.Drawing.Point(20, 132)
    $sep.BackColor = $corBorda
    $fDriver.Controls.Add($sep)

    # ── Opção 2: .inf manual ───────────────────────────────────
    $rbManual = New-Object System.Windows.Forms.RadioButton
    $rbManual.Text = "Selecionar .inf manualmente:"; $rbManual.Location = New-Object System.Drawing.Point(20, 145)
    $rbManual.AutoSize = $true
    $fDriver.Controls.Add($rbManual)

    $txtInfPath = New-Object System.Windows.Forms.TextBox
    $txtInfPath.Location = New-Object System.Drawing.Point(20, 172); $txtInfPath.Width = 370
    $txtInfPath.Enabled = $false
    $fDriver.Controls.Add($txtInfPath)

    $btnBrowse = New-ActionButton -Text "..." -BackColor $corCinza -HoverColor $corCinzaHover -Width 60 -Height 26
    $btnBrowse.Location = New-Object System.Drawing.Point(397, 171); $btnBrowse.Enabled = $false
    $fDriver.Controls.Add($btnBrowse)

    $lblDrv = New-Object System.Windows.Forms.Label
    $lblDrv.Text = "Driver disponível:"; $lblDrv.Location = New-Object System.Drawing.Point(20, 210); $lblDrv.AutoSize = $true
    $fDriver.Controls.Add($lblDrv)

    $cbDrivers = New-Object System.Windows.Forms.ComboBox
    $cbDrivers.Location = New-Object System.Drawing.Point(20, 230); $cbDrivers.Width = 437
    $cbDrivers.DropDownStyle = "DropDownList"; $cbDrivers.Enabled = $false
    $fDriver.Controls.Add($cbDrivers)

    # ── Habilita/desabilita campos conforme seleção ────────────
    $rbJSON.Add_CheckedChanged({
        $cbMarca.Enabled  = $true;  $cbModelo.Enabled  = $true
        $txtInfPath.Enabled = $false; $btnBrowse.Enabled = $false; $cbDrivers.Enabled = $false
    })
    $rbManual.Add_CheckedChanged({
        $cbMarca.Enabled  = $false; $cbModelo.Enabled  = $false
        $txtInfPath.Enabled = $true;  $btnBrowse.Enabled = $true
        # cbDrivers só habilita após carregar o .inf
    })

    # ── Browse: lê DriverNames do .inf ────────────────────────
    $btnBrowse.Add_Click({
        $dlg = New-Object System.Windows.Forms.OpenFileDialog
        $dlg.Filter = "Arquivo INF (*.inf)|*.inf"
        $dlg.Title  = "Selecionar arquivo de driver"
        if ($dlg.ShowDialog() -ne "OK") { return }

        $txtInfPath.Text = $dlg.FileName
        $cbDrivers.Items.Clear()

        try {
            $infContent = Get-Content $dlg.FileName -Encoding Default -ErrorAction Stop

            # 1. Descobre quais seções são de modelos lendo [Manufacturer]
            $secaoAtual   = ""
            $secaoModelos = @()
            foreach ($linha in $infContent) {
                $linha = $linha.Trim()
                if ($linha -match '^\[(.+)\]$') { $secaoAtual = $matches[1]; continue }
                if ($secaoAtual -ieq "Manufacturer" -and $linha -match '=\s*(.+)') {
                    $matches[1] -split ',' | ForEach-Object {
                        $s = $_.Trim()
                        if ($s) { $secaoModelos += $s }
                    }
                }
            }

            # 2. Extrai só os DriverNames (texto entre aspas antes do "=") nessas seções
            $drivers  = @()
            $emModelo = $false
            foreach ($linha in $infContent) {
                $linha = $linha.Trim()
                if ($linha -match '^\[(.+)\]$') {
                    $secNome  = $matches[1]
                    $emModelo = $secaoModelos | Where-Object { $secNome -ilike "$_*" }
                    continue
                }
                if ($emModelo -and $linha -match '^"([^"]+)"\s*=') {
                    $nome = $matches[1].Trim()
                    if ($nome -and $drivers -notcontains $nome) { $drivers += $nome }
                }
            }

            if ($drivers.Count -eq 0) {
                [System.Windows.Forms.MessageBox]::Show(
                    "Nenhum driver encontrado neste .inf.",
                    "Aviso", [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
                return
            }

            foreach ($d in ($drivers | Sort-Object)) { $cbDrivers.Items.Add($d) | Out-Null }
            $cbDrivers.SelectedIndex = 0
            $cbDrivers.Enabled = $true

        } catch {
            [System.Windows.Forms.MessageBox]::Show("Erro ao ler o arquivo .inf:`n$_") | Out-Null
        }
    })

    # ── Botão Aplicar ──────────────────────────────────────────
    $btnOK = New-ActionButton -Text "Aplicar Driver" -BackColor $corAzul -HoverColor $corAzulHover -Width 130 -Height 28
    $btnOK.Location = New-Object System.Drawing.Point(180, 295)
    $fDriver.Controls.Add($btnOK)
    $fDriver.AcceptButton = $btnOK

    $btnOK.Add_Click({
        try {
            if ($rbJSON.Checked) {
                # ── Fluxo JSON ──
                if (-not $cbModelo.SelectedItem) { [System.Windows.Forms.MessageBox]::Show("Selecione o modelo.") | Out-Null; return }
                $driverInfo = $Drivers | Where-Object { $_.Marca -eq $cbMarca.SelectedItem -and $_.Modelo -eq $cbModelo.SelectedItem }
                $DriverName = $driverInfo.DriverName
                $DriverPath = $driverInfo.Caminho
                if (!(Test-Path $DriverPath)) { [System.Windows.Forms.MessageBox]::Show("Caminho do driver não encontrado:`n$DriverPath") | Out-Null; return }

                Add-Log "Copiando driver '$DriverName' para $($txtPC.Text.Trim())..."
                Invoke-Command -Session $script:SessionAtiva -ScriptBlock { New-Item "C:\Temp\DriverTemp" -ItemType Directory -Force | Out-Null }
                Copy-Item "$DriverPath\*" -Destination "C:\Temp\DriverTemp" -Recurse -ToSession $script:SessionAtiva -Force

                Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                    param($PName, $DName)
                    pnputil /add-driver "C:\Temp\DriverTemp\*.inf" /install | Out-Null
                    if (-not (Get-PrinterDriver -Name $DName -ErrorAction SilentlyContinue)) { Add-PrinterDriver -Name $DName }
                    Set-Printer -Name $PName -DriverName $DName
                } -ArgumentList $PrinterName, $DriverName

                Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                    Remove-Item "C:\Temp\DriverTemp" -Recurse -Force -ErrorAction SilentlyContinue
                }
                Add-Log "Driver da impressora '$PrinterName' alterado para '$DriverName' (JSON)."
                Add-Log "Pasta temporaria limpa."

            } else {
                # ── Fluxo .inf manual ──
                if (-not $txtInfPath.Text -or -not (Test-Path $txtInfPath.Text)) { [System.Windows.Forms.MessageBox]::Show("Selecione um arquivo .inf válido.") | Out-Null; return }
                if (-not $cbDrivers.SelectedItem) { [System.Windows.Forms.MessageBox]::Show("Selecione um driver da lista.") | Out-Null; return }

                $DriverName = $cbDrivers.SelectedItem.ToString()
                $InfFolder  = Split-Path $txtInfPath.Text -Parent

                Add-Log "Copiando driver '$DriverName' para $($txtPC.Text.Trim())..."
                Invoke-Command -Session $script:SessionAtiva -ScriptBlock { New-Item "C:\Temp\DriverTemp" -ItemType Directory -Force | Out-Null }
                Copy-Item "$InfFolder\*" -Destination "C:\Temp\DriverTemp" -Recurse -ToSession $script:SessionAtiva -Force

                Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                    param($PName, $DName)
                    pnputil /add-driver "C:\Temp\DriverTemp\*.inf" /install | Out-Null
                    if (-not (Get-PrinterDriver -Name $DName -ErrorAction SilentlyContinue)) { Add-PrinterDriver -Name $DName }
                    Set-Printer -Name $PName -DriverName $DName
                } -ArgumentList $PrinterName, $DriverName

                Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                    Remove-Item "C:\Temp\DriverTemp" -Recurse -Force -ErrorAction SilentlyContinue
                }
                Add-Log "Driver da impressora '$PrinterName' alterado para '$DriverName' (.inf manual)."
                Add-Log "Pasta temporaria limpa."
            }

            [System.Windows.Forms.MessageBox]::Show(
                "Driver alterado com sucesso!", "OK",
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
            $fDriver.Close()
            Atualizar-Lista
        }
        catch { Add-Log "ERRO ao alterar driver: $_"; [System.Windows.Forms.MessageBox]::Show("Erro: $_") | Out-Null }
    })

    $fDriver.ShowDialog($form) | Out-Null
})

# ============================================================
# EVENTO: DEFINIR COMO PADRÃO
# ============================================================
$btnDefinirPadrao.Add_Click({
    $PrinterName = Get-SelectedPrinterName
    if (-not $PrinterName) { return }
    try {
        Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
            param($PName)
            (New-Object -ComObject WScript.Network).SetDefaultPrinter($PName)
        } -ArgumentList $PrinterName
        Add-Log "Impressora padrão definida: '$PrinterName'."
        Atualizar-Lista
    }
    catch { Add-Log "ERRO ao definir padrão: $_"; [System.Windows.Forms.MessageBox]::Show("Erro: $_") | Out-Null }
})

# ============================================================
# EVENTO: EXCLUIR
# ============================================================
$ctxExcluir.Add_Click({
    $PrinterName = Get-SelectedPrinterName
    if (-not $PrinterName) { return }
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Deseja realmente excluir a impressora:`n`n'$PrinterName'?",
        "Confirmar Exclusão",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }
    try {
        Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
            param($PName) Remove-Printer -Name $PName -Confirm:$false
        } -ArgumentList $PrinterName
        Add-Log "Impressora '$PrinterName' excluída."
        Atualizar-Lista
    }
    catch { Add-Log "ERRO ao excluir impressora: $_"; [System.Windows.Forms.MessageBox]::Show("Erro: $_") | Out-Null }
})

# ============================================================
# EVENTO: LIMPAR FILA DE IMPRESSÃO
# ============================================================
$btnLimparFila.Add_Click({
    if (-not $script:SessionAtiva) {
        [System.Windows.Forms.MessageBox]::Show("Conecte a um computador primeiro.", "Aviso",
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }
    $confirm = [System.Windows.Forms.MessageBox]::Show(
        "Isso vai parar o Spooler e limpar a fila de TODAS as impressoras em $($txtPC.Text.Trim()).`n`nDeseja continuar?",
        "Limpar Fila Geral",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) { return }
    try {
        Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
            Stop-Service -Name Spooler -Force
            Get-ChildItem "C:\Windows\System32\spool\PRINTERS" -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Start-Service -Name Spooler
        }
        Add-Log "Fila geral limpa em '$($txtPC.Text.Trim())' (spooler reiniciado)."
        [System.Windows.Forms.MessageBox]::Show("Fila de todas as impressoras limpa com sucesso.", "OK",
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null
    }
    catch { Add-Log "ERRO ao limpar fila: $_"; [System.Windows.Forms.MessageBox]::Show("Erro: $_") | Out-Null }
})

# ============================================================
# EVENTO: ADICIONAR IMPRESSORA (janela de instalação)
# ============================================================
$btnAdicionar.Add_Click({
    if (-not $script:SessionAtiva) {
        [System.Windows.Forms.MessageBox]::Show("Conecte a um computador antes de adicionar uma impressora.", "Aviso",
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
        return
    }

    $fAdd = New-Object System.Windows.Forms.Form
    $fAdd.Text          = "Adicionar Impressora — $($txtPC.Text.Trim())"
    $fAdd.Size          = New-Object System.Drawing.Size(520, 520)
    $fAdd.StartPosition = "CenterParent"
    $fAdd.FormBorderStyle = "FixedDialog"
    $fAdd.MaximizeBox   = $false; $fAdd.MinimizeBox = $false
    $fAdd.BackColor     = $corFundo; $fAdd.Font = $fontePadrao

    $pnlAdd = New-Object System.Windows.Forms.Panel
    $pnlAdd.Size = New-Object System.Drawing.Size(480, 460); $pnlAdd.Location = New-Object System.Drawing.Point(18,18)
    $pnlAdd.BackColor = $corPainel
    $fAdd.Controls.Add($pnlAdd)

    $yA = 16

    function AddLabel($texto) {
        $l = New-Object System.Windows.Forms.Label
        $l.Text = $texto; $l.Location = New-Object System.Drawing.Point(16, $yA); $l.AutoSize = $true
        $l.Font = $fonteNegrito; $l.ForeColor = $corTexto
        $pnlAdd.Controls.Add($l)
        return $l
    }
    function AddTextbox($valor = "") {
        $t = New-Object System.Windows.Forms.TextBox
        $t.Location = New-Object System.Drawing.Point(180, $yA); $t.Width = 274; $t.Text = $valor
        $pnlAdd.Controls.Add($t)
        return $t
    }

    AddLabel "Marca:" | Out-Null
    $cbAddMarca = New-Object System.Windows.Forms.ComboBox
    $cbAddMarca.Location = New-Object System.Drawing.Point(180, $yA); $cbAddMarca.Width = 274
    $cbAddMarca.DropDownStyle = "DropDownList"
    if ($Drivers.Count -gt 0) { $Drivers | Select-Object -ExpandProperty Marca -Unique | ForEach-Object { $cbAddMarca.Items.Add($_) | Out-Null } }
    $pnlAdd.Controls.Add($cbAddMarca)
    $yA += 42

    AddLabel "Modelo:" | Out-Null
    $cbAddModelo = New-Object System.Windows.Forms.ComboBox
    $cbAddModelo.Location = New-Object System.Drawing.Point(180, $yA); $cbAddModelo.Width = 274
    $cbAddModelo.DropDownStyle = "DropDownList"
    $pnlAdd.Controls.Add($cbAddModelo)
    $yA += 52

    $cbAddMarca.Add_SelectedIndexChanged({
        $cbAddModelo.Items.Clear()
        $Drivers | Where-Object { $_.Marca -eq $cbAddMarca.SelectedItem } | ForEach-Object { $cbAddModelo.Items.Add($_.Modelo) | Out-Null }
    })

    # Grupo conexão
    $grpConn = New-Object System.Windows.Forms.GroupBox
    $grpConn.Text = "Tipo de Conexão"; $grpConn.Location = New-Object System.Drawing.Point(16, $yA)
    $grpConn.Size = New-Object System.Drawing.Size(446, 70); $grpConn.Font = $fontePadrao
    $pnlAdd.Controls.Add($grpConn)

    $rbAddRede = New-Object System.Windows.Forms.RadioButton
    $rbAddRede.Text = "Rede (TCP/IP)"; $rbAddRede.Location = New-Object System.Drawing.Point(30, 28); $rbAddRede.AutoSize = $true
    $grpConn.Controls.Add($rbAddRede)

    $rbAddUSB = New-Object System.Windows.Forms.RadioButton
    $rbAddUSB.Text = "USB"; $rbAddUSB.Location = New-Object System.Drawing.Point(220, 28); $rbAddUSB.AutoSize = $true
    $grpConn.Controls.Add($rbAddUSB)
    $yA += 86

    AddLabel "IP da Impressora:" | Out-Null
    $txtAddIP = AddTextbox
    $lblAddIP = $pnlAdd.Controls[$pnlAdd.Controls.Count - 2]
    $lblAddIP.Enabled = $false; $txtAddIP.Enabled = $false
    $txtAddIP.BackColor = [System.Drawing.Color]::FromArgb(230,230,230)
    $yA += 42

    AddLabel "Nome da Impressora:" | Out-Null
    $txtAddNome = AddTextbox
    $yA += 42

    # Porta USB
    AddLabel "Porta USB:" | Out-Null
    $cbAddUSBPort = New-Object System.Windows.Forms.ComboBox
    $cbAddUSBPort.Location = New-Object System.Drawing.Point(180, $yA); $cbAddUSBPort.Width = 200
    $cbAddUSBPort.DropDownStyle = "DropDownList"; $cbAddUSBPort.Enabled = $false
    $pnlAdd.Controls.Add($cbAddUSBPort)

    $btnDetUSB = New-ActionButton -Text "Detectar" -BackColor $corCinza -HoverColor $corCinzaHover -Width 68 -Height 26
    $btnDetUSB.Location = New-Object System.Drawing.Point(390, $yA); $btnDetUSB.Enabled = $false
    $pnlAdd.Controls.Add($btnDetUSB)
    $yA += 52

    $rbAddRede.Add_CheckedChanged({
        $txtAddIP.Enabled = $true; $txtAddIP.BackColor = "White"; $lblAddIP.Enabled = $true
        $cbAddUSBPort.Enabled = $false; $btnDetUSB.Enabled = $false
    })
    $rbAddUSB.Add_CheckedChanged({
        $txtAddIP.Enabled = $false; $txtAddIP.BackColor = [System.Drawing.Color]::FromArgb(230,230,230); $lblAddIP.Enabled = $false
        $cbAddUSBPort.Enabled = $true; $btnDetUSB.Enabled = $true
    })

    $btnDetUSB.Add_Click({
        $cbAddUSBPort.Items.Clear()
        try {
            $UsbPorts = Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                Get-PrinterPort | Where-Object { $_.Name -match "^USB\d+" }
            }
            foreach ($p in $UsbPorts) {
                $label = if ($p.Description) { "$($p.Name) - $($p.Description)" } else { $p.Name }
                $cbAddUSBPort.Items.Add($label) | Out-Null
            }
            if ($cbAddUSBPort.Items.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("Nenhuma porta USB encontrada.") | Out-Null }
        } catch { Add-Log "ERRO ao detectar USB: $_" }
    })

    $txtLog2 = New-Object System.Windows.Forms.TextBox
    $txtLog2.Multiline = $true; $txtLog2.ScrollBars = "Vertical"
    $txtLog2.Location = New-Object System.Drawing.Point(16, $yA); $txtLog2.Size = New-Object System.Drawing.Size(446, 80)
    $txtLog2.ReadOnly = $true; $txtLog2.Font = $fonteConsole
    $txtLog2.BackColor = [System.Drawing.Color]::FromArgb(22,22,22); $txtLog2.ForeColor = [System.Drawing.Color]::FromArgb(180,255,160)
    $pnlAdd.Controls.Add($txtLog2)
    $yA += 90

    $btnInstalarAdd = New-ActionButton -Text "Instalar Impressora" -BackColor $corVerde -HoverColor $corVerdeHover -Width 180 -Height 34
    $btnInstalarAdd.Location = New-Object System.Drawing.Point(150, $yA)
    $pnlAdd.Controls.Add($btnInstalarAdd)

    function LogAdd($msg) { $txtLog2.AppendText("$msg`r`n"); $txtLog2.ScrollToCaret() }

    $btnInstalarAdd.Add_Click({
        try {
            $Marca  = $cbAddMarca.SelectedItem
            $Modelo = $cbAddModelo.SelectedItem
            if (-not $Marca -or -not $Modelo) { [System.Windows.Forms.MessageBox]::Show("Selecione marca e modelo.") | Out-Null; return }
            $driverInfo = $Drivers | Where-Object { $_.Marca -eq $Marca -and $_.Modelo -eq $Modelo }
            $DriverName = $driverInfo.DriverName
            $DriverPath = $driverInfo.Caminho
            $PrinterName = if ($txtAddNome.Text.Trim()) { $txtAddNome.Text.Trim() } else { $driverInfo.NomeExibicao }

            if (!(Test-Path $DriverPath)) { LogAdd "ERRO: Caminho do driver não encontrado: $DriverPath"; return }

            if ($rbAddRede.Checked) {
                $PrinterIP = $txtAddIP.Text.Trim()
                if (-not $PrinterIP) { [System.Windows.Forms.MessageBox]::Show("Informe o IP da impressora.") | Out-Null; return }
                $TipoConexao = "Rede"; $SelectedPort = $null
            } elseif ($rbAddUSB.Checked) {
                if (-not $cbAddUSBPort.SelectedItem) { [System.Windows.Forms.MessageBox]::Show("Selecione a porta USB.") | Out-Null; return }
                $TipoConexao = "USB"; $PrinterIP = $null
                $SelectedPort = ($cbAddUSBPort.SelectedItem -split "-")[0].Trim()
            } else {
                [System.Windows.Forms.MessageBox]::Show("Selecione o tipo de conexão.") | Out-Null; return
            }

            LogAdd "Copiando driver..."
            Invoke-Command -Session $script:SessionAtiva -ScriptBlock { New-Item "C:\Temp\DriverTemp" -ItemType Directory -Force | Out-Null }
            Copy-Item "$DriverPath\*" -Destination "C:\Temp\DriverTemp" -Recurse -ToSession $script:SessionAtiva -Force
            LogAdd "Driver copiado. Instalando..."

            Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                param($PrinterName, $DriverName, $TipoConexao, $PrinterIP, $SelectedPort)
                pnputil /add-driver "C:\Temp\DriverTemp\*.inf" /install | Out-Null
                if (-not (Get-PrinterDriver -Name $DriverName -ErrorAction SilentlyContinue)) { Add-PrinterDriver -Name $DriverName }
                if ($TipoConexao -eq "Rede") {
                    $PortName = "IP_$PrinterIP"
                    if (-not (Get-PrinterPort -Name $PortName -ErrorAction SilentlyContinue)) { Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP }
                    $PortToUse = $PortName
                } else {
                    $PortToUse = $SelectedPort
                    if (-not (Get-PrinterPort -Name $PortToUse -ErrorAction SilentlyContinue)) { throw "Porta USB não encontrada." }
                }
                if (-not (Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue)) { Add-Printer -Name $PrinterName -DriverName $DriverName -PortName $PortToUse }
            } -ArgumentList $PrinterName, $DriverName, $TipoConexao, $PrinterIP, $SelectedPort

            # Limpar pasta temporaria
            Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                Remove-Item "C:\Temp\DriverTemp" -Recurse -Force -ErrorAction SilentlyContinue
            }
            LogAdd "Pasta temporaria limpa."
            LogAdd "Impressora '$PrinterName' instalada com sucesso!"
            Add-Log "Nova impressora adicionada: '$PrinterName'."
            [System.Windows.Forms.MessageBox]::Show("Impressora instalada com sucesso!", "OK",
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information) | Out-Null

            $resp = [System.Windows.Forms.MessageBox]::Show("Enviar página de teste?", "Teste de Impressão",
                [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
            if ($resp -eq [System.Windows.Forms.DialogResult]::Yes) {
                Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                    param($PName, $tec)
                    $tempPath = "C:\Temp"
                    $f = Join-Path $tempPath "teste_impressao.txt"

                     if (-not (Test-Path $tempPath)) {
                        New-Item -Path $tempPath -ItemType Directory -Force | Out-Null
                    }

                    "Teste de impressão em $((Get-Date).ToString('dd/MM/yyyy HH:mm')) — Técnico: $tec" | Out-File $f -Encoding utf8
                    Get-Content $f | Out-Printer -Name $PName

                    Start-Sleep -Seconds 2
                    
                } -ArgumentList $PrinterName, $tecnico

                Invoke-Command -Session $script:SessionAtiva -ScriptBlock {
                    Remove-Item "C:\Temp\" -Recurse -Force -ErrorAction SilentlyContinue
                }


                LogAdd "Página de teste enviada."
                LogAdd "Pasta temporaria limpa."
            }
            Atualizar-Lista
        }
        catch { LogAdd "ERRO: $_"; [System.Windows.Forms.MessageBox]::Show("Erro na instalação: $_") | Out-Null }
    })

    $fAdd.ShowDialog($form) | Out-Null
})

# ============================================================
# INICIALIZAÇÃO — LOG INICIAL
# ============================================================
Add-Log "Gerenciador de Impressoras iniciado. Técnico: $tecnico"
Add-Log "Informe o nome do computador e clique em Conectar."

# ============================================================
# FECHAR SESSÃO AO SAIR
# ============================================================
$form.Add_FormClosing({
    if ($script:SessionAtiva) {
        try { Remove-PSSession $script:SessionAtiva -ErrorAction SilentlyContinue } catch {}
    }
})

$form.ShowDialog() | Out-Null