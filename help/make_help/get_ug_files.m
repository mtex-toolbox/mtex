function ug_files = get_ug_files(folder,pattern)

dirs = getSubDirs(folder);
ug_files = {};

if nargin < 2
  pattern = {'*.m'};
else
  pattern = [{} pattern];
end

for id = 1:length(dirs)
  for pt = pattern
    files = dir(fullfile(dirs{id},pt{:}));
    if ~isempty(files)
      ug_files =[ ug_files; strcat(dirs{id},filesep,{files.name}')]; %#ok<AGROW>
    end
  end
end