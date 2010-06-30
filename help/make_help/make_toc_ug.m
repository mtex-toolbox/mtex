function toc = make_toc_ug(toc,folder,varargin)

[path topic] = fileparts(folder);


if isdir(folder),
  old_dir = pwd;
  cd(folder);
end

if exist([topic '.m'],'file')
  toc = [toc m2subToc([topic '.m'],varargin{:})];
elseif exist([folder '.m'],'file')
  toc = [toc m2subToc([folder '.m'],varargin{:})];  
else
  toc = [toc tocItemOpen(topic,[topic '.html'],varargin{:})];
end


if isdir(folder)
  str = file2cell(fullfile(folder,'toc'));
  for subtoc=regexp(str,'\s','split')
    subtoc = subtoc{1};
    toc = make_toc_ug(toc, fullfile(folder,subtoc{1}),subtoc{2:end});
  end
end

toc = [toc tocItemClose];

if isdir(folder),
  cd(old_dir)
end


function str = tocItemOpen(title,ref,icon)
if nargin > 2
  str = ['<tocitem target="' ref '" image="$toolbox/matlab/icons/' icon '.gif">' title];
else
  str = ['<tocitem target="' ref '">' title];
end

function str = tocItemClose
str = '</tocitem>';

function str = tocItem(title,ref)
str = ['<tocitem target="' ref '">' title '</tocitem>'];


function str = m2subToc(mfile,varargin)

fid = fopen(mfile);  
mst = m2struct(char(fread(fid))');
fclose(fid);


    
[path mfile] = fileparts(mfile);
str = {tocItemOpen(mst(1).title,[mfile '.html'],varargin{:})}; 

badKeyw = {'Abstract','Contents','Open in Editor'};

refcells = ~cellfun('isempty',{mst.title});  
for k=2:numel(refcells)
  if ~isempty(mst(k).title) && ~any(strcmpi(mst(k).title,badKeyw))
    str{end+1} = tocItem(mst(k).title,[ mfile '.html#' num2str(k-1)]);
  end
end

