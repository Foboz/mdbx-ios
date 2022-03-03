/* This is CMake-template for libmdbx's config.h
 ******************************************************************************/

/* *INDENT-OFF* */
/* clang-format off */

#define LTO_ENABLED
/* #undef MDBX_USE_VALGRIND */
/* #undef ENABLE_GPROF */
/* #undef ENABLE_GCOV */
/* #undef ENABLE_ASAN */
/* #undef ENABLE_UBSAN */
#define MDBX_FORCE_ASSERTIONS 0

/* Common */
#define MDBX_TXN_CHECKOWNER 1
#define MDBX_ENV_CHECKPID_AUTO
#ifndef MDBX_ENV_CHECKPID_AUTO
#define MDBX_ENV_CHECKPID 0
#endif
#define MDBX_LOCKING_AUTO
#ifndef MDBX_LOCKING_AUTO
/* #undef MDBX_LOCKING */
#endif
#define MDBX_TRUST_RTC_AUTO
#ifndef MDBX_TRUST_RTC_AUTO
#define MDBX_TRUST_RTC 0
#endif
#define MDBX_DISABLE_PAGECHECKS 0

/* Windows */
#define MDBX_WITHOUT_MSVC_CRT 0

/* MacOS & iOS */
#define MDBX_OSX_SPEED_INSTEADOF_DURABILITY 0

/* POSIX */
#define MDBX_DISABLE_GNU_SOURCE 0
#define MDBX_USE_OFDLOCKS_AUTO
#ifndef MDBX_USE_OFDLOCKS_AUTO
#define MDBX_USE_OFDLOCKS 0
#endif

/* Build Info */
#ifndef MDBX_BUILD_TIMESTAMP
#define MDBX_BUILD_TIMESTAMP "2022-03-03T00:35:21Z"
#endif
#ifndef MDBX_BUILD_TARGET
#define MDBX_BUILD_TARGET "Darwin-iOS"
#endif
#ifndef MDBX_BUILD_TYPE
#define MDBX_BUILD_TYPE "<CONFIGURATION DEPENDENT>"
#endif
#ifndef MDBX_BUILD_COMPILER
#define MDBX_BUILD_COMPILER "Apple clang version 13.0.0 (clang-1300.0.29.30)"
#endif
#ifndef MDBX_BUILD_FLAGS
#define MDBX_BUILD_FLAGS " -fexceptions -fcxx-exceptions -frtti -fno-common -ggdb -Wno-unknown-pragmas -Wall -Wextra -Werror -flto=thin LIBMDBX_EXPORTS MDBX_BUILD_SHARED_LIBRARY=1 -ffast-math -fvisibility=hidden"
#endif
#define MDBX_BUILD_SOURCERY 6c4d894dab57b371b97f4deffd0943e367692232b8ace053cec44fd1aae843da_v0_11_5_0_gd01e44db

/* *INDENT-ON* */
/* clang-format on */
