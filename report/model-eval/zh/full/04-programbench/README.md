# ProgramBench：200 个实例中文索引（无自然语言题面）

> 来源：HuggingFace 数据集 `programbench/ProgramBench-Tests`（目录列表，2026-11-02 拉取）、官方仓库 `facebookresearch/ProgramBench` @ commit `895f659`、官方站 <https://programbench.com/>。
> **重要事实：ProgramBench 没有「一段英文题面」。** 每个实例交给模型的只有两样东西——一个**只可执行、不可读**的二进制，和该程序的文档（README / man page / `--help` 输出）。所以不存在「把题面翻译成中文」这回事；本目录给出 200 个实例的中文索引与说明，题面/文档随镜像下发，不随仓库翻译。

## 1. 为什么这 200 题没有题面

| 环节 | ProgramBench 的做法 |
| :-- | :-- |
| 给什么 | 一个可执行二进制（只有执行权限，`strings`/`objdump`/反编译器全部失败）+ 该程序的文档 |
| 环境 | cleanroom：断网、无源码、无项目结构；模型自己选语言、自己搭代码库 |
| 交什么 | `/workspace/executable`（行为等价的新程序），整包为 `submission.tar.gz` |
| 怎么判 | 隐藏 pytest 黑盒调用可执行文件，逐条断言 stdout / stderr / 退出码 / 文件系统副作用；一个实例有多套独立测试分支 |

也就是说，模型的「题面」是**实验 + 文档阅读**：跑二进制、读文档、推断 CLI 契约（退出码、stderr 分流、帮助文本、数据库格式……），再自己实现。要人读的「题面中文版」在逻辑上不存在；能翻译的是**程序文档**，而文档随实例镜像/上游仓库分发（见 §2 的程序名，可到对应上游仓库看 README）。

## 2. 200 个实例清单（中文索引）

> `实例名` = `<owner>__<repo>.<commit7>`（`__` 替换为 `_1776_` 就是 Docker 镜像名）；`程序` 是被重建的 CLI 工具名。完整文档请查上游仓库或官方任务页。

| # | 实例名 | 上游 owner | 程序 | commit |
| --: | :-- | :-- | :-- | :-- |
| 1 | `abishekvashok__cmatrix.5c082c6` | abishekvashok | **cmatrix** | `5c082c6` |
| 2 | `agourlay__zip-password-finder.704700d` | agourlay | **zip-password-finder** | `704700d` |
| 3 | `ajeetdsouza__zoxide.67ca1bc` | ajeetdsouza | **zoxide** | `67ca1bc` |
| 4 | `alecthomas__chroma.8d04def` | alecthomas | **chroma** | `8d04def` |
| 5 | `alexpovel__srgn.89f943b` | alexpovel | **srgn** | `89f943b` |
| 6 | `altdesktop__i3-style.f93821b` | altdesktop | **i3-style** | `f93821b` |
| 7 | `ammarabouzor__tui-journal.2b4540d` | ammarabouzor | **tui-journal** | `2b4540d` |
| 8 | `anordal__shellharden.6a6ffd4` | anordal | **shellharden** | `6a6ffd4` |
| 9 | `antonmedv__fx.86d0d34` | antonmedv | **fx** | `86d0d34` |
| 10 | `antonmedv__walk.bf802ef` | antonmedv | **walk** | `bf802ef` |
| 11 | `ariga__atlas.6d81150` | ariga | **atlas** | `6d81150` |
| 12 | `arq5x__bedtools2.dd57059` | arq5x | **bedtools2** | `dd57059` |
| 13 | `arthursonzogni__json-tui.17a22b6` | arthursonzogni | **json-tui** | `17a22b6` |
| 14 | `ast-grep__ast-grep.dde0fe0` | ast-grep | **ast-grep** | `dde0fe0` |
| 15 | `astaxie__bat.17d1080` | astaxie | **bat** | `17d1080` |
| 16 | `astro__deadnix.d590041` | astro | **deadnix** | `d590041` |
| 17 | `axodotdev__oranda.27d60c7` | axodotdev | **oranda** | `27d60c7` |
| 18 | `bellard__quickjs.d7ae12a` | bellard | **quickjs** | `d7ae12a` |
| 19 | `bensadeh__tailspin.6278437` | bensadeh | **tailspin** | `6278437` |
| 20 | `blacknon__hwatch.edfcb62` | blacknon | **hwatch** | `edfcb62` |
| 21 | `blake3-team__blake3.15e83a5` | blake3-team | **blake3** | `15e83a5` |
| 22 | `bootandy__dust.62bf1e1` | bootandy | **dust** | `62bf1e1` |
| 23 | `boyter__scc.515f91c` | boyter | **scc** | `515f91c` |
| 24 | `brocode__fblog.3b54330` | brocode | **fblog** | `3b54330` |
| 25 | `burntsushi__ripgrep.3b7fd44` | burntsushi | **ripgrep** | `3b7fd44` |
| 26 | `burntsushi__xsv.f430466` | burntsushi | **xsv** | `f430466` |
| 27 | `byron__dua-cli.8570c15` | byron | **dua-cli** | `8570c15` |
| 28 | `canop__broot.d6c798e` | canop | **broot** | `d6c798e` |
| 29 | `canop__rhit.ae90bcb` | canop | **rhit** | `ae90bcb` |
| 30 | `cheat__cheat.b8098dc` | cheat | **cheat** | `b8098dc` |
| 31 | `chirlu__sox.42b3557` | chirlu | **sox** | `42b3557` |
| 32 | `chmln__handlr.90e78ba` | chmln | **handlr** | `90e78ba` |
| 33 | `chmln__sd.87d1ba5` | chmln | **sd** | `87d1ba5` |
| 34 | `clog-tool__clog-cli.7066cba` | clog-tool | **clog-cli** | `7066cba` |
| 35 | `cmatsuoka__figlet.202a0a8` | cmatsuoka | **figlet** | `202a0a8` |
| 36 | `codesnap-rs__codesnap.f81e4f3` | codesnap-rs | **codesnap** | `f81e4f3` |
| 37 | `cordx56__rustowl.655bc5c` | cordx56 | **rustowl** | `655bc5c` |
| 38 | `crowdagger__crowbook.ea214d7` | crowdagger | **crowbook** | `ea214d7` |
| 39 | `cslarsen__jp2a.61d205f` | cslarsen | **jp2a** | `61d205f` |
| 40 | `cweill__gotests.2a672c5` | cweill | **gotests** | `2a672c5` |
| 41 | `dalance__amber.69a0f52` | dalance | **amber** | `69a0f52` |
| 42 | `dandavison__delta.acd758f` | dandavison | **delta** | `acd758f` |
| 43 | `danmar__cppcheck.0a5b103` | danmar | **cppcheck** | `0a5b103` |
| 44 | `direnv__direnv.02040c7` | direnv | **direnv** | `02040c7` |
| 45 | `doxygen__doxygen.966d98e` | doxygen | **doxygen** | `966d98e` |
| 46 | `drew-alleman__datasurgeon.d257cee` | drew-alleman | **datasurgeon** | `d257cee` |
| 47 | `ducaale__xh.4a6e44f` | ducaale | **xh** | `4a6e44f` |
| 48 | `duckdb__duckdb.bdb65ec` | duckdb | **duckdb** | `bdb65ec` |
| 49 | `dundee__gdu.ede21d2` | dundee | **gdu** | `ede21d2` |
| 50 | `ecumene__rust-sloth.051c559` | ecumene | **rust-sloth** | `051c559` |
| 51 | `ekzhang__bore.8e059cd` | ekzhang | **bore** | `8e059cd` |
| 52 | `eliukblau__pixterm.1a93fd5` | eliukblau | **pixterm** | `1a93fd5` |
| 53 | `elkowar__pipr.fae0b17` | elkowar | **pipr** | `fae0b17` |
| 54 | `epistates__treemd.825c6dd` | epistates | **treemd** | `825c6dd` |
| 55 | `eradman__entr.8e2e8b4` | eradman | **entr** | `8e2e8b4` |
| 56 | `esubaalew__run.0fb9dec` | esubaalew | **run** | `0fb9dec` |
| 57 | `eudoxia0__hashcards.48aa136` | eudoxia0 | **hashcards** | `48aa136` |
| 58 | `facebook__zstd.1168da0` | facebook | **zstd** | `1168da0` |
| 59 | `facebookresearch__fasttext.1142dc4` | facebookresearch | **fasttext** | `1142dc4` |
| 60 | `ffmpeg__ffmpeg.360a402` | ffmpeg | **ffmpeg** | `360a402` |
| 61 | `filosottile__age.706dfc1` | filosottile | **age** | `706dfc1` |
| 62 | `foriequal0__git-trim.07c2f50` | foriequal0 | **git-trim** | `07c2f50` |
| 63 | `gabotechs__dep-tree.60a95a2` | gabotechs | **dep-tree** | `60a95a2` |
| 64 | `ggreer__the_silver_searcher.a61f178` | ggreer | **the_silver_searcher** | `a61f178` |
| 65 | `git-bahn__git-graph.87b4473` | git-bahn | **git-graph** | `87b4473` |
| 66 | `go-critic__go-critic.9aea378` | go-critic | **go-critic** | `9aea378` |
| 67 | `google__brotli.b3dc9cc` | google | **brotli** | `b3dc9cc` |
| 68 | `gromacs__gromacs.665ea4c` | gromacs | **gromacs** | `665ea4c` |
| 69 | `guumaster__hostctl.d6d9699` | guumaster | **hostctl** | `d6d9699` |
| 70 | `hairyhenderson__gomplate.05eb3aa` | hairyhenderson | **gomplate** | `05eb3aa` |
| 71 | `halitechallenge__halite.822cfb6` | halitechallenge | **halite** | `822cfb6` |
| 72 | `hatoo__oha.8dc6349` | hatoo | **oha** | `8dc6349` |
| 73 | `hooklift__gowsdl.2a06cec` | hooklift | **gowsdl** | `2a06cec` |
| 74 | `hpjansson__chafa.dd4d4c1` | hpjansson | **chafa** | `dd4d4c1` |
| 75 | `htop-dev__htop.523600b` | htop-dev | **htop** | `523600b` |
| 76 | `hush-shell__hush.560c33a` | hush-shell | **hush** | `560c33a` |
| 77 | `incu6us__goimports-reviser.81bd549` | incu6us | **goimports-reviser** | `81bd549` |
| 78 | `ip7z__7zip.839151e` | ip7z | **7zip** | `839151e` |
| 79 | `ismaelgv__rnr.fc0733b` | ismaelgv | **rnr** | `fc0733b` |
| 80 | `isona__dirble.e2dea9f` | isona | **dirble** | `e2dea9f` |
| 81 | `ivanceras__svgbob.6d00ad9` | ivanceras | **svgbob** | `6d00ad9` |
| 82 | `jarun__nnn.cb2c535` | jarun | **nnn** | `cb2c535` |
| 83 | `jesseduffield__lazygit.1d0db51` | jesseduffield | **lazygit** | `1d0db51` |
| 84 | `jgm__pandoc.5caad90` | jgm | **pandoc** | `5caad90` |
| 85 | `jhspetersson__fselect.c3559ca` | jhspetersson | **fselect** | `c3559ca` |
| 86 | `johanneskaufmann__html-to-markdown.3006818` | johanneskaufmann | **html-to-markdown** | `3006818` |
| 87 | `johnkerl__miller.8d85b46` | johnkerl | **miller** | `8d85b46` |
| 88 | `jonas__tig.8334123` | jonas | **tig** | `8334123` |
| 89 | `jqlang__jq.b33a763` | jqlang | **jq** | `b33a763` |
| 90 | `jrnxf__thokr.09375ef` | jrnxf | **thokr** | `09375ef` |
| 91 | `junegunn__fzf.b56d614` | junegunn | **fzf** | `b56d614` |
| 92 | `kaushiksrini__parqeye.8072121` | kaushiksrini | **parqeye** | `8072121` |
| 93 | `kisielk__errcheck.dacab89` | kisielk | **errcheck** | `dacab89` |
| 94 | `konradsz__igrep.aa75630` | konradsz | **igrep** | `aa75630` |
| 95 | `ksxgithub__parallel-disk-usage.96978ed` | ksxgithub | **parallel-disk-usage** | `96978ed` |
| 96 | `kyoh86__richgo.313114f` | kyoh86 | **richgo** | `313114f` |
| 97 | `kyoheiu__felix.95df390` | kyoheiu | **felix** | `95df390` |
| 98 | `lfos__calcurse.49180d5` | lfos | **calcurse** | `49180d5` |
| 99 | `lh3__seqtk.94e7070` | lh3 | **seqtk** | `94e7070` |
| 100 | `lua__lua.c6b4848` | lua | **lua** | `c6b4848` |
| 101 | `luajit__luajit.a553b3d` | luajit | **luajit** | `a553b3d` |
| 102 | `lymphatus__caesium-clt.a529b2e` | lymphatus | **caesium-clt** | `a529b2e` |
| 103 | `lz4__lz4.1519f46` | lz4 | **lz4** | `1519f46` |
| 104 | `madler__pigz.fe4894f` | madler | **pigz** | `fe4894f` |
| 105 | `mfridman__tparse.2416b4b` | mfridman | **tparse** | `2416b4b` |
| 106 | `mgdm__htmlq.6e31bc8` | mgdm | **htmlq** | `6e31bc8` |
| 107 | `mgechev__revive.201451e` | mgechev | **revive** | `201451e` |
| 108 | `mibk__dupl.1bf052b` | mibk | **dupl** | `1bf052b` |
| 109 | `mikefarah__yq.602586d` | mikefarah | **yq** | `602586d` |
| 110 | `miserlou__loop.209927c` | miserlou | **loop** | `209927c` |
| 111 | `mkj__dropbear.75f699b` | mkj | **dropbear** | `75f699b` |
| 112 | `mookid__diffr.2152742` | mookid | **diffr** | `2152742` |
| 113 | `multiprocessio__dsq.c3ae0ba` | multiprocessio | **dsq** | `c3ae0ba` |
| 114 | `nachoparker__dutree.44e877d` | nachoparker | **dutree** | `44e877d` |
| 115 | `naggie__dstask.ff57396` | naggie | **dstask** | `ff57396` |
| 116 | `nikoladucak__caps-log.2cf2d1e` | nikoladucak | **caps-log** | `2cf2d1e` |
| 117 | `nikolassv__bartib.6b9b5ce` | nikolassv | **bartib** | `6b9b5ce` |
| 118 | `ninja-build__ninja.cc60300` | ninja-build | **ninja** | `cc60300` |
| 119 | `noborus__ov.b96c2ba` | noborus | **ov** | `b96c2ba` |
| 120 | `noborus__trdsql.d8c5ff6` | noborus | **trdsql** | `d8c5ff6` |
| 121 | `nukesor__pueue.8b9d6fe` | nukesor | **pueue** | `8b9d6fe` |
| 122 | `nuta__nsh.bdd0702` | nuta | **nsh** | `bdd0702` |
| 123 | `o2sh__onefetch.e5958ce` | o2sh | **onefetch** | `e5958ce` |
| 124 | `ogham__dog.721440b` | ogham | **dog** | `721440b` |
| 125 | `oppiliappan__eva.41ae245` | oppiliappan | **eva** | `41ae245` |
| 126 | `oppiliappan__statix.e9df54c` | oppiliappan | **statix** | `e9df54c` |
| 127 | `orf__gping.26eb5b9` | orf | **gping** | `26eb5b9` |
| 128 | `osgeo__gdal.0847f12` | osgeo | **gdal** | `0847f12` |
| 129 | `osgeo__proj.75d455c` | osgeo | **proj** | `75d455c` |
| 130 | `paradigmxyz__solar.5190d0e` | paradigmxyz | **solar** | `5190d0e` |
| 131 | `parcel-bundler__lightningcss.aa2ed1e` | parcel-bundler | **lightningcss** | `aa2ed1e` |
| 132 | `peco__peco.4e58dad` | peco | **peco** | `4e58dad` |
| 133 | `pemistahl__grex.fa3e8ed` | pemistahl | **grex** | `fa3e8ed` |
| 134 | `php__php-src.c891263` | php | **php-src** | `c891263` |
| 135 | `pier-cli__pier.5e1bde9` | pier-cli | **pier** | `5e1bde9` |
| 136 | `pls-rs__pls.4e1ae50` | pls-rs | **pls** | `4e1ae50` |
| 137 | `psampaz__go-mod-outdated.bb79367` | psampaz | **go-mod-outdated** | `bb79367` |
| 138 | `quinn-rs__quinn.bb359cc` | quinn-rs | **quinn** | `bb359cc` |
| 139 | `raviqqe__muffet.a882908` | raviqqe | **muffet** | `a882908` |
| 140 | `rbakbashev__elfcat.52f8cc7` | rbakbashev | **elfcat** | `52f8cc7` |
| 141 | `rcoh__angle-grinder.9c2fc88` | rcoh | **angle-grinder** | `9c2fc88` |
| 142 | `rhysd__kiro-editor.4157485` | rhysd | **kiro-editor** | `4157485` |
| 143 | `riquito__tuc.16fb471` | riquito | **tuc** | `16fb471` |
| 144 | `robertdavidgraham__masscan.b99d433` | robertdavidgraham | **masscan** | `b99d433` |
| 145 | `rochacbruno__marmite.7d4bc2d` | rochacbruno | **marmite** | `7d4bc2d` |
| 146 | `rs__curlie.5dfcbb1` | rs | **curlie** | `5dfcbb1` |
| 147 | `rs__jplot.2a54bcc` | rs | **jplot** | `2a54bcc` |
| 148 | `rust-embedded__svd2rust.1760b5e` | rust-embedded | **svd2rust** | `1760b5e` |
| 149 | `rust-ethereum__ethabi.b1710ad` | rust-ethereum | **ethabi** | `b1710ad` |
| 150 | `rust-lang__mdbook.37273ba` | rust-lang | **mdbook** | `37273ba` |
| 151 | `rvben__rumdl.2d75c4d` | rvben | **rumdl** | `2d75c4d` |
| 152 | `samtools__samtools.aa823b5` | samtools | **samtools** | `aa823b5` |
| 153 | `sayanarijit__xplr.1751065` | sayanarijit | **xplr** | `1751065` |
| 154 | `sclevine__yj.8016400` | sclevine | **yj** | `8016400` |
| 155 | `segmentio__chamber.5f93f5f` | segmentio | **chamber** | `5f93f5f` |
| 156 | `sharkdp__bat.f822bd0` | sharkdp | **bat** | `f822bd0` |
| 157 | `sharkdp__fd.40d8eb3` | sharkdp | **fd** | `40d8eb3` |
| 158 | `sharkdp__hexyl.2e26437` | sharkdp | **hexyl** | `2e26437` |
| 159 | `sharkdp__hyperfine.327d5f4` | sharkdp | **hyperfine** | `327d5f4` |
| 160 | `sharkdp__pastel.b60e899` | sharkdp | **pastel** | `b60e899` |
| 161 | `shashwatah__jot.a92aad8` | shashwatah | **jot** | `a92aad8` |
| 162 | `sheepla__pingu.926d475` | sheepla | **pingu** | `926d475` |
| 163 | `sibprogrammer__xq.b89f681` | sibprogrammer | **xq** | `b89f681` |
| 164 | `sigoden__argc.04a08f1` | sigoden | **argc** | `04a08f1` |
| 165 | `simeg__eureka.df3796c` | simeg | **eureka** | `df3796c` |
| 166 | `sirwart__ripsecrets.34c9e03` | sirwart | **ripsecrets** | `34c9e03` |
| 167 | `sitkevij__hex.61ae69b` | sitkevij | **hex** | `61ae69b` |
| 168 | `skeema__skeema.6a76243` | skeema | **skeema** | `6a76243` |
| 169 | `sqlite__sqlite.839433d` | sqlite | **sqlite** | `839433d` |
| 170 | `sstadick__hck.b66c751` | sstadick | **hck** | `b66c751` |
| 171 | `stacked-git__stgit.430027d` | stacked-git | **stgit** | `430027d` |
| 172 | `stathissideris__ditaa.f2286c4` | stathissideris | **ditaa** | `f2286c4` |
| 173 | `stranger6667__jsonschema.d52e881` | stranger6667 | **jsonschema** | `d52e881` |
| 174 | `svenstaro__genact.16f96e3` | svenstaro | **genact** | `16f96e3` |
| 175 | `svenstaro__miniserve.8449e8b` | svenstaro | **miniserve** | `8449e8b` |
| 176 | `tarka__xcp.5e5b448` | tarka | **xcp** | `5e5b448` |
| 177 | `thezoraiz__ascii-image-converter.d05a757` | thezoraiz | **ascii-image-converter** | `d05a757` |
| 178 | `tinycc__tinycc.9b8765d` | tinycc | **tinycc** | `9b8765d` |
| 179 | `tomarrell__wrapcheck.c058da1` | tomarrell | **wrapcheck** | `c058da1` |
| 180 | `tomnomnom__gron.88a6234` | tomnomnom | **gron** | `88a6234` |
| 181 | `trasta298__keifu.3331426` | trasta298 | **keifu** | `3331426` |
| 182 | `tree-sitter__tree-sitter.5e23cca` | tree-sitter | **tree-sitter** | `5e23cca` |
| 183 | `tstack__lnav.ee34494` | tstack | **lnav** | `ee34494` |
| 184 | `tukaani-project__xz.1007bf0` | tukaani-project | **xz** | `1007bf0` |
| 185 | `typst__typst.88356d0` | typst | **typst** | `88356d0` |
| 186 | `unhappychoice__gittype.34b72d0` | unhappychoice | **gittype** | `34b72d0` |
| 187 | `universal-ctags__ctags.243595e` | universal-ctags | **ctags** | `243595e` |
| 188 | `wfxr__code-minimap.0ddeea5` | wfxr | **code-minimap** | `0ddeea5` |
| 189 | `wfxr__csview.8ac4de0` | wfxr | **csview** | `8ac4de0` |
| 190 | `wgunderwood__tex-fmt.3f1aef6` | wgunderwood | **tex-fmt** | `3f1aef6` |
| 191 | `wintermute-cell__ngrrram.8ea13c3` | wintermute-cell | **ngrrram** | `8ea13c3` |
| 192 | `xampprocky__tokei.505d648` | xampprocky | **tokei** | `505d648` |
| 193 | `xorg62__tty-clock.f2f847c` | xorg62 | **tty-clock** | `f2f847c` |
| 194 | `y2z__monolith.8702e66` | y2z | **monolith** | `8702e66` |
| 195 | `yaa110__nomino.f892499` | yaa110 | **nomino** | `f892499` |
| 196 | `yassinebridi__serpl.c48a9d7` | yassinebridi | **serpl** | `c48a9d7` |
| 197 | `yoav-lavi__melody.f4af9b4` | yoav-lavi | **melody** | `f4af9b4` |
| 198 | `ys-l__flamelens.0b4dc33` | ys-l | **flamelens** | `0b4dc33` |
| 199 | `zevv__duc.a58fa4e` | zevv | **duc** | `a58fa4e` |
| 200 | `zk-org__zk.10d93d5` | zk-org | **zk** | `10d93d5` |

## 3. 官方来源

- 官方站 / 榜单：<https://programbench.com/>（任务页含每个实例的历史最好成绩）
- 官方仓库：<https://github.com/facebookresearch/ProgramBench>
- 测试数据：HuggingFace `programbench/ProgramBench-Tests`（MIT、非 gated；每个实例一个 `tests/*.tar.gz`，2026-11-02 看到 200 个实例目录）
- 论文：<https://arxiv.org/abs/2605.03546>
- 五个基准中文总览与分册：[../../00-总览.md](../../00-总览.md)、[../../01-terminal-bench-4.zh.md](../../01-terminal-bench-4.zh.md)…

## 4. 与其它四个基准的差别

| | 题面 | 可翻译内容 |
| :-- | :-- | :-- |
| TB4 / DeepSWE / NL2Repo / Automation | 一段自然语言任务描述 | **是**，本目录其它子目录已逐题翻译 |
| ProgramBench | 二进制 + 文档（无任务描述） | **否**；只能翻译程序文档，而文档不随本仓库分发 |
