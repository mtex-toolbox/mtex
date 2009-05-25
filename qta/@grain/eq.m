function varargout = eq(grains,ebsd)
% return a selection between grains and correspondig ebsd data
%
%% Input
%  grains - @grain
%  ebsd   - @EBSD
%
%% Output
%  grains   - selected grains
%  ebsd     - selected ebsd data
%
%% Example
%  %return the grains of a given ebsd data 
%  grains == ebsd
%
%  %return the ebsd data of a given grains
%  ebsd == grains
%
%  %intersect two grainsets
%  grains(hasholes(grains)) == grains(hassubfraction(grains))
%

if isa(grains,'EBSD') & isa(ebsd,'grain')      %select ebsd data from grain
  [me mg ids] = assert_checksum(ebsd,grains);
  varargout{1} = copy(grains,me);  
  if nargout > 1, varargout{2} = ebsd(mg); end
elseif isa(ebsd,'EBSD') & isa(grains,'grain')  %select grain data from ebsd
	[me mg ids] = assert_checksum(grains,ebsd);
  varargout{1} = grains(mg);
  if nargout > 1, varargout{2} = copy(ebsd,me); end
elseif isa(grains,'grain') & isa(ebsd,'grain') 
  if grains(1).checksum == ebsd(1).checksum,
    [ignore ia] = intersect([grains.id],[ebsd.id]);
    varargout{1} = grains(ia);
    return
  else
    error('different grains')
  end
else
  error('something went wrong');
end

if nargout > 2, varargout{3} = ids; end