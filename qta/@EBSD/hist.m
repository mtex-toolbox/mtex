function [h bins] = hist(ebsd,varargin)
% histogram plot of rotation angles of a fundamental region
%
%% Syntax
%  hist(ebsd)
%  hist(ebsd,q0)
%  [n bins]= hist(ebsd,20)
%
%% Input
%  ebsd     - @EBSD
%  q0       - reference @quaternion 
%
%% Output
%  n    -  count the number of values that fall into a bin
%  bins -  the bounds of each edge
%
%% Options
%  n/bins - define custom bins
%  
%% See also
% grain/misorientation


assert(sum(sampleSize(ebsd))>0,'No Data');


o0 = find_type(varargin,'quaternion');
if ~isempty(o0)
  o0 = quaternion(varargin{o0});
else
  o0 = idquaternion;
end


for k=1:numel(ebsd)
  
  omega{k} = angle( ebsd(k).orientations , o0 );
  
end


bins = find_type(varargin,'double');
if ~isempty(bins)
  bins = varargin{bins};
else
  bins = 20;
end

max_omega = max(cellfun(@max,omega));
min_omega = min(cellfun(@min,omega));
if length(bins) == 1  
  bins = linspace(min_omega,max_omega,bins);
end

nl = length(omega);
his = zeros(nl,numel(bins));

for k=1:nl
  his(k,:) = hist(omega{k},bins);
end

if nargout > 0
  h = his;
else
  his = his./repmat(sum(his,2),1,length(his));
  bar(bins./degree,his');
  axis tight
  xlabel('(mis-)orientation / degree')
  ylabel('relative frequency %')
end
