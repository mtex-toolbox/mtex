function make_funcref


%input
toc_funcfile = 'functions_toc.xml';

%% create it
toc = xmlread(toc_funcfile);

make_mtex_version; %just to be shure

% alphabetic
dom = createDom;
make_func_alphabetic(toc,toc.getFirstChild,dom);
% publish
  out_file = fullfile(mtex_path,'help','html','mtexfuncbyalphabet.html');
  xslt(dom,'publishmtex.xsl',out_file);

% category
dom = createDom;
make_func_category(toc,toc.getFirstChild,dom);
% publish
  out_file = fullfile(mtex_path,'help','html','mtexfuncbycat.html');
  xslt(dom,'publishmtex.xsl',out_file);


function  make_func_alphabetic(toc,Node,dom)

if toc.getFirstChild.isSameNode(Node)
  text.table.ATTRIBUTE.width = '90%';  
  text.table.tr.td.ATTRIBUTE.align = 'right';
  text.table.tr.td.img.ATTRIBUTE.style = 'border:0px';
  text.table.tr.td.img.ATTRIBUTE.src = 'arrow_right.gif';
  text.table.tr.td.a.CONTENT = 'View Functions by Category';
  text.table.tr.td.a.ATTRIBUTE.href= 'mtexfuncbycat.html';
  make_func_header(dom,'MTEX Functions by Category',text);
  clear text
end

fold = Node.getElementsByTagName('folder');

help = cell(fold.getLength,1);
for n=0:fold.getLength-1
  folder = eval(fold.item(n).getTextContent);
  help{n+1} = helpfunc2struct(fullfile(folder{:}));
end

funcs = vertcat(help{:});
[fnames ndx] = sort( lower({funcs.name}));
funcs = funcs(ndx);

beginningLetter = cellfun(@(x) double(x(1)),fnames);
p = [0 find(diff(beginningLetter)) numel(funcs)];

cellNode.count = 1 ;
cellNode.steptitle = ' ';
cellNode.section = 0;
cellNode.text = '';
cellNode.cellOutputTarget = cellNode.count;

alphabet = char(double('A'):double('Z'));
for letter=1:numel(alphabet)
  text{letter}.span{1}.a.CONTENT = alphabet(letter);
  text{letter}.span{1}.a.ATTRIBUTE.href = ['#' num2str(letter+1)];
  text{letter}.span{1}.ATTRIBUTE.style = 'margin:5px';
end

cellNode.text = text;

struct2DOMnode(dom, dom.getDocumentElement, cellNode, 'cell');

for k=1:numel(p)-1
  cellNode.count = k+1 ;
  cellNode.steptitle = char(beginningLetter(p(k)+1)-32);
  cellNode.section = 0;
  cellNode.text = [];
  cellNode.cellOutputTarget = cellNode.count;
  
  cellNode.text.div.table = help2domtable(funcs(p(k)+1:p(k+1)),'withclassname');
  
  struct2DOMnode(dom, dom.getDocumentElement, cellNode, 'cell');

end


function make_func_category(toc,Node,dom)


if toc.getFirstChild.isSameNode(Node)
  text.table.ATTRIBUTE.width = '90%';  
  text.table.tr.td.ATTRIBUTE.align = 'right';
  text.table.tr.td.img.ATTRIBUTE.style = 'border:0px';
  text.table.tr.td.img.ATTRIBUTE.src = 'arrow_right.gif';
  text.table.tr.td.a.CONTENT = 'View Alphabetic Function List';
  text.table.tr.td.a.ATTRIBUTE.href= 'mtexfuncbyalphabet.html';
  make_func_header(dom,'MTEX Functions by Category',text);
  clear text
end

cellNode.count = nodePosition(toc,Node);
cellNode.steptitle = char(Node.getAttribute('name'));
cellNode.section = nodePosition(toc,Node.getParentNode);
cellNode.text = [];
cellNode.cellOutputTarget = cellNode.count;     


items = Node.getElementsByTagName('item');

pcount = 0;

if items.getLength > 0
  table = struct;
  table.ATTRIBUTE.class = 'ref';
  table.ATTRIBUTE.width = '90%';
  
  nn = 0;
  for k=0:items.getLength-1
    child = items.item(k);
    
    if child.getParentNode.isSameNode(Node)
      nn = nn+1;  
      table.tr(nn).td{1}.a.CONTENT = child.getAttribute('name');
      table.tr(nn).td{1}.a.ATTRIBUTE.href = ['#' num2str(nodePosition(toc,child))];
      table.tr(nn).td{1}.ATTRIBUTE.width = '250px';
              
      desc = child.getElementsByTagName('description');
      if desc.getLength > 0
        descriptNode  = desc.item(0);
        if descriptNode.getParentNode.isSameNode(child)
          table.tr(nn).td{2} = descriptNode.getTextContent;
        end
      end 
    end
  end
  
  pcount = pcount+1;
  cellNode.text.div(pcount).table = table;

end

folders = Node.getElementsByTagName('folder');
for k=0:folders.getLength-1
  folderNode =  folders.item(k);
  if folderNode.getParentNode.isSameNode(Node)
    folder = eval(folderNode.getTextContent);
        
    help = helpfunc2struct(fullfile(folder{:}));

    pcount = pcount+1;
    cellNode.text.div(pcount).table = help2domtable(help);
    
    
    if strfind(folder{end},'@')
      title = cellNode.steptitle;
      cellNode.steptitle =[];
      cellNode.steptitle.CONTENT{1} = [title ' (class @'];
      cellNode.steptitle.CONTENT{2}.a.CONTENT = folder{end}(2:end);
      cellNode.steptitle.CONTENT{2}.a.ATTRIBUTE.href = [folder{end}(2:end) '_index.html'];
      cellNode.steptitle.CONTENT{3} = ')';
    end
  end
end

struct2DOMnode(dom, dom.getDocumentElement, cellNode, 'cell');

% proced child nodes
if Node.hasChildNodes
  Childs = Node.getChildNodes;  
  for count = 0:Childs.getLength-1
    ChildNode = Childs.item(count);    
    if strcmpi(ChildNode.getNodeName,'item')          
      make_func_category(toc,ChildNode,dom);      
    end
  end
end


function make_func_header(dom,title,text)

cell.ATTRIBUTE.style = 'overview';
cell.steptitle.CONTENT = title;
cell.steptitle.ATTRIBUTE.style = 'document';
cell.text = text;
struct2DOMnode(dom, dom.getDocumentElement, cell, 'cell');


function dom = createDom
% Now create the new DOM
dom = com.mathworks.xml.XMLUtils.createDocument('mscript');
dom.getDocumentElement.setAttribute('xmlns:mwsh', ...
    'http://www.mathworks.com/namespace/mcode/v1/syntaxhighlight.dtd')

% Add version.
newNode = dom.createElement('version');
matlabVersion = ver('MATLAB');
newTextNode = dom.createTextNode(matlabVersion.Version);
newNode.appendChild(newTextNode);
dom.getFirstChild.appendChild(newNode);

% Add date.
newNode = dom.createElement('date');
newTextNode = dom.createTextNode(datestr(now,29));
newNode.appendChild(newTextNode);
dom.getFirstChild.appendChild(newNode);

  
function table = help2domtable(help,varargin)

do_classname = check_option(varargin,'withclassname');
for k = 1:numel(help)
        
  fname = help(k).name;
  ref = strcat(fname,'.html');
  if help(k).isclassdir
    ref = strcat(help(k).folder,'_',ref);
  end
  
  td = cell(2,1);
  td{1}.a.CONTENT = help(k).name;
  td{1}.a.ATTRIBUTE.href = ref;
  
  if do_classname && help(k).isclassdir
    td{1}.span.CONTENT = ['(' help(k).folder ')'];
    td{1}.span.ATTRIBUTE.style = 'margin-left:5px';
  end
  td{1}.ATTRIBUTE.width = '250px';
  td{2}.CONTENT = help(k).description;
  
  table.tr(k).td = td;
end
