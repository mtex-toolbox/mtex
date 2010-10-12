function generate_script(mfile, out_dir,varargin) 
% convert comments of mfile to a a publish ready script
%
%% input
% mfile  - file to be published
% outdir - destination directory

%% Parse m-file

% class name

[path, file_name, ext] = fileparts(mfile); %#ok<NASGU,NASGU>
class_name = char(regexp(path,'(?<=@)\w*','match'));

% check whether update is needed
if isempty(class_name)
  html_name = fullfile(out_dir,[file_name '.html']);
else
  html_name = fullfile(out_dir,[class_name '_' file_name '.html']);
end
if (is_newer(html_name,mfile) && ...
    ~check_option(varargin,'force')) || strcmp(file_name,'Content')
  return;
end


% preformat mfile
%keywords = {'Syntax', 'Description','Input', 'Output', 'Options',...
%  'Flags', 'See also','Example'};
%format_mfile(mfile,keywords);

% Read in source.

code = file2cell(mfile);

% extract syntax
syntax = strtrim(code{1}(10:end));

% extract first commentline
comment = regexprep(code{2},'\s*%%?\s*','% ');

% restrict code to the first comment block
last_comment = find(~strncmp('%',code(3:end),1),1,'first');
code = code(3:last_comment+1);

% where are the keywords?
keywords_pos = strmatch('%%',code);
first_item = min(keywords_pos);

% markup class links beginning with @
code = regexprep(code,'([^/])@(\w*)','$1[[$2_index.html,$2]]');

% markup Syntax
for l = getrange('%% Syntax',code,keywords_pos)
  code{l} = regexprep(code{l},'^% ?','');
end

% markup Example
for l = getrange('%% Example',code,keywords_pos)
  code{l} = regexprep(code{l},'^% ?','');
end

% markup See also links
% for l = getrange('%% See also',code,keywords_pos)
%   code{l} = regexprep(code{l},...
%     '([^\s/%]*)(/?)\<([^\s%]\w*)\>','[[$1_$3.html,$1$2$3]]');
%   code{l} = regexprep(code{l},...
%     '([[)_','$1');
% end


%% create script_file

% create dir to publish into
if ~exist(out_dir,'dir'), mkdir(out_dir);end
if out_dir(end) ~= filesep, out_dir(end+1) = filesep;end

% create file & write function name
if isempty(class_name)
  script = fopen([out_dir 'script_' file_name '.m'],'w');
  write_cell(script,{['%% ' file_name]});
else
  script = fopen([out_dir 'script_' class_name '_' file_name '.m'],'w');
  %write_cell(script,{['%% [[' class_name '_index.html,@' class_name ']]/' file_name]});
  write_cell(script,{['%% ' file_name ' (class [['...
    class_name '_index.html,' class_name ']])']});
end

% write first commentline
write_cell(script,{comment});

% if no seperate syntax item exists
if isempty(strmatch('%% Syntax',code)) 
  % write default syntax
  write_cell(script,{'%% Syntax',syntax}); 
end

% if no seperate description item exists and
% if there is any word before the first item
if isempty(strmatch('%% Description',code)) && ...
    ~isempty_cell(regexpi(code(1:first_item-1),'\w'))
  
  % take all up to the first itemas description
  write_cell(script,['%% Description',code(1:first_item-1)]);
  
end

% write remaining comments
write_cell(script,code(first_item:end));

write_cell(script,{' ','%% View Code',['% ' class_name '/' file_name ]});


fclose(script);

% return specific part defines by keyword
function range = getrange(keyword,code,keywords_pos)

rstart = min([strmatch(keyword,code);length(code)]);
rend = min([keywords_pos(keywords_pos>rstart)-1;length(code)]);
range = rstart+1:rend;

function o = is_newer(f1,f2)

d1 = dir(f1);
d2 = dir(f2);
o = ~isempty(d1) && ~isempty(d2) && d1.datenum > d2.datenum;
