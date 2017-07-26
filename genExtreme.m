% generalized extreme value distribution 
classdef genExtreme < distribution 


	properties
		% define parameters and bounds
		parameter_names = {'mu','sigma',  'epsilon'};
		lb = 			  [-1e3    0       -1e6   ];
		ub = 			  [1e3    1e6       1e6   ];
		default_values =  [0       1         1    ]

	end % end properties 

	methods

		function [m] = evaluate(m)

			x = m.x;

			p = m.parameters;
			switch p.epsilon
			case 0
				tx = (1 + p.epsilon*((x - p.mu)./(p.sigma))).^(-1/p.epsilon);
			otherwise
				tx = exp(-(x - p.mu)/p.sigma);
			end
			y = (1/p.sigma)*(tx.^(p.epsilon + 1)).*exp(-tx);

			m.probability = y;
		end % end evaluate 



	end

end