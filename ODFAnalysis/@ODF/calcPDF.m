function Z = calcPDF(odf,h,r,varargin)
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
% ODF/plotPDF ODF/plotIPDF ODF/calcPoleFigure

% check crystal symmetry
if isa(h,'Miller'), h = odf.CS.ensureCS(h);end

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
  
  % compute pole density for all portions
  for i = 1:length(odf.components)
    Z = Z + odf.weights(i) * sp(s) * ...
      reshape(calcPDF(odf.components{i},hh,r,varargin{:}),size(Z));
  end
end

end
