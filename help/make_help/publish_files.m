function publish_files(files,in_dir,varargin)
% format html file, i.e. add links ...

% set publishing options
poptions.format = 'html';
poptions.useNewFigure = false;
if ~newer_version(7.6), poptions.stopOnError = false;end
poptions.stylesheet = get_option(varargin,'Stylesheet','');
poptions.evalCode = check_option(varargin,'evalCode');
poptions.outputDir = get_option(varargin,'out_dir','.');

global mtex_progress;


%% convert to html

old_dir = pwd;cd(in_dir);

if check_option(varargin,'waitbar') && ~check_option(varargin,'deadlinks')
  mtex_progress = 1;
  progress(0,length(files),'publishing: ');
end

for i=1:length(files)

  out_file = fullfile(poptions.outputDir,strrep(files{i},'.m','.html'));
  % check wether publishing is needed
  if is_newer(strrep(out_file,'script_',''),files{i}) && ...
      ~check_option(varargin,'force')
    continue;
  end
  
  if check_option(varargin,'waitbar') && ~check_option(varargin,'deadlinks')
    mtex_progress = 1;
    progress(i,length(files),'publishing: ');
    mtex_progress = 0;
  end
  
  close all
  if poptions.evalCode || check_option(varargin,'verbose'),disp(files{i});end

  % publish
  publish(files{i},poptions);

  
  % format html file  
  code = file2cell(out_file);
  delete(out_file);

  % make links
  code = regexprep(code, '\<([[)(.*?),(.*?)(\]\])\>','<a href="$2">$3</a>');
  
  % remove output "calculate: [......]"
  code(strmatch('calculate: [',code)) = [];
  code = regexprep(code, 'calculate: [.*','');
  % insert true file name of mfile
  code = regexprep(code, 'XXXX',strrep(files{i},'.m',''));

  
  % check for dead links
  if check_option(varargin,'deadlinks')
    links = regexp(code, '\<(?:href=")(\S*?.html)(?:")\>','tokens');
    links = links(~cellfun('isempty',links));
    for j = 1:length(links)
      if ~exist(fullfile(poptions.outputDir,char(links{j}{1})),'file')
        if strmatch('script',files{i})
          ss = strrep(files{i},'script_','');
          ss = strrep(ss,'_','/');
          ss2 = ss;
        else
          ss2 = files{i};
          ss = [in_dir,'/',files{i}];
        end
        
        s = ['Dead link ',char(links{j}{1}),' in file <a href="matlab: edit ',...
          ss,'">',ss2,'</a> '];
        disp(s);
      end
    end
  end
  
  % save  html file
  cell2file(strrep(out_file,'script_',''),code);

end

cd(old_dir);
%if get_option(varargin,'waitbar'),close(h);end

function o = is_newer(f1,f2)

d1 = dir(f1);
d2 = dir(f2);
o = ~isempty(d1) && ~isempty(d2) && d1.datenum > d2.datenum;
