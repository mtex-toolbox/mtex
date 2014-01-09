function pf = loadPoleFigure_slc(fname,varargin)
% load *.txt file with regular grid
%
% Input
% fname - file name
%
% Output
% pf    - @PoleFigure
%
% See also
% ImportPoleFigureData loadPoleFigure

% ensure right extension

assertExtension(fname,'.slc');

try
  
  %read data
  [A,ffn,nh,SR,hl,fpos] = txt2mat(fname,'InfoLevel',0,...
    'ReplaceRegExpr',{{'FRAME0.',''}});
  
  % set up specimen directions
  rho = A(:,1)*10*degree;
  theta = linspace(90*degree,-90*degree,size(A,2)-1);
  
  r = regularS2Grid('theta',theta,'rho',rho,'antipodal');
  
  A = A(:,2:end);
  
  h = string2Miller(fname);
  
  pf = PoleFigure(h,r,A,varargin{:});
catch
  interfaceError(fname);
end
