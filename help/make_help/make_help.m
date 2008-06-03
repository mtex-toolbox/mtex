function make_help(varargin)
%
%
%

%% set global options

tic

global mtex_path;
html_path = [mtex_path '/help/html'];

global mtex_progress;
mtex_progress = 0;

set(0,'FormatSpacing','compact')

%% generate general help files

if check_option(varargin, {'general','all'})
  
  current_path = [mtex_path '/help/general'];
  files = dir([current_path '/*.m']);
  publish_files({files.name},current_path,'out_dir',html_path,varargin{:});
%  unix(['cp -f ' html_path '/mtex_top.html ' html_path '/help_product_page.html']);
end


%% generate classes index files

if check_option(varargin, {'classes','all'})
  
  current_path = [mtex_path '/help/classes'];

  folders = {'qta/@ODF','qta/@PoleFigure','qta/@EBSD','qta/@kernel',...
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
      @(file) generate_script(file,html_path),'*.m');
  
  end


 % publish all script_files in help/classes directory
 files = dir([html_path '/script_*.m']);
 publish_files({files.name},html_path,'out_dir',html_path,...
   'stylesheet',[pwd '/publishmtex.xsl'],varargin{:});
 delete([html_path '/script_*.m']);
 
end

%% calculate ODF files

if check_option(varargin, {'odf','all'})
  
  current_path = [mtex_path '/help/ODFCalculation'];
  files = dir([current_path '/*.m']);
  publish_files({files.name},current_path,'stylesheet',[pwd '/example_style.xsl'],...
    'out_dir',html_path,'evalcode',1);
end


%% calculate plotting files

if check_option(varargin, {'plotting','all'})
  
  current_path = [mtex_path '/help/plotting'];
  files = dir([current_path '/*.m']);
  publish_files({files.name},current_path,'stylesheet',[pwd '/example_style.xsl'],...
    'out_dir',html_path,'evalcode',1);
end


%% calculate examples

if check_option(varargin, {'examples','all'})
  
  current_path = [mtex_path '/examples'];
  files = dir([current_path '/*.m']);
  publish_files({files.name},current_path,'stylesheet',[pwd '/example_style.xsl'],...
    'out_dir',[current_path '/html'],'evalcode',1);
  copyfile([current_path '/html/*.html'],html_path);
  copyfile([current_path '/html/*.png'],html_path);
end

%% calculate interfaces

if check_option(varargin, {'interfaces','all'})

  current_path = [mtex_path filesep 'help' filesep 'interfaces'];
  files = dir([current_path filesep '*.m']);
  publish_files({files.name},current_path,'out_dir',html_path,...
    'evalcode',1,'stylesheet',[pwd '/example_style.xsl'],varargin{:});

end

toc

%% create searchable database
system('jar -cf ../mtex/help.jar -C ../html/ .');
cd([mtex_path '/help/html']);
builddocsearchdb('.');
global mtex_startup_dir;
unix(['rm -rf ' mtex_path '/help/mtex/helpsearch']);
unix(['mv -f ' mtex_startup_dir,'/helpsearch ' mtex_path '/help/mtex/']);
cd([mtex_path '/help/make_help']);
