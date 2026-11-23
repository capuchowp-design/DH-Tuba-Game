# DH Tuba Game

Game estilo Guitar Hero para aprender os hinos na tuba.

- **Telas:** início, escolha do hino (busca por número/título, com estrelas), configurações e o game.
- **Jogo (simulação do instrumento):** as notas descem em 3 ou 4 colunas (uma por pisto). Na hora da nota, seus dedos precisam estar na **posição** dela; não é preciso bater.
  - **Nota solta** (barra larga "SOLTA") = nenhum pisto: tire os dedos da tela.
  - **Nota repetida:** continue segurando o(s) pisto(s); o novo "sopro" é reconhecido sozinho.
  - Ao acertar, a nota toca (som de tuba).
- **Pistões:** tuba de **3** ou **4** pistões (a digitação muda; com 4 alcança notas mais graves).
- **Afinação:** Si♭ (BBb), Dó (CC), Mi♭ (EEb) ou Fá (F). Mesma digitação, com o alcance deslocado.
- **Vozes:** soprano, contralto, tenor ou baixo. Todas soam uma oitava abaixo do escrito e são encaixadas no alcance da tuba. As outras vozes tocam sozinhas como acompanhamento (pode desligar).
- **Modos:** Normal (digitação) e Fácil (basta tocar no tempo). Velocidade do hino de 40% a 120%, tolerância de tempo, velocidade da queda, nomes das notas (Dó Ré Mi ou C D E), ajuste de atraso do som.
- **Partitura** em clave de Fá no topo, acompanhando a música.
- **Teclado (computador):** J K L ; (ou 1 2 3 4) = pistos, Esc = pausa.

## Publicar
Suba tudo no GitHub Pages. A cada versão nova, mude `CACHE_NAME` em `sw.js`.
Para o APK: Actions → "Gerar APK" (usa os mesmos *secrets* de assinatura dos outros apps).
Os hinos ficam em `hinos/` (arquivos .mxl + `index.json`).
