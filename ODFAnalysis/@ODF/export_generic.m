function export_generic(odf,filename,varargin)
% export an ODF to an ASCII file
%
% Syntax
%   export(odf,'file.txt',S3G)
%   export(odf,'file.txt',regular,'resolution',2.5*degree)
%   export(odf,'file.txt',regular,'resolution',2.5*degree)
%
% Input
%  odf      - ODF to be exported
%  filename - name of the ascii file
%
% Options
%  weights   - export weights of the ODF components
%  ZYZ, ABG  - Matthies (alpha, beta, gamma) convention (default)
%  ZXZ,BUNGE - Bunge (phi1,Phi,phi2) convention 
%
% See also
% ODFImportExport
  

% open the file
if nargin == 1, filename = uigetfile;end
fid = fopen(filename,'w');

% write intro
fprintf(fid,'%% MTEX ODF\n');

% symmetries
CS = odf.CS; SS = odf.SS;
fprintf(fid,'%% crystal symmetry: %s\n',char(CS));
fprintf(fid,'%% specimen symmetry: %s\n',char(SS));

% get SO3Grid
if any(cellfun(@(x) isa(x,'SO3Grid'),varargin))
  S3G = getClass(varargin,'SO3Grid');
  d = Euler(S3G,varargin{:});
else
  [S3G,~,~,d] = regularSO3Grid(CS,SS,varargin{:});
end

% evaluate ODF
v = eval(odf,S3G,varargin{:});

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
