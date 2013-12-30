function varargout = find(S2G,v,varargin)
% return index of all points in a epsilon neighborhood of a vector
%
%% Syntax  
% ind = find(S2G,v,epsilon) - find all points in a epsilon neighborhood of v
% ind = find(S2G,v)         - find closest point
%
%% Input
%  S2G     - @S2Grid
%  v       - @vector3d
%  epsilon - double
%
%% Options
%  antipodal      - include [[AxialDirectional.html,antipodal symmetry]]
%
%% Output
%  ind     - int32        

%% if points are not indexed
if ~check_option(S2G,'INDEXED') || ~check_option(varargin,'direct')
  
  [varargout{1:nargout}] = find(S2G.vector3d,v,varargin{:});
  return
  
end
  
%% use indexing for fast finding of points
d = [];
if check_option(S2G,'antipodal'), v = [v(:),-v(:)]; end

% compute polar coordinats
[ytheta,yrho,iytheta,prho,rhomin] = getdata(S2G);
yrho = yrho - rhomin;
[xtheta,xrho] = polar(v);
xrho = xrho - rhomin;

% find closest points
if nargin == 2
  
  ind = S2Grid_find(ytheta,int32(iytheta),yrho,prho,xtheta,xrho);
    
  if check_option(S2G,'antipodal')
    ind = reshape(ind,[],2);
        
    d = abs(dot(S2G(ind),v));
    ind2 = d == repmat(max(d,[],2),1,2);
    ind2(all(ind2,2),2) = false;
    ind = ind(ind2);
    d = d(ind2);
    
  end
  
% find epsilon region
else
  
  ind = S2Grid_find_region(ytheta,int32(iytheta),...
    yrho,prho,xtheta,xrho,varargin{1});
  
  if check_option(S2G,'antipodal')
    ind = ind(:,1:size(v,1)) | ind(:,size(v,1) + 1:end);
  end
  
end

% assign return values
varargout{1} = ind;
varargout{2} = d;
