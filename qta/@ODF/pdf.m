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
% ODF/plotpdf ODF/plotipdf ODF/simulatePoleFigure

if isa(h,'S2Grid')
  Z = zeros(numel(h),1);
else
  if isa(h,'Miller'), h = set(h,'CS',odf(1).CS);end
  Z = zeros(numel(r),1);
end

% superposition coefficients
sp = get_option(varargin,'superposition',1);

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
      
      q1 = hr2quat(vector3d(hh),vector3d(r));
      q2 = q1 .* axis2quat(vector3d(hh),pi);
      
      ASym = quaternion(symmetrise(odf(i).center));
    
      C = odf(i).c(1) ./ mhyper(odf(i).psi);
       
      for iA = 1:size(ASym,1)
    
        A1 = dot_outer(q1,ASym(iA,:));
        A2 = dot_outer(q2,ASym(iA,:));
      
        a = (A1.^2 +  A2.^2) * reshape(odf(i).psi,[],1) ./2;
        b = (A1.^2 -  A2.^2) * reshape(odf(i).psi,[],1) ./2;
        c = (A1 .*  A2) * reshape(odf(i).psi,[],1);
        
        Z = Z + sp(s) * exp(a) .* C .* besseli(0,sqrt(b.^2 + c.^2))./ size(ASym,1);

      end
      
            
      % --------------- radially symmetric portion ----------------------------
    else
      
      Z = Z + sp(s) * reshape(...
        RK(odf(i).psi,odf(i).center,hh,r,odf(i).c,...
        odf(i).CS,odf(i).SS,varargin{:}),size(Z));
    end
  end
end
