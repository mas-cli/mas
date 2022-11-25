<h1 align="center"><img src="mas-cli.png" alt="mas-cli" width="450" height="auto"></h1>

# mas-cli

Uma interface de linha de comando simples para a Mac App Store. Projetado para scripts e automação.

[![Software License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/mas-cli/mas/blob/main/LICENSE)
[![Swift 5](https://img.shields.io/badge/Language-Swift_5-orange.svg)](https://swift.org)
[![GitHub Release](https://img.shields.io/github/release/mas-cli/mas.svg)](https://github.com/mas-cli/mas/releases)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Build, Test, & Lint](https://github.com/mas-cli/mas/actions/workflows/build-test.yml/badge.svg?branch=main)](https://github.com/mas-cli/mas/actions/workflows/build-test.yml?query=branch%3Amain)

## 📲 Install

### 🍺 Homebrew

[Homebrew](http://brew.sh) é a maneira preferida de instalar:

```bash
brew install mas
```

### MacPorts

[MacPorts](https://www.macports.org/install.php) funciona também:

```bash
sudo port install mas
```

⚠️ Observe que o macOS 10.15 (Catalina) é necessário para instalar o mas a partir do MacPorts ou da fórmula principal do Homebrew.

### ☎️ Versões mais antigas do macOS

Nós fornecemos um[custom Homebrew tap](https://github.com/mas-cli/homebrew-tap) com garrafas pré-construídas
para todas as versões do macOS desde 10.11.

Para instalar mas da nossa torneira:

```bash
brew install mas-cli/tap/mas
```

#### Suporte de tempo de execução do Swift 5

mas requer suporte de tempo de execução do Swift 5. O macOS 10.14.4 e posteriores o incluem, mas as versões anteriores não.
Sem ele, executar `mas` pode relatar um erro semelhante a este:
> dyld: Symbol not found: _$s11SubSequenceSlTl

Para obter suporte para Swift 5, você tem algumas opções:

- Instale o [Swift 5 Runtime Support for Command Line Tools](https://support.apple.com/kb/DL1998).
- Atualize para macOS 10.14.4 ou posterior.
- Instale o Xcode 10.2 ou posterior para `/Applications/Xcode.app`.

### 🐙 Lançamentos do GitHub

Como alternativa, os binários estão disponíveis no [GitHub Releases](https://github.com/mas-cli/mas/releases).

## 🤳🏻 Uso

Cada aplicativo na Mac App Store possui um identificador de produto que também é
usado para comandos mas-cli. Usando `mas list` vai mostrar todos instalados
aplicativos e seus identificadores de produto.

```bash
$ mas list
446107677 Screens
407963104 Pixelmator
497799835 Xcode
```

É possível pesquisar aplicativos pelo nome usando `mas search` que
pesquisará na Mac App Store e retornará identificadores correspondentes.
Incluir o `--price` flag para incluir preços no resultado.

```bash
$ mas search Xcode
497799835 Xcode
688199928 Docs for Xcode
449589707 Dash 3 - API Docs & Snippets. Integrates with Xcode, Alfred, TextWrangler and many more.
[...]
```

Outra maneira de encontrar o identificador de um aplicativo é

1. Encontre o aplicativo na Mac App Store
2. Selecione `Share` > `Copy Link`
3. Pegue o identificador da string, e.g. for Xcode,
   [https://apps.apple.com/us/app/xcode/id497799835?mt=12](https://apps.apple.com/us/app/xcode/id497799835?mt=12)
   tem identificador `497799835`

Para instalar ou atualizar um aplicativo basta executar `mas install` com um
identificador de aplicativo:

```bash
$ mas install 808809998
==> Downloading PaintCode 2
==> Installed PaintCode 2
```

Se você deseja instalar o primeiro resultado que o `search` o comando retorna, use o `lucky` comando.

```bash
$ mas lucky twitter
==> Downloading Twitter
==> Installed Twitter
```

> Observe que este comando não permitirá que você instale (ou mesmo compre) um aplicativo pela primeira vez:
use o `purchase` comando nesse caso.
> ⛔ o `purchase` O comando não é suportado a partir do macOS 10.15 Catalina. Por favor, veja [Known Issues](#%EF%B8%8F-known-issues).

```bash
$ mas purchase 768053424
==> Downloading Gapplin
==> Installed Gapplin
```

> Observe que você pode ter que se autenticar novamente na App Store para concluir a compra.
Este é o caso se o aplicativo não for gratuito ou se você configurou sua conta para não lembrar o
credenciais para compras gratuitas.

Use `mas outdated` para listar todos os aplicativos com atualizações pendentes.

```bash
$ mas outdated
497799835 Xcode (7.0)
446107677 Screens VNC - Access Your Computer From Anywhere (3.6.7)
```

> `mas` só é capaz de instalar/atualizar aplicativos listados na própria Mac App Store.
Usar [`softwareupdate(8)`] utilitário para baixar atualizações do sistema (e.g. Xcode Command Line Tools)

Para instalar todas as atualizações pendentes, execute `mas upgrade`.

```bash
$ mas upgrade
Upgrading 2 outdated applications:
Xcode (7.0), Screens VNC - Access Your Computer From Anywhere (3.6.7)
==> Downloading Xcode
==> Installed Xcode
==> Downloading iFlicks
==> Installed iFlicks
```

As atualizações podem ser realizadas seletivamente, fornecendo o(s) identificador(es) do aplicativo para
`mas upgrade`

```bash
$ mas upgrade 715768417
Upgrading 1 outdated application:
Xcode (8.0)
==> Downloading Xcode
==> Installed Xcode
```

### 🚏📥 Entrar

> ⛔ O `signin` O comando não é suportado a partir do macOS 10.13 High Sierra. Por favor, veja [Known Issues](#%EF%B8%8F-known-issues).

Para entrar na Mac App Store pela primeira vez, execute `mas signin`.

```bash
$ mas signin mas@example.com
==> Signing in to Apple ID: mas@example.com
Password:
```

Se você tiver problemas para fazer login dessa maneira, peça para fazer login usando uma caixa de diálogo gráfica
(fornecido pelo aplicativo Mac App Store):

```bash
$ mas signin --dialog mas@example.com
==> Signing in to Apple ID: mas@example.com
```

Você também pode incorporar sua senha no comando.

```bash
$ mas signin mas@example.com 'ZdkM4f$gzF;gX3ABXNLf8KcCt.x.np'
==> Signing in to Apple ID: mas@example.com
```

Use `mas signout` para sair da Mac App Store.

## 🍺 Homebrew integração

`mas` está integrado com [homebrew-bundle]. If `mas` está instalado e você executa `brew bundle dump`,
então seus aplicativos da Mac App Store serão incluídos no Brewfile criado. Veja o [homebrew-bundle]
docs para mais detalhes.

## ⚠️ Problemas conhecidos

Com o tempo, a Apple mudou as APIs usadas por `mas` para gerenciar aplicativos da App Store, limitando seus recursos. Por favor, inscreva-se
ou compre aplicativos usando o aplicativo da App Store. Novos downloads subsequentes podem ser executados com `mas install`.

- ⛔️ The `signin` O comando não é suportado a partir do macOS 10.13 High Sierra. [#164](https://github.com/mas-cli/mas/issues/164)
- ⛔️ The `purchase` O comando não é suportado a partir do macOS 10.15 Catalina. [#289](https://github.com/mas-cli/mas/issues/289)
- ⛔️ The `account` O comando não é suportado a partir do macOS 12 Monterey. [#417](https://github.com/mas-cli/mas/issues/417)

As versões `mas` vê nos pacotes de aplicativos em seu Mac nem sempre correspondem às versões relatadas pela App Store para
os mesmos pacotes de aplicativos. Isso leva a alguma confusão quando o `outdated` e `upgrade` ccomandos diferem em comportamento de
o que é mostrado como desatualizado no aplicativo da App Store. Assuntos ainda mais confusos, muitas vezes há algum atraso devido ao CDN
propagação e armazenamento em cache entre o momento em que uma nova versão do aplicativo é lançada na App Store e o momento em que aparece
disponível no aplicativo App Store ou através do `mas` comando. Esses problemas causam sintomas como
[#384](https://github.com/mas-cli/mas/issues/384) e [#387](https://github.com/mas-cli/mas/issues/387).

Os Macs com Apple Silicon podem instalar e executar aplicativos iOS e iPadOS da App Store. `mas` ainda não está ciente destes
aplicativos e ainda não é capaz de instalá-los ou atualizá-los. [#321](https://github.com/mas-cli/mas/issues/321)

## 💥 When something doesn't work

Se você vir esse erro, provavelmente é porque ainda não instalou o aplicativo pela App Store.
Se [#46](https://github.com/mas-cli/mas/issues/46#issuecomment-248581233).
> Este novo download não está disponível para este ID Apple porque foi comprado por um usuário diferente ou o
> item foi reembolsado ou cancelado.

Se `mas` não funciona para você como esperado (e.g. you can't update/download apps), run `mas reset` e tente novamente.
Se o problema persistir, por favor [file a bug](https://github.com/mas-cli/mas/issues/new).
Todos os seus comentários são muito apreciados! ✨

## 📺 Usando `tmux`

`mas` opera através dos mesmos serviços de sistema da Mac App Store. Estes existem como
processos separados com comunicação através de XPC. Como resultado disso, `mas`
apresenta problemas semelhantes aos da área de transferência ao executar dentro `tmux`. A
[wrapper tool exists](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard) para
corrigir o comportamento da área de trabalho, que também funciona para `mas`.

Você deve considerar a configuração `tmux` para usar o invólucro, mas se você não quiser
para isso, pode ser usado de forma pontual da seguinte forma:

```bash
brew install reattach-to-user-namespace
reattach-to-user-namespace mas install
```

## ℹ️ Construir a partir da fonte

Você pode compilar a partir do Xcode abrindo o diretório raiz `mas` ou a partir do Terminal:

```bash
script/bootstrap
script/build
```

A saída da compilação pode ser encontrada no diretório `.build/` dentro do projeto.

## ✅ Testes

Os testes neste projeto são um trabalho em andamento recente.
Como o Xcode não oferece suporte oficial a testes para alvos de ferramentas de linha de comando,
toda a lógica faz parte do alvo MasKit com testes em MasKitTests.
Os testes são escritos usando [Quick].

```bash
script/test
```

## 📄 Licença

mas-cli foi criado por [@argon](https://github.com/argon).
Código está sob o [MIT license](LICENSE).

[homebrew-bundle]: https://github.com/Homebrew/homebrew-bundle
[`softwareupdate(8)`]: https://www.unix.com/man-page/osx/8/softwareupdate/
[Quick]: https://github.com/Quick/Quick
