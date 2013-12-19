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
%  antipodal - include [[AxialDirectional.html,antipodal symmetry]]
%
%% See also
% ODF/plotpdf ODF/plotipdf ODF/calcPoleFigure

% superposition coefficients
sp = get_option(varargin,'superposition',1);

if numel(h) == numel(sp)
  Z = zeros(numel(r),1);
elseif numel(r) == numel(sp)
  Z = zeros(numel(h),1);
else
  error('Either h or r must contain only a single value!')
end
if isa(h,'Miller'), h = ensureCS(odf(1).CS,{h});end



for s = 1:length(sp)

  if length(sp) == 1
    hh = h;
  else
    hh = h(s);
  end
  
  % for all portions
  for i = 1:length(odf)
  
    % ----------------------- uniform portion -------------------------------
    if check_option(odf(i),'UNIFORM')
      Z = Z + sp(s) * odf(i).c;
      
    elseif check_option(odf(i),'FOURIER')
      
      Z = Z + sp(s) * fourier2pdf(odf(i),vector3d(hh),r,varargin{:});
      
      % -------------------- fibre symmetric portion --------------------------
    elseif check_option(odf(i),'FIBRE')
      
      Z = Z + sp(s) * reshape(...
        RRK(odf(i).psi,odf(i).center{1},odf(i).center{2},...
        hh,r,odf(i).CS,odf(i).SS,varargin{:}),[],1) *...
        odf(i).c(:);
      
      % -------------------- Bingham portion --------------------------
    elseif check_option(odf(i),'Bingham')
      
       Z = Z + sp(s) * bingham2pdf(odf(i),vector3d(hh),r,varargin{:});
            
      % --------------- radially symmetric portion ----------------------------
    else
      
      Z = Z + sp(s) * reshape(...
        RK(odf(i).psi,odf(i).center,hh,r,odf(i).c,...
        odf(i).CS,odf(i).SS,varargin{:}),size(Z));
    end
  end
end
