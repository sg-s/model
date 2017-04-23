classdef ssBacteriaModel < model


	properties
		% define parameters and bounds
		parameter_names = {'B','a0','e_L','K_1','K_2'};
		lb = 			  [0    0    1e-3 1e-6 1e1];
		ub = 			  [1e3  1    .1   1e1  1e5];

		variable_names = {'a','e0'}; % the first response is compared to data

	end % end properties 

	methods

		function [m] = evaluate(m)

			% pre-allocate
			m.prediction.a = NaN*m.stimulus;
			m.prediction.e0 = NaN*m.stimulus;

			% translation layer
			T = 1e-4:1e-4:max(m.time);
			allS = m.stimulus;
			p = m.parameters;

			for mi = 1:size(allS,2)
				S = allS(:,mi);		

				% interpolate 
				S_ = interp1(m.time,S,T); S_(isnan(S_)) = S(1);
				e0_ = 0*S_;
				a_ = 0*S_;


				% inital conditions 
				a_(1) = p.a0;
				Shat = (1 + S_(1)/p.K_2)/(1 + S_(1)/p.K_1);
				e0_(1) = log((1-p.a0)/p.a0) - log(Shat);
				if e0_(1) < p.e_L
					e0_(1) = p.e_L;
				end

				% use a fixed-step Euler to solve this
				for i = 2:length(S_)
					dydt = p.B*(a_(i-1) - p.a0);

					e0_(i) = dydt*1e-4 + e0_(i-1);

					if e0_(i) < p.e_L
						e0_(i) = p.e_L;
					end

					% update a
					Shat = (1 + S_(i-1)/p.K_2)/(1 + S_(i-1)/p.K_1);
					E = exp(e0_(i-1) + log(Shat));
					a_(i) = 1/(1 + E);

				end

				% switch back to timestep of data
				m.prediction.a(:,mi) = interp1(T,a_,m.time);
				m.prediction.e0(:,mi) = interp1(T,e0_,m.time);
			end

		end % end evaluate 

		function m = plot_Custom(m)
		end % end some dummy custom plot function 



 	end % end methods



end % end classdef 