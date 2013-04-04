function apply_recursivly(in_dir,cmd,pattern)
% apply cmd recursively to all file in a directory
%
%% Input
%
%% Output

sub_dirs = getSubDirs(in_dir);

for id = 1:length(sub_dirs)
  
  %disp(sub_dirs{id});
  files = dir(fullfile(sub_dirs{id},pattern));
  
  for i = 1:length(files)
    cmd(fullfile(sub_dirs{id},files(i).name)); 
  end
  
end
