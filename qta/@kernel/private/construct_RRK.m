function RRK = construct_RRK(name,p,A)

switch lower(name)
  
  case 'fibre von mises fisher'

    RRK = @(dh,dr) ...
      p/sinh(p)*besseli(0,p * sqrt((1-dh.^2)*(1-dr.^2))).*...
      exp(p* dh*dr);
    
  case 'square singularity'
    
    RRK = @rrk_squaresingularity;
    
  otherwise

    RRK = @rrk_clenshaw;
    
end


  function res = rrk_squaresingularity(dh,dr)
    
    
    c = 2*p/log((1+p)/(1-p));
		sindhdr = sqrt((1-dh.^2)*(1-dr.^2));
		res = c./...
		(1 + h^2 - 2*h*(dh * dr - sindhdr)).^(0.5) ./...
		(1 + h^2 - 2*h*(dh * dr + sindhdr)).^(0.5);

	end

	function res = rrk_clenshaw(dh,dr)
		
		res = zeros(numel(dh),numel(dr));
		if numel(dh)<numel(dr)
			for ih = 1:length(dh)
				Plh = mylegendre(length(A)-1,dh(ih))';
				res(ih,:) = ClenshawL(A .* Plh,dr);				
			end
		else
			for ir = 1:length(dr)				
				Plr = mylegendre(length(A)-1,dr(ir))';
				res(:,ir) = ClenshawL(A .* Plr,dh).';				
			end
		end
		res(res<0)=0;
	end
end
