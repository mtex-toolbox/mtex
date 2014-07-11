function n = nfold( cs )
% maximal n-fold of symmetry axes

switch cs.LaueName
  case {'2/m','mmm'}
    n = 2;
  case {'m-3','-3','-3m'}
    n = 3;
  case {'4/m','4/mmm','m-3m'}
    n = 4;
  case {'6/m','6/mmm'}
    n = 6;
  otherwise
    n = 1;
end
