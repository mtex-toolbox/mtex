function export_VPSC(ori,filename,varargin)
% export individual orientations to the VPSC format
%
% Syntax
%   export_VPSC(ori,'file.txt')
%   export_VPSC(ori,'file.txt','weights',weights)
%
% Input
%  ori      - individual @orientation to be exported
%  filename - name of the ascii file
%  weights  - list weights with the same size as the orientations
%
% Flags
%  Bunge, Kocks, Roe - Euler angle convention, Bunge by default
%
% See also
% quaternion/export SO3Fun/export_VPSC interfaces/loadODF_VPSC

% VPSC knows three Euler angle conventions and names the one in use on the
% fourth header line. Default to Bunge rather than to the MTEX preference:
% the preference may be a convention VPSC cannot express at all, and a file
% whose header says B while the columns hold something else is worse than no
% file - see issue #297
% note that get_flag keeps the *last* match, so the default goes first
convention = EulerAngleConvention('Bunge',varargin{:});
switch lower(convention)
  case {'bunge','zxz'}, letter = 'B';
  case 'kocks', letter = 'K';
  case 'roe', letter = 'R';
  otherwise
    error('MTEX:export_VPSC',['VPSC stores Euler angles in the Bunge, the ' ...
      'Kocks or the Roe convention. %s is none of them.'],convention);
end

% allocate memory
d = zeros(length(ori),4);

% add Euler angles
d(:,1:3) = ori.Euler(varargin{:},convention);
if ~check_option(varargin,{'radians','radiant','radiand'})
  d = d ./ degree;
end

w = get_option(varargin,'weights',ones(size(ori)));

% add weight
d(:,4) = w./ sum(w);

fid = efopen(filename,'w');

% header
% VPSC prescribes four header lines. The first three are free format - a
% VPSC output file carries the strain and the phase ellipsoid there, an
% exported texture has neither - while the fourth has to name the angle
% convention and the total number of grains in the phase
fprintf(fid,'texture exported by MTEX\n\n\n%s %d\n',letter,length(ori));

fprintf(fid,'%7.2f %7.2f %7.2f %11.7f\n',d');

fclose(fid);
