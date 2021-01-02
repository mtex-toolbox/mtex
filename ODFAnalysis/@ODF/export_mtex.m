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

  if isa(odf(i).components{1},'uniformComponent') % uniform portion

    fprintf(fid,'%%\n%%%% uniform component\n');
    fprintf(fid,'%% weight: %3.5f\n',odf(i).weights);

  elseif isa(odf(i).components{1},'FourierComponent')

    fprintf(fid,'%%\n%%%% fourier component: currently not supported! \n');

  elseif isa(odf(i).components{1},'fibreComponent') % fibre symmetric portion
    
    fprintf(fid,'%%\n%%%% fibre component\n');
    fprintf(fid,'%% weight: %3.5f\n',odf(i).weights);
    fprintf(fid,'%% kernel: %s\n',char(odf(i).components{1}.psi));
    fprintf(fid,'%% fibre h: %s\n',char(odf(i).components{1}.h));
    fprintf(fid,'%% fibre r: %s\n',char(odf(i).components{1}.r));

  else % radially symmetric portion

    fprintf(fid,'%%\n%%%% radial component:\n');
    fprintf(fid,'%% kernel: %s\n',char(odf(i).components{1}.psi));

    % build up matrix to be exported
    d = Euler(odf(i).components{1}.center,varargin{:});
    if ~check_option(varargin,'radians'), d = d./degree;end

    % convention
    if check_option(varargin,{'Bunge','ZXZ'})
      convention = 'ZXZ';
    elseif check_option(varargin,{'ABG','ZYZ'})
      convention = 'ZYZ';
    elseif isa(odf(i).center,'SO3Grid')
      convention = get_flag(get(odf(i).components{1}.center,'options'),{'ZXZ','ZYZ'},'none');
    else
      convention = getMTEXpref('EulerAngleConvention');
    end

    % save matrix
    if strcmp(convention,'ZXZ')
      fprintf(fid,'%% phi1    Phi     phi2    weight\n');
    else
      fprintf(fid,'%% alpha   beta    gamma   weight\n');
    end

    fprintf(fid,'%3.5f %3.5f %3.5f %3.5f\n',[d,odf(i).components{1}.weights].');

  end
end



fclose(fid);
