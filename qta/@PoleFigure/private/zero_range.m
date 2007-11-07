function NS3G = zero_range(pf,S3G,varargin)
%
global mtex_path;


g = quaternion(S3G);
cs = pf(1).CS; ss = pf(1).SS;

% calculate symmetrically equivalent orientations
g = ss*reshape(g,1,[]);               % SS x S3G
g = reshape(g.',[],1);                % S3G x SS
g = reshape(g*cs,GridLength(S3G),[]); % S3G x SS x CS

ind = true(GridLength(S3G),1);
for ip = 1:length(pf)

  fprintf('applying zero range method to %s',char(getMiller(pf(ip))));
  k = kernel('de la Vallee Poussin','halfwidth',...
    max([2.5*degree,2*getResolution(S3G),2*getResolution(pf(ip))]));

  gh = g(ind) * pf(ip).h;
    
  % transform in polar coordinates
	[in_theta,in_rho] = polar(pf(ip).r);
	[out_theta,out_rho] = polar(gh);
	
	in_theta = fft_theta(in_theta); 
	in_rho   = fft_rho(in_rho);   
	out_theta= fft_theta(out_theta);
	out_rho  = fft_rho(out_rho);  
	
	gh = [reshape(in_rho,1,[]);reshape(in_theta,1,[])];
	r  = [reshape(out_rho,1,[]);reshape(out_theta,1,[])];
	
	% extract legendre coefficents
	Al = getA(k); Al(2:2:end) = 0;

  delta = get_option(varargin,'zero_range',0.01,'double');
  bg = delta * max(pf(ip).data(:));
  c = 100*(pf(ip).data > bg)-1;
  
  f = run_linux([mtex_path,'/c/bin/odf2pf'],'EXTERN',gh,r,c,Al);

  f = reshape(f,sum(ind),[]);

  ind(ind) = all(f > 0,2);
  
  fprintf(' - reduction: %d / %d\n',sum(ind),length(ind));
end

NS3G = SO3Grid(quaternion(S3G,ind),cs,ss);
