function deadlink(varargin)

html_path = fullfile(mtex_path,'help','html');
files = dir(fullfile(html_path,'*.html'));
html_page = {files.name};

ug_files = get_ug_files(fullfile(mtex_path,'help'));

for page=html_page
  html_file = fullfile(html_path,  page{:});
  link = regexp(file2cell(html_file),'(href=")(?<href>\S*?)(.html")','names');
  for line = find(~cellfun('isempty',link))
    for href = {link{line}.href}
      if ~any(~cellfun('isempty',strfind(html_page, href{1})))    
        p = regexprep(page{:},'.html','');
        if ~exist(p,'file')
          ug = get_ug_filebytopic(ug_files,'test');
          if ~isempty(ug)
            p = ug;
          else
            p = regexprep(p,'_','/');
          end
        end
        
        if isempty(href{1})
           s = ['EMPTY LINK -> <a href="' html_file '">' page{:}  ...
             '</a> -> (<a href="matlab:edit ' p '">' p '.m</a>)' ];
        else        
          s = ['<a href="' html_file '">' page{:}  '</a> -> (<a href="matlab:edit ' p '">' p '.m</a>)' ...
            ' -> link: '  href{1} ];
        end
        disp(s)
      end
    end
  end
end

