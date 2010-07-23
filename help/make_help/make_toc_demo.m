function make_toc_demo

%output
toc_file = fullfile(mtex_path,'examples','demos.xml');
demotoc = file2cell(fullfile(mtex_path,'examples','toc'));

%input
dom = createDemoDom;

for k=1:numel(demotoc)
  fid = fopen(fullfile(mtex_path,'examples',[demotoc{k},'.m']),'r');
  label = regexprep(fgetl(fid),'%%','');
  fclose(fid); 
  
  demoitem(k).label = label;
  demoitem(k).type  = 'M-file';
  demoitem(k).source = demotoc{k};
end
      
struct2DOMnode(dom, dom.getFirstChild, demoitem, 'demoitem');


% xmlwrite(dom)
xmlwrite(toc_file,dom);


function toc = createDemoDom
    
toc = com.mathworks.xml.XMLUtils.createDocument('demos');

description.p = ...
  ['The MTEX Toolbox software provides a comprehensive set of functions ' ...
   'for exploring, processing and understanding Quantitative Texture Analysis (QTA)'];
 
description.ATTRIBUTE.isCdata = 'no';
struct2DOMnode(toc, toc.getDocumentElement, 'MTEX', 'name');
struct2DOMnode(toc, toc.getDocumentElement, 'toolbox', 'type');
struct2DOMnode(toc, toc.getDocumentElement, 'mtex_icon.gif', 'icon');
struct2DOMnode(toc, toc.getDocumentElement, description, 'description');



