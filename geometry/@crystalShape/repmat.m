function cS =repmat(cS,varargin)
% implements repmat for crystalShape
%

n = prod([varargin{:}]);

% duplicate the faces
shift = length(cS.V) * repmat((0:n-1),size(cS.F,1),1);
shift = repmat(shift(:),1,size(cS.F,2));

% shift faces indices
cS.F = repmat(cS.F,n,1) + shift;

% dublicate vertices 
cS.V = repmat(cS.V,1,n);

end