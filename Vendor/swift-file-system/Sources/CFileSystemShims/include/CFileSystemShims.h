//
//  CFileSystemShims.h
//  swift-file-system
//
//  C shims for system calls not available through Swift's platform overlays.
//

#ifndef CFileSystemShims_h
#define CFileSystemShims_h

#include <stdint.h>

#ifdef __linux__

/// Attempts renameat2(AT_FDCWD, from, AT_FDCWD, to, RENAME_NOREPLACE).
/// Returns 0 on success, -1 on failure with errno stored in *out_errno.
int atomicfilewrite_renameat2_noreplace(
    const char *from,
    const char *to,
    int32_t *out_errno
);

#endif // __linux__

#endif // CFileSystemShims_h
