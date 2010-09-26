#message("Adding dependencies")

#message("CMAKE_D_FLAGS:  ${CMAKE_D_FLAGS} ")
#message("CMAKE_D_COMPILER:  ${CMAKE_D_COMPILER} ")
#message("include_directories:  ${include_directories} ")
#message("source file ${source_file}")
#message("dependency file ${dependency_file}")

execute_process(COMMAND ${CMAKE_D_COMPILER} ${include_directories} -deps=${dependency_file}.tmp -o- ${source_file})
#message("executing:  ${CMAKE_D_COMPILER} ${CMAKE_D_FLAGS} ${include_directories} -deps=${dependency_file}.tmp -o- ${source_file}")

if(NOT EXISTS ${dependency_file})
	file(WRITE ${dependency_file} "# Generated by: ${CMAKE_CURRENT_LIST_FILE}\nSET(D_DMD_DEPEND\n)\n\n")
endif()

file(READ ${dependency_file}.tmp depend_text)
#message("DEPENDENCIES: ${depend_text}")

# extract dependencies
string(REGEX MATCHALL "\\([^)]*\\)" out ${depend_text})
string(REGEX MATCHALL "[^()]+" out ${out})
list(REMOVE_DUPLICATES out)
list(SORT out)

foreach(file ${out})
	set(dependencies "${dependencies} \"${file}\"\n")
endforeach()

# write new dependencies to temporary file
file(WRITE ${dependency_file}.tmp "# Generated by: ${CMAKE_CURRENT_LIST_FILE}\nSET(D_DMD_DEPEND\n ${dependencies})\n\n")

# get old dependencies
include(${dependency_file})
set(old_dependencies ${D_DMD_DEPEND})
# and the new dependencies from temporary file
include(${dependency_file}.tmp)

# did the dependencies change?
if(NOT "${D_DMD_DEPEND}" STREQUAL "${old_dependencies}")
	message("Dependencies changed. Need to build.")
	execute_process(COMMAND ${CMAKE_COMMAND} -E touch ${source_file})
endif()

execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${dependency_file}.tmp ${dependency_file})
execute_process(COMMAND ${CMAKE_COMMAND} -E remove ${dependency_file}.tmp)

#message("Finished dependencies")
