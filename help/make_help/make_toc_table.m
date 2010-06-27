function table = make_toc_table(folder,varargin)

if nargin < 1
  toc = {};
	folder = fullfile(mtex_path,'help','UsersGuide');
end

table = {'<table class="refsub" width="90%">'};

if isdir(folder)
  str = file2cell(fullfile(folder,'toc'));
  for subtoc=regexp(str,'\s','split')
    subtoc = subtoc{1}{1};
    
    if exist([subtoc '.m']),
      addfile = [subtoc '.m'];
    else
      addfile = [subtoc '.html'];
    end
    
    [i i ext] = fileparts(addfile);
    if strcmpi(ext,'.m')
      fid = fopen(addfile);  
      mst = m2struct(char(fread(fid))');
      fclose(fid);
      table = [table addItem(mst(1).title,subtoc,mst(1).text)];
    else
      table = [table addItem(subtoc,subtoc,'')];
    end
  end
end

table{end+1} = '</table>';


function item = addItem(title,ref,text)


% 
if ~isempty(text)
text = strcat(text{:});
end

item = strcat(' <tr><td width="250px"  valign="top"><a href="', ref,  '.html">' ,title, ...
                           '</a></td><td valign="top">',text , '</td></tr>');

