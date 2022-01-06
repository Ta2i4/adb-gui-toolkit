# ADB GUI Toolkit
Stress testing for Android smartphones

## Version history

### Build 1.1.1.107-beta (2019/10/09)
- For the option "Logging level" added the value "Maximum"

### Build 1.1.0.105-beta (2019/09/23)
- Screen video recordind to file on connected device
- New option "Applications filter" for "Selected application mode"
- Help file with .chm extension
- Parallel running of test algorythm rewritten
- Changing main window size (smaller)
- When the testing process is stopped, now the ADB child process is killed immediately, without waiting for the end of the command execution
- Fixed errors when incorrect information was displayed in the "Select application" list
- Fixed a bug when the "Logging level" setting was not pulled up from the settings file when the program was started
- Cleaned "platform-tools" subdirectory from unused files
- Removing the OmniThreadLibrary in favor of the native capabilities of the application development environment

### Build 1.0.0.64-beta (2019/09/15)
- First stable version
- Parallel running of test on all connected devices
- Loading of installed applications from connected devices
- Saving logs for Monkey stress test
- Saving settings to file

### 2019/09/19
- Initialize development