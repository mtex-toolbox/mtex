function s = helpfunc2struct(folder)

[~, fold] = fileparts(folder);
helpStr = helpfunc(folder);
      
tokens = regexp(helpStr,'([^\n]*)','tokens');
tokens = vertcat(tokens{2:end});
tokens = regexp(tokens,'-','split');

description = cellfun(@(x) horzcat(x{2:end}),tokens,'uniformoutput',false);

s = struct('folder',char(regexprep(fold,'@','')),...
  'isclassdir',logical(~isempty(strfind(fold,'@'))),...
  'name',cellfun(@(x) deblank(x(1)),tokens),...
  'description',cellfun(@(x) x(2:end),description,'uniformoutput',false));

% check for missing files, i.e. files that does not contain an h1
% line

files = dir([folder filesep '*.m']);
if length(files)>length(s)
  warning(['Some files in ' folder ' do not have an H1 line!']); %#ok<WNTAG>
end
