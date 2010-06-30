function make_ug(folder,varargin)
% Make User Guide

% if isempty(folder)
% 	folder = fullfile(mtex_path,'help','UsersGuide');
% end

html_dir =  fullfile(mtex_path,'help','html');
dirs = getSubDirs(folder);

% clean up all files before
delete(fullfile(html_dir,'*.m'))

% if check_option(varargin,{'all','all-'})
  dotopics = ug_topics(folder);
% else
%   dotopics = extract_option(varargin,ug_topics);
% end

for k=1:numel(dirs)
  current_folder = dirs{k};
  [ig topic] = fileparts(current_folder);
  if ismember(topic,dotopics)
    ug_mfiles = dir(fullfile(current_folder,'*.m'));
    
    if isdir(current_folder),
      old_dir = pwd;
      cd(current_folder);
    end
    
    make_topic = false;
    make_abovetopic = false;
    for l=1:numel(ug_mfiles)
      ug_mfile = ug_mfiles(l).name;
      [ig mfile] = fileparts(ug_mfile);
      html_file = fullfile(html_dir,strrep(ug_mfile,'.m','.html'));
      
      if ~is_newer(html_file,fullfile(current_folder,ug_mfile)) || check_option(varargin,'force')
      	if ~strcmp(topic,mfile)
          trycopyfile(fullfile(current_folder,ug_mfile),fullfile(mtex_path,'help','html'));
          make_topic = true;
        else
          make_topic = true;
          make_abovetopic = true;
        end
      end           
      trycopyfile(fullfile(current_folder,'*.png'),html_dir);
    end
    
    if make_topic
      try
      make_topic_withtable( fullfile(current_folder,[topic '.m'] ) )
     	catch,
      end
    end
    
    if make_abovetopic
       [above_folder ig] = fileparts(current_folder);
       [ig above_topic] = fileparts(above_folder);
       try
       make_topic_withtable( fullfile(above_folder,[above_topic '.m'] ) );
       catch,
       end
    end
    
    if isdir(current_folder),
      cd(old_dir);
    end
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
% folder = fullfile(mtex_path,'help','UsersGuide');
[ig tops] = cellfun(@fileparts, getSubDirs(folder)','Uniformoutput',false);

function make_topic_withtable(mfile)

[current_folder ug_mfile] = fileparts(mfile);

fid = fopen(mfile);
mst = m2struct(char(fread(fid))');
fclose(fid);

mst(1).text = [mst(1).text , ' ', '<html>',make_toc_table(current_folder),'</html>'];
cell2file(fullfile(mtex_path,'help','html',[ug_mfile '.m']), struct2m(mst),'w');


function trycopyfile(varargin)

try, 
  copyfile(varargin{:});
catch
end


function o = is_newer(f1,f2)

d1 = dir(f1);
d2 = dir(f2);
o = ~isempty(d1) && ~isempty(d2) && d1.datenum > d2.datenum;

