#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "OpenImageDenoise" for configuration "Release"
set_property(TARGET OpenImageDenoise APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(OpenImageDenoise PROPERTIES
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/lib/libOpenImageDenoise.1.3.0.dylib"
  IMPORTED_SONAME_RELEASE "@rpath/libOpenImageDenoise.1.dylib"
  )

list(APPEND _IMPORT_CHECK_TARGETS OpenImageDenoise )
list(APPEND _IMPORT_CHECK_FILES_FOR_OpenImageDenoise "${_IMPORT_PREFIX}/lib/libOpenImageDenoise.1.3.0.dylib" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
