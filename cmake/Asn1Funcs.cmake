function (cc_asn1_ensure_comms_target)
    if (CC_ASN1_FOUND_COMMS_INTERNAL)
        return ()
    endif ()

    if (CC_ASN1_EXTERNAL_COMMS)
        find_package(LibComms REQUIRED)
        cc_asn1_mark_comms_found()
        return()
    endif ()

    set (repo "${CC_COMMS_REPO}")
    if ("${repo}" STREQUAL "")
        set (repo "https://github.com/commschamp/comms.git")
    endif ()

    set (tag "${COMMS_TAG}")
    if ("${tag}" STREQUAL "")
        set (tag "master")
    endif ()

    if (NOT COMMAND cc_prefetch)
        include (${PROJECT_SOURCE_DIR}/cmake/CC_Prefetch.cmake)
    endif ()

    set (externals_dir "${CC_ASN1_EXTERNALS_DIR}")
    if ("${externals_dir}" STREQUAL "")
        set (externals_dir "${CMAKE_CURRENT_BINARY_DIR}/externals")
    endif ()

    set (src_dir "${externals_dir}/comms")
    cc_prefetch(SRC_DIR ${src_dir} TAG ${tag} REPO ${repo})

    set (build_file_include ${src_dir}/cmake/CC_CommsExternal.cmake)
    if (NOT EXISTS ${build_file_include})
        message (FATAL_ERROR "Required file ${build_file_include} doesn't exist")
    endif ()    

    include (${build_file_include})
    set (build_dir "${PROJECT_BINARY_DIR}/externals/comms/build")
    set (install_dir "${build_dir}/install")
    cc_comms_build_during_config(
        SRC_DIR ${src_dir}
        BUILD_DIR ${build_dir}
        CMAKE_ARGS 
            -DCMAKE_INSTALL_PREFIX=${install_dir}
            -DCC_COMMS_BUILD_UNIT_TESTS=OFF
        NO_REPO
    )

    list (APPEND CMAKE_PREFIX_PATH ${install_dir})
    find_package(LibComms REQUIRED)
    cc_asn1_mark_comms_found()
endfunction()

macro (cc_asn1_negate_option old_name new_name)
    if (DEFINED ${old_name})
        if (${old_name})
            set (${new_name} OFF)
        else ()
            set (${new_name} ON)
        endif ()
    endif ()
endmacro ()