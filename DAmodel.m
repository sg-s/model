% implementation of the reduced version of the Dynamical Adaptation Model 
% see: http://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1003289
% using the model abstract class 

classdef DAmodel < model


	properties
		% define parameters and bounds
		parameter_names = {'A','B',  'C','tau_y','n_y','tau_z','n_z'};
		lb = 			  [0    0     0   1       1     1        1];
		ub = 			  [1e3  10    1   100     5     400      5];

		variable_names = {'R','y','z'}; 

	end % end properties 

	methods

		function [m] = evaluate(m)

			% pre-allocate
			m.prediction.R = NaN*m.stimulus;
			m.prediction.y = NaN*m.stimulus;
			m.prediction.z = NaN*m.stimulus;

			% translation layer
			allS = m.stimulus;
			p = m.parameters;

			for mi = 1:size(allS,2)
				if size(allS,2) > 1
					S = allS(:,mi);		
				else
					S = allS;
				end

				[Ky,Kz] = generateFilters(m);

				% y and z are the stimulus convolved with the filters Ky and Kz
				y = filter(Ky,1,S);
				z = filter(Kz,1,S);
				m.prediction.R(:,mi) = (p.A*y./(1+p.B*z));

				m.prediction.y(:,mi) = y;
				m.prediction.z(:,mi) = z;
			end

			% return a dummy time vector 
			if isempty(m.time)
				m.time = 1:length(m.stimulus);
			end

		end % end evaluate 

		function [Ky,Kz] = generateFilters(m)
			p = m.parameters;
			S = m.stimulus;
			filter_length = 4*max([p.n_z*p.tau_z  p.n_y*p.tau_y]);
			if filter_length < length(S)/10
			else
				filter_length = length(S)/10; % ridiculously long filters
			end
			t = 0:filter_length; 

			n = p.n_y; tau = p.tau_y;
			f = t.^n.*exp(-t/tau); % functional form in paper
			f = f/tau^(n+1)/gamma(n+1); % normalize appropriately
			Ky = f;

			n = p.n_z; tau = p.tau_z;
			f = t.^n.*exp(-t/tau); % functional form in paper
			f = f/tau^(n+1)/gamma(n+1); % normalize appropriately
			Kz = p.C*Ky + (1-p.C)*f;
		end


 	end % end methods
end % end classdef 