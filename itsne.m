% interactive t-SNE visualization and exploration 
% the engine flag switches between different t-SNE implementations:
% 1 -- multi-core tSNE (https://github.com/sg-s/Multicore-TSNE)
% 2 -- built-in t-sne
% 3 -- built-in t-sne, Barnes-Hut

classdef itsne < model


	properties
		% define parameters and bounds
		parameter_names = {'perplexity','n_iter','engine','slice'};
		lb = 			  [      3       100       1        1];
		ub = 			  [      100     1000      3        10];
		default_values =  [      30      500       1        10];
		live_update = false;
		variable_names = {'x','y'}; 

	end % end properties 

	methods

		function [m] = evaluate(m)

			m.disableManipulateControls;

			S = m.stimulus;

			% slice
			if length(size(S)) == 3
				S = S(:,:,1:floor(m.parameters.slice):end);
			elseif length(size(S)) == 2
				S = S(:,1:floor(m.parameters.slice):end);
			else
				error('Unsupported stimulus dimension')
			end

			try
				m.handles.plot_fig.Name = '--embedding--';
				drawnow
			catch
			end

			engine = floor(m.parameters.engine);
			switch engine
			case 1

				% if the stimulus is an image set, we need to reshape the matrix before feeding it to t-SNE

				if length(size(S)) == 2
					R = mctsne(S,ceil(m.parameters.n_iter),ceil(m.parameters.perplexity));
					n = size(m.stimulus,2);
				else
					S = reshape(S,size(S,1)*size(S,2),size(S,3));
					R = mctsne(S,ceil(m.parameters.n_iter),ceil(m.parameters.perplexity));
					n = size(m.stimulus,3);
				end
				m.prediction.x = NaN(1,n);
				m.prediction.y = NaN(1,n);
				m.prediction.x(1:floor(m.parameters.slice):end) = R(1,:);
				m.prediction.y(1:floor(m.parameters.slice):end) = R(2,:);
			case 2
				error('not coded')
			case 3
				error('not coded')
			otherwise
				error('engine flag unrecognized.')
			end

			try
				m.handles.plot_fig.Name = '--DONE--';
			catch
			end

			m.enableManipulateControls;


		end % end evaluate 


		function m = setStimulus(m)
			if isempty(m.stimulus)
				return
			end
			if length(size(m.stimulus)) == 3
				n = size(m.stimulus,3);
				m.ub(1) = floor((n-1)/(3*m.parameters.slice));
			elseif length(size(m.stimulus)) == 2
				n = size(m.stimulus,2);
				m.ub(1) = floor((n-1)/(3*m.parameters.slice));
			else 
				error('Unsupported stimulus dimension.')
			end
		end % setStimulus runs AFTER stimulus is set. 



		function m = plotTSNE(m,action)

			

			if ~isfield(m.handles,'plot_fig')
				% this is being called for the first time
				% create a figure

				m.handles.plot_fig = figure('Name','t-SNE visualization','WindowButtonDownFcn',@m.mouseCallback,'NumberTitle','off','position',[50 150 1200 700], 'Toolbar','figure','Menubar','none','CloseRequestFcn',@m.quitManipulateCallback); 
				m.handles.plot_ax(1) = axes('parent',m.handles.plot_fig,'position',[-0.1 0.1 0.85 0.85],'box','on','TickDir','out');axis square, hold on ; title('Reduced Data')
				m.handles.plot_ax(2) = axes('parent',m.handles.plot_fig,'position',[0.6 0.1 0.3 0.3],'box','on','TickDir','out');axis square, hold on  ; title('Raw data');

				% based on the dimension of the data, show an image or a plot in the 2nd axes
				if length(size(m.stimulus)) == 2
					m.handles.selected_data = plot(m.handles.plot_ax(2),NaN,NaN,'k');
				elseif length(size(m.stimulus)) == 3
					m.handles.selected_data = imagesc(m.handles.plot_ax(2),NaN(4));
					m.handles.plot_ax(2).XLim = [1 size(m.stimulus,1)];
	            	m.handles.plot_ax(2).YLim = [1 size(m.stimulus,2)];
				else
					error('your data has an unsupported dimension')
				end
		
				hold(m.handles.plot_ax(1),'on')
				hold(m.handles.plot_ax(2),'on')

				m.handles.plot_data.handles = plot(m.handles.plot_ax(1),NaN,NaN,'k+');
				
				prettyFig();
				
			end
				
			if nargin == 2
				if strcmp(action,'update')

					m.evaluate;

					% update X and Y data for plot handles directily from the prediction
					m.handles.plot_data(1).handles(1).XData = m.prediction.x;
					m.handles.plot_data(1).handles(1).YData = m.prediction.y;
					
					m.handles.plot_ax(1).XLim = [min(m.prediction.x) max(m.prediction.x)];
					m.handles.plot_ax(1).YLim = [min(m.prediction.y) max(m.prediction.y)];
				end
			end
		end


 		function mouseCallback(m,~,~)
 			hm1 = m.handles.plot_ax(1);
	 		if gca == hm1
	            pp = get(hm1,'CurrentPoint');
	            p(1) = (pp(1,1)); p(2) = pp(1,2);
	            x = m.prediction.x; y = m.prediction.y;
	            [~,cp] = min((x-p(1)).^2+(y-p(2)).^2); % cp C the index of the chosen point
	            if length(cp) > 1
	                cp = min(cp);
	            end
	            % now plot the data vector corresponding to this plot on the secondary axis
	            if length(size(m.stimulus)) == 3
	            	m.handles.selected_data.CData = m.stimulus(:,:,cp);
	    
	            elseif length(size(m.stimulus)) == 2
	            	error('not coded')
	            	
	            end
	        end
 		end

 	end % end class methods



end % end classdef 