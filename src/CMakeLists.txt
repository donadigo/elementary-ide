configure_file (${CMAKE_CURRENT_SOURCE_DIR}/config.vala.cmake ${CMAKE_CURRENT_SOURCE_DIR}/config.vala)

vala_precompile(VALA_C ${EXEC_NAME}
    Constants.vala
    IDEApplication.vala
    IDEWindow.vala
    Project.vala
    Utils.vala
    Location.vala
    DocumentManager.vala
    CodeParser.vala
    IDEBuffer.vala
    BuildSystem.vala
    DebugSystem.vala
    BaseDialog.vala
    FileSearchEngine.vala
    Report.vala
    CMake/CMakeParser.vala
    CMake/CMakeCommand.vala
    CMake/CMakeVariable.vala
    Vala/ValaDocumentProvider.vala
    Vala/ValaBlockLocator.vala
    Vala/ValaCodeParser.vala
    Vala/ValaDefinitionWriter.vala
    Projects/CMakeProject.vala
    Projects/NativeProject.vala
    Projects/GenericProject.vala
    Widgets/ReportWidget.vala
    Widgets/TerminalWidget.vala
    Widgets/InfoWindow.vala
    Widgets/SourceList.vala
    Widgets/ProjectView.vala
    Widgets/EditorView.vala
    Widgets/EditorWindow.vala
    Widgets/ToolBar.vala
    Widgets/MenuButton.vala  
    Widgets/TabWidget.vala
    Widgets/SearchToolbar.vala
    Widgets/Document.vala   
    Widgets/BottomWidget.vala   
    Widgets/BottomStack.vala
    Widgets/Sidebar.vala
    Widgets/FileSearchView.vala
    Widgets/SettingsFrame.vala
    Dialogs/EditorPreferencesDialog.vala
    Dialogs/NewFileDialog.vala
    Dialogs/OpenProjectDialog.vala
    Dialogs/EditorPreferencesPage.vala
    Services/IDESettings.vala
    config.vala
PACKAGES
    granite
    valadoc-1.0
    vte-2.91
    json-glib-1.0
    posix
    gee-0.8
    libvala-0.34
OPTIONS
  --target-glib=2.32
  --thread
CUSTOM_VAPIS
    ../vapi/gtksourceview-3.0.vapi
)

add_executable (${EXEC_NAME} ${VALA_C})
target_link_libraries (${EXEC_NAME} ${DEPS_LIBRARIES})

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

