#!/usr/bin/env bash
# Gera o APK pelo GitHub Actions, criando e configurando os secrets de assinatura sozinho.
# Use no terminal do Codespace, dentro da pasta do repositório:  bash gerar-apk.sh
set -uo pipefail

REPO=$(git config --get remote.origin.url | sed -E 's#.*github\.com[:/]##; s#\.git$##')
WF=build-apk.yml
KS_DIR="$HOME/dh-keystore"
echo "Repositório: $REPO"

# 1) Java (para o keytool)
command -v keytool >/dev/null 2>&1 || { echo "Instalando Java..."; sudo apt-get update -qq && sudo apt-get install -y -qq default-jre-headless; }

# 2) Permissão do gh para mexer em secrets e rodar workflows (o token padrão do Codespace não tem)
export GIT_TERMINAL_PROMPT=0
API="repos/$REPO/actions/secrets/public-key"
if ! gh api "$API" >/dev/null 2>&1; then
  if env -u GITHUB_TOKEN -u GH_TOKEN gh api "$API" >/dev/null 2>&1; then
    unset GITHUB_TOKEN GH_TOKEN                      # já existe um login seu salvo
  else
    echo "Faça o login do GitHub (abra o link, cole o código e autorize):"
    unset GITHUB_TOKEN GH_TOKEN
    gh auth login -h github.com -p https -w -s repo,workflow || { echo "Login não concluído."; exit 1; }
  fi
fi
gh auth setup-git >/dev/null 2>&1                    # o git push passa a usar o seu login

# 3) Envia o código para o GitHub (o workflow precisa estar lá)
touch .gitignore
for p in apk-out/ dh-keystore-backup/ '*.keystore'; do grep -qxF "$p" .gitignore || echo "$p" >> .gitignore; done   # nunca sobe APK nem chave
if [ -n "$(git status --porcelain)" ]; then
  git add -A && git commit -q -m "Atualização do app" && echo "Alterações salvas."
fi
git push -q 2>/dev/null || git push -q -u origin HEAD || { echo "Não consegui enviar o código (git push). Rode: gh auth setup-git && git push"; exit 1; }

# 4) Chave de assinatura: cria uma vez e grava os 3 secrets
if gh secret list -R "$REPO" 2>/dev/null | grep -q '^KEYSTORE_BASE64'; then
  echo "Secrets de assinatura já existem neste repositório. Mantendo."
else
  mkdir -p "$KS_DIR"
  if [ ! -f "$KS_DIR/release.keystore" ]; then
    PASS=$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 20)
    keytool -genkeypair -keystore "$KS_DIR/release.keystore" -alias dhkey -keyalg RSA -keysize 2048 \
      -validity 10000 -storepass "$PASS" -keypass "$PASS" -dname "CN=DigitaHinos, O=DH, C=BR" >/dev/null 2>&1 || { echo "Falha ao criar a chave."; exit 1; }
    printf 'alias: dhkey\nsenha: %s\n' "$PASS" > "$KS_DIR/senha.txt"
    echo "Chave criada em $KS_DIR"
  fi
  PASS=$(sed -n 's/^senha: //p' "$KS_DIR/senha.txt")
  base64 -w0 "$KS_DIR/release.keystore" | gh secret set KEYSTORE_BASE64 -R "$REPO" &&
  printf '%s' "$PASS" | gh secret set KEYSTORE_PASSWORD -R "$REPO" &&
  printf '%s' "dhkey" | gh secret set KEY_ALIAS -R "$REPO" || { echo "Não consegui gravar os secrets."; exit 1; }
  echo "Secrets gravados: KEYSTORE_BASE64, KEYSTORE_PASSWORD, KEY_ALIAS"
fi

# 5) Dispara o build e espera terminar
PREV=$(gh run list -R "$REPO" --workflow="$WF" --limit 1 --json databaseId -q '.[0].databaseId' 2>/dev/null)
gh workflow run "$WF" -R "$REPO" || { echo "Não consegui iniciar o workflow ($WF). Ele está na branch principal?"; exit 1; }
echo "Build iniciado. Aguardando..."
RUN=""
for i in $(seq 1 30); do
  sleep 3
  RUN=$(gh run list -R "$REPO" --workflow="$WF" --limit 1 --json databaseId -q '.[0].databaseId' 2>/dev/null)
  [ -n "$RUN" ] && [ "$RUN" != "$PREV" ] && break
done
gh run watch "$RUN" -R "$REPO" --exit-status || { echo "O build falhou. Veja: gh run view $RUN -R $REPO --log-failed"; exit 1; }

# 6) Baixa o APK
rm -rf apk-out && gh run download "$RUN" -R "$REPO" -D apk-out
echo
echo "APK pronto:"; ls -1 apk-out/*/*.apk 2>/dev/null || ls -1 apk-out/*.apk
echo
echo "Para baixar: no painel de arquivos do Codespace, clique com o botão direito no APK > Download."
echo "GUARDE a pasta $KS_DIR (chave + senha): sem ela você não consegue atualizar o app depois. Não suba para o GitHub."
