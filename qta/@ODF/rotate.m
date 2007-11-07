function nodf = rotate(odf,q)
% rotate ODF
%
%% Input
%  odf - @ODF
%  q   - @quaternion
%
%% Output
%  rotated odf - @ODF

nodf = odf;

for i = 1:length(odf)
  if check_option(odf(i),'FIBRE')
    nodf(i).center{2} = q * nodf(i).center{2};
  elseif ~check_option(odf(i),'UNIFORM')
    nodf(i).center = q * nodf(i).center;
  end
end
