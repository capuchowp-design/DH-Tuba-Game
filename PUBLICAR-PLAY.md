# Publicar o DH Tuba Game na Google Play

## Versões
| Canal | Grátis | Como libera o resto |
|---|---|---|
| **Google Play** (AAB) | hinos 1–10 completos; demais com 15 s de prévia | anúncio premiado (1 hino por 1 h) + Pro opcional pela Play (`playCompra`) |
| **APK** (site/APKPure) e **PWA** | hinos 1–50 completos; demais 15 s | Pix → código na planilha (1 código = 1 aparelho) |

Os números ficam em `pro-config.js` (`freeHinos`, `freeHinosPlay`, `previewSec`, `adHoras`).
Na versão da Play o Pix e o WhatsApp são removidos do app automaticamente (a Play exige cobrança só pelo Google).

## Antes do primeiro build da Play
1. **AdMob**: crie um app "DH Tuba Game" (Android) e um bloco **Premiado**. Troque:
   - `adRewardedId` em `pro-config.js`;
   - `ADMOB_APP_ID` em `.github/workflows/build-apk.yml`.
   (Os valores que vêm no projeto são IDs de TESTE do Google. O build de produção é recusado com eles.)
2. **Play Console**: crie o app, depois **Monetizar → Produtos → Produtos no app** com ID `pro_desbloqueio` (preço sugerido R$ 19,90). Ou ponha `playCompra:false` para ter só anúncio.
3. **Secrets do GitHub**: `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS` (o `gerar-apk.sh` já cria). A Play exige o `.aab` assinado.
4. Publique `app-ads.txt` na raiz do site do desenvolvedor.
5. **Planilha**: use a mesma do Trompete (veja `planilha-pro/COMO-CONFIGURAR.md` do projeto do trompete). No menu da planilha, **Gerar códigos novos…** com o app `tuba`. O código do trompete não vale na tuba.

## Gerar
Actions → **Gerar APK** → Run workflow (ou, no Codespace, `bash gerar-apk.sh ...`):
- `canal = play` + `anuncios_teste` marcado → AAB de teste (faixa interna): `bash gerar-apk.sh play`
- `canal = play` + desmarcado → AAB de produção: `bash gerar-apk.sh play producao`
- `canal = apkpure` → APK com Pix: `bash gerar-apk.sh`

## Formulários da Play
- **Anúncios**: sim. **Segurança dos dados**: ID de publicidade/dispositivo (anúncios); compras. Política de privacidade: `privacy.html` publicado no GitHub Pages.
- Classificação de conteúdo e público-alvo como nos outros apps.
