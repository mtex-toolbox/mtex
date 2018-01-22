function makeS2FunDoc

setMTEXpref('generatingHelpMode', true);

[filepath,name,ext] = fileparts(mfilename('fullpath'));
list = dir(fullfile(filepath, '*.m'));

for j = 1:length(list)
  if ~strcmp(list(j).name, [name '.m'])
    publish(list(j).name, 'maxHeight', 200)
  end
end

setMTEXpref('generatingHelpMode', false);

end
