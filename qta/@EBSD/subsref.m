function ebsd = subsref(ebsd,s)
% indexing of EBSD data
%
%% Syntax:
%  ebsd('Fe')        % returns data of phase Fe
%  ebsd({'Fe','Mg'}) % returns data of phase Fe and Mg
%  ebsd(grain)       % returns data of the grains grain
%

if isa(s,'double') || isa(s,'logical')
  
  ebsd.options = structfun(@(x) x(s),ebsd.options,'UniformOutput',false);
  ebsd.rotations = ebsd.rotations(s);
  ebsd.phases = ebsd.phases(s);
        
elseif strcmp(s.type,'()')

  ind = subsind(ebsd,s.subs);
  ebsd = subsref(ebsd,ind);

end


  
