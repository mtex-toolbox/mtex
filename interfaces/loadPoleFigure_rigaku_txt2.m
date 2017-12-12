function pf = loadPoleFigure_rigaku_txt2(fname,varargin)
% import data fom ana file
%
% Syntax
%   pf = loadPoleFigure_rigaku_txt2(fname)
%
% Input
%  fname  - filename
%
% Output
%  pf - @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

try 
 
  [data,~,~,~,header] = txt2mat(fname,'infoLevel',0);
  
  rho = data(:,1);
  step = rho(2)-rho(1);
  header = strsplit(header,'\n');
  id = find(~cellfun(@isempty,strfind(header,'Step')),1);
  step2 = cell2mat(textscan(header{id},'Step %d'));
  assert(step2(1) == step);
  
  data(:,1:2:end) = [];
  theta = ((size(data,2)-2):-1:0)*step;
  
  r = regularS2Grid('theta',theta*degree,'rho',rho*degree);
  
  assert(size(data,1)>5 && size(data,2)>5);
  
  pf = PoleFigure(string2Miller(fname),r,data(:,2:end),varargin{:});
  
catch
  interfaceError(fname);
end

end

