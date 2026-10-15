function checkFunctionReference
% verify that source classes and diagram classes are reachable from the reference contents
%
% Syntax
%   checkFunctionReference
%
% Description
% The audit checks the class indexes, the contents graph and searchable API labels.
% Inline class definitions also need a link to their class description.

root=mtex_path;
ref=fullfile(root,'doc','FunctionReference');
roots={'S1Fun','S2Fun','SO3Fun','EBSDAnalysis','ODFAnalysis', ...
  'PoleFigureAnalysis','TensorAnalysis','plotting','geometry','interfaces','tools'};
classes={};
flat={};
for k=1:numel(roots)
  files=dir(fullfile(root,roots{k},'**','*.m'));
  for j=1:numel(files)
    if contains(files(j).folder,[filesep 'private']), continue; end
    [~,name]=fileparts(files(j).name);
    [~,parent]=fileparts(files(j).folder);
    text=regexprep(fileread(fullfile(files(j).folder,files(j).name)), ...
      '\.\.\.[^\r\n]*\r?\n',' ');
    token=regexp(text,'(?m)^\s*classdef\s*(?:\([^)]*\)\s*)?(\w+)','tokens','once');
    if strcmp(parent,['@' name]) || (~isempty(token) && strcmp(token{1},name))
      classes{end+1}=name; %#ok<AGROW>
      if ~ismember(parent,{['@' name],name}), flat{end+1}=name; end %#ok<AGROW>
    end
  end
end
classes=unique(classes);
tocs=dir(fullfile(ref,'**','*.toc'));
names=cellfun(@(x) x(1:end-4),{tocs.name},'UniformOutput',false);
assert(numel(unique(names))==numel(names),'Reference contents have duplicate basenames');
tocText=cellfun(@(f,n) fileread(fullfile(f,n)),{tocs.folder},{tocs.name},'UniformOutput',false);
tocText=strjoin(tocText,newline);
queue={'FunctionReference'};
visited={};
while ~isempty(queue)
  name=queue{1};queue(1)=[];
  if ismember(name,visited), continue; end
  visited{end+1}=name; %#ok<AGROW>
  idx=find(strcmp(names,name));
  if isempty(idx), continue; end
  text=fileread(fullfile(tocs(idx).folder,tocs(idx).name));
  entries=regexp(text,'(?m)^\s*([A-Za-z]\w*)','tokens');
  queue=[queue cellfun(@(x) x{1},entries,'UniformOutput',false)]; %#ok<AGROW>
end
for k=1:numel(classes)
  index=[classes{k} '_index'];
  assert(ismember(index,visited),'Class %s is missing from the function reference contents',classes{k});
  label=regexp(tocText,['(?m)^[ \t]*' index '[ \t]+([^\r\n]+)'],'tokens','once');
  assert(isempty(label) || contains(lower(label{1}),lower(classes{k})), ...
    'Class %s needs its API name in the navigation label',classes{k});
  source=dir(fullfile(ref,'**',[index '.m']));
  assert(numel(source)==1,'Class %s needs one globally unique class index',classes{k});
  if ismember(classes{k},flat)
    toc=fullfile(source.folder,[index '.toc']);
    assert(isfile(toc),'Class %s needs its inline class description in the contents',classes{k});
    assert(~isempty(regexp(fileread(toc),['(?m)^\s*' classes{k} '\s*$'],'once')), ...
      'Class %s is missing its class description link',classes{k});
  end
end
indexes=dir(fullfile(ref,'**','*_index.m'));
count=0;
for k=1:numel(indexes)
  text=fileread(fullfile(indexes(k).folder,indexes(k).name));
  body=regexp(text,'(?s)<pre>(.*?)</pre>','tokens','once');
  if isempty(body), continue; end
  entries=regexp(body{1},'(?m)^%\s*[│├└─ ]*([A-Za-z]\w*)\s*$','tokens');
  for j=1:numel(entries)
    name=entries{j}{1};
    assert(ismember(name,classes),'Diagram class %s has no source class',name);
    assert(ismember([name '_index'],visited),'Diagram class %s is missing from the contents',name);
    count=count+1;
  end
end
fprintf('checkFunctionReference: %d source classes and %d diagram classes covered.\n',numel(classes),count);
end
