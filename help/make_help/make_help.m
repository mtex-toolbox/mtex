function make_help(varargin)
%
%
% 'topicpages'

%% set global options

timing = tic;

% addpath(pwd);
plotx2east;
html_path = fullfile(mtex_path,'help','html');

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

generateversionnumber;

%maintain style-sheet
copyfile( fullfile(mtex_path,'help','make_help','*.css') , ...
  fullfile(mtex_path,'help','html') );


%% generate TOCs

if nargin > 0 && ~check_option(varargin,{'clear','notoc'})
  make_toc(varargin{:});
end

%% generate general help files

% if check_option(varargin, {'general','all'})
  locations = {...
    {{'help' 'general' '*.gif'},    {'help' 'html'}},...    
    {{'help' 'general' '*.html'},    {'help' 'html'}},...
    {{'help' 'general' '*.js'},    {'help' 'html'}},...
    {{'README'},                  {'help' 'html' 'README.txt'}},...
    {{'COPYING'},                 {'help' 'html' 'COPYING.txt'}},...
    {{'VERSION'},                 {'help' 'html' 'VERSION.txt'}}};
  
  copyfiles = @(a,b) copyfile( fullfile(mtex_path,a{:}) , fullfile(mtex_path,b{:}) );
  
  cellfun(@(pos) copyfiles(pos{1},pos{2}), locations);
% end


%% generate classes index files

if check_option(varargin, {'classes','all'})
   
  current_path = fullfile(mtex_path, 'help','classes');

  folders = {...
    {'qta' '@ODF'},{'qta' '@PoleFigure'},{'qta' '@EBSD'},{'qta' '@kernel'},{'qta' '@grain'},...
    {'qta' 'standardODFs'},...
    {'geometry' '@vector3d'},{'geometry' '@quaternion'},{'geometry' '@Miller'},...
    {'geometry' '@symmetry'},{'geometry' '@S1Grid'},{'geometry' '@S2Grid'},...
    {'geometry' '@rotation'},{'geometry' '@orientation'},...
    {'geometry' '@polygon'},...
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
    'evalcode',true,'stylesheet',fullfile(mtex_path,'help','make_help','publishmtex.xsl'),varargin{:});
  delete(fullfile(current_path, 'script_*.m'));
end

%% generate help script files for all m files

if check_option(varargin, {'mfiles','all'})

  folders = {'qta','geometry','plot','tools','statistic'};

  for i=1:length(folders)
    apply_recursivly(fullfile(mtex_path,folders{i}),...
      @(file) generate_script(file,html_path,varargin{:}),'*.m');  
  end

 % publish all script_files in help/classes directory
 files = dir(fullfile(html_path, 'script_*.m'));
 if ~isempty(files)
   publish_files({files.name},html_path,'out_dir',html_path,...
     'stylesheet',fullfile(mtex_path,'help','make_help','publishmtex.xsl'),'evalcode',false,'waitbar',varargin{:});
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
 
  
  copyfile( fullfile(mtex_path,'help','make_help','*.css') , ...
    fullfile(mtex_path,'examples','html') );

  current_path = fullfile(mtex_path,'examples');
  files = dir(fullfile(current_path ,'*.m'));
  publish_files({files.name},current_path,'stylesheet',fullfile(mtex_path,'help','make_help', 'example_style.xsl'),...
    'out_dir',fullfile(current_path, 'html'),'evalcode',true,varargin{:});
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

system(['jar -cf ' fullfile(mtex_path,'help','mtex','help.jar') ' -C ' fullfile(mtex_path,'help','html') ' .']);

builddocsearchdb(fullfile(mtex_path ,'help','html'));
helpsearchpath = fullfile(mtex_path, 'help','html','helpsearch');
if exist(helpsearchpath,'dir'),
  e = rmdir(fullfile(mtex_path, 'help','mtex','helpsearch'),'s');
  movefile(helpsearchpath, fullfile(mtex_path, 'help','mtex'),'f');
end



function o = is_newer(f1,f2)

d1 = dir(f1);
d2 = dir(f2);
o = ~isempty(d1) && ~isempty(d2) && d1.datenum > d2.datenum;
