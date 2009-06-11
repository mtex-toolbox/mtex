function make_index(in_dir, out_file)
% append function list to in_dir_index.html

% extract class name
class_name = char(regexp(in_dir,'(?<=@)\w*(?=\w*)','match'));
if ~isempty(class_name), class_name = [class_name,'_'];end

% recreate contents file
current_dir = pwd; cd(in_dir);
makecontentsfile('.','force');
cd(current_dir);

% read Contents file
contents = file2cell(fullfile(in_dir,'Contents.m'));

% make section 'Files' to be rearly a section
contents = {contents{3:end}};
contents{1} = '%% *Complete function list*';

% make links
contents = regexprep(contents,'(?<=%\s*)(\w*)(?=\s*-\w*)',...
  ['[[' class_name '$1.html,$1]]']);

% append contents to out_file
cell2file(out_file,contents,'a');
