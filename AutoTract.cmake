CMAKE_MINIMUM_REQUIRED( VERSION 2.6 )
CMAKE_POLICY(VERSION 2.6)
PROJECT(AutoTract)

SETIFEMPTY( ARCHIVE_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/lib/static )
SETIFEMPTY( LIBRARY_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/lib )
SETIFEMPTY( RUNTIME_DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/bin )

SETIFEMPTY(INSTALL_RUNTIME_DESTINATION bin)
SETIFEMPTY(INSTALL_LIBRARY_DESTINATION lib)
SETIFEMPTY(INSTALL_ARCHIVE_DESTINATION lib)

#-----------------------------------------------------------------------------
# Update CMake module path
#------------------------------------------------------------------------------


set(CMAKE_MODULE_PATH
  ${CMAKE_MODULE_PATH}
  ${${PROJECT_NAME}_SOURCE_DIR}/CMake
  ${${PROJECT_NAME}_BINARY_DIR}/CMake
  )

IF(Qt4_SUPPORT)
  add_definitions(-DQT_4_SUPPORT=1)
  find_package(Qt4 COMPONENTS QtCore QtGui QtXml REQUIRED)
  include(${QT_USE_FILE})

ELSE()
  find_package(Qt5 REQUIRED Core Widgets Xml)
  include_directories(${Qt5Widgets_INCLUDES})
  include_directories(${Qt5Xml_INCLUDES})
ENDIF()


#Find SlicerExecutionModel
FIND_PACKAGE(SlicerExecutionModel REQUIRED)
INCLUDE(${SlicerExecutionModel_USE_FILE})

#INCLUDE(${GenerateCLP_USE_FILE})

find_package(QtToCppXML REQUIRED)
include(${QtToCppXML_USE_FILE}) 

find_package(Trafic)

if(Trafic_FOUND)
  
  foreach(Trafic_lib ${Trafic_LIBRARIES})

    get_target_property(Trafic_location ${Trafic_lib} LOCATION_RELEASE)
    if(NOT EXISTS ${Trafic_location})
      message(STATUS "skipping niral_utilities_lib install rule: [${Trafic_location}] does not exist")
      continue()
    endif()
    
    if(EXISTS "${Trafic_location}.xml")
      install(PROGRAMS ${Trafic_location} 
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}
        COMPONENT RUNTIME)

      install(FILES ${Trafic_location}.xml
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}
        COMPONENT RUNTIME)
    else()
      install(PROGRAMS ${Trafic_location} 
        DESTINATION ${INSTALL_RUNTIME_DESTINATION}/../ExternalBin
        COMPONENT RUNTIME)      
    endif()
  endforeach()
  
endif()


set(ITK_IO_MODULES_USED
ITKIOImageBase
ITKIONRRD
ITKIOCSV
ITKIOGIPL
ITKIOHDF5
ITKIOIPL
ITKIOImageBase
ITKIOLSM
ITKIOMRC
ITKIOMesh
ITKIOMeta
ITKIONIFTI
ITKIONRRD
ITKIORAW
ITKIOVTK
)
#Find ITK
find_package(ITK 4.7 REQUIRED COMPONENTS
  ITKCommon
  ITKIOImageBase
  ITKImageFunction
  ITKVTK
  ${ITK_IO_MODULES_USED}
)

include(${ITK_USE_FILE})


option(BUILD_TESTING "Build the testing tree" ON)

ADD_SUBDIRECTORY(src)

IF(BUILD_TESTING)
  include(CTest)
  ADD_SUBDIRECTORY(Testing)
ENDIF(BUILD_TESTING)


if( ${LOCAL_PROJECT_NAME}_BUILD_SLICER_EXTENSION )
  set(CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};${CMAKE_BINARY_DIR};${EXTENSION_NAME};ALL;/")
  include(${Slicer_EXTENSION_CPACK})
endif()

