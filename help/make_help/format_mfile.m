function format_mfile(file,keywords)
% format comments in mfile to standard style

% read source.
code = file2cell(file);

code = strrep(code,'usage','Syntax');
code = strrep(code,'Usage','Syntax');
code = strrep(code,'USAGE','Syntax');

for k = 1:length(keywords)
  % format keywords
  code = regexprep(code,['\s*%%?\s*',keywords{k},':?'],...
    ['%% ',keywords{k}],'ignorecase');
  % insert new line after each keyword followed by a word
  code = regexprep(code,['(?<=(%% ',keywords{k},'))\s(?=(\s*\S))'],'\n% ');
end

% make all lines beginning at least in the third column
code = regexprep(code,' *%\s\s\s*','%  ');

% write source
cell2file(file,code);
