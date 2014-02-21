function export_mtex(odf,filename,varargin)
% export an ODF into the MTEX format
%
% Syntax
%   export(odf,'filename')
%
% Input
%  odf      - ODF to be exported
%  filename - name of the ascii file
%
% Options
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
fprintf(fid,'%% crystal symmetry: %s\n',char(odf.CS));
fprintf(fid,'%% specimen symmetry: %s\n',char(odf.SS));

% loop over all components
% TODO
for i = 1:length(odf.components)

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
    elseif isa(odf(i).center,'SO3Grid')
      convention = get_flag(get(odf(i).center,'options'),{'ZXZ','ZYZ'},'none');
    else
      convention = getMTEXpref('EulerAngleConvention');
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



fclose(fid);
