# 🛠️ Gerenciador GitHub Pro

Script Bash interativo para gerenciar repositórios Git/GitHub pelo terminal, com menus coloridos, tratamento inteligente de erros e mensagens em português.

---

## 📋 Índice

- [Requisitos](#-requisitos)
- [Instalação](#-instalação)
- [Como usar](#-como-usar)
- [Menu de opções](#-menu-de-opções)
- [Tratamento de erros](#-tratamento-de-erros)
- [Exemplos de uso](#-exemplos-de-uso)
- [Perguntas frequentes](#-perguntas-frequentes)

---

## ✅ Requisitos

- **Bash** 4.0 ou superior
- **Git** instalado (`git --version`)
- Conta no [GitHub](https://github.com) (para operações remotas)
- Terminal com suporte a cores ANSI (a maioria dos terminais modernos)

> **Linux/macOS:** já vêm com Bash por padrão.  
> **Windows:** use o [Git Bash](https://gitforwindows.org/) ou WSL.

---

## 🚀 Instalação

**1. Baixe o script:**

```bash
git clone https://github.com/gersoniel/setup_git.git
cd setup_git
```

Ou copie o arquivo `git-manager.sh` diretamente para o seu computador.

**2. Dê permissão de execução:**

```bash
chmod +x git-manager.sh
```

**3. Execute:**

```bash
./git-manager.sh
```

> ⚠️ **Importante:** sempre execute com `./git-manager.sh` ou `bash git-manager.sh`.  
> Nunca use `sh git-manager.sh` — isso causa erros de compatibilidade.

---

## 💡 Como usar

Ao iniciar, o script pergunta em qual diretório você quer trabalhar:

```
  Diretório atual: /home/usuario/projetos
  
  1) Usar este diretório
  2) Informar outro caminho
```

- Escolha **1** para usar o diretório onde o script foi executado
- Escolha **2** para digitar o caminho de outro projeto (suporta `~` e caminhos com espaços)

Após selecionar o diretório, o menu principal é exibido. No topo do menu você sempre vê:
- 📁 O diretório de trabalho atual
- 🌿 A branch ativa
- 🔗 O repositório remoto configurado

---

## 📂 Menu de opções

### Repositório

| Opção | Comando equivalente | Descrição |
|-------|-------------------|-----------|
| `1` | `git init` | Inicializa um novo repositório Git na pasta atual. Oferece criar um `.gitignore` básico automaticamente |
| `2` | `git clone` | Clona um repositório remoto. Permite escolher o diretório de destino |
| `3` | `git status` | Exibe o status detalhado: arquivos modificados, branch atual, remoto configurado e commits pendentes de push |
| `4` | `git log` | Mostra os últimos 20 commits com gráfico de branches |

### Branches

| Opção | Comando equivalente | Descrição |
|-------|-------------------|-----------|
| `5` | `git branch` + `git checkout` | Lista todas as branches locais e remotas. Permite trocar de branch interativamente |
| `6` | `git checkout -b` | Cria uma nova branch e já muda para ela |
| `7` | `git merge` | Mescla outra branch na branch atual |
| `8` | `git branch -d` | Deleta uma branch local (pede confirmação antes) |

### Sincronização

| Opção | Comando equivalente | Descrição |
|-------|-------------------|-----------|
| `9` | `git add` + `git commit` + `git push` | Commit rápido: adiciona todos os arquivos, commita com mensagem e opcionalmente faz push |
| `10` | `git pull` | Atualiza o repositório local com as mudanças do remoto |
| `11` | `git push` | Envia os commits locais para o GitHub |
| `12` | `git remote add/set-url` | Configura ou atualiza a URL do repositório remoto |

### Avançado

| Opção | Comando equivalente | Descrição |
|-------|-------------------|-----------|
| `13` | `git stash` | Salva alterações temporariamente, lista stashes, aplica ou descarta |
| `14` | `git reset` | Desfaz o último commit mantendo os arquivos (`--soft`) ou descartando tudo (`--hard`) |
| `15` | `git diff` | Visualiza mudanças não commitadas, mudanças no stage ou diferenças entre branches |
| `16` | `git tag` | Cria, lista e envia tags de versão (ex: `v1.0.0`) |
| `17` | `git config` | Configura nome e e-mail globais do usuário Git |
| `18` | — | Troca o diretório de trabalho sem sair do script |

---

## 🔴 Tratamento de erros

O script detecta os erros mais comuns do Git e exibe orientações em português, com opções interativas de resolução.

---

### 🔐 Erro de autenticação

**Quando aparece:**
```
remote: Invalid username or token.
fatal: Authentication failed for 'https://github.com/...'
```

**O que o script faz:**  
Exibe um guia passo a passo para criar e configurar um **Personal Access Token (PAT)** no GitHub, já que o GitHub não aceita mais senhas comuns para operações Git.

**Solução rápida:**
1. Acesse [github.com/settings/tokens](https://github.com/settings/tokens)
2. Clique em **Generate new token (classic)**
3. Marque a permissão **repo** e gere o token
4. Use a **opção 12** do menu para atualizar a URL do remoto no formato:
   ```
   https://ghp_SEU_TOKEN@github.com/usuario/repositorio.git
   ```

---

### ⚡ Branches divergentes (pull)

**Quando aparece:**
```
fatal: Need to specify how to reconcile divergent branches.
```

**O que o script faz:**  
Apresenta um menu com 3 estratégias de resolução:

| Opção | Estratégia | Quando usar |
|-------|-----------|-------------|
| `1` | **Merge** | Quando você quer preservar o histórico completo |
| `2` | **Rebase** | Quando você quer um histórico linear e limpo |
| `3` | **Fast-forward only** | Quando você tem certeza que não há commits locais |

A estratégia escolhida é salva automaticamente como padrão global (`git config --global`) para que o erro não se repita.

---

### 🚫 Push rejeitado (non-fast-forward)

**Quando aparece:**
```
! [rejected] main -> main (non-fast-forward)
error: failed to push some refs to '...'
```

**O que o script faz:**  
Apresenta um menu com 3 formas de resolver sem precisar sair do script:

| Opção | O que faz |
|-------|----------|
| `1` | Faz pull com merge e depois push automaticamente |
| `2` | Faz pull com rebase e depois push automaticamente |
| `3` | **Push forçado** — sobrescreve o remoto ⚠️ (pede confirmação dupla) |

> ⚠️ O push forçado deve ser usado com extremo cuidado em repositórios compartilhados, pois apaga commits do remoto permanentemente.

---

## 📖 Exemplos de uso

### Fluxo básico: primeiro push de um projeto novo

```
1. Execute ./git-manager.sh
2. Escolha o diretório do projeto
3. Opção 1  → Inicializar repositório
4. Opção 17 → Configurar nome e e-mail Git
5. Opção 12 → Configurar URL do remoto
6. Opção 9  → Commit rápido (add + commit + push)
```

### Atualizar e enviar mudanças no dia a dia

```
1. Opção 10 → Pull (buscar atualizações do remoto)
2. [faça suas alterações no código]
3. Opção 9  → Commit rápido com mensagem e push
```

### Trabalhar com branches

```
1. Opção 6  → Criar nova branch (ex: feature/login)
2. [desenvolva sua feature]
3. Opção 9  → Commitar e enviar a branch
4. Opção 5  → Voltar para a branch main
5. Opção 7  → Mesclar a branch feature/login na main
6. Opção 11 → Push da main atualizada
```

### Salvar trabalho inacabado temporariamente

```
1. Opção 13 → Stash → "1) Salvar stash" (com descrição)
2. [troque de branch ou resolva outra coisa]
3. Opção 13 → Stash → "3) Aplicar último stash"
```

---

## ❓ Perguntas frequentes

**O script funciona no macOS?**  
Sim, desde que você tenha Bash 4+ instalado. No macOS o Bash padrão pode ser antigo; instale via `brew install bash`.

**Posso usar com caminhos que têm espaços?**  
Sim. O script foi desenvolvido para suportar caminhos com espaços, como `/media/HD Back/projetos`.

**O script salva minha senha ou token?**  
Não. O script não armazena credenciais. O armazenamento fica por conta do próprio Git via `credential.helper`.

**Posso usar com repositórios privados?**  
Sim, desde que você configure um Personal Access Token com a permissão `repo`.

**Como atualizar o script?**  
Se você clonou via Git, basta executar `git pull` dentro da pasta do projeto para obter a versão mais recente.

---

## 📄 Licença

Este projeto é de uso livre. Sinta-se à vontade para modificar, distribuir e melhorar.

---

*Desenvolvido para simplificar o uso do Git no terminal, com foco em usabilidade e mensagens claras em português.*
