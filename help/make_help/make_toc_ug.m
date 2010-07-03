function toc = make_toc_ug(folder,varargin)


ug_files = get_ug_files(folder,{'*.m','*.html'});
ug_tocs = get_ug_files(folder,'toc');

toc = make_sub({},folder,ug_files,varargin{:});


function toc = make_sub(toc,folder,ug_files,varargin)

[ig topic] = fileparts(folder);

topic_file = get_ug_filebytopic(ug_files,topic);

switch get_fileext(topic_file)
  case '.m'
    toc = [toc m2subToc(topic_file,varargin{:})];
  case '.html'
    toc = [toc tocItemOpen(topic,[ topic '.html'])];
end

if isdir(folder)
  toccontents = file2cell(fullfile(folder,'toc'));
  toccontents = regexpi(toccontents,'(?<item>\w*)\s(?<icon>\w*)|(?<item>\w*)','names');
  for entry = [toccontents{:}]  
    toc = make_sub(toc,fullfile(folder,entry.item),ug_files,entry.icon);
  end
end

toc = [toc tocItemClose];



function str = tocItemOpen(title,ref,icon)

if nargin > 2 && ~isempty(icon)    
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

badKeyw = {'Abstract','Contents','Open in Editor','See also','View Code'};

refcells = ~cellfun('isempty',{mst.title});  
for k=2:numel(refcells)
  if ~isempty(mst(k).title) && ~any(strcmpi(mst(k).title,badKeyw))
    str{end+1} = tocItem(mst(k).title,[ mfile '.html#' num2str(k-1)]);
  end
end


function extension = get_fileext(fname)
extension = fname(find(fname == '.', 1, 'last'):end);

