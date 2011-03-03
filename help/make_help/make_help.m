function make_help(varargin)
%
%
% 'topicpages'

%% set global options
recycle('off')
timing = tic;

% addpath(pwd);
plotx2east;

html_path = get_option(varargin,'html_path',fullfile(mtex_path,'help','html'));
publish_style = get_option(varargin,'publish_style',fullfile(mtex_path,'help','make_help', 'publishmtex.xsl'));
example_style = get_option(varargin,'example_style',fullfile(mtex_path,'help','make_help', 'example_style.xsl'));
evalcode = get_option(varargin,'evalcode',true);


global mtex_progress;
mtex_progress = 0;

if check_option(varargin,'clear')
  delete(fullfile(html_path,'*.*'));
  delete(fullfile(mtex_path,'examples','html','*.*'));
end

set_mtex_option('generate_help',true);
set(0,'FormatSpacing','compact')

c = get(0,'DefaultFigureColor');
set(0,'DefaultFigureColor','white');

%% update version string

make_mtex_version;

%% generate general help files

tocopy(1).from = strcat('help',filesep,'general',filesep,...
                                      {'*.gif','*.html','*.css','*.js'});
tocopy(1).to   = '';

tocopy(2).from = {'README','COPYING','VERSION'};
tocopy(2).to   = '*.txt';

copy_it = @(infile,to) cellfun( @(from) copyfile( ...
  fullfile(mtex_path,from),regexprep(to,'*',from)), infile);

arrayfun(@(x) copy_it(x.from,fullfile(html_path,x.to)), tocopy);

%% generate TOCs

if nargin > 0 && ~check_option(varargin,{'clear','notoc'})
  make_toc;
end

%% generate Function list

if check_option(varargin,{'FunctionsReference','all','all-'})
  make_funcref;
end

%% generate classes index files

if check_option(varargin, {'classes','all','all-'})
   
  current_path = fullfile(mtex_path, 'help','classes');

  folders = {...
    {'qta' '@tensor'},{'qta' '@ODF'},{'qta' '@PoleFigure'},{'qta' '@EBSD'},{'qta' '@kernel'},{'qta' '@grain'},...
    {'qta' 'standardODFs'},...
    {'geometry' '@vector3d'},{'geometry' '@quaternion'},{'geometry' '@Miller'},...
    {'geometry' '@symmetry'},{'geometry' '@S1Grid'},{'geometry' '@S2Grid'},...
    {'geometry' '@rotation'},{'geometry' '@orientation'},...
    {'geometry' '@polygon'}, {'geometry' '@polyeder'}, {'geometry' '@polytope'},...
    {'geometry' '@SO3Grid'},{'geometry' 'geometry_tools'},...
    {'tools'},{'tools' 'dubna_tools'},{'tools' 'statistic_tools'},...
    {'tools' 'plot_tools'}};

  for i = 1:length(folders)
  
    % name of the index files
    folder = char(regexp(folders{i}{end},'(\w*)$','match'));
    in_file = fullfile(current_path,[folder '_index.m']);
    script_file = fullfile(current_path, ['script_',folder,'_index.m']);
    html_file = fullfile(html_path,[folder,'_index.html']);
    
%     in_file
    if is_newer(html_file,in_file) && ~check_option(varargin,'force')
      continue;
    end
    
    % make index mfile
    disp(in_file)
    disp(script_file)
    copyfile(in_file,script_file);
    
    isinterface = strfind(folders{i}(:),'interfaces');
    if any([isinterface{:}]); folders{i} = {'qta' 'interfaces'}; end
    make_index(fullfile(mtex_path,folders{i}{:}),script_file);

  end

  files = dir(fullfile(current_path,'script_*.m'));
  publish_files({files.name},current_path,'out_dir',html_path,...
    'evalcode',evalcode,'stylesheet',publish_style,varargin{:});
  delete(fullfile(current_path, 'script_*.m'));
end

%% generate help script files for all m files

if check_option(varargin, {'mfiles','all','all-'})

  folders = {'qta','geometry','plot','tools','statistic'};

  for i=1:length(folders)
    apply_recursivly(fullfile(mtex_path,folders{i}),...
      @(file) generate_script(file,html_path,varargin{:}),'*.m');  
  end

 % publish all script_files in help/classes directory
 files = dir(fullfile(html_path, 'script_*.m'));
 if ~isempty(files)
   publish_files({files.name},html_path,'out_dir',html_path,...
     'stylesheet',publish_style,'evalcode',false,'waitbar',varargin{:});
   delete(fullfile(html_path,'script_*.m'));
 end
 
end

%% Make Getting Started

if check_option(varargin,{'GettingStarted','all','all-'}), 
  make_ug(fullfile(mtex_path,'help','GettingStarted'),'evalcode',false,varargin{:}); 
end

%% Make User Guide

if check_option(varargin,{'UsersGuide','all','all-'}), 
  make_ug(fullfile(mtex_path,'help','UsersGuide'),varargin{:}); 
end

%% Make Release Notes
if check_option(varargin,{'ReleaseNotes','all','all-'}), 
  make_ug(fullfile(mtex_path,'help','ReleaseNotes'),'evalcode',false,varargin{:}); 
end

%% calculate examples
if check_option(varargin, {'examples','all'})
 
  make_toc_demo;
  copyfile( fullfile(mtex_path,'help','general','*.css') , ...
    fullfile(mtex_path,'examples','html') );

  current_path = fullfile(mtex_path,'examples');
  files = dir(fullfile(current_path ,'*.m'));
  publish_files({files.name},current_path,'stylesheet',example_style,...
    'out_dir',fullfile(current_path, 'html'),'evalcode',evalcode,varargin{:});
  copyfile(fullfile(current_path, 'html','*.html'),html_path);
  copyfile(fullfile(current_path, 'html','*.png'),html_path);
  
  make_ug(fullfile(mtex_path,'examples'),'topicpages',varargin{:}); 
end

set(0,'DefaultFigureColor',c)

toc(timing)

%% finisch
set_mtex_option('generate_help',false);
% rmpath(pwd);

%% create searchable database
if ~check_option(varargin,'dontpack')
  system(['jar -cf ' fullfile(mtex_path,'help','mtex','help.jar') ' -C ' fullfile(mtex_path,'help','html') ' .']);
  
  builddocsearchdb(fullfile(mtex_path ,'help','html'));
  helpsearchpath = fullfile(mtex_path, 'help','html','helpsearch');
  if exist(helpsearchpath,'dir'),
    e = rmdir(fullfile(mtex_path, 'help','mtex','helpsearch'),'s');
    movefile(helpsearchpath, fullfile(mtex_path, 'help','mtex'),'f');
  end
end


function o = is_newer(f1,f2)

d1 = dir(f1);
d2 = dir(f2);
o = ~isempty(d1) && ~isempty(d2) && d1.datenum > d2.datenum;

