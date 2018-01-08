function sVF = times(sVF1,sVF2)
%
% Syntax
%  sVF = sVF1.*sVF2
%  sVF = a.*sVF1
%  sVF = sVF1.*a
%

if isnumeric(sVF1)
  sVF = sVF2;
  sVFsF = sVF.sF.*sVF1;
elseif isnumeric(sVF2)
  sVF = sVF1;
  sV.sF = sVF.sF.*sVF2;
end

end
