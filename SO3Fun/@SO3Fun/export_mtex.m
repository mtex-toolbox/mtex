function export_mtex(SO3F,filename,varargin)
% export an SO3Fun into the MTEX format
%
% Syntax
%   export(SO3F,'filename')
%
% Input
%  SO3F     - @SO3Fun to be exported
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
fprintf(fid,'%% crystal symmetry: %s\n',char(SO3F.CS));
fprintf(fid,'%% specimen symmetry: %s\n',char(SO3F.SS));

% loop over all components
SO3F = SO3FunComposition(SO3F);
% TODO
for i = 1:length(SO3F.components)

  if isa(SO3F.components{i},'SO3FunRBF') && SO3F.components{i}.c0~=0 % uniform portion

    fprintf(fid,'%%\n%%%% uniform component\n');
    fprintf(fid,'%% weight: %3.5f\n',SO3F.weights(i));

  elseif isa(SO3F.components{i},'SO3FunHarmonic')

    fprintf(fid,'%%\n%%%% harmonic component: currently not supported! \n');

  elseif isa(SO3F.components{i},'SO3FunCBF') % fibre symmetric portion
    
    fprintf(fid,'%%\n%%%% fibre component\n');
    fprintf(fid,'%% weight: %3.5f\n',SO3F.weights(i));
    fprintf(fid,'%% kernel: %s\n',char(SO3F.components{i}.psi));
    fprintf(fid,'%% fibre h: %s\n',char(SO3F.components{i}.h));
    fprintf(fid,'%% fibre r: %s\n',char(SO3F.components{i}.r));

  else % radially symmetric portion

    fprintf(fid,'%%\n%%%% radial component:\n');
    fprintf(fid,'%% kernel: %s\n',char(SO3F.components{i}.psi));

    % build up matrix to be exported
    d = Euler(SO3F.components{i}.center,varargin{:});
    if ~check_option(varargin,'radians'), d = d./degree;end

    % convention
    if check_option(varargin,{'Bunge','ZXZ'})
      convention = 'ZXZ';
    elseif check_option(varargin,{'ABG','ZYZ'})
      convention = 'ZYZ';
    elseif isa(SO3F.components{i}.center,'SO3Grid')
      convention = get_flag(get(SO3F.components{i}.center,'options'),{'ZXZ','ZYZ'},'none');
    else
      convention = getMTEXpref('EulerAngleConvention');
    end

    % save matrix
    if strcmp(convention,'ZXZ')
      fprintf(fid,'%% phi1    Phi     phi2    weight\n');
    else
      fprintf(fid,'%% alpha   beta    gamma   weight\n');
    end

    fprintf(fid,'%3.5f %3.5f %3.5f %3.5f\n',[d,SO3F.components{i}.weights].');

  end
end



fclose(fid);
