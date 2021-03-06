cmake_minimum_required(VERSION 2.4)

#=========================================================
# To avoid warning with some version
if(COMMAND cmake_policy)
  cmake_policy(SET CMP0003 NEW)
endif(COMMAND cmake_policy)
#=========================================================

#=========================================================
#List of vv tools to compile
SET(vv_TOOLS
  vvToolMedianFilter
  vvToolRigidReg
  vvToolCropImage
  vvToolBinarize
  vvToolImageArithm
  vvToolResample
  vvToolMIP
  vvToolConvert ## with dummy vvToolConvert.ui
  vvToolROIManager
  vvToolSegmentation
  ## these ones are for tests (not working)
  # vvToolFoo
  # vvToolFooWithWidgetBase
  # vvToolPlastimatch
  # vvToolConnectedComponentLabeling  
  ## these ones are old ones
  # vvToolExtractPatient
  # vvToolExtractLung
  # vvToolStructureSetManager
)
# dependencies of the tools
# Future issues : when tool depend on other tools ... how to manage that ?
#  >> add the relevant $_LIBS variable to the tool that has dependencies?
SET(vvToolBinarize_LIBS clitkBinarizeImageLib)
SET(vvToolResample_LIBS clitkResampleImageLib)
SET(vvToolConvert_LIBS clitkImageConvertLib)
SET(vvToolExtractPatient_LIBS clitkSegmentationGgoLib)
SET(vvToolExtractLung_LIBS clitkSegmentationGgoLib)
SET(vvToolCropImage_LIBS clitkCropImageLib)
SET(vvToolMIP_LIBS clitkMIPLib)
SET(vvToolMedianFilter_LIBS clitkMedianImageFilterLib)
SET(vvToolImageArithm_LIBS clitkImageArithmImageLib)
SET(vvToolROIManager_LIBS clitkDicomRTStruct)

#=========================================================
# List of vv source files

# in COMMON_WITH_UI -> must have .h and .cxx and .ui
SET(vv_COMMON_WITH_UI
  vvInfoPanel
  vvMainWindow 
  vvLinkPanel 
  vvOverlayPanel 
  vvLandmarksPanel 
  vvProgressDialog 
  vvSegmentationDialog
  vvSurfaceViewerDialog
  vvDeformationDialog
  vvStructSelector
  vvIntensityValueSlider
  vvLabelImageLoaderWidget
  vvToolWidgetBase  
  vvToolSimpleInputSelectorWidget
  vvToolInputSelectorWidget
  vvRegisterForm
)

# All others sources
SET(vv_SRCS
  vvQProgressDialogITKCommand.cxx
  vvQDicomSeriesSelector.cxx
  QTreePushButton.cxx
  vvMainWindowBase.cxx
  vvImageWarp.cxx
  vvDeformableRegistration.cxx
  vtkVOXImageWriter.cxx
  vvInteractorStyleNavigator.cxx
  vvSlicer.cxx
  vvLandmarks.cxx
  vvLandmarksGlyph.cxx
  vvClipPolyData.cxx
  vvGlyphSource.cxx
  vvGlyph2D.cxx
  vvSlicerManager.cxx
  vvSlicerManagerCommand.cxx
  vvUtils.cxx
#  vvMaximumIntensityProjection.cxx
  vvMesh.cxx
  vvMeshActor.cxx
  vvMeshReader.cxx
  vvMidPosition.cxx
  vvImageContour.cxx
  vvBinaryImageOverlayActor.cxx
  vvStructureSetActor.cxx
  vvSaveState.cxx
  vvReadState.cxx
  vvROIActor.cxx
  vvBlendImageActor.cxx
  vvToolManager.cxx
  vvToolCreatorBase.cxx
  vvToolBaseBase.cxx
)

#=========================================================
# Qt related commands
FIND_PACKAGE(Qt4 REQUIRED)

QT4_WRAP_CPP(vv_SRCS 
  vvMainWindowBase.h 
  QTreePushButton.h 
  vvDocumentation.h  
  vvHelpDialog.h  
  vvQDicomSeriesSelector.h 
  vvSlicerManager.h
  vvStructureSetActor.h
  vvROIActor.h
  vvToolCreatorBase.h
  )

QT4_WRAP_UI(vv_UI_CXX 
  qt_ui/vvHelpDialog.ui 
  qt_ui/vvDocumentation.ui 
  qt_ui/vvDicomSeriesSelector.ui 
  qt_ui/vvDummyWindow.ui #For testing
  )

QT4_ADD_RESOURCES(vv_SRCS vvIcons.qrc)

# Add the autotools in the header vvToolsList.h for initialization of the dummy
# variables in vv.cxx for the tools contained in vvLib
if(${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt IS_NEWER_THAN ${CMAKE_CURRENT_BINARY_DIR}/vvToolsList.h)
  file(REMOVE ${CMAKE_CURRENT_BINARY_DIR}/vvToolsList.h)
  foreach(tool ${vv_TOOLS})
    FILE(APPEND ${CMAKE_CURRENT_BINARY_DIR}/vvToolsList.h "#include \"${tool}.h\"\n")
    FILE(APPEND ${CMAKE_CURRENT_BINARY_DIR}/vvToolsList.h "extern const vvToolCreator<${tool}> *dummy${tool};\n")
    FILE(APPEND ${CMAKE_CURRENT_BINARY_DIR}/vvToolsList.h "const vvToolCreator<${tool}> *dummy${tool}2 = dummy${tool};\n\n")
  endforeach(tool)
endif(${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt IS_NEWER_THAN ${CMAKE_CURRENT_BINARY_DIR}/vvToolsList.h)

# Add the autotools and the common files ui
foreach(tool ${vv_TOOLS} ${vv_COMMON_WITH_UI})
    SET(vv_SRCS ${vv_SRCS} ${tool}.cxx)
    QT4_WRAP_CPP(vv_SRCS ${tool}.h)
    QT4_WRAP_UI(vv_UI_CXX qt_ui/${tool}.ui)
endforeach(tool)

# Add the common source files
foreach(tool ${vv_COMMON})
    SET(vv_SRCS ${vv_SRCS} ${tool}.cxx)
    QT4_WRAP_CPP(vv_SRCS ${tool}.h)
endforeach(tool)

# if Windows and Qt was built as a static lib then don't set QT_DLL flag
SET(QT_STATIC 0)
IF (WIN32)
  IF(EXISTS ${QT_LIBRARY_DIR}/QtCore.prl)
    FILE(READ ${QT_LIBRARY_DIR}/QtCore.prl QT_CORE_PRL)
    IF(${QT_CORE_PRL} MATCHES "static")
      SET(QT_STATIC 1)
    ENDIF(${QT_CORE_PRL} MATCHES "static")
  ENDIF(EXISTS ${QT_LIBRARY_DIR}/QtCore.prl)
ENDIF(WIN32)
IF(NOT QT_STATIC)
  ADD_DEFINITIONS(-DQT_DLL)
ENDIF(NOT QT_STATIC)

ADD_DEFINITIONS(-DQT_THREAD_SUPPORT)

INCLUDE_DIRECTORIES(
  ${QT_INCLUDES}
  ${QT_INCLUDE_DIR}
  ${QT_QTGUI_INCLUDE_DIR}
  ${QT_QTCORE_INCLUDE_DIR}
  ${CMAKE_CURRENT_BINARY_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}
)
#=========================================================

#=========================================================
#support for parallel deformable registration with OpenMP
IF(NOT APPLE)
IF(CMAKE_COMPILER_IS_GNUCC)
  SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fopenmp")
ENDIF(CMAKE_COMPILER_IS_GNUCC)
ENDIF(NOT APPLE)
#=========================================================

#=========================================================
INCLUDE_DIRECTORIES(
  ../common
  ../tools
  ../segmentation
  )

LINK_DIRECTORIES(${QT_LIBRARY_DIR})

#=========================================================
#Add each tool's dependencies
foreach(tool ${vv_TOOLS})
  SET(toolLibs ${toolLibs} ${${tool}_LIBS})
endforeach(tool)

#=========================================================
#Add Foundation Libraries (this should be after our libraries, since we depend
#on them)
SET(foundationLibraries clitkCommon ${ITK_LIBRARIES} QVTK vtkHybrid)

#=========================================================
# Use CxImage to create animated gifs
IF(CLITK_EXPERIMENTAL)
  SET(vvCxImage clitkCxImage)
  SET(vv_SRCS ${vv_SRCS} vvAnimatedGIFWriter.cxx)
  INCLUDE_DIRECTORIES(${CLITK_SOURCE_DIR}/utilities/CxImage)
  ADD_SUBDIRECTORY(${CLITK_SOURCE_DIR}/utilities/CxImage ${PROJECT_BINARY_DIR}/utilities/CxImage)
ENDIF(CLITK_EXPERIMENTAL)
#=========================================================

#=========================================================
#Create binary and libs for tests
SET(vvExternalLibs ${QT_QTNETWORK_LIBRARY} clitkSegmentationGgoLib ${toolLibs} ${foundationLibraries} ${vvCxImage})
# QtNetwork is required by vvRegisterForm

ADD_LIBRARY(vvLib ${vv_SRCS} ${vv_UI_CXX})
TARGET_LINK_LIBRARIES(vvLib ${vvExternalLibs})

IF(WIN32)
  ADD_EXECUTABLE(vv WIN32 vv.cxx vvIcon.rc)
ELSE(WIN32)
  ADD_EXECUTABLE(vv vv.cxx)
ENDIF(WIN32)

TARGET_LINK_LIBRARIES(vv vvLib)

#=========================================================
# Install options (also used by CPack)
INSTALL (TARGETS vv DESTINATION bin PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_EXECUTE WORLD_EXECUTE)

#=========================================================

#=========================================================
# CPack options
SET(CPACK_PACKAGE_NAME "vv")
SET(CPACK_SOURCE_PACKAGE_FILE_NAME "vv-src")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "vv, the 4D slicer : let's jump into a new dimension !")
SET(CPACK_PACKAGE_VENDOR "Creatis-CLB")
SET(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/ReadMe.txt")
SET(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/License.txt")
SET(CPACK_PACKAGE_VERSION_MAJOR "1")
SET(CPACK_PACKAGE_VERSION_MINOR "3")
SET(CPACK_PACKAGE_VERSION_PATCH "0")
IF(NIGHTLY)
  SET(CPACK_PACKAGE_INSTALL_DIRECTORY "vv-nightly")
ELSE(NIGHTLY)
  SET(CPACK_PACKAGE_INSTALL_DIRECTORY "vv")
ENDIF(NIGHTLY)
SET(CPACK_STRIP_FILES TRUE)

IF(WIN32)
  # There is a bug in NSI that does not handle full unix paths properly. Make
  # sure there is at least one set of four (4) backlasshes.
  SET(CPACK_NSIS_MUI_ICON "${CMAKE_CURRENT_SOURCE_DIR}\\\\icons\\\\ducky.ico")
  SET(CPACK_NSIS_INSTALLED_ICON_NAME "vv.exe")
IF(NIGHTLY)
  SET(CPACK_NSIS_DISPLAY_NAME "vv - The 4D slicer (nightly)")
ELSE(NIGHTLY)
  SET(CPACK_NSIS_DISPLAY_NAME "vv - The 4D slicer")
ENDIF(NIGHTLY)
  SET(CPACK_NSIS_HELP_LINK "http://www.creatis.insa-lyon.fr/rio/vv")
  SET(CPACK_NSIS_URL_INFO_ABOUT "http://www.creatis.insa-lyon.fr/rio")
  SET(CPACK_NSIS_CONTACT "vv@creatis.insa-lyon.fr")
  SET(CPACK_NSIS_CREATE_ICONS_EXTRA "CreateShortCut \\\"$SMPROGRAMS\\\\$STARTMENU_FOLDER\\\\vv.lnk\\\" \\\"$INSTDIR\\\\bin\\\\vv.exe\\\" ")
  SET(CPACK_NSIS_DELETE_ICONS_EXTRA "Delete \\\"$SMPROGRAMS\\\\$MUI_TEMP\\\\vv.lnk\\\" ")
  #SET(CPACK_NSIS_MODIFY_PATH ON) SR: buggy, wait for cmake updates for a fix
  #SET(CPACK_BINARY_ZIP ON)
ELSE(WIN32)
  SET(CPACK_GENERATOR "STGZ")
  SET(CPACK_SOURCE_GENERATOR "TGZ") 
ENDIF(WIN32)
INCLUDE(CPack)
#=========================================================
#=========================================================
configure_file(vvConfiguration.h.in vvConfiguration.h)
#=========================================================
