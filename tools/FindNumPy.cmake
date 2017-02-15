# - Find the NumPy libraries
# This module finds if NumPy is installed, and sets the following variables
# indicating where it is.
#
# TODO: Update to provide the libraries and paths for linking npymath lib.
#
#  NUMPY_FOUND               - was NumPy found
#  NUMPY_VERSION             - the version of NumPy found as a string
#  NUMPY_VERSION_MAJOR       - the major version number of NumPy
#  NUMPY_VERSION_MINOR       - the minor version number of NumPy
#  NUMPY_VERSION_PATCH       - the patch version number of NumPy
#  NUMPY_VERSION_DECIMAL     - e.g. version 1.6.1 is 10601
#  NUMPY_INCLUDE_DIRS        - path to the NumPy include files

#============================================================================
# Copyright 2012 Continuum Analytics, Inc.
# Copyright 2017 Robot Locomotion Group @ CSAIL
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
#============================================================================

# Finding NumPy involves calling the Python interpreter
if(NumPy_FIND_QUIETLY)
  set(_NUMPY_FIND_QUIET QUIET)
else()
  set(_NUMPY_FIND_QUIET)
endif()
if(NumPy_FIND_QUIETLY)
  set(_NUMPY_FIND_REQUIRED REQUIRED)
else()
  set(_NUMPY_FIND_REQUIRED)
endif()

find_package(PythonInterp ${_NUMPY_FIND_REQUIRED} ${_NUMPY_FIND_QUIET})

if(PYTHONINTERP_FOUND)
  execute_process(COMMAND "${PYTHON_EXECUTABLE}" "-c"
    "import numpy as n; print(n.__version__); print(n.get_include());"
    RESULT_VARIABLE _NUMPY_SEARCH_RESULT
    OUTPUT_VARIABLE _NUMPY_SEARCH_OUTPUT
    ERROR_VARIABLE _NUMPY_SEARCH_ERROR
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(NOT _NUMPY_SEARCH_RESULT EQUAL 0)
    set(_NUMPY_FAIL_MESSAGE
      FAIL_MESSAGE "NumPy import failure: ${_NUMPY_SEARCH_ERROR}")
  else()
    # Convert the process output into a list
    string(REGEX REPLACE ";" "\\\\;" _NUMPY_VALUES ${_NUMPY_SEARCH_OUTPUT})
    string(REGEX REPLACE "\n" ";" _NUMPY_VALUES ${_NUMPY_VALUES})

    # Read from end, just in case there is unexpected output
    list(GET _NUMPY_VALUES -2 NUMPY_VERSION)

    if(NOT "${NUMPY_VERSION}" MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)")
      # The output from Python was unexpected
      set(_NUMPY_FAIL_MESSAGE
        FAIL_MESSAGE "Requested version and include path from NumPy, got instead:\n${_NUMPY_SEARCH_OUTPUT}\n")
    else()
      # Get the major and minor version numbers
      set(NUMPY_VERSION_MAJOR "${CMAKE_MATCH_1}")
      set(NUMPY_VERSION_MINOR "${CMAKE_MATCH_2}")
      set(NUMPY_VERSION_PATCH "${CMAKE_MATCH_3}")
      math(EXPR NUMPY_VERSION_DECIMAL
          "(${NUMPY_VERSION_MAJOR} * 10000) + (${NUMPY_VERSION_MINOR} * 100) + ${NUMPY_VERSION_PATCH}")

      # Get include directory and make sure all directory separators are '/'
      list(GET _NUMPY_VALUES -1 NUMPY_INCLUDE_DIRS)
      file(TO_CMAKE_PATH NUMPY_INCLUDE_DIRS "${NUMPY_INCLUDE_DIRS}")
    endif()
  endif()
endif()

find_package_handle_standard_args(NumPy
  ${_NUMPY_FAIL_MESSAGE}
  REQUIRED_VARS PYTHONINTERP_FOUND NUMPY_INCLUDE_DIRS
  VERSION_VAR NUMPY_VERSION)

if(NOT DEFINED NumPy_FOUND)
  # Before CMake 3.3, FPHSA only sets the all-upper-case FOUND_VAR
  set(NumPy_FOUND ${NUMPY_FOUND})
endif()

if(NUMPY_FOUND)
  find_package_message(NUMPY
      "Found NumPy: ${NUMPY_INCLUDE_DIRS} (found version \"${NUMPY_VERSION}\")"
      "${NUMPY_INCLUDE_DIRS}${NUMPY_VERSION}")
endif()
