#if defined _mewjam_version_included_
#endinput
#endif
#define _mewjam_version_included_

#if defined MEWJAM_VERSION_IMPL
#error `MEWJAM_VERSION_IMPL` is already defined _X
#endif

#define MEWJAM_VERSION_IMPL(%1,%2,%3) %1 ... "." ... %2 ... "-r" ... %3
