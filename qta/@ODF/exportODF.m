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
  

%% open the file
if nargin == 1, filename = uigetfile;end
fid = fopen(filename,'w');

%% write intro
fprintf(fid,'%% MTEX ODF\n');
fprintf(fid,'%% %s\n',get(odf,'comment'));

% symmetries
CS = odf(1).CS; SS = odf(1).SS;
fprintf(fid,'%% crystal symmetry: %s\n',char(CS));
fprintf(fid,'%% specimen symmetry: %s\n',char(SS));

%% export as generic text file
if check_option(varargin,'generic')

  % get SO3Grid
  if nargin > 2 && isa(varargin{1},'SO3Grid')
    S3G = varargin{1};
    varargin = varargin(2:end);
  else
    S3G = SO3Grid('regular',CS,SS,varargin{:});
  end

  % evaluate ODF
  v = eval(odf,S3G,varargin{:}); %#ok<EVLC>

  % build up matrix to be exported
  d = Euler(S3G,varargin{:});
  if ~check_option(varargin,'radians'), d = d./degree;end

  % convention
  if check_option(varargin,{'Bunge','ZXZ'})
    convention = 'ZXZ';
  elseif check_option(varargin,{'ABG','ZYZ'})
    convention = 'ZYZ';
  else
    convention = get_flag(get(S3G,'options'),{'ZXZ','ZYZ'},'none');
  end

  % save matrix
  if strcmp(convention,'ZXZ')
    fprintf(fid,'%% phi1    Phi     phi2    volume\n');
  else
    fprintf(fid,'%% alpha   beta    gamma   volume\n');
  end

  fprintf(fid,'%3.5f %3.5f %3.5f %3.5f\n',[d,v(:)].');

%% save as MTEX format
else
  for i = 1:length(odf)
    
    if check_option(odf(i),'UNIFORM') % uniform portion
      
      fprintf(fid,'%%\n%%%% uniform component\n');
      fprintf(fid,'%% weight: %3.5f\n',odf(i).c);
      
    elseif check_option(varargin,'FOURIER') || check_option(odf(i),'FOURIER')
      
      fprintf(fid,'%%\n%%%% fourier component: currently not supported! \n');
  
    elseif check_option(odf(i),'FIBRE') % fibre symmetric portion
      
      fprintf(fid,'%%\n%%%% fibre component\n');
      fprintf(fid,'%% weight: %3.5f\n',odf(i).c);
      fprintf(fid,'%% kernel: %s\n',char(odf(i).psi));
      fprintf(fid,'%% fibre h: %s\n',char(odf(i).center{1}));      
      fprintf(fid,'%% fibre r: %s\n',char(odf(i).center{2}));
      
    else % radially symmetric portion
  
      fprintf(fid,'%%\n%%%% radial component:\n');
      fprintf(fid,'%% kernel: %s\n',char(odf(i).psi));
      
      % build up matrix to be exported
      d = Euler(odf(i).center,varargin{:});
      if ~check_option(varargin,'radians'), d = d./degree;end

      % convention
      if check_option(varargin,{'Bunge','ZXZ'})
        convention = 'ZXZ';
      elseif check_option(varargin,{'ABG','ZYZ'})
        convention = 'ZYZ';
      else
        convention = get_flag(get(odf(i).center,'options'),{'ZXZ','ZYZ'},'none');
      end

      % save matrix      
      if strcmp(convention,'ZXZ')
        fprintf(fid,'%% phi1    Phi     phi2    weight\n');
      else
        fprintf(fid,'%% alpha   beta    gamma   weight\n');
      end
    
      fprintf(fid,'%3.5f %3.5f %3.5f %3.5f\n',[d,odf(i).c(:)].');
      
    end
  end
end


fclose(fid);

