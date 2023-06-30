function(target_link_libraries_system target visibility)
  set(libs ${ARGN})
  foreach(lib ${libs})
    get_target_property(lib_include_dirs ${lib} INTERFACE_INCLUDE_DIRECTORIES)
    target_include_directories(${target} SYSTEM ${visibility} ${lib_include_dirs})
    target_link_libraries(${target} ${visibility} ${lib})
  endforeach(lib)
endfunction(target_link_libraries_system)

macro(amrex_options)
#Set amrex options
  set(USE_XSDK_DEFAULTS OFF)
  set(AMReX_SPACEDIM 3)
  set(AMReX_AMRDATA OFF)
  set(AMReX_AMRLEVEL OFF)
  set(AMReX_ASSERTIONS OFF)
  set(AMReX_ASCENT OFF)
  set(AMReX_BACKTRACE OFF)
  set(AMReX_BASE_PROFILE OFF)
  set(AMReX_COMM_PROFILE OFF)
  set(AMReX_CONDUIT OFF)
  set(AMReX_PRECISION "DOUBLE")
  set(AMReX_EB OFF)
  set(AMReX_FORTRAN OFF)
  set(AMReX_FORTRAN_INTERFACES OFF)
  set(AMReX_FPE OFF)
  set(AMReX_HYPRE OFF)
  set(AMReX_LINEAR_SOLVERS OFF)
  set(AMReX_MEM_PROFILE OFF)
  set(AMReX_MPI ${WAVES2AMR_ENABLE_MPI})
  set(AMReX_OMP ${WAVES2AMR_ENABLE_OPENMP})
  set(AMReX_PARTICLES OFF)
  set(AMReX_PIC OFF)
  set(AMReX_PLOTFILE_TOOLS ${WAVES2AMR_ENABLE_FCOMPARE})
  set(AMReX_PROFPARSER OFF)
  set(AMReX_SENSEI OFF)
  set(AMReX_SUNDIALS OFF)
  set(AMReX_TINY_PROFILE OFF)
  set(AMReX_TRACE_PROFILE OFF)
  set(AMReX_HDF5 OFF)
  set(AMReX_HDF5_ZFP OFF)
  set(AMReX_BUILD_SHARED_LIBS OFF)

  if (WAVES2AMR_ENABLE_CUDA)
    set(AMReX_GPU_BACKEND CUDA CACHE STRING "AMReX GPU type" FORCE)
  elseif(WAVES2AMR_ENABLE_ROCM)
    set(AMReX_GPU_BACKEND HIP CACHE STRING "AMReX GPU type" FORCE)
  elseif(WAVES2AMR_ENABLE_SYCL)
    set(AMReX_GPU_BACKEND SYCL CACHE STRING "AMReX GPU type" FORCE)
  else()
    set(AMReX_GPU_BACKEND NONE CACHE STRING "AMReX GPU type" FORCE)
  endif()
endmacro(amrex_options)

macro(init_amrex)
  if (${WAVES2AMR_USE_INTERNAL_AMREX})
    set(AMREX_SUBMOD_LOCATION "${CMAKE_SOURCE_DIR}/submods/amrex")
    amrex_options()
    list(APPEND CMAKE_MODULE_PATH "${AMREX_SUBMOD_LOCATION}/Tools/CMake")
    if (WAVES2AMR_ENABLE_CUDA AND (CMAKE_VERSION VERSION_LESS 3.20))
      include(AMReX_SetupCUDA)
    endif()
    add_subdirectory(${AMREX_SUBMOD_LOCATION})
    set(FCOMPARE_EXE ${CMAKE_BINARY_DIR}/submods/amrex/Tools/Plotfile/fcompare
      CACHE INTERNAL "Path to fcompare executable for regression tests")
  else()
    set(CMAKE_PREFIX_PATH ${AMREX_DIR} ${CMAKE_PREFIX_PATH})
    list(APPEND AMREX_COMPONENTS
      "3D" "PIC" "PARTICLES" "PDOUBLE" "DOUBLE" "LSOLVERS")
    if (WAVES2AMR_ENABLE_MPI)
      list(APPEND AMREX_COMPONENTS "MPI")
    endif()
    if (WAVES2AMR_ENABLE_OPENMP)
      list(APPEND AMREX_COMPONENTS "OMP")
    endif()
    if (WAVES2AMR_ENABLE_CUDA)
      list(APPEND AMREX_COMPONENTS "CUDA")
    endif()
    if (WAVES2AMR_ENABLE_SYCL)
      list(APPEND AMREX_COMPONENTS "SYCL")
    endif()
    if (WAVES2AMR_ENABLE_ROCM)
      list(APPEND AMREX_COMPONENTS "HIP")
    endif()
    if (WAVES2AMR_ENABLE_HYPRE)
      list(APPEND AMREX_COMPONENTS "HYPRE")
    endif()
    if (WAVES2AMR_ENABLE_TINY_PROFILE)
      list(APPEND AMREX_COMPONENTS "TINY_PROFILE")
    endif()
    separate_arguments(AMREX_COMPONENTS)
    find_package(AMReX CONFIG REQUIRED
      COMPONENTS ${AMREX_COMPONENTS})
    message(STATUS "Found AMReX = ${AMReX_DIR}")
    set(FCOMPARE_EXE ${AMReX_DIR}/../../../bin/fcompare
      CACHE INTERNAL "Path to fcompare executable for regression tests")
  endif()
endmacro(init_amrex)