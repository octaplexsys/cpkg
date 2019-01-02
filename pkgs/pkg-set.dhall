{- Dhall prelue imports -}
let concatMapSep = https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/Text/concatMapSep
in

{- cpkg prelude imports -}
let types = ../dhall/cpkg-types.dhall
in

let prelude = ../dhall/cpkg-prelude.dhall
in

{- gnupg: https://www.gnupg.org/ -}
let gpgPackage =
  λ(x : { name : Text, version : List Natural }) →
    prelude.simplePackage x ⫽
      { pkgUrl = "https://gnupg.org/ftp/gcrypt/${x.name}/${x.name}-${prelude.showVersion x.version}.tar.bz2" }
in

let gnupg =
  λ(v : List Natural) →
    gpgPackage { name = "gnupg", version = v } ⫽
      { pkgDeps = [ prelude.lowerBound { name = "npth", lower = [1,2] }
                  , prelude.lowerBound { name = "libgpg-error", lower = [1,24] }
                  , prelude.lowerBound { name = "libgcrypt", lower = [1,7,0] }
                  , prelude.lowerBound { name = "libassuan", lower = [2,5,0] }
                  , prelude.lowerBound { name = "libksba", lower = [1,3,4] }
                  ]
      , configureCommand = prelude.configureMkExes [ "tests/inittests", "tests/runtest", "tests/pkits/inittests" ]
      , installCommand = prelude.installWithBinaries [ "bin/gpg" ]
      }
in

let npth =
  λ(v : List Natural) →
    gpgPackage { name = "npth", version = v }
in

let libgpgError =
  λ(v : List Natural) →
    gpgPackage { name = "libgpg-error", version = v }
in

let libgcrypt =
  λ(v : List Natural) →
    gpgPackage { name = "libgcrypt", version = v } ⫽
      { pkgDeps = [ prelude.lowerBound { name = "libgpg-error", lower = [1,25] } ] }
in

let libassuan =
  λ(v : List Natural) →
    gpgPackage { name = "libassuan", version = v } ⫽
      { pkgDeps = [ prelude.lowerBound { name = "libgpg-error", lower = [1,24] } ] }
in

let libksba =
  λ(v : List Natural) →
    gpgPackage { name = "libksba", version = v } ⫽
      { pkgDeps = [ prelude.lowerBound { name = "libgpg-error", lower = [1,8] } ] }
in

{- musl: https://www.musl-libc.org/ -}
let musl =
  λ(v : List Natural) →
    prelude.simplePackage { name = "musl", version = v } ⫽
      { pkgUrl = "https://www.musl-libc.org/releases/musl-${prelude.showVersion v}.tar.gz"
      , installCommand = prelude.installWithBinaries [ "bin/musl-gcc" ]
      , configureCommand = prelude.configureMkExes [ "tools/install.sh" ]
      }
in

let binutils =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "binutils", version = v } ⫽
      { pkgUrl = "https://mirrors.ocf.berkeley.edu/gnu/binutils/binutils-${prelude.showVersion v}.tar.xz"
      , configureCommand = prelude.configureMkExes [ "mkinstalldirs" ]
      , installCommand =
          prelude.installWithBinaries [ "bin/ar", "bin/as", "bin/ld", "bin/strip", "bin/strings", "bin/readelf", "bin/objdump", "bin/nm", "bin/ranlib" ]
      }
in

let bison =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "bison", version = v } ⫽
      { configureCommand = prelude.configureMkExes [ "build-aux/move-if-change" ]
      , installCommand = prelude.installWithBinaries [ "bin/bison", "bin/yacc" ]
      , pkgBuildDeps = [ prelude.unbounded "m4" ]
      }
in

{- cmake https://cmake.org/ -}
let cmake =
  λ(cfg : { version : List Natural, patch : Natural }) →
    let patchString = Natural/show cfg.patch
    in
    let versionString = prelude.showVersion cfg.version
    in
    let cmakeConfigure =
      λ(cfg : types.BuildVars) →
        prelude.configureMkExesExtraFlags { bins = [ "bootstrap" ]
                                          , extraFlags = [ "--parallel=${Natural/show cfg.cpus}" ]
                                          } cfg
    in

    prelude.defaultPackage ⫽
      { pkgName = "cmake"
      , pkgVersion = prelude.fullVersion cfg
      , pkgUrl = "https://cmake.org/files/v${versionString}/cmake-${versionString}.${patchString}.tar.gz"
      , pkgSubdir = "cmake-${versionString}.${patchString}"
      , configureCommand = cmakeConfigure
      , installCommand = prelude.installWithBinaries [ "bin/cmake" ]
      }
in

let curl =
  λ(v : List Natural) →
    prelude.simplePackage { name = "curl", version = v } ⫽
      { pkgUrl = "https://curl.haxx.se/download/curl-${prelude.showVersion v}.tar.xz"
      , installCommand = prelude.installWithBinaries [ "bin/curl" ]
      }
in

let dbus =
  λ(v : List Natural) →
    prelude.simplePackage { name = "dbus", version = v } ⫽
      { pkgUrl = "https://dbus.freedesktop.org/releases/dbus/dbus-${prelude.showVersion v}.tar.gz"
      , pkgDeps = [ prelude.unbounded "expat"
                  , prelude.unbounded "libselinux"
                  ]
      , configureCommand = prelude.configureLinkExtraLibs [ "pcre" ]
      }
in

let fltk =
  λ(cfg : { version : List Natural, patch : Natural }) →

    let versionString = prelude.showVersion cfg.version
    in
    let patchString = Natural/show cfg.patch
    in

    prelude.defaultPackage ⫽
      { pkgName = "fltk"
      , pkgVersion = prelude.fullVersion cfg
      , pkgUrl = "http://fltk.org/pub/fltk/${versionString}/fltk-${versionString}-${patchString}-source.tar.bz2"
      , pkgSubdir = "fltk-${versionString}-${patchString}"
      }
in

let gawk =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "gawk", version = v } ⫽
      { configureCommand = prelude.configureMkExes [ "install-sh", "extension/build-aux/install-sh" ]
      , installCommand = prelude.installWithBinaries [ "bin/gawk", "bin/awk" ]
      }
in

let gc =
  λ(v : List Natural) →
    prelude.simplePackage { name = "gc", version = v } ⫽
        { pkgUrl = "https://github.com/ivmai/bdwgc/releases/download/v${prelude.showVersion v}/gc-${prelude.showVersion v}.tar.gz"
        , pkgDeps = [ prelude.unbounded "libatomic_ops" ]
        }
in

let libatomic_ops =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libatomic_ops", version = v } ⫽
        { pkgUrl = "https://github.com/ivmai/libatomic_ops/releases/download/v${prelude.showVersion v}/libatomic_ops-${prelude.showVersion v}.tar.gz" }
in

let git =
  λ(v : List Natural) →
    prelude.simplePackage { name = "git", version = v } ⫽
      { pkgUrl = "https://mirrors.edge.kernel.org/pub/software/scm/git/git-${prelude.showVersion v}.tar.xz"
      , configureCommand = prelude.configureMkExes [ "check_bindir" ]
      , installCommand = prelude.installWithBinaries [ "bin/git" ]
      , pkgBuildDeps = [ prelude.unbounded "gettext" ]
      }
in

let glibc =
  let buildDir =
    Some "build"
  in

  let glibcConfigure =
    λ(cfg : types.BuildVars) →

      let maybeHost = prelude.mkHost cfg.targetTriple
      in
      let modifyArgs = prelude.maybeAppend Text maybeHost
      in

      prelude.mkExes
        [ "configure", "scripts/mkinstalldirs", "scripts/rellns-sh" ]
          # [ prelude.createDir "build"
            , prelude.call { program = "../configure"
                           , arguments = modifyArgs [ "--prefix=${cfg.installDir}" ]
                           , environment = prelude.defaultEnv
                           , procDir = buildDir
                           }
            ]
  in

  let glibcBuild =
    λ(cfg : types.BuildVars) →
      [ prelude.call { program = prelude.makeExe cfg.buildOS
                     , arguments = [ "-j${Natural/show cfg.cpus}" ]
                     , environment = prelude.defaultEnv
                     , procDir = buildDir
                     }
      ]
  in

  let glibcInstall =
    λ(cfg : types.BuildVars) →
      [ prelude.call { program = prelude.makeExe cfg.buildOS
                     , arguments = [ "install" ]
                     , environment = prelude.defaultEnv
                     , procDir = buildDir
                     }
      ]
  in

  λ(v : List Natural) →
    prelude.defaultPackage ⫽
      { pkgName = "glibc"
      , pkgVersion = v
      , pkgUrl = "http://mirror.keystealth.org/gnu/libc/glibc-${prelude.showVersion v}.tar.xz"
      , pkgSubdir = "glibc-${prelude.showVersion v}"
      , configureCommand = glibcConfigure
      , buildCommand = glibcBuild
      , installCommand = glibcInstall
      , pkgBuildDeps = [ prelude.unbounded "bison", prelude.unbounded "gawk" ]
      }
in

let gmp =
  λ(v : List Natural) →
    prelude.simplePackage { name = "gmp", version = v } ⫽
      { pkgUrl = "https://gmplib.org/download/gmp/gmp-${prelude.showVersion v}.tar.xz"
      , configureCommand = prelude.configureMkExes [ "mpn/m4-ccas" ]
      , pkgBuildDeps = [ prelude.unbounded "m4" ]
      -- TODO: run 'make check'?
      }
in

let harfbuzz =
  let symlinkHarfbuzz =
    λ(h : Text) →
      prelude.symlink "include/harfbuzz/${h}" "include/${h}"
  in

  λ(v : List Natural) →
    prelude.simplePackage { name = "harfbuzz", version = v } ⫽
      { pkgUrl = "https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-${prelude.showVersion v}.tar.bz2"
      , pkgDeps = [ prelude.unbounded "freetype-prebuild"
                  , prelude.unbounded "glib"
                  ]
      , configureCommand = prelude.configureLinkExtraLibs [ "pcre", "z" ]
      , installCommand =
          λ(cfg : types.BuildVars) →
            prelude.defaultInstall cfg
              # [ symlinkHarfbuzz "hb-aat-layout.h"
                , symlinkHarfbuzz "hb-aat.h"
                , symlinkHarfbuzz "hb-blob.h"
                , symlinkHarfbuzz "hb-buffer.h"
                , symlinkHarfbuzz "hb-common.h"
                , symlinkHarfbuzz "hb-deprecated.h"
                , symlinkHarfbuzz "hb-face.h"
                , symlinkHarfbuzz "hb-font.h"
                , symlinkHarfbuzz "hb-ft.h"
                , symlinkHarfbuzz "hb-glib.h"
                , symlinkHarfbuzz "hb-icu.h"
                , symlinkHarfbuzz "hb-map.h"
                , symlinkHarfbuzz "hb-ot-color.h"
                , symlinkHarfbuzz "hb-ot-font.h"
                , symlinkHarfbuzz "hb-ot-layout.h"
                , symlinkHarfbuzz "hb-ot-math.h"
                , symlinkHarfbuzz "hb-ot-name.h"
                , symlinkHarfbuzz "hb-ot-shape.h"
                , symlinkHarfbuzz "hb-ot-var.h"
                , symlinkHarfbuzz "hb-ot.h"
                , symlinkHarfbuzz "hb-set.h"
                , symlinkHarfbuzz "hb-shape-plan.h"
                , symlinkHarfbuzz "hb-shape.h"
                , symlinkHarfbuzz "hb-subset.h"
                , symlinkHarfbuzz "hb-unicode.h"
                , symlinkHarfbuzz "hb-version.h"
                , symlinkHarfbuzz "hb.h"
                ]
      }
in

let jpegTurbo =
  λ(v : List Natural) →
    prelude.cmakePackage ⫽
      { pkgName = "libjpeg-turbo"
      , pkgVersion = v
      , pkgUrl = "https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-${prelude.showVersion v}.tar.gz"
      , pkgSubdir = "libjpeg-turbo-${prelude.showVersion v}"
      , pkgBuildDeps = [ prelude.unbounded "cmake" ]
      }
in

let libuv =
  λ(v : List Natural) →
    prelude.defaultPackage ⫽
      { pkgName = "libuv"
      , pkgVersion = v
      , pkgUrl = "https://dist.libuv.org/dist/v${prelude.showVersion v}/libuv-v${prelude.showVersion v}.tar.gz"
      , pkgSubdir = "libuv-v${prelude.showVersion v}"
      , configureCommand = prelude.autogenConfigure
      }
in

let nasm =
  λ(v : List Natural) →
    prelude.simplePackage { name = "nasm", version = v } ⫽
      { pkgUrl = "http://www.nasm.us/pub/nasm/releasebuilds/${prelude.showVersion v}/nasm-${prelude.showVersion v}.tar.xz"
      , installCommand = prelude.installWithBinaries [ "bin/nasm", "bin/ndisasm" ]
      }
in

let ncurses =
  λ(v : List Natural) →
    prelude.simplePackage { name = "ncurses", version = v } ⫽
      { pkgUrl = "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-${prelude.showVersion v}.tar.gz"
      , configureCommand = prelude.configureWithFlags [ "--disable-stripping", "--with-shared" ] -- we disable stripping because otherwise the script fails during cross-compilation
      }
in

let pcre2 =
  λ(v : List Natural) →
    prelude.simplePackage { name = "pcre2", version = v } ⫽
      { pkgUrl = "https://ftp.pcre.org/pub/pcre/pcre2-${prelude.showVersion v}.tar.bz2" }
in

let pcre =
  λ(v : List Natural) →
    prelude.simplePackage { name = "pcre", version = v } ⫽
      { pkgUrl = "https://ftp.pcre.org/pub/pcre/pcre-${prelude.showVersion v}.tar.bz2" }
in

let perl5 =
  let perlConfigure =
    λ(cfg : types.BuildVars) →
      [ prelude.mkExe "Configure"
      , prelude.call (prelude.defaultCall ⫽ { program = "./Configure"
                                            , arguments = [ "-des", "-Dprefix=${cfg.installDir}" ] # (if cfg.static then [] : List Text else [ "-Duseshrplib" ])
                                            })
      ]
  in

  λ(v : List Natural) →
    let major = Optional/fold Natural (List/head Natural v) Text (Natural/show) ""
    in

    prelude.simplePackage { name = "perl", version = v } ⫽
      { pkgUrl = "https://www.cpan.org/src/${major}.0/perl-${prelude.showVersion v}.tar.gz"
      , configureCommand = perlConfigure
      , installCommand =
        λ(cfg : types.BuildVars) →
          let libperlFile =
            if cfg.static
              then "libperl.a"
              else "libperl.so"
          in

          prelude.installWithBinaries [ "bin/perl", "bin/cpan" ] cfg
            # [ prelude.symlink "lib/${prelude.showVersion v}/${prelude.printArch cfg.buildArch}-${prelude.printOS cfg.buildOS}/CORE/${libperlFile}" "lib/${libperlFile}" ]
      }
in

let libpng =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libpng", version = v } ⫽
      { pkgUrl = "https://download.sourceforge.net/libpng/libpng-${prelude.showVersion v}.tar.xz"
      , pkgDeps = [ prelude.unbounded "zlib" ]
      }
in

let sed =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "sed", version = v } -- TODO: require pcre?
in

let tar =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "tar", version = v }
in

let unistring =
  λ(v : List Natural) →
    prelude.makeGnuLibrary { name = "unistring", version = v }
in

let valgrind =
  λ(v : List Natural) →
    prelude.simplePackage { name = "valgrind", version = v } ⫽
      { pkgUrl = "http://www.valgrind.org/downloads/valgrind-${prelude.showVersion v}.tar.bz2"
      , installCommand = prelude.installWithBinaries [ "bin/valgrind" ]
      , configureCommand = prelude.configureMkExes [ "auxprogs/make_or_upd_vgversion_h" ]
      }
in

let vim =
  λ(v : List Natural) →
    prelude.defaultPackage ⫽
      { pkgName = "vim"
      , pkgVersion = v
      , pkgUrl = "http://ftp.vim.org/vim/unix/vim-${prelude.showVersion v}.tar.bz2"
      , pkgSubdir = "vim${prelude.squishVersion v}"
      , configureCommand =
          prelude.configureMkExesExtraFlags { bins = [ "src/configure", "src/auto/configure", "src/which.sh" ]
                                            , extraFlags = [ "--enable-gui=no"
                                                           , "--enable-pythoninterp"
                                                           ]
                                            }
      , installCommand =
          λ(cfg : types.BuildVars) →
            let mkLibDynload =
              λ(libs : List Text) →
                concatMapSep ":" Text (λ(dir : Text) → "${dir}/python2.7/lib-dynload") libs
            in
            let mkPython =
              λ(libs : List Text) →
                concatMapSep ":" Text (λ(dir : Text) → "${dir}/python2.7/:${dir}/python2.7/lib-dynload") libs
            in
            -- TODO: change LD_RUN_PATH during build instead...
            -- or alternately, symlink lib-dynload stuff when installing python2??
            let wrapper = "LD_LIBRARY_PATH=${mkLibDynload cfg.linkDirs} PYTHONPATH=${mkPython cfg.linkDirs} ${cfg.installDir}/bin/vim $@"
            in
            let wrapped = "wrapper/vim"
            in

            prelude.installWithBinaries [ "bin/xxd" ] cfg
              # [ prelude.createDir "wrapper"
                , prelude.writeFile { file = wrapped, contents = wrapper }
                , prelude.mkExe wrapped
                , prelude.copyFile wrapped wrapped
                , prelude.symlinkBinary wrapped
                ]
      , pkgDeps = [ prelude.unbounded "ncurses"
                  , prelude.unbounded "libXpm"
                  , prelude.unbounded "libXt"
                  , prelude.unbounded "python2"
                  ]
      }
in

let xz =
  λ(v : List Natural) →
    prelude.simplePackage { name = "xz", version = v } ⫽
      { pkgUrl = "https://tukaani.org/xz/xz-${prelude.showVersion v}.tar.xz"
      , installCommand = prelude.installWithBinaries [ "bin/xz" ]
      }
in

let zlib =
  λ(v : List Natural) →

    let zlibConfigure =
      λ(cfg : types.BuildVars) →

        let host =
          prelude.mkCCVar cfg
        in

        [ prelude.mkExe "configure"
        , prelude.call (prelude.defaultCall ⫽ { program = "./configure"
                                              , arguments = [ "--prefix=${cfg.installDir}" ]
                                              , environment = Some (host # [ { var = "PATH", value = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" } ])
                                              })
        ]
    in

    prelude.simplePackage { name = "zlib", version = v } ⫽
      { pkgUrl = "http://www.zlib.net/zlib-${prelude.showVersion v}.tar.xz"
      , configureCommand = zlibConfigure
      }
in

let gettext =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "gettext", version = v } ⫽
      { installCommand = prelude.installWithBinaries [ "bin/gettext", "bin/msgfmt" ] }
in

let gzip =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "gzip", version = v }
in

let wget =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "wget", version = v } ⫽
      { pkgUrl = "https://ftp.gnu.org/gnu/wget/wget-${prelude.showVersion v}.tar.gz"
      , pkgDeps = [ prelude.unbounded "gnutls" ]
      , pkgBuildDeps = [ prelude.unbounded "perl" ]
      , configureCommand = prelude.configureMkExes [ "doc/texi2pod.pl" ]
      , installCommand =
          prelude.installWithWrappers [ "wget" ]
      }
in

let gnutls =
  λ(cfg : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion cfg.version
    in

    prelude.simplePackage { name = "gnutls", version = prelude.fullVersion cfg } ⫽
      { pkgUrl = "https://www.gnupg.org/ftp/gcrypt/gnutls/v${versionString}/gnutls-${versionString}.${Natural/show cfg.patch}.tar.xz"
      , pkgDeps = [ prelude.lowerBound { name = "nettle", lower = [3,1] }
                  , prelude.unbounded "unistring"
                  , prelude.lowerBound { name = "libtasn1", lower = [4,9] }
                  , prelude.lowerBound { name = "p11-kit", lower = [0,23,1] }
                  ]
      , configureCommand =
	λ(cfg : types.BuildVars) →
	  prelude.mkExes [ "src/gen-mech-list.sh" ]
	    # prelude.configureLinkExtraLibs [ "nettle", "hogweed" ] cfg
      }
in

let lapack =
  λ(v : List Natural) →
    prelude.cmakePackage ⫽
      { pkgName = "lapack"
      , pkgVersion = v
      , pkgUrl = "http://www.netlib.org/lapack/lapack-${prelude.showVersion v}.tar.gz"
      , pkgSubdir = "lapack-${prelude.showVersion v}"
      , pkgBuildDeps = [ prelude.unbounded "cmake" ]
      }
in

let cairo =
  let symlinkCairo =
    λ(h : Text) →
      prelude.symlink "include/cairo/${h}" "include/${h}"
  in

  λ(v : List Natural) →
    prelude.simplePackage { name = "cairo", version = v } ⫽
     { pkgUrl = "https://www.cairographics.org/releases/cairo-${prelude.showVersion v}.tar.xz"
     , pkgDeps = [ prelude.lowerBound { name = "pixman", lower = [0,30,0] }
                 , prelude.lowerBound { name = "freetype", lower = [9,7,3] }
                 , prelude.lowerBound { name = "fontconfig", lower = [2,2,95] }
                 , prelude.unbounded "libXext"
                 ]
     , installCommand =
        λ(cfg : types.BuildVars) →
          prelude.defaultInstall cfg #
            [ symlinkCairo "cairo-deprecated.h"
            , symlinkCairo "cairo-features.h"
            , symlinkCairo "cairo-ft.h"
            , symlinkCairo "cairo-gobject.h"
            , symlinkCairo "cairo-pdf.h"
            , symlinkCairo "cairo-ps.h"
            , symlinkCairo "cairo-script-interpreter.h"
            , symlinkCairo "cairo-script.h"
            , symlinkCairo "cairo-svg.h"
            , symlinkCairo "cairo-version.h"
            , symlinkCairo "cairo-xcb.h"
            , symlinkCairo "cairo-xlib-xrender.h"
            , symlinkCairo "cairo-xlib.h"
            , symlinkCairo "cairo.h"
            ]
     }
in

let pycairo =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    prelude.python2Package { name = "pycairo", version = v } ⫽
      { pkgUrl = "https://github.com/pygobject/pycairo/releases/download/v${versionString}/pycairo-${versionString}.tar.gz"
      , pkgDeps = [ prelude.unbounded "cairo" ]
      }
in

let libnettle =
  λ(v : List Natural) →
    prelude.simplePackage { name = "nettle", version = v } ⫽
      { pkgUrl = "https://ftp.gnu.org/gnu/nettle/nettle-${prelude.showVersion v}.tar.gz"
      , pkgBuildDeps = [ prelude.unbounded "m4" ]
      }
in

let m4 =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "m4", version = v }
in

let nginx =
  λ(v : List Natural) →
    prelude.simplePackage { name = "nginx", version = v } ⫽
      { pkgUrl = "http://nginx.org/download/nginx-${prelude.showVersion v}.tar.gz"
      , pkgDeps = [ prelude.unbounded "zlib", prelude.unbounded "pcre2" ]
      }
in

let openssl =
  λ(v : List Natural) →
    -- CC=arm-linux-gnueabihf-gcc ./Configure linux-armv4 works....
    prelude.simplePackage { name = "openssl", version = v } ⫽
      { pkgUrl = "https://www.openssl.org/source/openssl-${prelude.showVersion v}a.tar.gz"
      , configureCommand = prelude.generalConfigure prelude.configSome "config" ([] : List Text) ([] : List Text)
      , pkgSubdir = "openssl-${prelude.showVersion v}a"
      , pkgBuildDeps = [ prelude.unbounded "perl" ]
      }
in

let libssh2 =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libssh2", version = v } ⫽
      { pkgUrl = "https://www.libssh2.org/download/libssh2-${prelude.showVersion v}.tar.gz" }
in

let giflib =
  λ(v : List Natural) →
    prelude.simplePackage { name = "giflib", version = v } ⫽
      { pkgUrl = "https://downloads.sourceforge.net/giflib/giflib-${prelude.showVersion v}.tar.bz2" }
in

let emacs =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "emacs", version = v } ⫽
      { pkgDeps = [ prelude.unbounded "giflib"
                  , prelude.unbounded "libXaw"
                  , prelude.unbounded "libpng"
                  , prelude.unbounded "libjpeg-turbo"
                  , prelude.unbounded "ncurses"
                  , prelude.unbounded "gtk2"
                  , prelude.unbounded "libotf"
                  , prelude.unbounded "m17n-lib"
                  , prelude.unbounded "gnutls"
                  , prelude.unbounded "libXft"
                  , prelude.unbounded "dbus"
                  ]
      , configureCommand = prelude.configureMkExesExtraFlags
          { bins = [ "build-aux/move-if-change", "build-aux/update-subdirs" ]
          , extraFlags = [ "--with-tiff=no"
                         , "--with-libotf"
                         , "--with-m17n-flt"
                         , "--with-gnutls"
                         , "--with-xft"
                         , "--with-dbus"
                         ]
          }
      , installCommand =
          prelude.installWithWrappers [ "emacs" ]
      }
in

let which =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "which", version = v } ⫽
      { pkgUrl = "https://ftp.gnu.org/gnu/which/which-${prelude.showVersion v}.tar.gz" }
in

let automake =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "automake", version = v } ⫽
      { pkgBuildDeps = [ prelude.lowerBound { name =  "autoconf", lower = [2,65] } ]
      , installCommand = prelude.installWithBinaries [ "bin/automake", "bin/aclocal" ]
      }
in

let autoconf =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "autoconf", version = v } ⫽
      { pkgBuildDeps = [ prelude.lowerBound { name =  "m4", lower = [1,4,16] } ]
      , installCommand = prelude.installWithBinaries [ "bin/autoconf", "bin/autoheader", "bin/autom4te", "bin/autoreconf" ]
      }
in

let python =
  λ(v : List Natural) →
    let major = Optional/fold Natural (List/head Natural v) Text (Natural/show) ""
    in
    let versionString = prelude.showVersion v
    in

    prelude.simplePackage { name = "python${major}", version = v } ⫽
      { pkgUrl = "https://www.python.org/ftp/python/${versionString}/Python-${versionString}.tar.xz"
      , pkgSubdir = "Python-${versionString}"
      , configureCommand =
        λ(cfg : types.BuildVars) →
          let staticFlag =
            if cfg.static
              then [] : List Text
              else [ "--enable-shared" ]
          in
          prelude.configureWithFlags ([ "--build=${prelude.printArch cfg.buildArch}" ] # staticFlag) cfg
          -- "--enable-optimizations" (takes forever)
      , pkgDeps = [ prelude.unbounded "libffi" ]
      , installCommand = prelude.installWithBinaries [ "bin/python${major}" ]
      -- , installCommand =
          -- prelude.installWithWrappers [ "python${major}" ]
      }
in

let lua =
  λ(v : List Natural) →
    let printLuaOS =
      λ(os : types.OS) →
        merge
          { FreeBSD   = λ(_ : {}) → "freebsd"
          , OpenBSD   = λ(_ : {}) → "bsd"
          , NetBSD    = λ(_ : {}) → "bsd"
          , Solaris   = λ(_ : {}) → "solaris"
          , Dragonfly = λ(_ : {}) → "bsd"
          , Linux     = λ(_ : {}) → "linux"
          , Darwin    = λ(_ : {}) → "macosx"
          , Windows   = λ(_ : {}) → "mingw"
          , Redox     = λ(_ : {}) → "generic"
          , Haiku     = λ(_ : {}) → "generic"
          , IOS       = λ(_ : {}) → "generic"
          , AIX       = λ(_ : {}) → "generic"
          , Hurd      = λ(_ : {}) → "generic"
          , Android   = λ(_ : {}) → "generic"
          , NoOs      = λ(_ : {}) → "c89"
          }
          os
    in

    let luaBuild =
      λ(cfg : types.BuildVars) →
        let cc = prelude.mkCCArg cfg
        in

        let ldflags =
          (prelude.mkLDFlags cfg.linkDirs).value
        in

        let cflags =
          (prelude.mkCFlags cfg.includeDirs).value
        in

        let os =
          prelude.osCfg cfg
        in

        [ prelude.call (prelude.defaultCall ⫽ { program = "make"
                                              , arguments = cc # [ printLuaOS os, "MYLDFLAGS=${ldflags}", "MYCFLAGS=${cflags}", "MYLIBS=-lncurses", "-j${Natural/show cfg.cpus}" ]
                                              })
        ]
    in

    let luaInstall =
      λ(cfg : types.BuildVars) →
        [ prelude.call (prelude.defaultCall ⫽ { program = "make"
                                              , arguments = [ "install", "INSTALL_TOP=${cfg.installDir}" ]
                                              })
        ]
          # prelude.symlinkBinaries [ "bin/lua", "bin/luac" ]
    in

    prelude.simplePackage { name = "lua", version = v } ⫽
      { pkgUrl = "http://www.lua.org/ftp/lua-${prelude.showVersion v}.tar.gz"
      , configureCommand = prelude.doNothing
      , buildCommand = luaBuild
      , installCommand = luaInstall
      , pkgDeps = [ prelude.unbounded "readline"
                  , prelude.unbounded "ncurses"
                  ]
      }
in

let libtasn1 =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libtasn1", version = v } ⫽
      { pkgUrl = "https://ftp.gnu.org/gnu/libtasn1/libtasn1-${prelude.showVersion v}.tar.gz" }
in

let p11kit =
  λ(v : List Natural) →
    prelude.simplePackage { name = "p11-kit", version = v } ⫽
      { pkgUrl = "https://github.com/p11-glue/p11-kit/releases/download/${prelude.showVersion v}/p11-kit-${prelude.showVersion v}.tar.gz"
      , pkgDeps = [ prelude.lowerBound { name = "libffi", lower = [3,0,0] }
                  , prelude.unbounded "libtasn1"
                  ]
      }
in

let libffi =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libffi", version = v } ⫽
      { pkgUrl = "https://sourceware.org/ftp/libffi/libffi-${prelude.showVersion v}.tar.gz" }
in

let gdb =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "gdb", version = v } ⫽
      { configureCommand = prelude.configureMkExes [ "mkinstalldirs" ] }
in

let libtool =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "libtool", version = v } ⫽
      { pkgUrl = "http://ftpmirror.gnu.org/libtool/libtool-${prelude.showVersion v}.tar.gz"
      , pkgBuildDeps = [ prelude.lowerBound { name =  "m4", lower = [1,4,16] } ]
      }
in

let pkg-config =
  λ(v : List Natural) →
    prelude.simplePackage { name = "pkg-config", version = v } ⫽
      { pkgUrl = "https://pkg-config.freedesktop.org/releases/pkg-config-${prelude.showVersion v}.tar.gz"
      , installCommand = prelude.installWithBinaries [ "bin/pkg-config" ]
      }
in

let qrencode =
  λ(v : List Natural) →
    prelude.simplePackage { name = "qrencode", version = v } ⫽
      { pkgUrl = "https://fukuchi.org/works/qrencode/qrencode-${prelude.showVersion v}.tar.gz"
      , configureCommand = prelude.configureWithFlags [ "--without-tools" ]
      }
in

let readline =
  λ(v : List Natural) →
    prelude.simplePackage { name = "readline", version = v } ⫽
      { pkgUrl = "https://ftp.gnu.org/gnu/readline/readline-${prelude.showVersion v}.tar.gz" } -- TODO: should this depend on ncurses?
in

let pixman =
  λ(v : List Natural) →
    prelude.simplePackage { name = "pixman", version = v } ⫽
      { pkgUrl = "https://www.cairographics.org/releases/pixman-${prelude.showVersion v}.tar.gz"
      , pkgDeps = [ prelude.unbounded "libpng" ]
      }
in

let freetype-shared =
  λ(x : { name : Text, version : List Natural }) →
    let versionString = prelude.showVersion x.version
    in

    prelude.simplePackage x ⫽
      { pkgUrl = "https://download.savannah.gnu.org/releases/freetype/freetype-${versionString}.tar.gz"
      , configureCommand = prelude.configureMkExes [ "builds/unix/configure" ]
      , pkgSubdir = "freetype-${versionString}"
      , pkgBuildDeps = [ prelude.unbounded "sed" ]
      , installCommand =
          λ(cfg : types.BuildVars) →
            prelude.defaultInstall cfg
              # [ prelude.symlink "include/freetype2/ft2build.h" "include/ft2build.h"
                , prelude.symlink "include/freetype2/freetype" "include/freetype"
                ]
      }
in

let freetype-prebuild =
  λ(v : List Natural) →
    freetype-shared { name = "freetype-prebuild", version = v } -- FIXME: for some reason a zlib dep here breaks harfbuzz???
in

let freetype =
  λ(v : List Natural) →
    freetype-shared { name = "freetype", version = v } ⫽
      { pkgDeps = [ prelude.unbounded "zlib", prelude.unbounded "harfbuzz" ]
      , configureCommand = prelude.configureMkExesExtraFlags { bins = [ "builds/unix/configure" ]
                                                             , extraFlags = [ "--enable-freetype-config" ]
                                                             }
      }
in

let sdl2 =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v
    in

    prelude.simplePackage { name = "sdl2", version = v } ⫽
      { pkgUrl = "https://www.libsdl.org/release/SDL2-${versionString}.tar.gz"
      , pkgSubdir = "SDL2-${versionString}"
      }
in

let imageMagick =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v
    in
    let major = Optional/fold Natural (List/head Natural v) Text (Natural/show) ""
    in

    prelude.simplePackage { name = "imagemagick", version = v } ⫽
      { pkgUrl = "https://imagemagick.org/download/ImageMagick-${versionString}-21.tar.xz"
      , pkgSubdir = "ImageMagick-${versionString}-21"
      , installCommand =
          λ(cfg : types.BuildVars) →
            prelude.defaultInstall cfg
              # [ prelude.symlink "include/ImageMagick-${major}/MagickWand" "include/wand" ]
      }
in

let gtk2 =
  let gtkEnv =
    λ(cfg : types.BuildVars) →
      prelude.defaultPath cfg # [ { var = "LDFLAGS", value = (prelude.mkLDFlags cfg.linkDirs).value ++ " -lpcre -lfribidi" }
                                , prelude.mkCFlags cfg.includeDirs
                                , prelude.mkPkgConfigVar cfg.linkDirs
                                , prelude.libPath cfg
                                , prelude.mkLDRunPath cfg.linkDirs
                                , prelude.mkXdgDataDirs cfg.shareDirs
                                , prelude.mkLDPreload cfg.preloadLibs
                                ]
  in
  let gtkConfig =
    λ(cfg : types.BuildVars) →
      [ prelude.mkExe "configure"
      , prelude.call (prelude.defaultCall ⫽ { program = "./configure"
                                            , arguments = [ "--prefix=${cfg.installDir}" ]
                                            , environment = Some (gtkEnv cfg)
                                            })
      ]
  in

  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in

    prelude.simplePackage { name = "gtk2", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/gnome/sources/gtk+/${versionString}/gtk+-${fullVersion}.tar.xz"
      , pkgSubdir = "gtk+-${fullVersion}"
      , pkgDeps = [ prelude.lowerBound { name = "cairo", lower = [1,6] }
                  , prelude.lowerBound { name = "pango", lower = [1,20] }
                  , prelude.lowerBound { name = "atk", lower = [1,29,2] }
                  , prelude.lowerBound { name = "glib", lower = [2,28,0] }
                  , prelude.lowerBound { name = "gdk-pixbuf", lower = [2,38,0] }
                  ]
      , buildCommand =
          λ(cfg : types.BuildVars) →
            prelude.buildWith (gtkEnv cfg) cfg
      , configureCommand = gtkConfig
      , installCommand =
          λ(cfg : types.BuildVars) →
            prelude.defaultInstall cfg #
              [ prelude.symlink "include/gdk-pixbuf-2.0/gdk-pixbuf" "include/gdk-pixbuf" ]
      }
in

let mkXProto =
  λ(name : Text) →
  λ(v : List Natural) →
    prelude.simplePackage { name = name, version = v } ⫽
      { pkgUrl = "https://www.x.org/releases/individual/proto/${name}-${prelude.showVersion v}.tar.bz2" }
in

let xproto =
  mkXProto "xproto"
in

let renderproto =
  mkXProto "renderproto"
in

let randrproto =
  mkXProto "randrproto"
in

let scrnsaverproto =
  mkXProto "scrnsaverproto"
in

let pango =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in

    prelude.simplePackage { name = "pango", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/GNOME/sources/pango/${versionString}/pango-${fullVersion}.tar.xz"
      , configureCommand = prelude.mesonConfigure
      , buildCommand = prelude.ninjaBuild
      , installCommand =
          λ(cfg : types.BuildVars) →
            prelude.ninjaInstallWithPkgConfig (prelude.mesonMoves [ "pango.pc", "pangocairo.pc", "pangoft2.pc" ]) cfg
              # [ prelude.symlink "include/pango-1.0/pango" "include/pango" ]
      , pkgBuildDeps = [ prelude.lowerBound { name = "meson", lower = [0,48,0] }
                       , prelude.unbounded "gobject-introspection"
                       ]
      , pkgDeps = [ prelude.lowerBound { name = "fontconfig", lower = [2,11,91] }
                  , prelude.lowerBound { name = "cairo", lower = [1,12,10] }
                  , prelude.lowerBound { name = "fribidi", lower = [0,19,7] }
                  , prelude.lowerBound { name = "harfbuzz", lower = [1,4,2] }
                  , prelude.unbounded "libXrender"
                  , prelude.unbounded "libxcb"
                  ]
      }
in

let libxml2 =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libxml2", version = v } ⫽
     { pkgUrl = "http://xmlsoft.org/sources/libxml2-${prelude.showVersion v}.tar.gz"
     , configureCommand = prelude.configureWithFlags [ "--without-python" ]
     }
in

let shared-mime-info =
  λ(v : List Natural) →
    prelude.simplePackage { name = "shared-mime-info", version = v } ⫽
     { pkgUrl = "http://freedesktop.org/~hadess/shared-mime-info-${prelude.showVersion v}.tar.xz"
     , buildCommand =
        λ(cfg : types.BuildVars) →
          [ prelude.call (prelude.defaultCall ⫽ { program = prelude.makeExe cfg.buildOS
                                                , environment = Some (prelude.defaultPath cfg # [ prelude.libPath cfg
                                                                                                , prelude.mkLDRunPath cfg.linkDirs
                                                                                                , prelude.mkPerlLib { libDirs = cfg.linkDirs, perlVersion = [5,28,1], cfg = cfg }
                                                                                                ])
                                                })
          ]
     , pkgDeps = [ prelude.unbounded "glib"
                 , prelude.unbounded "libxml2"
                 ]
     , pkgBuildDeps = [ prelude.lowerBound { name = "intltool", lower = [0,35,0] }
                      , prelude.unbounded "sed"
                      ]
     }
in

let intltool =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    prelude.simplePackage { name = "intltool", version = v } ⫽
      { pkgUrl = "https://launchpad.net/intltool/trunk/${versionString}/+download/intltool-${versionString}.tar.gz"
      , configureCommand =
          λ(cfg : types.BuildVars) →
            [ prelude.mkExe "configure"
            , prelude.call (prelude.defaultCall ⫽ { program = "./configure"
                                                  , arguments = [ "--prefix=${cfg.installDir}" ]
                                                  , environment = Some (prelude.defaultPath cfg
                                                      # [ prelude.mkPerlLib { libDirs = cfg.linkDirs, perlVersion = [5,28,1], cfg = cfg } ])
                                                  })
            ]
    , pkgDeps = [ prelude.unbounded "XML-Parser" ]
    , pkgBuildDeps = [ prelude.upperBound { name = "perl", upper = [5,30] } ] -- lower bound: 5.8.1
    }
in

let gdk-pixbuf =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in

    let gdkInstall =
      λ(fs : List { src : Text, dest : Text }) →
      λ(cfg : types.BuildVars) →
        [ prelude.call (prelude.defaultCall ⫽ { program = "ninja"
                                              , environment = Some [ prelude.mkPkgConfigVar cfg.linkDirs
                                                                   , { var = "PATH", value = prelude.mkPathVar cfg.binDirs ++ ":${cfg.currentDir}/gdk-pixbuf-${fullVersion}/build/gdk-pixbuf:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }
                                                                   , prelude.mkPy3Path cfg.linkDirs
                                                                   , prelude.libPath cfg
                                                                   , prelude.mkLDRunPath cfg.linkDirs
                                                                   , prelude.mkLDFlags cfg.linkDirs
                                                                   , prelude.mkCFlags cfg.includeDirs
                                                                   ]
                                              , arguments = [ "install" ]
                                              , procDir = Some "build"
                                              })
        , prelude.symlink "include/gdk-pixbuf-2.0/gdk-pixbuf" "include/gdk-pixbuf"
        ] # prelude.copyFiles fs
    in

    prelude.simplePackage { name = "gdk-pixbuf", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/GNOME/sources/gdk-pixbuf/${versionString}/gdk-pixbuf-${fullVersion}.tar.xz"
      , configureCommand = prelude.mesonConfigure
      , buildCommand = prelude.ninjaBuild
      , installCommand =
          gdkInstall (prelude.mesonMoves [ "gdk-pixbuf-2.0.pc" ])
      , pkgDeps = [ prelude.unbounded "glib"
                  , prelude.unbounded "libjpeg-turbo"
                  , prelude.unbounded "libpng"
                  , prelude.unbounded "gobject-introspection"
                  , prelude.unbounded "shared-mime-info"
                  ]
      }
in

let xmlParser =
  λ(v : List Natural) →
    prelude.simplePackage { name = "XML-Parser", version = v } ⫽
     { pkgUrl = "https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-${prelude.showVersion v}.tar.gz"
     , configureCommand = prelude.perlConfigure
     , pkgBuildDeps = [ prelude.unbounded "perl" ]
     , pkgDeps = [ prelude.unbounded "expat" ]
     }
in

let meson =
  λ(v : List Natural) →
    prelude.simplePackage { name = "meson", version = v } ⫽
      { pkgUrl = "https://github.com/mesonbuild/meson/archive/${prelude.showVersion v}.tar.gz"
      , configureCommand =
          λ(cfg : types.BuildVars) →
            prelude.python3Install cfg # prelude.mkPy3Wrapper "meson" cfg
      , buildCommand = prelude.doNothing
      , installCommand = prelude.doNothing
      , pkgDeps = [ prelude.unbounded "python3" ]
      }
in

let ninja =
  let ninjaConfigure =
    λ(cfg : types.BuildVars) →
      [ prelude.mkExe "configure.py"
      , prelude.mkExe "src/inline.sh"
      , prelude.call (prelude.defaultCall ⫽ { program = "./configure.py"
                                            , arguments = [ "--bootstrap" ]
                                            })
      ]
  in

  let ninjaInstall =
    λ(cfg : types.BuildVars) →
      [ prelude.copyFile "ninja" "bin/ninja"
      , prelude.symlinkBinary "bin/ninja"
      ]
  in

  λ(v : List Natural) →
    prelude.simplePackage { name = "ninja", version = v } ⫽
      { pkgUrl = "https://github.com/ninja-build/ninja/archive/v${prelude.showVersion v}.tar.gz"
      , configureCommand = ninjaConfigure
      , buildCommand = prelude.doNothing
      , installCommand = ninjaInstall
      , pkgBuildDeps = [ prelude.unbounded "python2" ]
      }
in

let fontconfig =
  λ(v : List Natural) →
    prelude.simplePackage { name = "fontconfig", version = v } ⫽
      { pkgUrl = "https://www.freedesktop.org/software/fontconfig/release/fontconfig-${prelude.showVersion v}.tar.bz2"
      , pkgDeps = [ prelude.unbounded "freetype"
                  , prelude.unbounded "expat"
                  , prelude.unbounded "util-linux"
                  ]
      , pkgBuildDeps = [ prelude.unbounded "gperf" ]
      }
in

let util-linux =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
      prelude.simplePackage { name = "util-linux", version = v } ⫽
        { pkgUrl = "https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v${versionString}/util-linux-${versionString}.tar.xz"
        , configureCommand = prelude.configureWithFlags [ "--disable-makeinstall-chown" -- otherwise we'd need sudo permissions
                                                        , "--disable-bash-completion"
                                                        , "--disable-pylibmount" -- easier for cross-compiling
                                                        , "--without-tinfo" -- can't figure out what tinfo is or how to supply it when cross compiling
                                                        ]
        , pkgDeps = [ prelude.unbounded "ncurses" ]
        }
in

let fribidi =
  λ(v : List Natural) →
    prelude.simplePackage { name = "fribidi", version = v } ⫽
      { pkgUrl = "https://github.com/fribidi/fribidi/releases/download/v${prelude.showVersion v}/fribidi-${prelude.showVersion v}.tar.bz2" }
in

let gobject-introspection =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in

    prelude.simplePackage { name = "gobject-introspection", version = prelude.fullVersion x } ⫽
      { pkgUrl = "https://download.gnome.org/sources/gobject-introspection/${versionString}/gobject-introspection-${fullVersion}.tar.xz"
      , pkgBuildDeps = [ prelude.unbounded "flex" ]
      , configureCommand = prelude.configureLinkExtraLibs [ "pcre", "gobject-2.0", "gio-2.0" ]
      , pkgDeps = [ prelude.lowerBound { name = "glib", lower = [2,58,0] } ]
      }
in

let flex =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v
    in

    prelude.simplePackage { name = "flex", version = v } ⫽
      { pkgUrl = "https://github.com/westes/flex/releases/download/v${versionString}/flex-${versionString}.tar.gz"
      , pkgBuildDeps = [ prelude.unbounded "m4", prelude.unbounded "bison" ]
      }
in

let glib =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in

    let glibConfigure =
      λ(cfg : types.BuildVars) →
        let crossArgs =
          if cfg.isCross
            then [ "--cross-file", "cross.txt" ]
            else [] : List Text
        in

        [ prelude.createDir "build"
        , prelude.writeFile { file = "build/cross.txt", contents = prelude.mesonCfgFile cfg }
        , prelude.call { program = "meson"
                       , arguments = [ "--prefix=${cfg.installDir}", "..", "-Dselinux=false" ] # crossArgs
                       , environment = Some [ prelude.mkPkgConfigVar cfg.linkDirs
                                            , { var = "PATH", value = prelude.mkPathVar cfg.binDirs ++ "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }
                                            , { var = "LDFLAGS", value = (prelude.mkLDFlags cfg.linkDirs).value ++ " -lpcre" }
                                            , prelude.mkPy3Path cfg.linkDirs
                                            , prelude.libPath cfg
                                            , prelude.mkCFlags cfg.includeDirs
                                            , prelude.mkPkgConfigVar cfg.linkDirs
                                            ]
                       , procDir = Some "build"
                       }
        ]

    in

    let symlinkGio =
      λ(h : Text) →
        prelude.symlink "include/glib-2.0/gio/${h}" "include/gio/${h}"
    in

    let symlinkGunix =
      λ(h : Text) →
        prelude.symlink "include/gio-unix-2.0/gio/${h}" "include/gio/${h}"
    in

    prelude.simplePackage { name = "glib", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/gnome/sources/glib/${versionString}/glib-${fullVersion}.tar.xz"
      , configureCommand = glibConfigure
      , buildCommand =
        λ(cfg : types.BuildVars) →
          prelude.ninjaBuild cfg
            # prelude.mkExes [ "build/gobject/glib-mkenums"
                             , "build/gobject/glib-genmarshal"
                             , "build/gio/gdbus-2.0/codegen/gdbus-codegen"
                             , "build/glib-gettextize"
                             ]
      , installCommand =
          λ(cfg : types.BuildVars) →
            let libDir = "lib/${prelude.printArch cfg.buildArch}-${prelude.printOS cfg.buildOS}-gnu"
            in

            prelude.ninjaInstallWithPkgConfig (prelude.mesonMoves [ "glib-2.0.pc"
                                                                  , "gobject-2.0.pc"
                                                                  , "gio-2.0.pc"
                                                                  , "gio-unix-2.0.pc" -- TODO: only on unix
                                                                  , "gmodule-no-export-2.0.pc"
                                                                  , "gmodule-2.0.pc"
                                                                  , "gthread-2.0.pc"
                                                                  ]) cfg

              # [ prelude.symlink "${libDir}/libglib-2.0.so" "lib/libglib-2.0.so"
                , prelude.symlink "${libDir}/libgobject-2.0.so" "lib/libgobject-2.0.so"
                , prelude.symlink "${libDir}/libgio-2.0.so" "lib/libgio-2.0.so"
                , prelude.symlink "${libDir}/glib-2.0/include/glibconfig.h" "include/glibconfig.h"
                , prelude.symlink "include/glib-2.0/glib" "include/glib"
                , prelude.symlink "include/glib-2.0/gobject" "include/gobject"
                , prelude.symlink "include/glib-2.0/glib.h" "include/glib.h"
                , prelude.symlink "include/glib-2.0/glib-object.h" "include/glib-object.h"
                , prelude.symlink "include/glib-2.0/glib-unix.h" "include/glib-unix.h" -- TODO: only symlink on unix
                , prelude.symlink "include/glib-2.0/gmodule.h" "include/gmodule.h"
                , symlinkGio "gaction.h"
                , symlinkGio "gactiongroup.h"
                , symlinkGio "gactiongroupexporter.h"
                , symlinkGio "gactionmap.h"
                , symlinkGio "gappinfo.h"
                , symlinkGio "gapplication.h"
                , symlinkGio "gapplicationcommandline.h"
                , symlinkGio "gasyncinitable.h"
                , symlinkGio "gasyncresult.h"
                , symlinkGio "gbufferedinputstream.h"
                , symlinkGio "gbufferedoutputstream.h"
                , symlinkGio "gbytesicon.h"
                , symlinkGio "gcancellable.h"
                , symlinkGio "gcharsetconverter.h"
                , symlinkGio "gcontenttype.h"
                , symlinkGio "gconverter.h"
                , symlinkGio "gconverterinputstream.h"
                , symlinkGio "gconverteroutputstream.h"
                , symlinkGio "gcredentials.h"
                , symlinkGio "gdatagrambased.h"
                , symlinkGio "gdatainputstream.h"
                , symlinkGio "gdataoutputstream.h"
                , symlinkGio "gdbusactiongroup.h"
                , symlinkGio "gdbusaddress.h"
                , symlinkGio "gdbusauthobserver.h"
                , symlinkGio "gdbusconnection.h"
                , symlinkGio "gdbuserror.h"
                , symlinkGio "gdbusinterface.h"
                , symlinkGio "gdbusinterfaceskeleton.h"
                , symlinkGio "gdbusintrospection.h"
                , symlinkGio "gdbusmenumodel.h"
                , symlinkGio "gdbusmessage.h"
                , symlinkGio "gdbusmethodinvocation.h"
                , symlinkGio "gdbusnameowning.h"
                , symlinkGio "gdbusnamewatching.h"
                , symlinkGio "gdbusobject.h"
                , symlinkGio "gdbusobjectmanager.h"
                , symlinkGio "gdbusobjectmanagerclient.h"
                , symlinkGio "gdbusobjectmanagerserver.h"
                , symlinkGio "gdbusobjectproxy.h"
                , symlinkGio "gdbusobjectskeleton.h"
                , symlinkGio "gdbusproxy.h"
                , symlinkGio "gdbusserver.h"
                , symlinkGio "gdbusutils.h"
                , symlinkGio "gdrive.h"
                , symlinkGio "gdtlsclientconnection.h"
                , symlinkGio "gdtlsconnection.h"
                , symlinkGio "gdtlsserverconnection.h"
                , symlinkGio "gemblem.h"
                , symlinkGio "gemblemedicon.h"
                , symlinkGio "gfile.h"
                , symlinkGio "gfileattribute.h"
                , symlinkGio "gfileenumerator.h"
                , symlinkGio "gfileicon.h"
                , symlinkGio "gfileinfo.h"
                , symlinkGio "gfileinputstream.h"
                , symlinkGio "gfileiostream.h"
                , symlinkGio "gfilemonitor.h"
                , symlinkGio "gfilenamecompleter.h"
                , symlinkGio "gfileoutputstream.h"
                , symlinkGio "gfilterinputstream.h"
                , symlinkGio "gfilteroutputstream.h"
                , symlinkGio "gicon.h"
                , symlinkGio "ginetaddress.h"
                , symlinkGio "ginetaddressmask.h"
                , symlinkGio "ginetsocketaddress.h"
                , symlinkGio "ginitable.h"
                , symlinkGio "ginputstream.h"
                , symlinkGio "gio-autocleanups.h"
                , symlinkGio "gio.h"
                , symlinkGio "gioenums.h"
                , symlinkGio "gioenumtypes.h"
                , symlinkGio "gioerror.h"
                , symlinkGio "giomodule.h"
                , symlinkGio "gioscheduler.h"
                , symlinkGio "giostream.h"
                , symlinkGio "giotypes.h"
                , symlinkGio "glistmodel.h"
                , symlinkGio "gliststore.h"
                , symlinkGio "gloadableicon.h"
                , symlinkGio "gmemoryinputstream.h"
                , symlinkGio "gmemoryoutputstream.h"
                , symlinkGio "gmenu.h"
                , symlinkGio "gmenuexporter.h"
                , symlinkGio "gmenumodel.h"
                , symlinkGio "gmount.h"
                , symlinkGio "gmountoperation.h"
                , symlinkGio "gnativevolumemonitor.h"
                , symlinkGio "gnetworkaddress.h"
                , symlinkGio "gnetworking.h"
                , symlinkGio "gnetworkmonitor.h"
                , symlinkGio "gnetworkservice.h"
                , symlinkGio "gnotification.h"
                , symlinkGio "goutputstream.h"
                , symlinkGio "gpermission.h"
                , symlinkGio "gpollableinputstream.h"
                , symlinkGio "gpollableoutputstream.h"
                , symlinkGio "gpollableutils.h"
                , symlinkGio "gpropertyaction.h"
                , symlinkGio "gproxy.h"
                , symlinkGio "gproxyaddress.h"
                , symlinkGio "gproxyaddressenumerator.h"
                , symlinkGio "gproxyresolver.h"
                , symlinkGio "gremoteactiongroup.h"
                , symlinkGio "gresolver.h"
                , symlinkGio "gresource.h"
                , symlinkGio "gseekable.h"
                , symlinkGio "gsettings.h"
                , symlinkGio "gsettingsbackend.h"
                , symlinkGio "gsettingsschema.h"
                , symlinkGio "gsimpleaction.h"
                , symlinkGio "gsimpleactiongroup.h"
                , symlinkGio "gsimpleasyncresult.h"
                , symlinkGio "gsimpleiostream.h"
                , symlinkGio "gsimplepermission.h"
                , symlinkGio "gsimpleproxyresolver.h"
                , symlinkGio "gsocket.h"
                , symlinkGio "gsocketaddress.h"
                , symlinkGio "gsocketaddressenumerator.h"
                , symlinkGio "gsocketclient.h"
                , symlinkGio "gsocketconnectable.h"
                , symlinkGio "gsocketconnection.h"
                , symlinkGio "gsocketcontrolmessage.h"
                , symlinkGio "gsocketlistener.h"
                , symlinkGio "gsocketservice.h"
                , symlinkGio "gsrvtarget.h"
                , symlinkGio "gsubprocess.h"
                , symlinkGio "gsubprocesslauncher.h"
                , symlinkGio "gtask.h"
                , symlinkGio "gtcpconnection.h"
                , symlinkGio "gtcpwrapperconnection.h"
                , symlinkGio "gtestdbus.h"
                , symlinkGio "gthemedicon.h"
                , symlinkGio "gthreadedsocketservice.h"
                , symlinkGio "gtlsbackend.h"
                , symlinkGio "gtlscertificate.h"
                , symlinkGio "gtlsclientconnection.h"
                , symlinkGio "gtlsconnection.h"
                , symlinkGio "gtlsdatabase.h"
                , symlinkGio "gtlsfiledatabase.h"
                , symlinkGio "gtlsinteraction.h"
                , symlinkGio "gtlspassword.h"
                , symlinkGio "gtlsserverconnection.h"
                , symlinkGio "gvfs.h"
                , symlinkGio "gvolume.h"
                , symlinkGio "gvolumemonitor.h"
                , symlinkGio "gzlibcompressor.h"
                , symlinkGio "gzlibdecompressor.h"
                -- TODO: only do this on unix
                , symlinkGunix "gdesktopappinfo.h"
                , symlinkGunix "gfiledescriptorbased.h"
                , symlinkGunix "gunixconnection.h"
                , symlinkGunix "gunixcredentialsmessage.h"
                , symlinkGunix "gunixfdlist.h"
                , symlinkGunix "gunixfdmessage.h"
                , symlinkGunix "gunixinputstream.h"
                , symlinkGunix "gunixmounts.h"
                , symlinkGunix "gunixoutputstream.h"
                , symlinkGunix "gunixsocketaddress.h"
                ]

      , pkgBuildDeps = [ prelude.unbounded "meson"
                       , prelude.unbounded "ninja"
                       ]
      , pkgDeps = [ prelude.unbounded "util-linux"
                  , prelude.unbounded "pcre" -- >= 8.31
                  , prelude.unbounded "libffi"
                  , prelude.unbounded "zlib"
                  , prelude.unbounded "dbus"
                  ]
      }
in

let atk =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in

    prelude.ninjaPackage { name = "atk", version = prelude.fullVersion x } ⫽
      { pkgUrl = "https://ftp.gnome.org/pub/gnome/sources/atk/${versionString}/atk-${fullVersion}.tar.xz"
      , pkgBuildDeps = [ prelude.unbounded "gobject-introspection" ]
      , installCommand =
          prelude.ninjaInstallWithPkgConfig [{ src = "build/atk.pc", dest = "lib/pkgconfig/atk.pc" }]
      }
in

let re2c =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v
    in

    prelude.simplePackage { name = "re2c", version = v } ⫽
      { pkgUrl = "https://github.com/skvadrik/re2c/releases/download/${versionString}/re2c-${versionString}.tar.gz" }
in

let chickenScheme =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v
    in

    let printChickenOS =
      λ(os : types.OS) →
        merge
          { FreeBSD   = λ(_ : {}) → "bsd"
          , OpenBSD   = λ(_ : {}) → "bsd"
          , NetBSD    = λ(_ : {}) → "bsd"
          , Solaris   = λ(_ : {}) → "solaris"
          , Dragonfly = λ(_ : {}) → "bsd"
          , Linux     = λ(_ : {}) → "linux"
          , Darwin    = λ(_ : {}) → "macosx"
          , Windows   = λ(_ : {}) → "mingw"
          , Haiku     = λ(_ : {}) → "haiku"
          , IOS       = λ(_ : {}) → "ios"
          , AIX       = λ(_ : {}) → "aix"
          , Hurd      = λ(_ : {}) → "hurd"
          , Android   = λ(_ : {}) → "android"
          , Redox     = λ(_ : {}) → "error: no port for Redox OS"
          , NoOs      = λ(_ : {}) → "error: no port for no OS"
          }
          os
    in

    let chickenBuild =
      λ(cfg : types.BuildVars) →
        let cc =
          Optional/fold types.TargetTriple cfg.targetTriple (List Text)
            (λ(tgt : types.TargetTriple) → [ "C_COMPILER=${prelude.printTargetTriple tgt}-gcc" ])
              ([] : List Text)
        in
        let os =
          prelude.osCfg cfg
        in
        [ prelude.call (prelude.defaultCall ⫽ { program = prelude.makeExe cfg.buildOS
                                              , arguments = cc # [ "PLATFORM=${printChickenOS os}", "PREFIX=${cfg.installDir}" ]
                                              })
        , prelude.call (prelude.defaultCall ⫽ { program = prelude.makeExe cfg.buildOS
                                              , arguments = cc # [ "PLATFORM=${printChickenOS os}", "PREFIX=${cfg.installDir}", "install" ]
                                              })
        ]
          # prelude.symlinkBinaries [ "bin/csc", "bin/chicken-install", "bin/csi" ]
    in

    prelude.simplePackage { name = "chicken-scheme", version = v } ⫽
      { pkgUrl = "https://code.call-cc.org/releases/${versionString}/chicken-${versionString}.tar.gz"
      , configureCommand = prelude.doNothing
      , buildCommand = chickenBuild
      , installCommand = prelude.doNothing
      , pkgSubdir = "chicken-${versionString}"
      }
in

let xcb-proto =
  λ(v : List Natural) →
    prelude.simplePackage { name = "xcb-proto", version = v } ⫽
      { pkgUrl = "https://xorg.freedesktop.org/archive/individual/xcb/xcb-proto-${prelude.showVersion v}.tar.bz2" }
in

let libxcb =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libxcb", version = v } ⫽
      { pkgUrl = "https://xorg.freedesktop.org/archive/individual/xcb/libxcb-${prelude.showVersion v}.tar.bz2"
      , pkgDeps = [ prelude.lowerBound { name = "xcb-proto", lower = [1,13] }
                  , prelude.unbounded "libXau"
                  , prelude.unbounded "libpthread-stubs"
                  , prelude.unbounded "libXdmcp"
                  ]
      }
in

let libpthread-stubs =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libpthread-stubs", version = v } ⫽
      { pkgUrl = "https://www.x.org/archive/individual/xcb/libpthread-stubs-${prelude.showVersion v}.tar.bz2" }
in

let libXdmcp =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libXdmcp", version = v } ⫽
      { pkgUrl = "https://www.x.org/archive/individual/lib/libXdmcp-${prelude.showVersion v}.tar.bz2"
      , pkgDeps = [ prelude.unbounded "xproto" ]
      }
in

let libXau =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libXau", version = v } ⫽
      { pkgUrl = "https://www.x.org/archive/individual/lib/libXau-${prelude.showVersion v}.tar.bz2"
      , pkgDeps = [ prelude.unbounded "xproto" ]
      }
in

let xorgConfigure =
  prelude.configureWithFlags [ "--disable-malloc0returnsnull" ] -- necessary for cross-compilation
in

-- TODO: mkXLibWithDeps
let mkXLib =
  λ(name : Text) →
  λ(v : List Natural) →
    prelude.simplePackage { name = name, version = v } ⫽
      { pkgUrl = "https://www.x.org/releases/individual/lib/${name}-${prelude.showVersion v}.tar.bz2"
      , configureCommand = xorgConfigure
      }
in

let mkXLibDeps =
  λ(x : { name : Text, deps : List types.Dep }) →
  λ(v : List Natural) →
    mkXLib x.name v ⫽
      { pkgDeps = x.deps }
in

let mkXUtil =
  λ(name : Text) →
  λ(v : List Natural) →
    prelude.simplePackage { name = name, version = v } ⫽
      { pkgUrl = "https://www.x.org/releases/individual/util/${name}-${prelude.showVersion v}.tar.bz2" }
in

let libXrender =
  mkXLibDeps { name = "libXrender"
             , deps = [ prelude.unbounded "xproto"
                      , prelude.unbounded "renderproto"
                      , prelude.unbounded "libX11"
                      ]
             }
in

let util-macros =
  mkXUtil "util-macros"
in

let libXft =
  mkXLibDeps { name = "libXft"
             , deps = [ prelude.unbounded "freetype"
                      , prelude.unbounded "fontconfig"
                      , prelude.unbounded "libXrender"
                      , prelude.unbounded "libX11"
                      ]
             }
in

let kbproto =
  mkXProto "kbproto"
in

let libX11 =
  mkXLibDeps { name = "libX11"
             , deps = [ prelude.unbounded "libxcb"
                      , prelude.unbounded "kbproto"
                      , prelude.unbounded "xextproto"
                      , prelude.unbounded "inputproto"
                      , prelude.unbounded "xtrans"
                      ]
             }
in

let inputproto =
  mkXProto "inputproto"
in

let xineramaproto =
  mkXProto "xineramaproto"
in

let xtrans =
  mkXLib "xtrans"
in

let libXrandr =
  mkXLibDeps { name = "libXrandr"
             , deps = [ prelude.unbounded "util-macros"
                      , prelude.unbounded "libXext"
                      , prelude.unbounded "libXrender"
                      , prelude.unbounded "libX11"
                      , prelude.unbounded "randrproto"
                      ]
             }
in

let libXinerama =
  mkXLibDeps { name = "libXinerama"
             , deps = [ prelude.unbounded "util-macros"
                      , prelude.unbounded "libX11"
                      , prelude.unbounded "libXext"
                      , prelude.unbounded "xineramaproto"
                      ]
             }
in

let libXext =
  mkXLibDeps { name = "libXext"
             , deps = [ prelude.lowerBound { name = "xextproto", lower = [7,1,99] }
                      , prelude.lowerBound { name = "xproto", lower = [7,0,13] }
                      , prelude.lowerBound { name = "libX11", lower = [1,6] }
                      ]
             }
in

let xextproto =
  mkXProto "xextproto"
in

let libXScrnSaver =
  λ(v : List Natural) →
    mkXLib "libXScrnSaver" v ⫽
      { pkgDeps = [ prelude.unbounded "util-macros"
                  , prelude.unbounded "libXext" -- >= 1.2
                  , prelude.unbounded "scrnsaverproto" -- >= 1.2
                  ]
      }
in

let bzip2 =
  let cc = prelude.mkCCArg
  in
  let bzipInstall =
    λ(cfg : types.BuildVars) →
      [ prelude.call (prelude.defaultCall ⫽ { program = prelude.makeExe cfg.buildOS
                                            , arguments = cc cfg # [ "PREFIX=${cfg.installDir}", "install", "-j${Natural/show cfg.cpus}" ]
                                            })
      ]
  in

  λ(v : List Natural) →
    prelude.simplePackage { name = "bzip2", version = v } ⫽
      { pkgUrl = "https://cytranet.dl.sourceforge.net/project/bzip2/bzip2-${prelude.showVersion v}.tar.gz"
      , configureCommand = prelude.doNothing
      , buildCommand = prelude.doNothing
      , installCommand = bzipInstall
      }
in

let expat =
  let underscoreVersion =
    concatMapSep "_" Natural Natural/show
  in

  λ(v : List Natural) →
    prelude.simplePackage { name = "expat", version = v } ⫽
      { pkgUrl = "https://github.com/libexpat/libexpat/releases/download/R_${underscoreVersion v}/expat-${prelude.showVersion v}.tar.bz2" }
in

let gperf =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "gperf", version = v } ⫽
      { pkgUrl = "http://ftp.gnu.org/pub/gnu/gperf/gperf-${prelude.showVersion v}.tar.gz" }
in

let coreutils =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "coreutils", version = v } ⫽
      { installCommand = prelude.installWithBinaries [ "bin/install", "bin/chmod", "bin/rm", "bin/cp", "bin/ln", "bin/mkdir", "bin/test" ] }
in

let libsepol =
  let cc = prelude.mkCCArg
  in
  -- TODO: proper separation
  let sepolInstall =
    λ(cfg : types.BuildVars) →
      [ prelude.call (prelude.defaultCall ⫽ { program = prelude.makeExe cfg.buildOS
                                            , arguments = cc cfg # [ "PREFIX=${cfg.installDir}", "SHLIBDIR=${cfg.installDir}/lib", "EXTRA_CFLAGS=-Wno-error", "install", "-j${Natural/show cfg.cpus}" ]
                                            , environment =
                                                Some (prelude.defaultPath cfg # [ prelude.mkLDFlags cfg.linkDirs, prelude.mkCFlags cfg.includeDirs, prelude.mkPkgConfigVar cfg.linkDirs ])
                                            })
      ]
  in

  λ(v : List Natural) →
    prelude.simplePackage { name = "libsepol", version = v } ⫽
      { pkgUrl = "https://github.com/SELinuxProject/selinux/releases/download/20180524/libsepol-${prelude.showVersion v}.tar.gz"
      , configureCommand = prelude.doNothing
      , buildCommand = prelude.doNothing
      , installCommand = sepolInstall
      , pkgBuildDeps = [ prelude.unbounded "flex" ]
      }
in

let libselinux =
  let cc = prelude.mkCCArg
  in
  -- TODO: proper separation
  let selinuxInstall =
    λ(cfg : types.BuildVars) →
      [ prelude.call (prelude.defaultCall ⫽ { program = prelude.makeExe cfg.buildOS
                                            , arguments = cc cfg # [ "PREFIX=${cfg.installDir}", "SHLIBDIR=${cfg.installDir}/lib", "EXTRA_CFLAGS=-Wno-error -lpcre", "install", "-j${Natural/show cfg.cpus}" ]
                                            , environment =
                                                Some (prelude.defaultPath cfg # [ prelude.mkLDFlags cfg.linkDirs
                                                                                , prelude.mkCFlags cfg.includeDirs
                                                                                , prelude.mkPkgConfigVar cfg.linkDirs
                                                                                , prelude.libPath cfg
                                                                                ])
                                            })
      ]
  in

  λ(v : List Natural) →
    prelude.simplePackage { name = "libselinux", version = v } ⫽
      { pkgUrl = "https://github.com/SELinuxProject/selinux/releases/download/20180524/libselinux-${prelude.showVersion v}.tar.gz"
      , configureCommand = prelude.doNothing
      , buildCommand = prelude.doNothing
      , installCommand = selinuxInstall
      , pkgDeps = [ prelude.unbounded "pcre", prelude.unbounded "libsepol" ]
      }
in

let libXtst =
  mkXLibDeps { name = "libXtst"
             , deps = [ prelude.unbounded "libXi" ]
             }
in

let libXi =
  mkXLibDeps { name = "libXi"
             , deps = [ prelude.unbounded "libXext" ]
             }
in

let at-spi-core =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in

    prelude.ninjaPackage { name = "at-spi2-core", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/gnome/sources/at-spi2-core/${versionString}/at-spi2-core-${fullVersion}.tar.xz"
      , pkgDeps = [ prelude.unbounded "libXtst"
                  , prelude.unbounded "glib"
                  ]
      , installCommand =
          prelude.ninjaInstallWithPkgConfig [{ src = "build/atspi-2.pc", dest = "lib/pkgconfig/atspi-2.pc" }]
      }
in

let at-spi-atk =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in

    prelude.ninjaPackage { name = "at-spi2-atk", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/gnome/sources/at-spi2-atk/${versionString}/at-spi2-atk-${fullVersion}.tar.xz"
      , pkgDeps = [ prelude.unbounded "at-spi2-core"
                  , prelude.lowerBound { name = "atk", lower = [2,29,2] }
                  , prelude.unbounded "libxml2"
                  ]
      , installCommand =
          prelude.ninjaInstallWithPkgConfig (prelude.mesonMoves [ "atk-bridge-2.0.pc" ])
      }
in

let libdrm =
  λ(v : List Natural) →
    prelude.ninjaPackage { name = "libdrm", version = v } ⫽
      { pkgUrl = "https://dri.freedesktop.org/libdrm/libdrm-${prelude.showVersion v}.tar.bz2"
      , pkgDeps = [ prelude.unbounded "libpciaccess"
                  , prelude.unbounded "cairo"
                  ]
      }
in

let libpciaccess =
  mkXLib "libpciaccess"
in

let markupSafe =
  λ(v : List Natural) →
    prelude.python3Package { name = "MarkupSafe", version = v } ⫽
      { pkgUrl = "https://files.pythonhosted.org/packages/source/M/MarkupSafe/MarkupSafe-${prelude.showVersion v}.tar.gz" }
in

let mako =
  λ(v : List Natural) →
    prelude.python3Package { name = "Mako", version = v } ⫽
      { pkgUrl = "https://files.pythonhosted.org/packages/source/M/Mako/Mako-${prelude.showVersion v}.tar.gz" }
in

let elfutils =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    prelude.simplePackage { name = "elfutils", version = v } ⫽
      { pkgUrl = "https://sourceware.org/ftp/elfutils/${versionString}/elfutils-${versionString}.tar.bz2" }
in

let gtk3 =
  let gtkEnv =
    λ(cfg : types.BuildVars) →
      prelude.defaultPath cfg # [ { var = "LDFLAGS", value = (prelude.mkLDFlags cfg.linkDirs).value ++ " -lpcre -lfribidi" }
                                , prelude.mkCFlags cfg.includeDirs
                                , prelude.mkPkgConfigVar cfg.linkDirs
                                , prelude.libPath cfg
                                , prelude.mkLDRunPath cfg.linkDirs
                                , prelude.mkXdgDataDirs cfg.shareDirs
                                , prelude.mkLDPreload cfg.preloadLibs
                                ]
  in
  let gtkConfig =
    λ(cfg : types.BuildVars) →
      [ prelude.mkExe "configure"
      , prelude.call (prelude.defaultCall ⫽ { program = "./configure"
                                            , arguments = [ "--prefix=${cfg.installDir}" ]
                                            , environment = Some (gtkEnv cfg)
                                            })
      ]
  in

  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in
    prelude.simplePackage { name = "gtk3", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/gnome/sources/gtk+/${versionString}/gtk+-${fullVersion}.tar.xz"
      , pkgSubdir = "gtk+-${fullVersion}"
      , configureCommand = gtkConfig
      , buildCommand =
          λ(cfg : types.BuildVars) →
            prelude.buildWith (gtkEnv cfg) cfg
      , pkgDeps = [ prelude.lowerBound { name = "pango", lower = [1,41,0] }
                  , prelude.unbounded "at-spi2-atk"
                  , prelude.lowerBound { name = "atk", lower = [2,15,1] }
                  , prelude.lowerBound { name = "gdk-pixbuf", lower = [2,30,0] }
                  , prelude.unbounded "libXft"
                  ]
      }
in

let graphviz =
  λ(v : List Natural) →
    prelude.simplePackage { name = "graphviz", version = v } ⫽
      { pkgUrl = "https://graphviz.gitlab.io/pub/graphviz/stable/SOURCES/graphviz.tar.gz"
      , configureCommand = prelude.configureMkExes [ "iffe" ]
      , pkgDeps = [ prelude.unbounded "perl" ]
      , installCommand = prelude.installWithBinaries [ "bin/dot" ]
      }
in

let wayland =
  λ(v : List Natural) →
    prelude.simplePackage { name = "wayland", version = v } ⫽
      { pkgUrl = "https://wayland.freedesktop.org/releases/wayland-${prelude.showVersion v}.tar.xz"
      , pkgDeps = [ prelude.unbounded "libxml2" ]
      , configureCommand = prelude.configureWithFlags [ "--disable-documentation" ]
      }
in

let swig =
  λ(v : List Natural) →
    prelude.simplePackage { name = "swig", version = v } ⫽
      { pkgUrl = "https://downloads.sourceforge.net/swig/swig-${prelude.showVersion v}.tar.gz"
      , configureCommand = prelude.configureMkExes [ "Tools/config/install-sh" ]
      , installCommand = prelude.installWithBinaries [ "bin/swig" ]
      }
in

let lmdb =

  let cc = prelude.mkCCArg
  in

  let ar =
    λ(cfg : types.BuildVars) →
      Optional/fold types.TargetTriple cfg.targetTriple (List Text)
        (λ(tgt : types.TargetTriple) → ["AR=${prelude.printTargetTriple tgt}-ar"])
          ([] : List Text)
  in

  let lmdbInstall =
    λ(cfg : types.BuildVars) →
      [ prelude.call (prelude.defaultCall ⫽ { program = "make"
                                            , arguments = cc cfg # ar cfg # [ "prefix=${cfg.installDir}", "install", "-j${Natural/show cfg.cpus}" ]
                                            , procDir = Some "libraries/liblmdb" -- TODO: path on windows?
                                            })
      ]
  in

  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    prelude.simplePackage { name = "lmdb", version = v } ⫽
      { pkgUrl = "https://github.com/LMDB/lmdb/archive/LMDB_${versionString}.tar.gz"
      , pkgSubdir = "lmdb-LMDB_${versionString}"
      , configureCommand = prelude.doNothing
      , buildCommand = prelude.doNothing
      , installCommand = lmdbInstall
      }
in

let gsl =
  λ(v : List Natural) →
    prelude.simplePackage { name = "gsl", version = v } ⫽
      { pkgUrl = "http://gnu.mirror.constant.com/gsl/gsl-${prelude.showVersion v}.tar.gz" }
in

let postgresql =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    prelude.simplePackage { name = "postgresql", version = v } ⫽
      { pkgUrl = "https://ftp.postgresql.org/pub/source/v${versionString}/postgresql-${versionString}.tar.bz2"
      , configureCommand = prelude.configureWithFlags [ "--without-readline" ] -- TODO: set USE_DEV_URANDOM=1 or USE_WIN32_RANDOM=1 on windows
      }
in

let sqlite =
  λ(x : { year : Natural, version : List Natural }) →
    let versionString = prelude.squishVersion x.version in
    prelude.simplePackage { name = "sqlite", version = x.version } ⫽
      { pkgUrl = "https://sqlite.org/${Natural/show x.year}/sqlite-autoconf-${versionString}000.tar.gz"
      , pkgSubdir = "sqlite-autoconf-${versionString}000"
      }
in

let ragel =
  λ(v : List Natural) →
    prelude.simplePackage { name = "ragel", version = v } ⫽
      { pkgUrl = "http://www.colm.net/files/ragel/ragel-${prelude.showVersion v}.tar.gz"
      , installCommand = prelude.installWithBinaries [ "bin/ragel" ]
      }
in

let nano =
  λ(v : List Natural) →
    prelude.makeGnuExe { name = "nano", version = v } ⫽
      { pkgDeps = [ prelude.unbounded "ncurses" ] }
in

let libarchive =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libarchive", version = v } ⫽
      { pkgUrl = "https://www.libarchive.org/downloads/libarchive-${prelude.showVersion v}.tar.gz" }
in

let pygobject =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in
    prelude.simplePackage { name = "pygobject", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/gnome/sources/pygobject/${versionString}/pygobject-${fullVersion}.tar.xz"
      , pkgDeps = [ prelude.unbounded "glib" ]
      , configureCommand = prelude.preloadCfg
      }
in

let pygtk =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in
    prelude.simplePackage { name = "pygtk", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/gnome/sources/pygtk/${versionString}/pygtk-${fullVersion}.tar.bz2"
      , configureCommand =
          λ(cfg : types.BuildVars) →
            prelude.mkExes [ "py-compile" ]
              # prelude.preloadCfg cfg
      , pkgDeps = [ prelude.lowerBound { name = "glib", lower = [2,8,0] }
                  , prelude.lowerBound { name = "pygobject", lower = [2,21,3] }
                  , prelude.unbounded "python2"
                  ]
      }
in

let libglade =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in
    prelude.simplePackage { name = "libglade", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/gnome/sources/libglade/${versionString}/libglade-${fullVersion}.tar.bz2"
      , pkgDeps = [ prelude.lowerBound { name = "libxml2", lower = [2,4,10] }
                  , prelude.lowerBound { name = "gtk2", lower = [2,5,0] }
                  ]
      , configureCommand = prelude.configureLinkExtraLibs [ "fribidi" ]
      }
in

let scour =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    prelude.python3Package { name = "scour", version = v } ⫽
      { pkgUrl = "https://github.com/scour-project/scour/archive/v${versionString}/scour-${versionString}.tar.gz"
      , installCommand = prelude.installWithPy3Wrappers [ "scour" ]
      }
in

let libXpm =
  λ(v : List Natural) →
    mkXLib "libXpm" v ⫽
      { pkgDeps = [ prelude.unbounded "libXext"
                  , prelude.unbounded "libXt"
                  ]
      , pkgBuildDeps = [ prelude.unbounded "gettext" ]
      }
in

let libXt =
  mkXLibDeps { name = "libXt"
             , deps = [ prelude.unbounded "libICE"
                      , prelude.unbounded "libSM"
                      , prelude.unbounded "libX11"
                      , prelude.unbounded "kbproto"
                      ]
             }
in

let libICE =
  mkXLibDeps { name = "libICE"
             , deps = [ prelude.unbounded "xproto"
                      , prelude.unbounded "xtrans"
                      ]
             }
in

let libSM =
  mkXLibDeps { name = "libSM"
             , deps = [ prelude.unbounded "libICE" ]
             }
in

let libXaw =
  mkXLibDeps { name = "libXaw"
             , deps = [ prelude.unbounded "libXmu"
                      , prelude.unbounded "libXpm"
                      ]
             }
in

let libXmu =
  mkXLibDeps { name = "libXmu"
             , deps = [ prelude.unbounded "util-macros"
                      , prelude.unbounded "libXt"
                      , prelude.unbounded "libXext"
                      ]
             }
in

let libotf =
  λ(v : List Natural) →
    prelude.simplePackage { name = "libotf", version = v } ⫽
      { pkgUrl = "http://download.savannah.gnu.org/releases/m17n/libotf-${prelude.showVersion v}.tar.gz"
      , pkgDeps = [ prelude.unbounded "freetype" ]
      }
in

let m17n =
  λ(v : List Natural) →
    prelude.simplePackage { name = "m17n-lib", version = v } ⫽
      { pkgUrl = "http://download.savannah.gnu.org/releases/m17n/m17n-lib-${prelude.showVersion v}.tar.gz"
      , buildCommand =
        λ(cfg : types.BuildVars) →
          [ prelude.call (prelude.defaultCall ⫽ { program = prelude.makeExe cfg.buildOS }) ]
      }
in

let babl =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in
    prelude.simplePackage { name = "babl", version = prelude.fullVersion x } ⫽
      { pkgUrl = "https://download.gimp.org/pub/babl/${versionString}/babl-${fullVersion}.tar.bz2" }
in

let gegl =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in
    prelude.simplePackage { name = "gegl", version = prelude.fullVersion x } ⫽
      { pkgUrl = "https://download.gimp.org/pub/gegl/${versionString}/gegl-${fullVersion}.tar.bz2"
      , pkgDeps = [ prelude.lowerBound { name = "babl", lower = [0,1,58] }
                  , prelude.lowerBound { name = "glib", lower = [2,44,0] }
                  , prelude.unbounded "glib-json"
                  ]
      , configureCommand = prelude.preloadCfg
      }
in

let libexif =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    prelude.simplePackage { name = "libexif", version = v } ⫽
      { pkgUrl = "https://nchc.dl.sourceforge.net/project/libexif/libexif/${versionString}/libexif-${versionString}.tar.bz2" }
in

let glib-json =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in
    prelude.ninjaPackage { name = "glib-json", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://ftp.gnome.org/pub/gnome/sources/json-glib/${versionString}/json-glib-${fullVersion}.tar.xz"
      , pkgSubdir = "json-glib-${fullVersion}"
      , pkgDeps = [ prelude.unbounded "glib"
                  , prelude.unbounded "libjpeg-turbo"
                  , prelude.unbounded "libpng"
                  ]
      , installCommand =
          prelude.ninjaInstallWithPkgConfig (prelude.mesonMoves [ "json-glib-1.0.pc" ])
      }
in

let gimp =
  λ(x : { version : List Natural, patch : Natural }) →
    let versionString = prelude.showVersion x.version
    in
    let fullVersion = versionString ++ "." ++ Natural/show x.patch
    in
    prelude.simplePackage { name = "gimp", version = prelude.fullVersion x } ⫽
      { pkgUrl = "http://pirbot.com/mirrors/gimp/gimp/v${versionString}/gimp-${fullVersion}.tar.bz2"
      , pkgBuildDeps = [ prelude.lowerBound { name = "intltool", lower = [0,40,1] }
                       , prelude.lowerBound { name = "gtk2", lower = [2,24,10] }
                       , prelude.lowerBound { name = "gdk-pixbuf", lower = [2,30,8] }
                       , prelude.lowerBound { name = "cairo", lower = [1,12,2] }
                       , prelude.lowerBound { name = "fontconfig", lower = [2,12,4] }
                       , prelude.lowerBound { name = "babl", lower = [0,1,58] }
                       , prelude.lowerBound { name = "pygtk", lower = [2,10,4] }
                       , prelude.lowerBound { name = "pycairo", lower = [1,0,2] }
                       , prelude.lowerBound { name = "lcms2", lower = [2,8] }
                       , prelude.lowerBound { name = "gegl", lower = [0,4,12] }
                       , prelude.unbounded "libtiff"
                       , prelude.lowerBound { name = "libmypaint", lower = [1,3,0] }
                       ]
      , configureCommand = prelude.preloadCfg
      }
in

let lcms2 =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    prelude.simplePackage { name = "lcms2", version = v } ⫽
      { pkgUrl = "https://github.com/mm2/Little-CMS/archive/lcms${versionString}.tar.gz"
      , pkgSubdir = "Little-CMS-lcms${versionString}"
      }
in

let libtiff =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    -- TODO: use cmake + ninja build system if I ever figure out cross-compilation...
    prelude.simplePackage { name = "libtiff", version = v } ⫽
      { pkgUrl = "http://download.osgeo.org/libtiff/tiff-${versionString}.tar.gz"
      , pkgSubdir = "tiff-${versionString}"
      }
in

let libmypaint =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    prelude.simplePackage { name = "libmypaint", version = v } ⫽
      { pkgUrl = "https://github.com/mypaint/libmypaint/releases/download/v${versionString}/libmypaint-${versionString}.tar.xz"
      , pkgDeps = [ prelude.unbounded "json-c" ]
      , pkgBuildDeps = [ prelude.unbounded "intltool" ]
      }
in

let json-c =
  λ(x : { version : List Natural, dateStr : Text }) →
    let versionString = "${prelude.showVersion x.version}-${x.dateStr}"
    in
    prelude.simplePackage { name = "json-c", version = x.version } ⫽
      { pkgUrl = "https://github.com/json-c/json-c/archive/json-c-${versionString}.tar.gz"
      , pkgSubdir = "json-c-json-c-${versionString}"
      }
in

let poppler =
  λ(v : List Natural) →
    prelude.simplePackage { name = "poppler", version = v } ⫽ prelude.cmakePackage ⫽
      { pkgUrl = "https://poppler.freedesktop.org/poppler-${prelude.showVersion v}.tar.xz"
      , configureCommand =
        λ(cfg : types.BuildVars) →
          prelude.cmakeConfigureGeneral (prelude.configSome ([] : List Text))
            [ "-DFREETYPE_INCLUDE_DIRS=${(prelude.mkIncludePath cfg.linkDirs).value}"
            , "-DFREETYPE_LIBRARY=${(prelude.mkLDPath cfg.linkDirs).value}"
            , "-DJPEG_INCLUDE_DIR=${(prelude.mkIncludePath cfg.linkDirs).value}"
            , "-DJPEG_LIBRARY=${(prelude.mkLDPath cfg.linkDirs).value}"
            ]
            cfg
      , pkgDeps = [ prelude.unbounded "freetype"
                  , prelude.unbounded "fontconfig"
                  -- , prelude.unbounded "libjpeg-turbo"
                  , prelude.unbounded "libopenjpeg"
                  ]
      }
in

let libopenjpeg =
  λ(v : List Natural) →
    let versionString = prelude.showVersion v in
    prelude.simplePackage { name = "libopenjpeg", version = v } ⫽ prelude.cmakePackage ⫽
      { pkgUrl = "https://github.com/uclouvain/openjpeg/archive/v${versionString}.tar.gz"
      , pkgSubdir = "openjpeg-${versionString}"
      , installCommand =
          λ(cfg : types.BuildVars) →
            prelude.cmakeInstall cfg
              # [ prelude.symlink "lib/openjpeg-2.3/OpenJPEGConfig.cmake" "lib/OpenJPEGConfig.cmake" ]
      }
in

[ autoconf [2,69]
, automake [1,16,1]
, at-spi-atk { version = [2,30], patch = 0 }
, at-spi-core { version = [2,30], patch = 0 }
, atk { version = [2,30], patch = 0 }
, babl { version = [0,1], patch = 60 }
, binutils [2,31]
, bison [3,2,2]
, bzip2 [1,0,6]
, cairo [1,16,0]
, chickenScheme [5,0,0]
, cmake { version = [3,13], patch = 2 }
, coreutils [8,30]
, curl [7,62,0]
, dbus [1,12,10]
, elfutils [0,175]
, emacs [26,1]
, expat [2,2,6]
, fontconfig [2,13,1]
, flex [2,6,3]
, fltk { version = [1,3,4], patch = 2 }
, freetype-prebuild [2,9,1] -- TODO: force both to have same version?
, freetype [2,9,1]
, fribidi [1,0,5]
, gawk [4,2,1]
, gc [8,0,2]
, gdb [8,2]
, gdk-pixbuf { version = [2,38], patch = 0 }
, gegl { version = [0,4], patch = 12 }
, gettext [0,19,8]
, gperf [3,1]
, giflib [5,1,4]
, gimp { version = [2,10], patch = 8 }
, git [2,19,2]
, glib { version = [2,58], patch = 2 } -- TODO: bump to 2.59.0 once gobject-introspection supports it
, glib-json { version = [1,4], patch = 4 }
, glibc [2,28]
, gmp [6,1,2]
, gobject-introspection { version = [1,59], patch = 1 }
, gnupg [2,2,12]
, gnutls { version = [3,6], patch = 5 }
, graphviz [2,40,1]
, gsl [2,5]
, gtk2 { version = [2,24], patch = 32 }
, gtk3 { version = [3,24], patch = 2 }
, gzip [1,9]
, harfbuzz [2,3,0]
, imageMagick [7,0,8]
, inputproto [2,3,2]
, intltool [0,51,0]
, jpegTurbo [2,0,1]
, json-c { version = [0,13,1], dateStr = "20180305" }
, kbproto [1,0,7]
, lapack [3,8,0]
, lcms2 [2,9]
, libarchive [3,3,3]
, libassuan [2,5,2]
, libatomic_ops [7,6,8]
, libdrm [2,4,96]
, libexif [0,6,21]
, libffi [3,2,1]
, libgcrypt [1,8,4]
, libglade { version = [2,6], patch = 4 }
, libgpgError [1,33]
, libICE [1,0,9]
, libksba [1,3,5]
, libmypaint [1,3,0]
, libnettle [3,4,1]
, libpciaccess [0,14]
, libpng [1,6,35]
, libpthread-stubs [0,4]
, libopenjpeg [2,3,0]
, libotf [0,9,16]
, libselinux [2,8]
, libsepol [2,8]
, libssh2 [1,8,0]
, libtasn1 [4,13]
, libtiff [4,0,10]
, libtool [2,4,6]
, libuv [1,24,0]
, libSM [1,2,3]
, libX11 [1,6,7]
, libxcb [1,13]
, libXft [2,3,2]
, libxml2 [2,9,8]
, libXau [1,0,8]
, libXaw [1,0,13]
, libXdmcp [1,1,2]
, libXext [1,3,3]
, libXi [1,7]
, libXinerama [1,1,4]
, libXmu [1,1,2]
, libXpm [3,5,12]
, libXScrnSaver [1,2,3]
, libXrandr [1,5,1]
, libXrender [0,9,10]
, libXt [1,1,5]
, libXtst [1,2,3]
, lmdb [0,9,23]
, lua [5,3,5]
, m17n [1,8,0]
, m4 [1,4,18]
, mako [1,0,7]
, markupSafe [1,0]
, meson [0,49,0]
, musl [1,1,20]
, nano [3,2]
, nasm [2,14]
, ncurses [6,1]
, nginx [1,15,7]
, ninja [1,8,2]
, npth [1,6]
, openssl [1,1,1]
, p11kit [0,23,14]
, pango { version = [1,43], patch = 0 }
, pcre [8,42]
, pcre2 [10,32]
, perl5 [5,28,1]
, pixman [0,36,0]
, pkg-config [0,29,2]
, poppler [0,72,0]
, postgresql [11,1]
, pycairo [1,18,0]
, pygobject { version = [2,28], patch = 7 }
, pygtk { version = [2,24], patch = 0 }
, python [2,7,15]
, python [3,7,2]
, qrencode [4,0,2]
, ragel [6,10]
, randrproto [1,5,0]
, re2c [1,1,1]
, readline [7,0]
, renderproto [0,11,1]
, scour [0,37]
, scrnsaverproto [1,2,2]
, sdl2 [2,0,9]
, sed [4,5]
, shared-mime-info [1,10]
, sqlite { year = 2018, version = [3,26,0] }
, swig [3,0,12]
, tar [1,30]
, unistring [0,9,10]
, util-linux [2,33]
, util-macros [1,19,2]
, valgrind [3,14,0]
, vim [8,1]
, wayland [1,16,0]
, wget [1,20]
, which [2,21]
, xcb-proto [1,13]
, xextproto [7,3,0]
, xineramaproto [1,2]
, xmlParser [2,44]
, xproto [7,0,31]
, xtrans [1,3,5]
, xz [5,2,4]
, zlib [1,2,11]
]
