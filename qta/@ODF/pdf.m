function Z = pdf(odf,h,r,varargin)
% calculate pdf 
%
% pdf is a lowlevel function to evaluate the PDF corresponding to an ODF 
% at a list of crystal and specimen directions
%
%% Input
%  odf - @ODF
%  h   - @Miller / @vector3d crystal directions
%  r   - @vector3d specimen directions
%
%% Options
%  SUPERPOSITION - calculate superposed pdf
%
%% Flags
%  REDUCED - reduced PDF
%
%% See also
% ODF/plotpdf ODF/plotipdf ODF/simulatePoleFigure

if isa(h,'S2Grid')
  Z = zeros(GridLength(h),1);
else
  if isa(h,'Miller'), h = set(h,'CS',getSym(odf));end
  Z = zeros(GridLength(r),1);
end

% superposition coefficients
sp = get_option(varargin,'superposition',1);

for s = 1:length(sp)

  % for all portions
  for i = 1:length(odf)
  
    % ----------------------- uniform portion -------------------------------
    if check_option(odf(i),'UNIFORM')
      Z = Z + sp(s) + odf(i).c;
      
      % -------------------- fibre symmetric portion --------------------------
    elseif check_option(odf(i),'FIBRE')
      
      Z = Z + sp(s) * reshape(...
        RRK(odf(i).psi,vector3d(odf(i).center{1}),odf(i).center{2},...
        vector3d(h(s)),vector3d(r),odf(i).CS,odf(i).SS,varargin{:}),[],1) *...
        odf(i).c(:);
    
      % --------------- radially symmetric portion ----------------------------
    else
      Z = Z + sp(s) * reshape(...
        RK(odf(i).psi,quaternion(odf(i).center),h(s),r,odf(i).c,...
        odf(i).CS,odf(i).SS,varargin{:}),size(Z));
    end
  end
end
