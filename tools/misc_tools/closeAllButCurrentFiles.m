function closeAllButCurrentFiles
% close all open files exept for the current one

allOpenFiles = matlab.desktop.editor.getAll'; % Array of open files
fileNames = {allOpenFiles.Filename}'; % Extract file names
current = matlab.desktop.editor.getActiveFilename;
found = ~strncmp(fileNames,current,length(current));

allOpenFiles(found).close
