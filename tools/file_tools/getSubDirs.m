function dirs = getSubDirs(root)
% getSubDirs - gets recursively all subdirectories of a given directory.

dirs = {root};

% get all file
file = dir(root); 

% extract directories
file = file([file.isdir] & ~strncmp({file.name},'.',1) ...
  & ~strncmp({file.name},'private',7));

% search subdirectories
for k=1:length(file)
  dirs = [dirs; getSubDirs(fullfile(root,file(k).name))];
end
