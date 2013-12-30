function Z = pdf(odf,h,r,varargin)
% calculate pdf 
%
% pdf is a lowlevel function to evaluate the PDF corresponding to an ODF 
% at a list of crystal and specimen directions
%
% Input
%  odf - @ODF
%  h   - @Miller / @vector3d crystal directions
%  r   - @vector3d specimen directions
%
% Options
%  superposition - calculate superposed pdf
%
% Flags
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%
% See also
% ODF/plotpdf ODF/plotipdf ODF/calcPoleFigure

% check crystal symmetry
if isa(h,'Miller'), h = ensureCS(odf(1).CS,{h});end

% superposition coefficients
sp = get_option(varargin,'superposition',1);

%
if length(h) == numel(sp)
  Z = zeros(length(r),1);
elseif length(r) == numel(sp)
  Z = zeros(length(h),1);
else
  error('Either h or r must contain only a single value!')
end


% cycle through components
for s = 1:length(sp)

  if length(sp) == 1
    hh = h;
  else
    hh = h(s);
  end
  
  % compute poledensity for all portions
  for i = 1:length(odf)
    Z = Z + odf(i).weight * sp(s) * reshape(doPDF(odf(i),hh,r,varargin{:}),size(Z));
  end
end

end
