function  display(ebsd,varargin)
% standard output

disp(' ');
h = doclink('EBSD_index','EBSD');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;
if numel(ebsd)>0 && ~isempty(ebsd(1).comment)
  h = [h, ' (' ebsd(1).comment ')'];
end  
disp(h);



if numel(ebsd)>0 && ~isempty(fields(ebsd(1).options))
  disp(['  properties: ',option2str(fields(ebsd(1).options))]);
end

for i = 1:numel(ebsd)
  disp(['  ' char(ebsd(i))]);
end
disp(' ');
