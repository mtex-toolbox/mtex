function ebsd = subsref(ebsd,s)
% indexing of EBSD data
%
%% Syntax:
%  ebsd('Fe')        - returns data of phase Fe
%  ebsd({'Fe','Mg'}) - returns data of phase Fe and Mg
%  ebsd(1:end)       - returns data 
%

if isa(s,'double') || isa(s,'logical')
  
  ebsd.options = structfun(@(x) x(s),ebsd.options,'UniformOutput',false);
  ebsd.rotations = ebsd.rotations(s);
  ebsd.phase = ebsd.phase(s);
  
elseif strcmp(s.type,'()')
  
  if check_option(s.subs,'sort')
    
    ebsd = subsref(ebsd,get_option(s.subs,'sort'));
    
  else
    
    ind = subsind(ebsd,s.subs);
    ebsd = subsref(ebsd,ind);
    
  end
end



