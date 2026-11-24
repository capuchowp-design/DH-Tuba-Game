#!/usr/bin/env bash
# Baixa o Tone.js e os sons do instrumento para dentro do projeto (o app passa a funcionar sem internet).
# Uso no Codespace, na pasta do projeto:   bash baixar-sons.sh tuba      (ou:  bash baixar-sons.sh trumpet)
set -uo pipefail
INST="${1:-}"
case "$INST" in tuba|trumpet) ;; *) echo "Uso: bash baixar-sons.sh tuba   ou   bash baixar-sons.sh trumpet"; exit 1;; esac
BASES=("https://nbrosowsky.github.io/tonejs-instruments/samples/$INST/" "https://cdn.jsdelivr.net/gh/nbrosowsky/tonejs-instruments@master/samples/$INST/")
mkdir -p lib "sons/$INST"

echo "Baixando Tone.js..."
curl -fsSL -o lib/Tone.js "https://cdnjs.cloudflare.com/ajax/libs/tone/14.8.49/Tone.js" \
 || curl -fsSL -o lib/Tone.js "https://cdn.jsdelivr.net/npm/tone@14.8.49/build/Tone.js" \
 || { echo "Falha ao baixar o Tone.js"; exit 1; }

echo "Baixando os sons ($INST)..."
rm -f "sons/$INST"/*.mp3
for o in 0 1 2 3 4 5 6; do
  for n in C Cs D Ds E F Fs G Gs A As B; do
    f="$n$o.mp3"
    for b in "${BASES[@]}"; do
      curl -fsSL --max-time 30 -o "sons/$INST/$f" "$b$f" 2>/dev/null && break || rm -f "sons/$INST/$f"
    done
  done
done
COUNT=$(ls "sons/$INST"/*.mp3 2>/dev/null | wc -l)
if [ "$COUNT" -lt 8 ]; then echo "Só consegui $COUNT sons. Verifique a internet do Codespace e rode de novo."; exit 1; fi
( cd "sons/$INST" && ls *.mp3 | sed 's/\.mp3$//' | sort -V | awk 'BEGIN{printf "["} {printf "%s\"%s\"", (NR>1?",":""), $0} END{print "]"}' > index.json )
echo "OK: $COUNT sons + Tone.js salvos ($(du -sh sons lib | awk '{print $1}' | paste -sd' ' -))."
echo "Agora rode:  bash gerar-apk.sh   (envia tudo para o GitHub e gera o APK)"
