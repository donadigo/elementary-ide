vala_precompile(VALA_C ${EXEC_NAME}
    Constants.vala
    IDEApplication.vala
    IDEWindow.vala
    EditorView.vala
    EditorWindow.vala
    ToolBar.vala
    MenuButton.vala
    Template.vala
    Project.vala
    Projects/CMakeProject.vala
    Projects/NativeProject.vala
    Projects/GenericProject.vala
    Utils.vala
    TabWidget.vala
    Document.vala
    DocumentManager.vala
    CodeParser.vala
    Vala/ValaDocumentProvider.vala
    Vala/Locator.vala
    Vala/ValaCodeParser.vala
    BuildSystem.vala
    BuildSystems/CMakeBuildSystem.vala
    BuildSystems/CMakeParser.vala
    BuildSystems/CMakeCommand.vala
    BuildSystems/CMakeVariable.vala
    Report.vala
    ReportWidget.vala
    TerminalWidget.vala
    InfoWindow.vala
    SourceList.vala
    BaseDialog.vala
    Dialogs/EditorPreferencesDialog.vala
    Dialogs/NewFileDialog.vala
    Dialogs/OpenProjectDialog.vala
PACKAGES
    granite
    gtksourceview-3.0
    valadoc-1.0
    vte-2.91
    posix
    gee-0.8
    libvala-0.34
OPTIONS
  --target-glib=2.32
  --thread
)

add_executable (${EXEC_NAME} ${VALA_C})
target_link_libraries (${EXEC_NAME} ${DEPS_LIBRARIES})

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

