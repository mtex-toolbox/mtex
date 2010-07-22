function pf = loadPoleFigure_slc(fname,varargin)
% load *.txt file with regular grid
%
%% Input
% fname - file name
%
%% Output
% pf    - @PoleFigure
%
%% See also
% ImportPoleFigureData loadPoleFigure

% ensure right extension
try
  [fdir,fn,ext] = fileparts(fname); %#ok<ASGLU>
  assert(any(strcmpi(ext,{'.slc'})));
catch %#ok<CTCH>
  error('Format slc does not match file %s',fname);
end

try
  
  %read data
  [A,ffn,nh,SR,hl,fpos] = txt2mat(fname,'InfoLevel',0,...
    'ReplaceRegExpr',{{'FRAME0.',''}});
  
  % set up specimen directions
  rho = A(:,1)*10*degree;  
  theta = linspace(90*degree,-90*degree,size(A,2)-1);
  r = S2Grid('theta',theta,'rho',rho,'antipodal');
  
  A = A(:,2:end);
   
  h = string2Miller(fname);    
  c = ones(1,length(h));
  
  
  pf = PoleFigure(h,r,A,symmetry('cubic'),symmetry,'superposition',c,varargin{:}); 
catch
  error('format slc does not match file %s',fname);
end
