#if defined _mewjam_phrases_included_
#endinput
#endif
#define _mewjam_phrases_included_

#include <mewjam/info>

#if defined MEWJAM_MESSAGE_FILENAME
#error `MEWJAM_MESSAGE_FILENAME` is already defined _X
#endif
#if defined MEWJAM_MESSAGE_IMPL
#error `MEWJAM_MESSAGE_IMPL` is already defined _X
#endif
#if defined MEWJAM_MESSAGE_POISONED_ENVIRONMENT
#error `MEWJAM_MESSAGE_POISONED_ENVIRONMENT` is already defined _X
#endif
#if defined MEWJAM_MESSAGE_POISONED_ENVIRONMENT_PARAMS
#error `MEWJAM_MESSAGE_POISONED_ENVIRONMENT_PARAMS` is already defined _X
#endif
#if defined MEWJAM_MESSAGE_HEARTBEAT_STARTED
#error `MEWJAM_MESSAGE_HEARTBEAT_STARTED` is already defined _X
#endif
#if defined MEWJAM_MESSAGE_HEARTBEAT_STARTED_PARAMS
#error `MEWJAM_MESSAGE_HEARTBEAT_STARTED_PARAMS` is already defined _X
#endif
#if defined MEWJAM_MESSAGE_GAME_DATA_LOAD_FAILURE
#error `MEWJAM_MESSAGE_GAME_DATA_LOAD_FAILURE` is already defined _X
#endif
#if defined MEWJAM_MESSAGE_GAME_DATA_FIND_FAILURE
#error `MEWJAM_MESSAGE_GAME_DATA_FIND_FAILURE` is already defined _X
#endif
#if defined MEWJAM_MESSAGE_GAME_DATA_ENABLE_FAILURE
#error `MEWJAM_MESSAGE_GAME_DATA_ENABLE_FAILURE` is already defined _S
#endif

#define MEWJAM_MESSAGE_FILENAME MEWJAM_NAME_LOWER ... ".phrases"
#define MEWJAM_MESSAGE_IMPL(%1) MEWJAM_NAME ... " / " ... %1

#define MEWJAM_MESSAGE_POISONED_ENVIRONMENT MEWJAM_MESSAGE_IMPL("Poisoned Environment")
#define MEWJAM_MESSAGE_HEARTBEAT_STARTED MEWJAM_MESSAGE_IMPL("Heartbeat Started")
#define MEWJAM_MESSAGE_GAME_DATA_LOAD_FAILURE MEWJAM_MESSAGE_IMPL("Game Data Load Failure")
#define MEWJAM_MESSAGE_GAME_DATA_FIND_FAILURE MEWJAM_MESSAGE_IMPL("Game Data Find Failure")
#define MEWJAM_MESSAGE_GAME_DATA_ENABLE_FAILURE MEWJAM_MESSAGE_IMPL("Game Data Enable Failure")
