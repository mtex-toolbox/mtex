function K = kernel(name,varargin)
% constructor
%
%% Description
% The constructor *kernel* defines a @kernel object given the name 
% of the kernel and its halfwidth beta or its free parameter kappa.
% A second posibility is to define the kernel by its Fourier 
% coefficients. A @kernel object is needed when defining a @ODF.
%
%% Input
%  kernel name - string
%
%% Options
%  PARAMETER - kappa (double)
%  HALFWIDTH - beta  (double)
%  FOURIER   - AL    (double)
%  BANDWIDTH - L     (int32)
%
% supported kernel:
% Laplace, Abel Poisson, de la Vallee Poussin, von Mises Fisher,
% fibre von Mises Fisher, Square Singularity, Gauss Weierstrass,
% Dirichlet, local, user
%
%% See also
% ODF_index kernel/gethw unimodalODF uniformODF

if check_option(varargin,'HALFWIDTH')
  p = hw2p(name,get_option(varargin,'HALFWIDTH'));
elseif length(varargin)>=1
  p = varargin{1};
end
L = get_option(varargin,'BANDWIDTH',1000);
       
if nargin == 0
  K.name = [];
  K.A    = [];
  K.p1   = 0;
  K.K    = [];
  K.RK   = [];
  K.RRK  = [];
  K = class(K,'kernel');
  warning('empty kernel'); %#ok<WNTAG>
else
	if isa(name,'kernel')
		K = name;
	elseif isa(name,'char')
    K.name = name;
		switch lower(name)
			case 'laplace'
        K.A = Laplacekern(p,L);
				K.p1 = p;  % -> h
		
				K.K   = @(co2) ClenshawU(K.A,acos(co2)*2);
				K.RK  = @(dmatrix) ClenshawL(K.A,dmatrix);
				K.RRK = @rrk_clenshaw;
			case 'abel poisson'
				K.A   = APkern(p,L);
				K.p1 = p;  %-> h
					
				K.K   = @(co2) ...
					0.5*((1-K.p1^2)./(1-2*K.p1*co2+K.p1^2).^2+...
					(1-K.p1^2)./(1+2*K.p1*co2+K.p1^2).^2);
				K.RK  = @(dmatrix) ...
					(1-K.p1^4)./((1-2*K.p1^2*dmatrix+K.p1^4).^(3/2));
				K.RRK = @rrk_clenshaw;
			case 'de la vallee poussin'
				K.A   = delaVPkern(p,L);
				K.p1  = p;  %-> xi
		
				K.K   = @(co2) ...
					beta(1.5,0.5)/beta(1.5,K.p1+0.5) * co2.^(2*K.p1);
				K.RK  = @(dmatrix) ...
					(1+K.p1) * ((1+dmatrix)/2).^K.p1;
				K.RRK = @rrk_clenshaw;
			case 'von mises fisher'
				K.A   = MFkern(p,L);
				K.p1  = p;  %-> xi

        if K.p1 < 500
          K.K   = @(co2) ...
            1/(besseli(0,K.p1)-besseli(1,K.p1))...
            * exp(K.p1*cos(acos(co2)*2));
        
          K.RK  = @(dmatrix) ...
            besseli(0,K.p1 *(1+dmatrix)/2)/...
            (besseli(0,K.p1)-besseli(1,K.p1))...
            .* exp(K.p1*(dmatrix-1)/2);
        else
          error('too small halfwidth - not yet supported');
%  K.K   = @(co2) ClenshawU(K.A,acos(co2)*2);
%  K.RK  = @(dmatrix) ClenshawL(K.A,dmatrix);          
        end
        
				K.RRK = @rrk_clenshaw;
			case 'fibre von mises fisher'
				K.A   = RMFkern(p,L);
				K.p1  = p;  %-> xi

				K.K   = @(co2) ClenshawU(K.A,acos(co2)*2);
				K.RK  = @(dmatrix) ...
					K.p1/sinh(K.p1)*exp(K.p1*dmatrix);
				K.RRK = @(dh,dr) ...
					K.p1/sinh(K.p1)*besseli(0,K.p1 * sqrt((1-dh.^2)*(1-dr.^2))).*...
					exp(K.p1* dh*dr);
			case 'square singularity'
				K.A   = squSingkern(p,L);
				K.p1  = p;  %-> h

				h = p;
				c = 2*h/log((1+h)/(1-h));
				
				K.K   = @(co2) ClenshawU(K.A,acos(co2)*2);
				K.RK  = @(dmatrix) ...
					2*K.p1/log((1+K.p1)/(1-K.p1))./...
					(1-2*K.p1*dmatrix+K.p1^2);
				K.RRK = @rrk_squaresingularity;
			case 'local'
				K.A   = localkern(p,3,L);
				K.p1  = p;  %-> h
				h     = p-1;
				diff  = -5120*h^5 - 2516480/231*h^6 - 1238528/143*h^7 - ...
					2884352/1001*h^8 - 327821248/1072071*h^9 - ...
					335519200/6789783*h^10 + 297252224/74687613*h^11 - ...
					6819984608/5153445297*h^12 + 10609776512/22331596287*h^13 - ...
					27354944/151915621*h^14 + 2986921984/42053005995*h^15 - ...
					44603484928/1544315774001*h^16 + 20524968991232/1706468930271105*h^17 - ...
					7128109283584/1396201852039995*h^18;
				p2  = 30*pi*( sqrt(1 - p^2) *...
					(16 + 83 * p^2 + 6 * p^4) + ...
					15 * p * (3 + 4*p^2) * acos(p)...
					)/diff;

				K.K   = @(co2) (co2>K.p1).* p2 .* (co2 - K.p1).^3;
				K.RK  = @(dmatrix) ClenshawL(K.A,dmatrix);%@rk_local;
				K.RRK = @rrk_clenshaw;
			case 'gauss weierstrass'
				K.A   = GWkern(p,L);
				K.p1  = p;
				
				K.K   = @(co2) ClenshawU(K.A,acos(co2)*2);
				K.RK  = @(dmatrix) ClenshawL(K.A,dmatrix);
				K.RRK = @rrk_clenshaw;
      case 'dirichlet'
        if L == 1000 || L < p, L = p;end
        K.A   = [ones(1,p),zeros(1,L-p)];
				K.p1  = p;
				
				K.K   = @(co2) ClenshawU(K.A,acos(co2)*2);
				K.RK  = @(dmatrix) ClenshawL(K.A,dmatrix);
				K.RRK = @rrk_clenshaw;
			case 'user'
				K.name = name;
				K.A   = p;
				K.p1  = p;
				
				K.K   = @(co2) ClenshawU(K.A,acos(co2)*2);
				K.RK  = @(dmatrix) ClenshawL(K.A,dmatrix);
				K.RRK = @rrk_clenshaw;
			otherwise
				error(sprintf(['unknown kernel: "',name,'".\nAvailable kernels are: \n',...
					' Laplace, \n',...
					' Abel Poisson, \n',...
					' de la Vallee Poussin, \n',...
					' von Mises Fisher, \n',...
					' fibre von Mises Fisher, \n',...
					' Square Singularity, \n',...
					' Gauss Weierstrass, \n',...
					' local, \n',...
          ' Dirichlet, \n',...
					' user']));
		end
    K = class(K,'kernel');
	else
    error('first parameter should be char');
  end
end

  function res = rk_local(dMatrix) %#ok<DEFNU>

		res = sparse(size(dMatrix)); %#ok<NASGU>
		
		c =  p2/3/pi;
		a = cos(dMatrix/2);
		
		%suche punkte die innerhalb der Umgebung liegen
                
		b = a(a > h);
                
%  if xray   % falls X-ray das selbe nochmal mit -h
%  a   = 1-a.^2;
%  ig2 = find(a > h^2);
%  b   = [b;sqrt(a(ig2))];
%  ig  = [ig;ig2];
%  c   = c *0.5;
%  end
		                
		res =  c * (b .* (4 * b.^2 + 11 .* h.^2) .* sqrt(1 - (h./b).^2) -...
			3 * (3 * b.^2 * h + 2 * h^3) .* acos(h./b));
		
%  c = p2/3/pi;
%  a = sqrt((1+dMatrix)./2);
%  res = (a > h).*c * (b .* (4 * b.^2 + 11 .* h.^2) .* sqrt(1 - (h./b).^2) -...
%  3 * (3 * b.^2 * h + 2 * h^3) .* acos(h./b));;
	end

	function res = rrk_squaresingularity(dh,dr)
		
		sindhdr = sqrt((1-dh.^2)*(1-dr.^2));
		res = c./...
		(1 + h^2 - 2*h*(dh * dr - sindhdr)).^(0.5) ./...
		(1 + h^2 - 2*h*(dh * dr + sindhdr)).^(0.5);

	end

	function res = rrk_clenshaw(dh,dr)
		
		res = zeros(numel(dh),numel(dr));
		if numel(dh)<numel(dr)
			for ih = 1:length(dh)
				
				Plh = mylegendre(length(K.A)-1,dh(ih))';
				res(ih,:) = ClenshawL(K.A .* Plh,dr);
				
			end
		else
			for ir = 1:length(dr)
				
				Plr = mylegendre(length(K.A)-1,dr(ir))';
				res(:,ir) = ClenshawL(K.A .* Plr,dh).';
				
			end
		end
		res(res<0)=0;
	end
end
