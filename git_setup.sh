#!/bin/bash

# Garante execução com bash
if [ -z "$BASH_VERSION" ]; then
    exec bash "$0" "$@"
fi

# ============================================================
#   GERENCIADOR GITHUB PRO
# ============================================================

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

WORKDIR=""

success() { echo -e "${GREEN}✔  $1${NC}"; }
error()   { echo -e "${RED}✘  $1${NC}"; }
info()    { echo -e "${CYAN}ℹ  $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠  $1${NC}"; }
step()    { echo -e "${BLUE}▶  $1${NC}"; }

confirm() {
    echo -en "${YELLOW}$1 [s/N]: ${NC}"
    read -r resp
    [[ "$resp" =~ ^[sS]$ ]]
}

pause() {
    echo -e "\n${DIM}Pressione Enter para continuar...${NC}"
    read -r
}

git_cmd() {
    git -C "${WORKDIR}" "$@"
}

is_git_repo() {
    git -C "${WORKDIR}" rev-parse --git-dir > /dev/null 2>&1
}

require_repo() {
    if ! is_git_repo; then
        error "Não é um repositório Git. Use a opção 1 para inicializar."
        return 1
    fi
}

current_branch() {
    git -C "${WORKDIR}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "desconhecida"
}

has_remote() {
    git -C "${WORKDIR}" remote get-url origin > /dev/null 2>&1
}
handle_git_error() {
    local output="$1"
    if echo "$output" | grep -qiE "Invalid username or token|Authentication failed|Password authentication is not supported"; then
        echo ""
        echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║           ERRO DE AUTENTICAÇÃO GITHUB                ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}O GitHub não aceita mais senha para operações Git.${NC}"
        echo -e "${YELLOW}Você precisa usar um ${BOLD}Personal Access Token (PAT)${NC}${YELLOW}.${NC}"
        echo ""
        echo -e "${BOLD}Como resolver:${NC}"
        echo ""
        echo -e "  ${CYAN}1.${NC} Acesse: ${BOLD}https://github.com/settings/tokens${NC}"
        echo -e "  ${CYAN}2.${NC} Clique em ${BOLD}Generate new token (classic)${NC}"
        echo -e "  ${CYAN}3.${NC} Marque a permissão ${BOLD}"repo"${NC} e gere o token"
        echo -e "  ${CYAN}4.${NC} Copie o token gerado (começa com ${BOLD}ghp_...${NC})"
        echo ""
        echo -e "  ${CYAN}5.${NC} Configure a URL do remoto com o token embutido:"
        echo -e "     ${DIM}https://SEU_TOKEN@github.com/usuario/repositorio.git${NC}"
        echo ""
        echo -e "  ${CYAN}   Ou use o gerenciador de credenciais:${NC}"
        echo -e "     ${DIM}git config --global credential.helper store${NC}"
        echo -e "     ${DIM}(na próxima operação, informe usuário + token como senha)${NC}"
        echo ""
        echo -e "${YELLOW}Use a opção ${BOLD}12${NC}${YELLOW} para atualizar a URL do remoto com o token.${NC}"
        echo ""
    else
        echo "$output"
    fi
}



# ── Configurar diretório ──────────────────────────────────────

setup_workdir() {
    clear
    echo -e "${BLUE}${BOLD}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║        GERENCIADOR GITHUB PRO            ║"
    echo "  ╚══════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}Diretório atual: ${BOLD}$(pwd)${NC}"
    echo ""
    echo "  1) Usar este diretório"
    echo "  2) Informar outro caminho"
    echo ""
    echo -en "  ${BOLD}Escolha: ${NC}"
    read -r opt

    if [[ "$opt" == "2" ]]; then
        echo -en "${CYAN}Caminho do projeto: ${NC}"
        read -r custom_path
        custom_path="${custom_path/#\~/$HOME}"
        if [[ ! -d "${custom_path}" ]]; then
            if confirm "Diretório não existe. Criar '${custom_path}'?"; then
                mkdir -p "${custom_path}" && success "Diretório criado."
            else
                error "Caminho inválido."
                setup_workdir
                return
            fi
        fi
        WORKDIR="${custom_path}"
    else
        WORKDIR="$(pwd)"
    fi

    # Confirma que o WORKDIR funciona
    if ! ls "${WORKDIR}" > /dev/null 2>&1; then
        error "Não foi possível acessar: ${WORKDIR}"
        setup_workdir
        return
    fi

    success "Trabalhando em: ${WORKDIR}"
    sleep 1
}

# ── Menu ──────────────────────────────────────────────────────

show_header() {
    clear
    local branch_info=""
    local remote_info=""

    if is_git_repo; then
        branch_info="${DIM} [branch: $(current_branch)]${NC}"
        if has_remote; then
            local remote_url
            remote_url=$(git -C "${WORKDIR}" remote get-url origin 2>/dev/null | sed 's|https://github.com/||')
            remote_info="${DIM} [${remote_url}]${NC}"
        fi
    fi

    echo -e "${BLUE}${BOLD}"
    echo "  ╔══════════════════════════════════════════╗"
    echo "  ║        GERENCIADOR GITHUB PRO            ║"
    echo "  ╚══════════════════════════════════════════╝${NC}"
    echo -e "  ${DIM}${WORKDIR}${NC}${branch_info}${remote_info}"
    echo ""
}

show_menu() {
    show_header
    echo -e "  ${BOLD}── Repositório ──────────────────────────${NC}"
    echo "  1) Inicializar repositório (git init)"
    echo "  2) Clonar repositório (git clone)"
    echo "  3) Status detalhado"
    echo "  4) Ver log de commits"
    echo ""
    echo -e "  ${BOLD}── Branches ─────────────────────────────${NC}"
    echo "  5) Listar / Trocar de branch"
    echo "  6) Criar nova branch"
    echo "  7) Mesclar branch (merge)"
    echo "  8) Deletar branch"
    echo ""
    echo -e "  ${BOLD}── Sincronização ────────────────────────${NC}"
    echo "  9) Commit rápido (add + commit + push)"
    echo " 10) Pull (atualizar do remoto)"
    echo " 11) Push (enviar ao GitHub)"
    echo " 12) Configurar remoto (remote add/set)"
    echo ""
    echo -e "  ${BOLD}── Avançado ──────────────────────────────${NC}"
    echo " 13) Stash (salvar alterações temporárias)"
    echo " 14) Desfazer último commit"
    echo " 15) Diff (ver mudanças não commitadas)"
    echo " 16) Tag de versão"
    echo " 17) Configurar identidade Git"
    echo " 18) Trocar diretório de trabalho"
    echo ""
    echo "  0) Sair"
    echo -e "  ${BLUE}──────────────────────────────────────────${NC}"
    echo -en "  ${BOLD}Escolha: ${NC}"
}

# ── Comandos ──────────────────────────────────────────────────

cmd_init() {
    if is_git_repo; then
        warn "Já é um repositório Git."
        return
    fi
    git -C "${WORKDIR}" init
    git -C "${WORKDIR}" branch -m main 2>/dev/null || true
    if [[ ! -f "${WORKDIR}/.gitignore" ]]; then
        if confirm "Criar .gitignore básico?"; then
            cat > "${WORKDIR}/.gitignore" << 'EOF'
.DS_Store
Thumbs.db
.vscode/
.idea/
*.swp
node_modules/
vendor/
__pycache__/
*.pyc
.env
.env.local
dist/
build/
EOF
            success ".gitignore criado."
        fi
    fi
    success "Repositório inicializado na branch 'main'."
}

cmd_clone() {
    echo -en "${CYAN}URL do repositório: ${NC}"
    read -r url
    [[ -z "$url" ]] && { error "URL vazia."; return; }
    echo -en "${CYAN}Diretório de destino (Enter = padrão): ${NC}"
    read -r dest
    if [[ -n "$dest" ]]; then
        git -C "${WORKDIR}" clone "$url" "$dest"
    else
        git -C "${WORKDIR}" clone "$url"
    fi
    success "Repositório clonado."
}

cmd_status() {
    require_repo || return
    echo ""
    git -C "${WORKDIR}" status -sb
    echo ""
    info "Branch atual: $(current_branch)"
    if has_remote; then
        info "Remoto: $(git -C "${WORKDIR}" remote get-url origin)"
    else
        warn "Sem remoto configurado."
    fi
    local unpushed
    unpushed=$(git -C "${WORKDIR}" log @{u}.. --oneline 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$unpushed" -gt 0 ]]; then
        warn "$unpushed commit(s) aguardando push."
    fi
}

cmd_log() {
    require_repo || return
    echo ""
    git -C "${WORKDIR}" log --oneline --graph --decorate --color -20
    echo ""
    info "Últimos 20 commits."
}

cmd_branches() {
    require_repo || return
    echo ""
    echo -e "${CYAN}Branches locais:${NC}"
    git -C "${WORKDIR}" branch -v
    echo ""
    if has_remote; then
        echo -e "${CYAN}Branches remotas:${NC}"
        git -C "${WORKDIR}" branch -rv 2>/dev/null
        echo ""
    fi
    echo -en "${YELLOW}Trocar para qual branch? (Enter = cancelar): ${NC}"
    read -r target
    if [[ -n "$target" ]]; then
        git -C "${WORKDIR}" checkout "$target" && success "Trocou para '$target'."
    fi
}

cmd_new_branch() {
    require_repo || return
    echo -en "${CYAN}Nome da nova branch: ${NC}"
    read -r name
    [[ -z "$name" ]] && { error "Nome vazio."; return; }
    git -C "${WORKDIR}" checkout -b "$name"
    success "Branch '$name' criada e ativada."
}

cmd_merge() {
    require_repo || return
    echo -e "${CYAN}Branches disponíveis:${NC}"
    git -C "${WORKDIR}" branch -v
    echo ""
    echo -en "${CYAN}Branch para mesclar na atual ($(current_branch)): ${NC}"
    read -r source
    [[ -z "$source" ]] && return
    git -C "${WORKDIR}" merge "$source" && success "Merge de '$source' concluído."
}

cmd_delete_branch() {
    require_repo || return
    echo -e "${CYAN}Branches disponíveis:${NC}"
    git -C "${WORKDIR}" branch -v
    echo ""
    echo -en "${CYAN}Branch para deletar: ${NC}"
    read -r name
    [[ -z "$name" ]] && return
    if confirm "Deletar branch '$name'?"; then
        git -C "${WORKDIR}" branch -d "$name" && success "Branch '$name' deletada."
    fi
}

cmd_quick_push() {
    require_repo || return
    echo -e "${DIM}Arquivos modificados:${NC}"
    git -C "${WORKDIR}" status -s
    echo ""
    echo -en "${CYAN}Mensagem do commit: ${NC}"
    read -r message
    [[ -z "$message" ]] && { error "Mensagem vazia."; return; }
    step "Adicionando arquivos..."
    git -C "${WORKDIR}" add .
    step "Commitando..."
    git -C "${WORKDIR}" commit -m "$message" || { error "Nenhuma mudança para commitar."; return; }
    if has_remote && confirm "Fazer push agora?"; then
        step "Enviando para o GitHub..."
        local git_output
        git_output=$(git -C "${WORKDIR}" push origin "$(current_branch)" 2>&1)
        local exit_code=$?
        if [[ $exit_code -ne 0 ]]; then
            handle_git_error "$git_output"
        else
            success "Push realizado!"
        fi
    else
        success "Commit realizado! (Push pendente)"
    fi
}

cmd_pull() {
    require_repo || return
    has_remote || { error "Sem remoto configurado."; return; }
    step "Atualizando do remoto..."
    local git_output
    git_output=$(git -C "${WORKDIR}" pull origin "$(current_branch)" 2>&1)
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        if echo "$git_output" | grep -q "divergent branches"; then
            echo ""
            echo -e "${RED}╔══════════════════════════════════════════════════════╗${NC}"
            echo -e "${RED}║           BRANCHES DIVERGENTES                       ║${NC}"
            echo -e "${RED}╚══════════════════════════════════════════════════════╝${NC}"
            echo ""
            echo -e "${YELLOW}Seu repositório local e o remoto têm commits diferentes${NC}"
            echo -e "${YELLOW}e o Git não sabe como combiná-los automaticamente.${NC}"
            echo ""
            echo -e "${BOLD}Escolha como deseja resolver:${NC}"
            echo ""
            echo -e "  ${CYAN}1)${NC} ${BOLD}Merge${NC} — une os históricos (cria um commit de merge)"
            echo -e "  ${CYAN}2)${NC} ${BOLD}Rebase${NC} — reaplica seus commits sobre o remoto (histórico linear)"
            echo -e "  ${CYAN}3)${NC} ${BOLD}Fast-forward only${NC} — só atualiza se não houver conflito"
            echo -e "  ${CYAN}0)${NC} Cancelar"
            echo ""
            echo -en "${YELLOW}Escolha: ${NC}"
            read -r resolve_opt
            case $resolve_opt in
                1)
                    step "Fazendo pull com merge..."
                    git_output2=$(git -C "${WORKDIR}" pull --no-rebase origin "$(current_branch)" 2>&1)
                    if [[ $? -eq 0 ]]; then
                        success "Pull com merge concluído!"
                        git config --global pull.rebase false
                        info "Preferência salva: pull.rebase false (merge)"
                    else
                        echo "$git_output2"
                        handle_git_error "$git_output2"
                    fi ;;
                2)
                    step "Fazendo pull com rebase..."
                    git_output2=$(git -C "${WORKDIR}" pull --rebase origin "$(current_branch)" 2>&1)
                    if [[ $? -eq 0 ]]; then
                        success "Pull com rebase concluído!"
                        git config --global pull.rebase true
                        info "Preferência salva: pull.rebase true (rebase)"
                    else
                        echo "$git_output2"
                        handle_git_error "$git_output2"
                    fi ;;
                3)
                    step "Fazendo pull fast-forward only..."
                    git_output2=$(git -C "${WORKDIR}" pull --ff-only origin "$(current_branch)" 2>&1)
                    if [[ $? -eq 0 ]]; then
                        success "Pull fast-forward concluído!"
                        git config --global pull.ff only
                        info "Preferência salva: pull.ff only"
                    else
                        echo ""
                        error "Fast-forward não é possível (há commits locais não enviados)."
                        echo ""
                        echo -e "${YELLOW}Dica: use Merge ou Rebase para combinar os históricos.${NC}"
                    fi ;;
                *) info "Operação cancelada." ;;
            esac
        else
            handle_git_error "$git_output"
        fi
    else
        success "Atualização concluída."
    fi
}

cmd_push() {
    require_repo || return
    has_remote || { error "Sem remoto configurado."; return; }
    local branch
    branch=$(current_branch)
    step "Enviando branch '$branch'..."
    local git_output
    git_output=$(git -C "${WORKDIR}" push origin "$branch" 2>&1)
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        handle_git_error "$git_output"
    else
        success "Push concluído."
    fi
}

cmd_remote() {
    require_repo || return
    if has_remote; then
        info "Remoto atual: $(git -C "${WORKDIR}" remote get-url origin)"
        confirm "Substituir remoto existente?" || return
        echo -en "${CYAN}Nova URL: ${NC}"
        read -r url
        [[ -z "$url" ]] && return
        git -C "${WORKDIR}" remote set-url origin "$url"
    else
        echo -en "${CYAN}URL do repositório: ${NC}"
        read -r url
        [[ -z "$url" ]] && return
        git -C "${WORKDIR}" remote add origin "$url"
    fi
    success "Remoto configurado: $url"
}

cmd_stash() {
    require_repo || return
    echo "  1) Salvar stash"
    echo "  2) Listar stashes"
    echo "  3) Aplicar último stash"
    echo "  4) Descartar último stash"
    echo -en "${YELLOW}Opção: ${NC}"
    read -r sub
    case $sub in
        1)
            echo -en "${CYAN}Descrição (Enter = padrão): ${NC}"
            read -r desc
            if [[ -n "$desc" ]]; then
                git -C "${WORKDIR}" stash push -m "$desc" && success "Stash salvo."
            else
                git -C "${WORKDIR}" stash && success "Stash salvo."
            fi ;;
        2) git -C "${WORKDIR}" stash list ;;
        3) git -C "${WORKDIR}" stash pop && success "Stash aplicado." ;;
        4) confirm "Descartar?" && git -C "${WORKDIR}" stash drop && success "Descartado." ;;
    esac
}

cmd_undo() {
    require_repo || return
    info "Último commit: $(git -C "${WORKDIR}" log -1 --oneline 2>/dev/null)"
    echo "  1) Desfazer mantendo arquivos (--soft)"
    echo "  2) Desfazer descartando tudo (--hard)"
    echo -en "${YELLOW}Opção: ${NC}"
    read -r sub
    case $sub in
        1) confirm "Desfazer último commit (manter arquivos)?" &&
           git -C "${WORKDIR}" reset --soft HEAD~1 && success "Commit desfeito." ;;
        2) warn "Isso descarta todas as mudanças permanentemente!"
           confirm "Confirma?" &&
           git -C "${WORKDIR}" reset --hard HEAD~1 && success "Descartado." ;;
    esac
}

cmd_diff() {
    require_repo || return
    echo "  1) Mudanças não staged"
    echo "  2) Mudanças staged"
    echo "  3) Comparar com branch"
    echo -en "${YELLOW}Opção: ${NC}"
    read -r sub
    case $sub in
        1) git -C "${WORKDIR}" diff ;;
        2) git -C "${WORKDIR}" diff --cached ;;
        3)
            echo -en "${CYAN}Branch: ${NC}"
            read -r b
            [[ -n "$b" ]] && git -C "${WORKDIR}" diff "$b" ;;
    esac
}

cmd_tag() {
    require_repo || return
    echo "  1) Listar tags"
    echo "  2) Criar tag"
    echo "  3) Enviar tags ao remoto"
    echo -en "${YELLOW}Opção: ${NC}"
    read -r sub
    case $sub in
        1) git -C "${WORKDIR}" tag -l ;;
        2)
            echo -en "${CYAN}Nome (ex: v1.0.0): ${NC}"
            read -r tag
            [[ -z "$tag" ]] && return
            echo -en "${CYAN}Mensagem (Enter = tag leve): ${NC}"
            read -r msg
            if [[ -n "$msg" ]]; then
                git -C "${WORKDIR}" tag -a "$tag" -m "$msg" && success "Tag '$tag' criada."
            else
                git -C "${WORKDIR}" tag "$tag" && success "Tag '$tag' criada."
            fi ;;
        3) git -C "${WORKDIR}" push origin --tags && success "Tags enviadas." ;;
    esac
}

cmd_config() {
    local name email
    name=$(git config --global user.name 2>/dev/null)
    email=$(git config --global user.email 2>/dev/null)
    info "Atual: ${name:-<não definido>} <${email:-<não definido>}>"
    echo ""
    echo -en "${CYAN}Nome (Enter = manter): ${NC}"
    read -r new_name
    [[ -n "$new_name" ]] && git config --global user.name "$new_name"
    echo -en "${CYAN}E-mail (Enter = manter): ${NC}"
    read -r new_email
    [[ -n "$new_email" ]] && git config --global user.email "$new_email"
    success "$(git config --global user.name) <$(git config --global user.email)>"
}

cmd_change_dir() {
    echo -en "${CYAN}Novo caminho: ${NC}"
    read -r new_path
    new_path="${new_path/#\~/$HOME}"
    if [[ -d "${new_path}" ]]; then
        WORKDIR="${new_path}"
        success "Diretório: ${WORKDIR}"
    else
        error "Não encontrado: ${new_path}"
    fi
}

# ── Início ────────────────────────────────────────────────────

setup_workdir

while true; do
    show_menu
    read -r option
    echo ""
    case $option in
        0)  echo -e "${GREEN}Até logo!${NC}"; exit 0 ;;
        1)  cmd_init ;;
        2)  cmd_clone ;;
        3)  cmd_status ;;
        4)  cmd_log ;;
        5)  cmd_branches ;;
        6)  cmd_new_branch ;;
        7)  cmd_merge ;;
        8)  cmd_delete_branch ;;
        9)  cmd_quick_push ;;
        10) cmd_pull ;;
        11) cmd_push ;;
        12) cmd_remote ;;
        13) cmd_stash ;;
        14) cmd_undo ;;
        15) cmd_diff ;;
        16) cmd_tag ;;
        17) cmd_config ;;
        18) cmd_change_dir ;;
        *)  error "Opção inválida!" ;;
    esac
    pause
done