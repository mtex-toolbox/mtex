function export_generic(SO3F,filename,varargin)
% export an SO3F to an ASCII file
%
% Syntax
%   export(SO3F,'file.txt',S3G)
%   export(SO3F,'file.txt',regular,'resolution',2.5*degree)
%   export(SO3F,'file.txt',regular,'resolution',2.5*degree)
%
% Input
%  SO3F     - @SO3Fun to be exported
%  filename - name of the ascii file
%
% Options
%  weights   - export weights of the ODF components
%  ZYZ, ABG  - Matthies (alpha, beta, gamma) convention (default)
%  ZXZ,BUNGE - Bunge (phi1,Phi,phi2) convention 
%
% See also
% ODFImport ODFExport
  

% open the file
if nargin == 1, filename = uigetfile;end
fid = fopen(filename,'w');

% write intro
fprintf(fid,'%% MTEX ODF\n');

% symmetries
CS = SO3F.CS; SS = SO3F.SS;
fprintf(fid,'%% crystal symmetry: %s\n',char(CS));
fprintf(fid,'%% specimen symmetry: %s\n',char(SS));

% get SO3Grid
if any(cellfun(@(x) isa(x,'SO3Grid'),varargin))
  S3G = getClass(varargin,'SO3Grid');
  S3G = orientation(S3G);
  d = Euler(S3G,varargin{:});
else
  [S3G,~,~,d] = regularSO3Grid(CS,SS,varargin{:});
end

% evaluate ODF
v = eval(SO3F,S3G,varargin{:});

% build up matrix to be exported
d = mod(d,2*pi);
if ~check_option(varargin,'radians'), d = d./degree;end

% convention
if check_option(varargin,{'Bunge','ZXZ'})
  convention = 'ZXZ';
elseif check_option(varargin,{'ABG','ZYZ'})
  convention = 'ZYZ';
else
  convention = 'ZXZ';
end

% save matrix
if strcmp(convention,'ZXZ')
  fprintf(fid,'%% phi1    Phi     phi2    value\n');
else
  fprintf(fid,'%% alpha   beta    gamma   value\n');
end

fprintf(fid,'%3.5f %3.5f %3.5f %3.5f\n',[d,v(:)].');

fclose(fid);
