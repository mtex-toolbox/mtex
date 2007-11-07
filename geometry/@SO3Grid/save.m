function save(SO3G,datei,varargin)
% save grid to file
%
% format a b c d

if check_option(varargin,{'Euler','Bunge'})
  
  [alpha,beta,gamma] = quat2euler(quaternion(SO3G),varargin{:});
  q = [alpha(:),beta(:),gamma(:)];   %#ok<NASGU>
else
  
  q = double(quaternion(SO3G));
  q = reshape(q,[],4); %#ok<NASGU>
end

save(datei,'q','-ASCII');
