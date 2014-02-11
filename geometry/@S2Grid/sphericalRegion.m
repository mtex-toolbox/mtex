function varargout = sphericalRegion(S2G,varargin)

if isa(S2G.thetaGrid,'function_handle')
  varargout{1} = 0;
   varargout{2} =  S2G.thetaGrid;
else
  varargout{1} = min([S2G.thetaGrid.min]);  
  varargout{2} = max([S2G.thetaGrid.max]);
end

varargout{3} = min([S2G.rhoGrid.min]);
varargout{4} = max([S2G.rhoGrid.max]);
