# Need CMD, INFILE, TARGET variables
message(STATUS "Running ${CMD} ${ARGS} with input ${INFILE}")
execute_process(COMMAND ${CMD} ${ARGS}
    INPUT_FILE ${INFILE}
    OUTPUT_FILE tmp
    #OUTPUT_VARIABLE CMD_RESULT
    ERROR_VARIABLE CMD_ERROR 
    RESULT_VARIABLE CMD_RETCODE)
if (CMD_RETCODE)
    message(FATAL_ERROR "Command ${CMD} failed: Code ${CMD_RETCODE}, error: ${CMD_ERROR}")
endif()
#file(WRITE tmp "${CMD_RESULT}")
execute_process(COMMAND ${CMAKE_COMMAND} 
    -E compare_files tmp ${TARGET}
    RESULT_VARIABLE CMP_RETCODE
    ERROR_VARIABLE CMP_ERROR)
if(CMP_RETCODE)
    file(WRITE ${TARGET}.testout "${CMD_RESULT}")       
    message(FATAL_ERROR "Test binary ${CMD} failed: Code ${CMP_RETCODE}, error: ${CMP_ERROR}")
endif()
file(REMOVE tmp)