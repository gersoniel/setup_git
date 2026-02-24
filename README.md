🚀 Git Helper Script
Um assistente em Bash para automatizar tarefas comuns do Git. Este script oferece um menu interativo para gerenciar repositórios, realizar commits, pushes, pulls e até recuperação de versões.

🛠️ Funcionalidades
• Iniciação Rápida: `git init` e branch `main`.

• Gestão de Commits: `git add .` + `git commit`.

• Sincronização: `push` e `pull` simplificados.

• Segurança: Reset para o último estado estável.

• Clonagem: Baixa repositórios via URL.

🚀 Como usar
1. Permissão: `chmod +x git_helper.sh`

2. Execução: `./git_helper.sh`

📋 Opções do Menu
1. Init: Inicializa o repositório.

2. Status: Mostra arquivos modificados.

3. Commit: Atalho para add + commit.S

4. Pull/5. Push: Sincronização.

5. Clone: Baixa repositório.

6. Reset: Apaga erros e volta ao último commit.

----------------------------------------------------

1. Criar o Token no GitHub
Acesse o seu GitHub pelo navegador.

Vá em Settings (clique na sua foto no canto superior direito).

No menu à esquerda, role até o fim e clique em Developer Settings.

Clique em Personal access tokens -> Tokens (classic).

Clique em Generate new token (selecione a opção Classic).

Dê um nome (ex: "Meu PC"), escolha o tempo de expiração e marque a caixinha repo (isso dá permissão para fazer push).

Clique em Generate token.