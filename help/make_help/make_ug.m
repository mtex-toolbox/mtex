function make_ug(folder,varargin)
% Make User Guide
%
%% options
% TopicPages  - force topic page creation

html_dir =  fullfile(mtex_path,'help','html');
ug_example_path = fullfile(mtex_path,'examples','UsersGuide');
ug_files = get_ug_files(folder,{'*.m','*.html'});

for pics = reshape(get_ug_files(folder,'*.png'),1,[])
  trycopyfile(pics{:},html_dir);
end

% clean up all files before
delete(fullfile(html_dir,'*.m'));

for k=1:numel(ug_files)
  ug_file = ug_files{k};
  
  [above_folder topic] = fileparts(ug_file);
  [a above_topic] = fileparts(above_folder);
  
  html_file = fullfile(html_dir,[topic,'.html']);
  if strcmpi(topic,above_topic) % special topic
    toc_list = {};    
    for tocentry = regexprep(file2cell(fullfile(above_folder,'toc')),'\s(\w*)','');
      toc_list = [toc_list, get_ug_filebytopic(ug_files,tocentry{:})];
    end
        
    make_topic = false;
   
    for tocentry = toc_list
      make_topic = make_topic | ~is_newer(html_file,tocentry{:});
    end
    
    if make_topic || ~is_newer(html_file,ug_file)  || check_option(varargin,'force')  || check_option(varargin,'TopicPages')
      make_topic_withtable( ug_file, toc_list);
    end
  elseif ~is_newer(html_file,ug_file) || check_option(varargin,'force')
    trycopyfile(ug_file,html_dir);
  end
  
  if is_openineditor(ug_file)
    trycopyfile(ug_file,ug_example_path);
  end
end


mfiles = dir( fullfile(html_dir,'*.m') );

publish_files({mfiles.name},html_dir,...
  'stylesheet',fullfile(mtex_path,'help','make_help','publishmtex.xsl'),...
  'out_dir',html_dir,'evalcode',1,'force',varargin{:}); 

delete(fullfile(html_dir,'*.m') );



function mtext = struct2m(mst)

mtext = {};
for k=1:numel(mst)  
  mtext = [mtext ...
              ['%% ' mst(k).title] ...
              regexprep(strcat('%[' , mst(k).text,']%'),{'%[',']%'},{'% ','  '}),...
              mst(k).code];
end

function tops = ug_topics(folder)
[ig tops] = cellfun(@fileparts, getSubDirs(folder)','Uniformoutput',false);

function make_topic_withtable(mfile, toc_list)

l = dir(mfile);

fid = fopen(mfile);
mst = m2struct(char(fread(fid))');
fclose(fid);

mst(1).text = [mst(1).text , ' ', '<html>',make_toc_table(toc_list),'</html>'];
cell2file(fullfile(mtex_path,'help','html',l.name), struct2m(mst),'w');



function b = is_openineditor(mfile)

fid = fopen(mfile);
mst = m2struct(char(fread(fid))');
fclose(fid);
b = any(strcmpi({mst.title},'Open in Editor'));

function trycopyfile(varargin)

try, 
  copyfile(varargin{:});
catch
end


function o = is_newer(f1,f2)

d1 = dir(f1);
d2 = dir(f2);

o = ~isempty(d1) && ~isempty(d2) && d1.datenum > d2.datenum;




