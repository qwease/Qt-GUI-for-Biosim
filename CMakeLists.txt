cmake_minimum_required(VERSION 3.5)

project(biosim4Qt VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(X11)
link_directories( /usr/lib/X11 )

INCLUDE_DIRECTORIES(
    ${PROJECT_SOURCE_DIR}
)
INCLUDE_DIRECTORIES("/opt/mxe/usr/i686-w64-mingw32.static/qt6")

set(CMAKE_CXX_FLAGS "-g -Wall -fopenmp -lopencv_core -lopencv_video -lopencv_videoio -lpthread -lX11 -lz")

# Create backup folder for original biosim4.ini
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/bak)
configure_file(./biosim4.ini ${CMAKE_BINARY_DIR}/bak/biosim4.ini COPYONLY)

# Copy the configuration file to the build directory
configure_file(./biosim4.ini ${CMAKE_BINARY_DIR}/biosim4.ini COPYONLY)

# application.ini
configure_file(./application.ini ${CMAKE_BINARY_DIR}/application.ini COPYONLY)

# Copy the contents of the tools directory to the build directory
file(COPY ./tools/ DESTINATION ${CMAKE_BINARY_DIR}/tools)

# Copy the contents of the platforms directory to the build directory
file(COPY ./platforms/ DESTINATION ${CMAKE_BINARY_DIR}/platforms)

# Copy the saves of generations directory to the build directory
file(COPY ./states/ DESTINATION ${CMAKE_BINARY_DIR}/states)

# Create the logs directory in the build directory
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/logs)

# Create the images directory in the build directory
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/images)



find_package(QT NAMES Qt6 REQUIRED COMPONENTS Widgets)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets)

find_package(Qt6 REQUIRED COMPONENTS Concurrent)

find_package(ZLIB REQUIRED)

include_directories(${ZLIB_INCLUDE_DIRS})

set(PROJECT_SOURCES
        main.cpp
        mainwindow.cpp
        mainwindow.h
        mainwindow.ui
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(biosim4Qt
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
        biosimparser.h biosimparser.cpp
        biosim4.ini
        biosim4/analysis.cpp biosim4/basicTypes.cpp biosim4/basicTypes.h biosim4/CMakeLists.txt biosim4/createBarrier.cpp biosim4/endOfGeneration.cpp biosim4/endOfSimStep.cpp biosim4/executeActions.cpp biosim4/feedForward.cpp biosim4/genome-compare.cpp biosim4/genome-neurons.h biosim4/genome.cpp biosim4/getSensor.cpp biosim4/grid.cpp biosim4/grid.h biosim4/imageWriter.cpp biosim4/imageWriter.h biosim4/indiv.cpp biosim4/indiv.h  biosim4/params.cpp biosim4/params.h biosim4/peeps.cpp biosim4/peeps.h biosim4/random.cpp biosim4/random.h biosim4/sensors-actions.h biosim4/signals.cpp biosim4/signals.h biosim4/simulator.cpp biosim4/simulator.h biosim4/spawnNewGeneration.cpp biosim4/survival-criteria.cpp biosim4/unitTestBasicTypes.cpp biosim4/unitTestConnectNeuralNetWiringFromGenome.cpp biosim4/unitTestGridVisitNeighborhood.cpp
        biosimrunner.h biosimrunner.cpp
        biosimwidget.h biosimwidget.cpp
        paramControllers.cpp
        assets.qrc
        AgentGraphicsView.h AgentGraphicsView.cpp

    )

    # Find OpenCV after defining the target
    find_package(OpenCV REQUIRED)
    include_directories(${OpenCV_INCLUDE_DIRS})
    find_package(OpenMP REQUIRED)

    # Link OpenCV libraries to the target
    target_link_libraries(biosim4Qt PRIVATE Qt${QT_VERSION_MAJOR}::Widgets ${OpenCV_LIBS})

    # Link ZLib
    target_link_libraries(biosim4Qt PRIVATE ${ZLIB_LIBRARIES})

# Define target properties for Android with Qt 6 as:
#    set_property(TARGET biosim4Qt APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
#                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
# For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation
else()
    if(ANDROID)
        add_library(biosim4Qt SHARED
            ${PROJECT_SOURCES}
        )
# Define properties for Android with Qt 5 after find_package() calls as:
#    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else()
        add_executable(biosim4Qt
            ${PROJECT_SOURCES}
        )
    endif()
endif()

target_link_libraries(biosim4Qt PRIVATE Qt${QT_VERSION_MAJOR}::Widgets)
target_link_libraries(biosim4Qt PRIVATE Qt${QT_VERSION_MAJOR}::Core)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
if(${QT_VERSION} VERSION_LESS 6.1.0)
  set(BUNDLE_ID_OPTION MACOSX_BUNDLE_GUI_IDENTIFIER com.example.biosim4Qt)
endif()
set_target_properties(biosim4Qt PROPERTIES
    ${BUNDLE_ID_OPTION}
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

set_target_properties(${PROJECT_NAME} PROPERTIES INSTALL_RPATH “${QT6_PATH}/lib”)

# Set the installation directory
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation directory")

# Install the executable
install(TARGETS biosim4Qt
    RUNTIME DESTINATION bin
)

# Install dependencies (e.g., Qt libraries)
if(WIN32)
    install(DIRECTORY "${CMAKE_PREFIX_PATH}/bin/"
        DESTINATION bin
        FILES_MATCHING PATTERN "Qt*.dll"
    )
elseif(UNIX)
    # Install Qt libraries on Linux
    install(DIRECTORY "${CMAKE_PREFIX_PATH}/lib/"
        DESTINATION lib/biosim4Qt
        FILES_MATCHING PATTERN "libQt*.so*"
    )
endif()

# Install other necessary files and directories
install(FILES "${CMAKE_SOURCE_DIR}/biosim4.ini"
    DESTINATION share/biosim4Qt
)
install(DIRECTORY "${CMAKE_SOURCE_DIR}/tools"
    DESTINATION share/biosim4Qt
)
install(DIRECTORY "${CMAKE_SOURCE_DIR}/states"
    DESTINATION share/biosim4Qt
)

# include(GNUInstallDirs)
# install(TARGETS biosim4Qt
#     BUNDLE DESTINATION .
#     LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
#     RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
# )

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(biosim4Qt)
endif()
