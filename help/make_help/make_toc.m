function make_toc


catfile = 'mtexfuncbycat.html';

cattoc = fullfile(mtex_path,'help','mtex','helptoc.xml');
tocfile = file2cell(fullfile(mtex_path,'help','make_help','helptoc.xml'));

tocpos = find(~cellfun('isempty',strfind(tocfile,'<makefuncbycat>')));


     
categories = generateToky;

str = [makeTocHeader makeTable(categories,true)];

toc = {... '<toc version="2.0">', ...
  ['<tocitem target="' catfile '" image="$toolbox/matlab/icons/help_fx.png">Functions']};

for catgry = categories
  ref_cat = link(catgry.title);
  
  str = [str ...
    addHeading('h1',catgry.title,ref_cat) ...
    makeTable(catgry.subcategory,false)];
  
  toc = addTocEntry(toc, [catfile '#' ref_cat], catgry.title);

  for sub = catgry.subcategory
    ref_sub = link(sub.title);
    
    str = [str ...
            addHeading('h2',sub.title,ref_sub) ...
            makeTable(sub.item,false) ...
            addBackToSec(ref_cat)];
          
    toc = addTocEntry(toc, [catfile '#' ref_sub], sub.title);
    
    for item = sub.item      
     
      folder = item.folder;
      fl = makeContentStr( fullfile(mtex_path,folder{:}) );
    
      ref_name = char(regexprep(folder{end},'@',''));
      if ~isempty(ref_name), ref_name = [ref_name,'_'];end
      
      class_name = char(regexp(folder{end},'(?<=@)\w*(?=\w*)','match'));
      if ~isempty(class_name), class_name = [class_name,'_'];end
      
      
      str = [ str,...
              addHeading('h3',{item.title , fullfile(folder{:}) } ,link(item.title),ref_name) ...
             '<table>',...
              regexprep(fl(4:end),'%\s+(\w*)\s+-([\W\S]*)', ...
                ['<tr><td width=200px><a href="' class_name '$1.html">$1</td><td> $2 </td></tr>']),...
              '</table>',...
              addBackToSec(ref_sub)];
            
%        toc = [toc ...
%          [' <tocitem target="' class_name 'index.html">' folder{2}] ...
%           regexprep(fl(4:end),'%\s+(\w*)\s+-([\W\S]*)', ...
%                ['<tocitem target="' class_name '$1.html"><name>$1</name><purpose>$2</purpose></tocitem>']) ...
%           '</tocitem>'];
       toc = addTocEntry(toc, [ref_name 'index.html'], folder{2});
       toc = [toc ...
               regexprep(fl(4:end),'%\s+(\w*)\s+-([\W\S]*)', ...
                 ['<tocitem target="' class_name '$1.html"  image="$toolbox/matlab/icons/help_fx.png">$1</tocitem>'])];        
       toc = closeTocEntry(toc);
      
    end    
    toc = closeTocEntry(toc);
    
  end
  toc = closeTocEntry(toc);
  
end
toc = closeTocEntry(toc);

str{end+1} =  '</body></html>';


cell2file(fullfile(mtex_path,'help','html',catfile),str,'w');


toc = [tocfile(1:tocpos-1)  toc  tocfile(tocpos+1:end)];
toc = makeDemosToc(toc);

cell2file(cattoc,toc,'w');



function str = makeTable(cat,sub)


if sub,  str = {'<table class="ref" width="90%">'};
else  str = {'<table class="refsub" width="90%">'}; end

for c=cat 
	str{end+1} = strcat('<tr><td width="50%"><a href="#', link(c.title),  '">' ,c.title, ...
                          '</a></td><td width="50%">', c.description, '</td></tr>');
end
str{end+1} = '</table>';




function toc = makeDemosToc(toc)


fl = makeContentStr( fullfile(mtex_path,'examples') );

% write demos.xml
str = [ makeDemoTocHeader,...
        regexprep(fl(4:end),'%\s+(\w*)\s+-([\W\S]*)', ...
               '<demoitem><label>$2</label><type>M-file</type><source>$1</source></demoitem>'),...
     '</demos>'];
cell2file(fullfile(mtex_path,'examples','demos.xml'),str,'w');

% makedemotoc
demotoc = [ '<tocitem target="demos.html" image="$toolbox/matlab/icons/demoicon.gif">Demos',...
            regexprep(fl(4:end),'%\s+(\w*)\s+-([\W\S]*)', '<tocitem target="$1.html">$2</tocitem>'),...
            '</tocitem>'];
          
tocpos = find(~cellfun('isempty',strfind(toc,'<makedemo>')));
toc = [toc(1:tocpos-1)  demotoc  toc(tocpos+1:end)];

function toc = addTocEntry(toc,refpage,title)
  toc = [toc ...
    ['<tocitem target="' refpage '">' title]];


function toc = closeTocEntry(toc)
 toc = [toc ...
   '</tocitem>'];


function strc = makeContentStr(folder)

current_dir = pwd; cd(folder);
makecontentsfile('.','force');
cd(current_dir);

file = fullfile(folder,'Contents.m');
strc = file2cell(file);
delete(file);


function ref = link(str)
ref = num2str(sum(double(str)));

function bac = addBackToSec(ref)
bac = strcat('<p><a href="#',ref,'">Back to Top of Section</a></p>');

function hd = addHeading(format,title,ref,refindex)

if nargin > 3
  hd = ['<' format ' class="ref">' title{1} ' (<a href="', refindex 'index.html" name="',ref,'">',title{2},'</a>)</' format '>'];
else
  hd = ['<' format ' class="ref"><a name="',ref,'"></a>',title,'</' format '>'];
end

function catgry = generateToky

catgry = addCat([],'Geometry','Geometry Classes for QTA');
  catgry = addSubCat(catgry,'Rotations','Treating all kinds of rotations');
    catgry = addItem(catgry, 'Quaternions',{'geometry' '@quaternion'},'Representation of rotations');
    catgry = addItem(catgry, 'Rotation',{'geometry' '@rotation'},'Generall rotations');
    catgry = addItem(catgry, 'Crystal Symmetry',{'geometry' '@symmetry'},'Space Group');
    catgry = addItem(catgry, 'Orientations',{'geometry' '@orientation'},'Crystallographic equivalent rotations');
    catgry = addItem(catgry, 'Orientation Space',{'geometry' '@SO3Grid'},'Discretisation of SO(3)');

  catgry = addSubCat(catgry,'Directions','Vectors and Crystal Directions');
    catgry = addItem(catgry, 'Vector',{'geometry' '@vector3d'});
    catgry = addItem(catgry, '2D - Sphere',{'geometry' '@S2Grid'});
    catgry = addItem(catgry, 'Miller',{'geometry' '@Miller'});

  catgry = addSubCat(catgry,'Miscellaneous','Additional geometry Classes');
    catgry = addItem(catgry, '1D - Sphere',{'geometry' '@S1Grid'});
    catgry = addItem(catgry, 'Polygons',{'geometry' '@polygon'},'Helper treating geometry of grains');
    catgry = addItem(catgry, 'Helping Functions',{'geometry' 'geometry_tools'});

catgry = addCat(catgry,'Quantitative Texture Analysis','Classes required for QTA');
  catgry = addSubCat(catgry,'Orientation Density');
    catgry = addItem(catgry, 'ODF',{'qta' '@ODF'},'Class implementing the Orientation Density Function');
    catgry = addItem(catgry, 'Standard ODFs',{'qta' 'standardODFs'},'Predefined Orientation Density Functions');
    catgry = addItem(catgry, 'Kernels',{'qta' '@kernel'},'Radially symmetric functions on SO(3)');

  catgry = addSubCat(catgry,'Experimental Data','Data Structures for Experimental Data');
    catgry = addItem(catgry, 'PoleFigure Data',{'qta' '@PoleFigure'},'Class for Polefigur data');
    catgry = addItem(catgry, 'EBSD Data',{'qta' '@EBSD'},'Class for Electron Backscatter Diffraction Data');
    catgry = addItem(catgry, 'Grains',{'qta' '@grain'},'Reconstructed Grains out of EBSD Data');
    catgry = addItem(catgry, 'Importing experimental Data',{'qta' 'interfaces'});
 
catgry = addCat(catgry,'Additional Functions','Helper functions making life easier');
    catgry = addSubCat(catgry,'Tools');
    catgry = addItem(catgry, 'Plotting',{'tools' 'plot_tools'});
    catgry = addItem(catgry, 'Dubna Data',{'tools' 'dubna_tools'});
    catgry = addItem(catgry, 'Statistics',{'tools' 'statistic_tools'});
    catgry = addItem(catgry, 'Math',{'tools' 'math_tools'});
  

function cat = addCat(cat,title,desc)
cat(end+1).title = title;
if nargin < 3, desc= ''; end
cat(end).description = desc;
cat(end).subcategory = [];

function cat = addSubCat(cat,subtitle,desc)
cat(end).subcategory(end+1).title = subtitle;
if nargin < 3,  desc= ''; end
cat(end).subcategory(end).description = desc;
cat(end).subcategory(end).item = [];

function cat = addItem(cat,title,item,desc)
% item
cat(end).subcategory(end).item(end+1).title = title;
if nargin < 4,  desc= ''; end
cat(end).subcategory(end).item(end).description = desc;
cat(end).subcategory(end).item(end).folder = item;

function str = makeTocHeader

str = {'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN">',...
       '<html><head>',...
       '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',...
       '<title>Functions by Category</title>',...
       '<link rel="stylesheet" href="style.css">',...
       '</head><body>',...
       '<h1 class="reft">MTEX Functions by Category</h1>',...
       };
     
function str = makeDemoTocHeader     
     
str = {'<?xml version="1.0" encoding="utf-8"?>',...
       '<demos>',...
       '<name>MTEX</name>',...
       '<type>toolbox</type>',...
       '<icon>$toolbox/matlab/icons/matlabicon.gif</icon>',...
       '<description isCdata="no">   ',...
       '<p> MTEX is a toolbox for quantitative texture analysis. It provides tools to analyze</p>',...
        '</description>'};
