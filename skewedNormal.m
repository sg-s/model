% skewed normal distribution 
% https://en.wikipedia.org/wiki/Skew_normal_distribution

classdef skewedNormal < distribution 


	properties
		% define parameters and bounds
		parameter_names = {'mu','sigma',  'shape'};
		lb = 			  [-10    0        -100   ];
		ub = 			  [10     10        100   ];
		default_values =  [0       1         0    ];


	end % end properties 

	methods

		function [m] = evaluate(m)

			x = m.x;
			p = m.parameters;

			% compute delta from shape
			d = p.shape/sqrt(1 + p.shape^2);

			% 2. compute omega from sigma 
			omega = p.sigma/(sqrt(1 - (2*d*d)/pi));

			% 3. compute xi 
			xi = p.mu - omega*d*sqrt(2/pi);

			X = (x - xi)./omega;

			y1 = exp(-(X.^2)/2)./sqrt(2*pi);
			y2 = (1 + erf((p.shape.*X)/sqrt(2)));
			m.probability = y1.*y2; 

		end % end evaluate 



	end

end