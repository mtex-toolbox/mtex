function make_help(varargin)
%
%
%

%% set global options

tic

html_path = [mtex_path '/help/html'];

global mtex_progress;
mtex_progress = 0;

if check_option(varargin,'clear')
  delete([html_path,'/*.*']);
  delete([mtex_path,'examples/html/*.*']);
end

set_mtex_option('generate_help',true);
set(0,'FormatSpacing','compact')

%% generate general help files

if check_option(varargin, {'general','all'})
  
  % copy html files
  copyfile([mtex_path,'/help/general/*.html'],[mtex_path,'/help/html'])
  copyfile([mtex_path,'/help/general/*.gif'],[mtex_path,'/help/html'])
  copyfile([mtex_path,'/README'],[mtex_path,'/help/html/README.txt']);
  copyfile([mtex_path,'/COPYING'],[mtex_path,'/help/html/COPYING.txt']);
  copyfile([mtex_path,'/VERSION'],[mtex_path,'/help/html/VERSION.txt']);
  
  current_path = [mtex_path '/help/general'];
  files = dir([current_path '/*.m']);
  publish_files({files.name},current_path,'out_dir',html_path,varargin{:});
end


%% generate classes index files

if check_option(varargin, {'classes','all'})
  
  current_path = [mtex_path '/help/classes'];

  folders = {'qta/@ODF','qta/@PoleFigure','qta/@EBSD','qta/@kernel','qta/@grain'...
    'qta/standardODFs','qta/interfaces','qta/interfacesEBSD',...
    'geometry/@vector3d','geometry/@quaternion','geometry/@Miller',...
    'geometry/@symmetry','geometry/@S1Grid','geometry/@S2Grid',...
    'geometry/@SO3Grid','geometry/geometry_tools',...
    'tools','tools/dubna_tools','tools/statistic_tools',...
    'tools/plot_tools'};

  for i = 1:length(folders)
  
    % name of the index files
    folder = char(regexp(folders{i},'(\w*)$','match'));
    in_file =  [current_path '/' folder ,'_index.m'];
    script_file = [current_path '/script_' folder ,'_index.m'];
    html_file =  [html_path '/' folder ,'_index.html'];
  
    if is_newer(html_file,in_file) && ~check_option(varargin,'force')
      continue;
    end
    
    % make index mfile
    disp(in_file)
    copyfile(in_file,script_file);
    make_index([mtex_path filesep folders{i}],script_file);

  end

  files = dir([current_path '/script_*.m']);
  publish_files({files.name},current_path,'out_dir',html_path,...
    'evalcode',1,'stylesheet',[pwd '/publishmtex.xsl'],varargin{:});
  delete([current_path '/script_*.m']);
end

%% generate help script files for all m files

if check_option(varargin, {'mfiles','all'})

  folders = {'qta','geometry','plot','tools','statistic'};

  for i=1:length(folders)
    
    apply_recursivly([mtex_path filesep folders{i}],...
      @(file) generate_script(file,html_path,varargin{:}),'*.m');
  
  end

 % publish all script_files in help/classes directory
 files = dir([html_path '/script_*.m']);
 publish_files({files.name},html_path,'out_dir',html_path,...
   'stylesheet',[pwd '/publishmtex.xsl'],'waitbar',varargin{:});
 delete([html_path '/script_*.m']);
 
end

%% process special topics
topics = {'CrystalGeometry','PoleFigureAnalysis','EBSDAnalysis','ODFAnalysis','plotting','interfaces'};

for i = 1:length(topics)

  if check_option(varargin, {topics{i},'all','all-'})    
    current_path = [mtex_path '/help/' topics{i}];
    files = dir([current_path '/*.m']);
    publish_files({files.name},current_path,...
      'stylesheet',[pwd '/mtex_style.xsl'],'out_dir',html_path,'evalcode',1,varargin{:});    
    try
      copyfile([current_path,'/*.png'],[mtex_path,'/help/html'])
    catch %#ok<CTCH>
    end
  end
  
end


%% calculate examples

if check_option(varargin, {'examples'})
  
  current_path = [mtex_path '/examples'];
  files = dir([current_path '/*.m']);
  publish_files({files.name},current_path,'stylesheet',[pwd '/example_style.xsl'],...
    'out_dir',[current_path '/html'],'evalcode',1,varargin{:});
  copyfile([current_path '/html/*.html'],html_path);
  copyfile([current_path '/html/*.png'],html_path);
end

toc

%% create searchable database
system('jar -cf ../mtex/help.jar -C ../html/ .');
cd([mtex_path '/help/html']);
builddocsearchdb('.');
mtex_startup_dir = get_mtex_option('mtex_startup_dir');
unix(['rm -rf ' mtex_path '/help/mtex/helpsearch']);
unix(['mv -f ' mtex_startup_dir,'/helpsearch ' mtex_path '/help/mtex/']);
%unix(['mv -f  ~/helpsearch ' mtex_path '/help/mtex/']);
cd([mtex_path '/help/make_help']);

%% finisch
set_mtex_option('generate_help',false);

function o = is_newer(f1,f2)

d1 = dir(f1);
d2 = dir(f2);
o = ~isempty(d1) && ~isempty(d2) && d1.datenum > d2.datenum;
