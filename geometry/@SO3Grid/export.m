function save(SO3G,datei,varargin)
% save grid to file
%
% format a b c d

if check_option(varargin,{'Euler','Bunge'})
  
  q = Euler(SO3G,varargin{:}); %#ok<NASGU>
  
else
  
  q = reshape(double(SO3G),[],4); %#ok<NASGU>
  
end

save(datei,'q','-ASCII');
