classdef lorenzModel < model


	properties
		% define parameters and bounds
		parameter_names = {'rho','sigma','beta'};
		lb = 			  [0       0        0 ];
		ub = 			  [100    100       100];
		default_values =  [28      10      8/3];
		variable_names = {'x','y','z'}; 

	end % end properties 

	methods

		function [m] = evaluate(m)

			ic = [.1 .1 .1];

			Tspan = [0 max(m.time)];

			options = odeset('InitialStep',1e-3,'MaxStep',1e-1,'RelTol',1e-3);
			[T, Y] = ode23t(@(t,y) m.lorenzModel_ode(t,y,m.parameters),Tspan,ic,options); % Solve ODE


			% re-interpolate and define new time. 
			m.time = T;

			m.prediction.x = Y(:,1);
			m.prediction.y = Y(:,2);
			m.prediction.z = Y(:,3);

		end % end evaluate 


		function m = plotButterfly(m,action)
			if ~isfield(m.handles,'plot_fig')
				m.handles.plot_data = [];
				% this is being called for the first time
				% create a figure
				m.handles.plot_fig = figure('position',[50 250 900 740],'NumberTitle','off','IntegerHandle','off','Name','The Lorenz Butterfly','CloseRequestFcn',@m.quitManipulateCallback);

				% we need to make only one axes -- 
				m.handles.plot_ax = autoPlot(1,1,true); 
				xlabel(m.handles.plot_ax,'x')
				ylabel(m.handles.plot_ax,'y')
				zlabel(m.handles.plot_ax,'z')
				hold(m.handles.plot_ax,'on')

				% make just one plot
				m.handles.plot_data.handles = plot3(NaN,NaN,NaN,'Color','k');
				prettyFig();
				
			end
				
			if nargin == 2
				if strcmp(action,'update')
					m.evaluate;
					m.handles.plot_data.handles.XData = m.prediction.x;
					m.handles.plot_data.handles.YData = m.prediction.y;
					m.handles.plot_data.handles.ZData = m.prediction.z;
					m.handles.plot_ax.XLim = [min(m.prediction.x) max(m.prediction.x)];
					m.handles.plot_ax.YLim = [min(m.prediction.y) max(m.prediction.y)];
					m.handles.plot_ax.ZLim = [min(m.prediction.z) max(m.prediction.z)];
				end
			end
		end

 	end % end class methods

 	methods (Static)
 		function dY = lorenzModel_ode(t,Y,p)

 			x = Y(1);
 			y = Y(2);
 			z = Y(3);

 			dx = p.sigma*(y-x);
 			dy = x*(p.rho - z) - y;
 			dz = x*y - p.beta*z;

 			dY = Y;
 			dY(1) = dx;
 			dY(2) = dy;
 			dY(3) = dz;

 		end
 	end



end % end classdef 