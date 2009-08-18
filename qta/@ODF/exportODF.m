function exportODF(odf,filename,varargin)
% export an ODF to an ASCII file
%
%% Syntax
% exportODF(odf,'file.txt',S3G)
% exportODF(odf,'file.txt',regular,'resolution',2.5*degree)
% exportODF(odf,'file.txt',regular,'resolution',2.5*degree)
%
%% Input
%  odf      - ODF to be exported
%  filename - name of the ascii file
%
%% Options
%  weights   - export weights of the ODF components
%  ZYZ, ABG  - Matthies (alpha, beta, gamma) convention (default)
%  ZXZ,BUNGE - Bunge (phi1,Phi,phi2) convention 
%
%% See also
%
  
%% define the orientations where the ODF should be evaluated

% symmetries
[CS,SS] = getSym(odf);

% SO3Grid
if check_option(varargin,'weights')
  S3G = getgrid(odf);
elseif nargin > 2 && isa(varargin{1},'SO3Grid')
  S3G = varargin{1};
  varargin = varargin(2:end);
else
  S3G = SO3Grid('regular',CS,SS,varargin{:});
end

%% evaluate ODF

if check_option(varargin,'weights')
  v = getdata(odf);
else
  v = eval(odf,S3G,varargin{:}); %#ok<EVLC>
end


%% build up matrix to be exported

d = Euler(S3G,varargin{:});
if ~check_option(varargin,'radians'), d = d./degree;end

%% convention
if check_option(varargin,{'Bunge','ZXZ'})
  convention = 'ZXZ';
elseif check_option(varargin,{'ABG','ZYZ'})
  convention = 'ZYZ';
else
  convention = get_flag(get(S3G,'options'),{'ZXZ','ZYZ'},'none');
end

%% save matrix

fid = fopen(filename,'w');

if strcmp(convention,'ZXZ')
  fprintf(fid,'phi1    Phi     phi2    volume\n');
else
  fprintf(fid,'alpha   beta    gamma   volume\n');
end

fprintf(fid,'%3.5f %3.5f %3.5f %3.5f\n',[d,v(:)].');
fclose(fid);

