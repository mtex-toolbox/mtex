function table = make_toc_table(toc_list)
% 

tabl.ATTRIBUTE.class = 'refsub';
tabl.ATTRIBUTE.width = '90%';

tr = [];
for k=1:numel(toc_list)
	mst = file2mst(toc_list{k});
	tr = [tr makeItem(toc_list{k},mst(1).title,mst(1).text,mst)];
end

html= createDom;
struct2DOMnode(html, html.getDocumentElement, tr, 'tr');

table = xmlwrite(html);
table = table(40:end);

table = regexp(table,'\n','split');


function item = makeItem(file,title,text,mst)

[above_folder ref] = fileparts(file);
[ig2 ref2] = fileparts(above_folder);

if ~isempty(text), text = strcat(text{:}); end

a.ATTRIBUTE.href = '#';
a.ATTRIBUTE.onClick =  ['return toggleexpander(''', ref, '_block'',''', ref, '_expandable_text'');'];
img.ATTRIBUTE.style = 'border:0px';
img.ATTRIBUTE.id = [ref, '_expandable_text'];
img.ATTRIBUTE.src = 'arrow_right.gif';

div.ATTRIBUTE.align = 'center';
div.a = a;
div.a.img = img;

item.td{1}.ATTRIBUTE.width = 15;
item.td{1}.ATTRIBUTE.valign= 'top';
item.td{1}.div = div;

td.ATTRIBUTE.valign = 'top';
td.ATTRIBUTE.width = '250px';

td.ATTRIBUTE.valign = 'top';
td.a.ATTRIBUTE.onClick = ['return toggleexpander(''', ref, '_block'',''', ref, '_expandable_text'');'];
td.a.ATTRIBUTE.onDblClick = ['document.location.href="' ref '.html"'];
td.a.ATTRIBUTE.href = '#';
%[ref, '_expandable_text'];
td.a.ATTRIBUTE.class = 'toplink';
td.a.CONTENT = title;


div = [];
div.ATTRIBUTE.style = 'display:none; background:#e7ebf7; padding-left:2ex;';
div.ATTRIBUTE.id    = [ref, '_block'];
div.ATTRIBUTE.class = 'expander';
% div.CONTENT = text;




tr = [];

if ~strcmpi(ref,ref2)
  titles = {mst(2:end).title};
  rel = find(cellfun(@(x) ~isempty(x) && ~any(strcmpi(x,badKeyword)) ,titles));

  for k=1:numel(rel)
    a = [];
    a.CONTENT = titles{ rel(k) };
    a.ATTRIBUTE.href = [ ref '.html#' num2str(rel(k))];
    a.ATTRIBUTE.style = 'font-weight:normal';
    tr(k).td.a = a;
    tr(k).td.ATTRIBUTE.align = 'left';
  end
else
  ug_files = get_ug_files(fullfile(mtex_path,'help','UsersGuide'),{'*.m','*.html'});
  toc_list = regexprep(file2cell(fullfile(above_folder,'toc')),'\s(\w*)','');
  for k = 1:numel(toc_list);
    ug_file = get_ug_filebytopic(ug_files,toc_list{k});
    mst = file2mst(ug_file);
    
    a = [];
    a.CONTENT = mst(1).title;
    a.ATTRIBUTE.href = [toc_list{k}  '.html'];
    a.ATTRIBUTE.style = 'font-weight:normal';
    tr(k).td.a = a;
    tr(k).td.ATTRIBUTE.align = 'left';     
  end
end

div.table.tr = tr;
% div.table.ATTRIBUTE.class = 'contents';


% td.table.tr{2}.td.div = div;
item.td{2} = td;
item.ATTRIBUTE.align ='left';
item.td{3}.CONTENT = text;
item.td{3}.ATTRIBUTE.valign = 'top';

item(2).td.ATTRIBUTE.width = '15';
item(2).th.ATTRIBUTE.colspan=2;
item(2).th.ATTRIBUTE.align='left';
item(2).th.div = div;



function html = createDom
html = com.mathworks.xml.XMLUtils.createDocument('table');
htmlt = html.getDocumentElement();
htmlt.setAttribute('class','ref');
htmlt.setAttribute('width','90%');
