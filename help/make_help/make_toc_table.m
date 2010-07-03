function table = make_toc_table(toc_list)

table = {'<table class="refsub" width="90%">'};

for tocentry = reshape(toc_list,1,[])
  mst = file2mst(tocentry{:});
  table = [table addItem(tocentry{:},mst(1).title,mst(1).text,mst)];
end

table{end+1} = '</table>';



function item = addItem(tocentry,title,text,mst)

[ig ref] = fileparts(tocentry);
[ig2 ref2] = fileparts(ig);
% 
if ~isempty(text)
text = strcat(text{:});
end

item = strcat(' <tr>',...
    '<td width="15"  valign="top">',...
    '<div align="center">',...
    '<a href="#" onClick="return toggleexpander(''', ref, '_block'',''', ref, '_expandable_text'');">',...
    '<img style="border:0;" id="', ref, '_expandable_text" src="arrow_right.gif">',...
    '</a></div>',...
    '</td><td width="250px"  valign="top"><a href="', ref,  '.html" class="toplink">' ,title, '</a></td>',...
    '<td valign="top">',text , '</td></tr>');
  
if nargin > 3
   item = [item,...
      ['<tr><td width="15"  valign="top"></td><th colspan="2"><div style="display:none; background:#e7ebf7; padding-left:2ex;" id="', ref, '_block" class="expander">']];
    
  if strcmp(ref,ref2)
    item = [item, toc2subToc(ig)];
  else  
    item = [item, m2subToc(ref,mst)];  
  end
  item = [item, '</div></th></tr>'];
% strvcat(item)
end


function str = m2subToc(ref,mst,varargin)

str = {'<table>'};
badKeyw = {'Abstract','Contents','Open in Editor','See also','View Code'};

refcells = ~cellfun('isempty',{mst.title});  
for k=2:numel(refcells)
  if ~isempty(mst(k).title) && ~any(strcmpi(mst(k).title,badKeyw))
    str{end+1} = ['<tr><td valign="top" align="left"><a href="', [ ref '.html#' num2str(k-1)],  '" class="blanklink">' ,mst(k).title, ...
                           '</a></td></tr>'];
  end
end
str{end+1} = '</table>';

% strvcat(str)


function str = toc2subToc(folder,toc_list)

    
top = regexprep(file2cell(fullfile(folder,'toc')),'\s(\w*)','');
ug_files = get_ug_files(fullfile(mtex_path,'help'),{'*.m','*.html'});

str = {'<table>'};
for k=1:numel(top)
  mst = file2mst(get_ug_filebytopic(ug_files,top{k}));
  str{end+1} = ['<tr><td valign="top" align="left"><a href="', [ top{k} '.html'],  '" class="blanklink">' , mst(1).title, ...
                           '</a></td></tr>'];                     
end
str{end+1} = '</table>';



function extension = get_fileext(fname)
extension = fname(find(fname == '.', 1, 'last'):end);


function mst = file2mst(file)

switch get_fileext(file)
	case '.m' 
    fid = fopen(file);  
    mst = m2struct(char(fread(fid))');
    fclose(fid);
  case '.html'
    docr = xmlread(file);
    title = docr.getElementsByTagName('title');
    intro = docr.getElementsByTagName('introduction');
      
    mst(1).title = char(title.item(0).getFirstChild.getNodeValue());
    mst(1).text = {char(intro.item(0).getFirstChild.getNodeValue)};
end
