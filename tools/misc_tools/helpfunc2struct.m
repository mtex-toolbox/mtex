function s = helpfunc2struct(folder)

[path fold] = fileparts(folder);

helpStr = helpfunc(folder);
      
tokens = regexp(helpStr,'([^\n]*)','tokens');
tokens = vertcat(tokens{2:end});
tokens = regexp(tokens,'-','split');

description = cellfun(@(x) horzcat(x{2:end}),tokens,'uniformoutput',false);

s = struct('folder',char(regexprep(fold,'@','')),...
      'isclassdir',logical(~isempty(strfind(fold,'@'))),...
      'name',cellfun(@(x) deblank(x(1)),tokens),...
      'description',cellfun(@(x) x(2:end),description,'uniformoutput',false));
