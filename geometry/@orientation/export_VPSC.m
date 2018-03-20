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
% See also
% quaternion/export ODF/export_VPSC
  
% allocate memory
d = zeros(length(ori),4);

% add Euler angles
d(:,1:3) = ori.Euler(varargin{:});
if ~check_option(varargin,{'radians','radiant','radiand'})
  d = d ./ degree;
end

w = get_option(varargin,'weights',ones(size(ori)));

% add weight
d(:,4) = w./ sum(w);

fid = efopen(filename,'w');

% header
% fourth line has to include the angle convention (B for Bunge)
% and the total number of grains in the phase
fprintf(fid,'\n\n\nB %d\n',length(ori));

fprintf(fid,'%7.2f %7.2f %7.2f %11.7f\n',d');

fclose(fid);
