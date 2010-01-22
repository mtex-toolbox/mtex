function [h bins] = hist(ebsd,varargin)
% histogram plot of rotation angles of a fundamental region
%
%% Syntax
%  hist(ebsd)
%  hist(ebsd,q0)
%  [n bins]= hist(ebsd,...)
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
%  Edges - define custom bins
%  
%% See also
% grain/misorientation

assert(sum(sampleSize(ebsd))>0,'No Data');

if nargin > 1 && isa(varargin{1},'quaternion')
  q0 = varargin{1};
else
  q0 = idquaternion;
end
  
nl = length(ebsd);
omega = cell(size(ebsd)); m_omega = 0;
  
for k=1:nl
  [q,omega{k}] = getFundamentalRegion(ebsd(k).orientations,q0);
  m_omega = max(m_omega,max(omega{k}));
end

bins = get_option(varargin,'Edges',0:m_omega/20:m_omega);

his = zeros(nl,length(bins));
for k=1:nl
  his(k,:) = hist( omega{k},bins);
end

if nargout > 0,
  h = his;
else
  his = his./repmat(sum(his,2),1,length(bins));
  bar(bins/degree,his');
  axis tight
  xlabel('(mis-)orientation / degree')
  ylabel('relative frequency %')
end
