function mtex_templates(varargin)
% generate a template overview from svn 


if check_option(varargin,'online')
  template_url = 'http://mtex.googlecode.com/svn/trunk/templates/';
  varargin = set_option(varargin,'url',template_url);
end

create_template_page(varargin{:});



function create_template_page(varargin)

%dirty
run(fullfile(mtex_path,'help','make_help','make_mtex_version.m'));

types = {'EBSD','ODF','PoleFigure'};
pos = find_option(types,varargin);
if pos > 0,types = types(pos);  end

if check_option(varargin,'online')
  url = get_option(varargin,'url');
  page = urlread(url);
  template_files = regexp(page,'a href="(\w+).m"','match'); 
  src = file2cell(fullfile(mtex_path,'tools','template_wizard','howto_online.m'));
else
  turl = fullfile(mtex_path,'templates');
  template_files = dir(turl);
  template_files = {template_files.name};
  template_files(cellfun('isempty',strfind(template_files,'.m'))) = [];
  url = ['file:///' turl filesep];
  src = file2cell(fullfile(mtex_path,'tools','template_wizard','howto.m'));
end
  
mtex_tmppath = fullfile(mtex_path,'tools','template_wizard');

fname = fullfile(mtex_tmppath,'templates.m');
fname_web = fullfile(mtex_tmppath,'templates.html');


installlink = @(tname) ['''url'',''' url ''',''template'',''' tname ''''];


template_files = sort(template_files);


template_type = zeros(size(template_files));
for l=1:numel(types)
  tpyes = ~cellfun('isempty',strfind(template_files,types{l}));
  do_template_type = template_type | tpyes;
  template_type(tpyes) = l;
end
template_type_chpos = [logical(do_template_type(1)) diff(template_type)>0];
template_type = cumsum(template_type_chpos);

for k=find(do_template_type)
  
  if check_option(varargin,'url')
    files = regexp(template_files{k},'"(\w+).m"','tokens');
    template_files{k} = [files{1}{1},'.m'];  
  end
  
  s = set_option({},'template',template_files{k} );
  inst_link = ['<a href="matlab:install_template('  installlink(template_files{k}) ')"> ' template_files{k} '</a>'];
  uninst_link = ['<a href="matlab:uninstall_template('''  template_files{k} ''')">Uninstall</a>'];
  wbb = [url template_files{k}];
  
  %local
  %wbb = ['file:///' fullfile(mtex_path,'templates',template_files{k})];
  
  files = urlread(wbb);
  
  % make an entry
  [description title author]= parse_template_comment(files);
  
  if ~isempty(author)
    author = ['<td align="right">author: ' author '</td></tr>'];
  else
    author = '';
  end
  
  if template_type_chpos(k)
     src = [src,['%% ' types{template_type(k)} ' Templates'] ];
  end
  
  if check_option(varargin,'online')
    src = [src,...
            [ '%% '],...
            [ '% <html>' ...
              '<div class="descript">' ...
              '<h3 class="destitle">'  title  ' </h3>' ...
              '<p class="destitle">' template_files{k} '</p>'  ...
              '<table width="100%" class="desinst"><tr><td align="left">'  ...
              ' Install : ' inst_link '' ...
              ' (' uninst_link ') ' ...
              ' </td>' author '</table></div></html>' ],...
            '% ' , ...
            '%% ',...
            description, ...
          ];
  else
    
     open_link = ['<a href="matlab:edit('''  fullfile(turl, template_files{k}) ''')"> ' template_files{k} '</a>'];
       src = [src,...
          [ '%% '],...
          [ '% <html>' ...
            '<div class="descript">' ...
            '<h3 class="destitle">'  title  ' </h3>' ...
            '<p class="destitle">' template_files{k} '</p>'  ...
            '<table width="100%" class="desinst"><tr><td align="left">'  ...
              '' open_link '' ...
            ' </td>' author '</table></div></html>' ],...
          '% ' , ...
          '%% ',...
          description, ...
        ];
  end
  
end

cell2file(fname,src);
current_dir = cd;
cd(mtex_tmppath);

poptions.format = 'html';
poptions.useNewFigure = false;
if ~newer_version(7.6), poptions.stopOnError = false;end
poptions.stylesheet = fullfile(mtex_path,'help','make_help','publishmtex.xsl');
poptions.evalCode = check_option(varargin,'evalCode');
poptions.outputDir = get_option(varargin,'out_dir','.');

publish(fname,poptions);
delete(fname)
cd(current_dir);

eval(['web ' fname_web ' -helpbrowser'])


% delete(fullfile(mtex_tmppath,'style.css'))
% delete(fname_web)

function [description title author]= parse_template_comment(src)


author = regexp(src,'<author:(\w.+)>','match');
if ~isempty(author)
 author = author{1}(9:end-1);
 if strfind(author,'@')
  author = regexpsplit(author,' ');
  author = ['<a href="mailto:' author{1} '">' author{2:end} '</a>'];
 end
else
  author =  '';
end
src = regexpsplit(src,'<author:(\w.+)>');
src = [src{:}];

pos = regexpi(src,'%');
pp = find(diff(pos) == 1);

if numel(pos)>2
  pos1 = pos(3)-1;
else
  pos1 = numel(src);
end

if numel(pp)>1
  pos2 = pos(pp(2))-1;
else
  pos2 = numel(src);
end

title = src(1:pos1);
description = src(pos1+1:pos2);

title = regexprep(title,char(10),'');
title = regexprep(title,char(13),'');
title = regexprep(title,'%% ','');




