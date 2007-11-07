function apply_recursivly(in_dir,cmd,pattern)
% apply cmd recursively to all file in a directory
%
%% Input
%
%% Output

sub_dirs = getSubDirs(in_dir);

for id = 1:length(sub_dirs)
  
  disp(sub_dirs{id});
  files = dir([sub_dirs{id},filesep,pattern]);
  
  for i = 1:length(files)
    cmd([sub_dirs{id},filesep,files(i).name]); 
  end
  
end
