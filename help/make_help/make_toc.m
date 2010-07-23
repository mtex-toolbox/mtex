function make_toc

%output
toc_file = fullfile(mtex_path,'help','mtex','helptoc.xml');

%input
toc_funcfile = 'functions_toc.xml';


%% create it
dom = createTocDom;

make_toc_ug(dom,fullfile(mtex_path,'help','GettingStarted'),'greenarrowicon');
make_toc_ug(dom,fullfile(mtex_path,'help','UsersGuide'),'book_mat');

toc_functions = xmlread(toc_funcfile);
make_toc_func(toc_functions,toc_functions.getFirstChild,dom.getLastChild.getLastChild);

dom.getLastChild.getLastChild.getLastChild.setAttribute('image','$toolbox/matlab/icons/help_fx.png');

make_toc_ug(dom,fullfile(mtex_path,'examples'),'demoicon');
make_toc_ug(dom,fullfile(mtex_path,'help','ReleaseNotes'),'notesicon');

xmlwrite(toc_file,dom);


function toc = createTocDom
    
toc = com.mathworks.xml.XMLUtils.createDocument('toc');
tocmtex = toc.getDocumentElement();
tocmtex.setAttribute('version','2.0');
tocitem.CONTENT = 'MTEX Toolbox';
tocitem.ATTRIBUTE.target = 'mtex_product_page.html';
tocitem.ATTRIBUTE.image = 'mtex_icon.gif';
struct2DOMnode(toc, toc.getFirstChild, tocitem, 'tocitem');


function make_toc_func(toc,Node,domNode)

funcfile = 'mtexfuncbycat.html';

if strcmpi(Node.getTagName,'item')  
  tocItem.CONTENT = Node.getAttribute('name');
  tocItem.ATTRIBUTE.target = [funcfile '#' num2str(nodePosition(toc,Node))];
  struct2DOMnode(domNode.getOwnerDocument, domNode, tocItem, 'tocitem');
  
  folders = Node.getElementsByTagName('folder');
  for k=0:folders.getLength-1
    folderNode =  folders.item(k);
    if folderNode.getParentNode.isSameNode(Node)
      folder = eval(folderNode.getTextContent);
      help = helpfunc2struct(fullfile(folder{:}));
      
      for n=1:numel(help)
        fname = help(n).name;
        ref = strcat(fname,'.html');
        if help(n).isclassdir
          ref = strcat(help(n).folder,'_',ref);
        end
        
        funcItems(n).CONTENT = help(n).name;
        funcItems(n).ATTRIBUTE.target = ref;
        funcItems(n).ATTRIBUTE.image = '$toolbox/matlab/icons/help_fx.png';
      end
      
      struct2DOMnode(domNode.getOwnerDocument, domNode.getLastChild, funcItems, 'tocitem');
    end
  end
end

% proced child nodes
if Node.hasChildNodes
  Childs = Node.getChildNodes;
  for count = 0:Childs.getLength-1
    ChildNode = Childs.item(count);
    if strcmpi(ChildNode.getNodeName,'item')
      make_toc_func(toc,ChildNode,domNode.getLastChild);
    end
  end   
end


