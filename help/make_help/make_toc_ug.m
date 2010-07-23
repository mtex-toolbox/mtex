function make_toc_ug(toc,folder,varargin)


ug_files = get_ug_files(folder,{'*.m','*.html'});
make_sub(toc,toc.getLastChild.getFirstChild,folder,ug_files,varargin{:});


function make_sub(toc,parent,folder,ug_files,varargin)

[ig topic] = fileparts(folder);

topic_file = get_ug_filebytopic(ug_files,topic);

switch get_fileext(topic_file)
  case '.m'
    m2subToc(toc, parent, topic_file,varargin{:});
  case '.html'
    html2subToc(toc, parent, topic_file,varargin{:});
end

if isdir(folder)
  toccontents = file2cell(fullfile(folder,'toc'));
  toccontents = regexpi(toccontents,'(?<item>\w*)\s(?<icon>\w*)|(?<item>\w*)','names');
  for entry = [toccontents{:}]  
    make_sub(toc,parent.getLastChild,fullfile(folder,entry.item),ug_files,entry.icon);
  end
end


function m2subToc(toc,parent,mfile,icon)

fid = fopen(mfile);
mst = m2struct(char(fread(fid))');
fclose(fid);
    
[path mfile] = fileparts(mfile);

tocItem.CONTENT = mst(1).title;
tocItem.ATTRIBUTE.target = [mfile '.html'];
if nargin>3
  tocItem.ATTRIBUTE.image = ['$toolbox/matlab/icons/' icon '.gif' ];
end

ref = find(cellfun(@(x) ~isempty(x) && ~any(strcmpi(x,badKeyword)) ,{mst(2:end).title}));
for k=1:numel(ref)
  tocItem.tocitem(k).CONTENT = mst(ref(k)+1).title;
  tocItem.tocitem(k).ATTRIBUTE.target = [ mfile '.html#' num2str(ref(k))];
end

struct2DOMnode(toc, parent, tocItem, 'tocitem');


function html2subToc(toc,parent,mfile,varargin)

html = xmlread(mfile);
title = html.getElementsByTagName('title');
titletext =  char(title.item(0).getFirstChild.getNodeValue());

mfile = dir(mfile);

tocItem.CONTENT = titletext;
tocItem.ATTRIBUTE.target = [mfile.name '.html'];

struct2DOMnode(toc, parent, tocItem, 'tocitem');


function extension = get_fileext(fname)
extension = fname(find(fname == '.', 1, 'last'):end);

