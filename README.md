# 🖨️ Gerenciador Remoto de Impressoras

Ferramenta gráfica em PowerShell para gerenciamento remoto de impressoras em estações de trabalho Windows, voltada para técnicos de suporte de TI.

---

## 📋 Descrição

O **Gerenciador Remoto de Impressoras** é uma interface gráfica (WinForms) que permite ao técnico conectar-se remotamente a qualquer computador da rede e realizar operações completas de gerenciamento de impressoras — tudo sem sair da própria máquina. Os drivers disponíveis são carregados a partir de um arquivo `drivers.json` centralizado, apontando para um servidor de arquivos compartilhado na rede.

---

## ✨ Funcionalidades

| Funcionalidade           | Descrição                                                                                                           |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| **Conexão remota**       | Conecta via WinRM (PowerShell Remoting). Se o WinRM não estiver ativo, tenta habilitá-lo automaticamente via PsExec |
| **Listar impressoras**   | Exibe todas as impressoras instaladas no PC remoto com nome, driver, porta e impressora padrão                      |
| **Adicionar impressora** | Instala driver e cria impressora no PC remoto via rede (TCP/IP) ou USB                                              |
| **Alterar driver**       | Substitui o driver de uma impressora existente — via catálogo JSON ou arquivo `.inf` manual                         |
| **Alterar porta**        | Muda a porta de uma impressora para uma porta existente ou um novo IP                                               |
| **Definir padrão**       | Define a impressora selecionada como padrão no PC remoto                                                            |
| **Renomear**             | Renomeia uma impressora instalada                                                                                   |
| **Excluir**              | Remove uma impressora do PC remoto com confirmação                                                                  |
| **Limpar fila**          | Para o Spooler, limpa toda a fila de impressão e reinicia o serviço                                                 |
| **Página de teste**      | Envia uma página de teste para a impressora selecionada                                                             |
| **Log em tempo real**    | Painel de log com timestamp registrando todas as operações                                                          |

---

## 🗂️ Estrutura do Projeto

```
📁 Gerenciador de Impressoras/
├── script.ps1                        # Script principal (interface + lógica)
├── drivers.json                      # Catálogo de drivers disponíveis
├── script.bat                        # Executável
├── PsExec.exe                        # Necessário para habilitar WinRM remotamente
└── Como adicionar um novo driver.pdf # Guia de referência (opcional)
```

---

## 📦 Arquivo `drivers.json`

Catálogo com os drivers disponíveis no servidor de arquivos da rede. Cada entrada contém:

```json
{
  "Marca": "Epson",
  "Modelo": "L3250",
  "NomeExibicao": "Epson L3250",
  "DriverName": "EPSON L3250 Series",
  "Caminho": "\\\\192.168.0.5\\suporte\\DRIVERS\\Impressoras\\Epson\\Epson L3250\\WINX64"
}
```

| Campo          | Descrição                                                  |
| -------------- | ---------------------------------------------------------- |
| `Marca`        | Fabricante da impressora (usado para filtrar na interface) |
| `Modelo`       | Modelo específico                                          |
| `NomeExibicao` | Nome padrão sugerido ao instalar                           |
| `DriverName`   | Nome exato do driver conforme registrado no Windows        |
| `Caminho`      | Caminho UNC para a pasta do driver no servidor             |

### Marcas suportadas atualmente

`Epson` · `Ricoh` · `Brother` · `HP` · `Canon` · `Samsung` · `Lexmark` · `Gainscha`

---

## ⚙️ Pré-requisitos

- **Sistema operacional:** Windows 10/11 (64 bits)
- **PowerShell:** 5.1 ou superior
- **Permissões:** Conta com direitos de administrador local nos PCs remotos
- **Rede:** Acesso ao compartilhamento `\\192.168.0.5\suporte\DRIVERS\`
- **WinRM:** Habilitado nos PCs de destino (ou `PsExec.exe` presente na pasta do script para habilitação automática)

---

## 🚀 Como usar

1. Coloque `script.ps1`, `script.bat`, `drivers.json` e `PsExec.exe` na mesma pasta.
2. Execute `script.bat` (Já irá pedir os privilégios de administrador).
3. No campo **Computador**, informe o nome do PC remoto e clique em **Conectar** (ou pressione Enter).
4. Após a conexão, a lista de impressoras instaladas será carregada automaticamente.
5. Use os botões da barra de ações ou o menu de contexto (botão direito na lista) para gerenciar.

> **Dica:** O técnico logado (`$env:USERNAME`) é exibido no cabeçalho e registrado nos logs de operação.

---

## ➕ Como adicionar um novo driver ao catálogo

1. Copie a pasta do driver (com o `.inf` e arquivos relacionados) para o servidor em `\\192.168.0.5\suporte\DRIVERS\Impressoras\<Marca>\<Modelo>\`.
2. Edite o `drivers.json` e adicione um novo objeto seguindo o padrão existente.
3. O nome em `DriverName` deve ser **exatamente** o nome do driver como aparece no Windows (verifique no `.inf` ou no Gerenciador de Dispositivos).

> Consulte o arquivo **"Como adicionar um novo driver.pdf"** (disponível na pasta do script) para um guia passo a passo com capturas de tela.

---

## 🔧 Solução de problemas

| Problema                               | Possível causa                                | Solução                                                          |
| -------------------------------------- | --------------------------------------------- | ---------------------------------------------------------------- |
| "Computador não responde na rede"      | PC desligado ou fora da rede                  | Verifique conectividade com `ping`                               |
| "PsExec.exe não encontrado"            | Arquivo ausente na pasta                      | Baixe o PsExec do Sysinternals e coloque na pasta do script      |
| "WinRM não respondeu após habilitação" | Política de grupo bloqueando                  | Habilite manualmente com `Enable-PSRemoting -Force` no PC remoto |
| "Caminho do driver não encontrado"     | Servidor offline ou caminho incorreto no JSON | Verifique acesso ao compartilhamento e o campo `Caminho` no JSON |
| Driver não aparece após instalação     | Nome em `DriverName` diverge do `.inf`        | Confira o nome exato do driver no arquivo `.inf`                 |

---

## 📝 Notas

- Os arquivos de driver são copiados para `C:\Temp\DriverTemp` no PC remoto durante a instalação e removidos automaticamente ao final.
- A limpeza de fila reinicia o serviço **Spooler** no PC remoto — isso afeta **todas** as impressoras instaladas naquele computador.
- O script foi desenvolvido e testado no **PowerShell 5.1**. Versões mais recentes (7+) podem apresentar comportamentos diferentes com WinForms.

