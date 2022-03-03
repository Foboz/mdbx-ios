/* This is CMake-template for libmdbx's version.c
 ******************************************************************************/

#include "internals.h"

#if MDBX_VERSION_MAJOR != 0 ||                             \
    MDBX_VERSION_MINOR != 11
#error "API version mismatch! Had `git fetch --tags` done?"
#endif

static const char sourcery[] = MDBX_STRINGIFY(MDBX_BUILD_SOURCERY);

__dll_export
#ifdef __attribute_used__
    __attribute_used__
#elif defined(__GNUC__) || __has_attribute(__used__)
    __attribute__((__used__))
#endif
#ifdef __attribute_externally_visible__
        __attribute_externally_visible__
#elif (defined(__GNUC__) && !defined(__clang__)) ||                            \
    __has_attribute(__externally_visible__)
    __attribute__((__externally_visible__))
#endif
    const struct MDBX_version_info mdbx_version = {
        0,
        11,
        5,
        0,
        {"2022-02-23T20:06:30+03:00", "68aed41e918246f54556dda5cfce00bceaff279b", "d01e44db0ca74724d3d6053807201dc544352c2b",
         "v0.11.5-0-gd01e44db"},
        sourcery};

__dll_export
#ifdef __attribute_used__
    __attribute_used__
#elif defined(__GNUC__) || __has_attribute(__used__)
    __attribute__((__used__))
#endif
#ifdef __attribute_externally_visible__
        __attribute_externally_visible__
#elif (defined(__GNUC__) && !defined(__clang__)) ||                            \
    __has_attribute(__externally_visible__)
    __attribute__((__externally_visible__))
#endif
    const char *const mdbx_sourcery_anchor = sourcery;
