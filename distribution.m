%% distribution.m
% an abstract MATLAB class to manipulate and sample from distributions 
% 


classdef (Abstract) distribution < handle

	properties (Abstract) 
		% parameters
		parameter_names
		 
		lb
		ub
		default_values		


	end % end properties

	properties

		parameters

		% data
		x
		probability
		data % samples of data, not a PDF
		
		handles 

	end


	methods

		function m = distribution(m)
			init(m);
			checkBounds(m);
		end

		function [m] = init(m)
			for i = 1:length(m.parameter_names)
				% if default_values are defines, use them
				if ~isempty(m.default_values)
					for i = 1:length(m.default_values)
						m.parameters.(strtrim(m.parameter_names{i})) = (m.default_values(i));
					end
				else
					if m.lb(i) > 0 && m.ub(i) > 0
						m.parameters.(strtrim(m.parameter_names{i})) = sqrt(m.lb(i)*m.ub(i));
					else
						m.parameters.(strtrim(m.parameter_names{i})) = (m.ub(i) + m.lb(i))/2;
					end
				end
			end

		end % end init

		function summary_statistics = summary(m)
			summary_statistics.sample_mean = mean(m);
			summary_statistics.sample_variance = std(m)^2;
			summary_statistics.median = median(m);
			summary_statistics.skewness = skewness(m);
		end

		function mu = mean(m)
			% pick a million samples from the distribution 
			X = m.sample(1e6);
			mu = mean(X);
		end % end mean

		function s = std(m)
			% pick a million samples from the distribution 
			X = m.sample(1e6);
			s = std(X);
		end % end std

		function m = median(m)
			% pick a million samples from the distribution 
			X = m.sample(1e6);
			m = median(X);
		end % end median

		function sk = skewness(m)
			% pick a million samples from the distribution 
			X = m.sample(1e6);
			sk = skewness(X);
		end % end skewness

		function X = sample(m,n_samples)
			% sample from distribution 
			X = pdfrnd(m.x,m.probability,n_samples);

		end % end sample

		function m = checkBounds(m)
			assert(~any(m.lb >= m.ub),'At least one lower bound is greater than a upper bound');
			assert(min(((struct2mat(m.parameters) >= m.lb) & (struct2mat(m.parameters) <= m.ub))),'At least one parameter out of bounds');
		end


		function [m] = manipulate(m)
			% check if a manipulate control window is already open. otherwise, create it
			make_gui = true;
			if isfield(m.handles,'manipulate_control')
				if isvalid(m.handles.manipulate_control)
					make_gui = false;
				end
			end

			if make_gui
				Height = 440;
				m.handles.manipulate_control = figure('position',[10 250 1000 Height], 'Toolbar','none','Menubar','none','NumberTitle','off','IntegerHandle','off','CloseRequestFcn',@m.quitManipulateCallback,'Name',['distribution: [' class(m) ']']);

				% draw for the first time
				f = m.parameter_names;
				pvec = struct2mat(m.parameters);

				% make sure the bounds are OK
				checkBounds(m);
		
				nspacing = Height/(length(f)+1);
				for i = 1:length(f)
					m.handles.control(i) = uicontrol(m.handles.manipulate_control,'Position',[70 Height-i*nspacing 230 20],'Style', 'slider','FontSize',12,'Callback',@m.sliderCallback,'Min',m.lb(i),'Max',m.ub(i),'Value',pvec(i));

					try    % R2013b and older
					   addlistener(m.handles.control(i),'ActionEvent',@m.sliderCallback);
					catch  % R2014a and newer
					   addlistener(m.handles.control(i),'ContinuousValueChange',@m.sliderCallback);
					end

					% hat tip: http://undocumentedmatlab.com/blog/continuous-slider-callback

					thisstring = [f{i} '=',mat2str(m.parameters.(strtrim(m.parameter_names{i})))];
					m.handles.controllabel(i) = uicontrol(m.handles.manipulate_control,'Position',[40 (Height-i*nspacing +30) 300 30],'style','text','String',thisstring,'FontSize',20);
					m.handles.lbcontrol(i) = uicontrol(m.handles.manipulate_control,'Position',[305 Height-i*nspacing+3 40 20],'style','edit','String',mat2str(m.lb(i)),'Callback',@m.resetSliderBounds);
					m.handles.ubcontrol(i) = uicontrol(m.handles.manipulate_control,'Position',[350 Height-i*nspacing+3 40 20],'style','edit','String',mat2str(m.ub(i)),'Callback',@m.resetSliderBounds);

					% add a button that allows for log variation in the sliders
					m.handles.log_control(i) = uicontrol(m.handles.manipulate_control,'Position',[10 Height-i*nspacing+3 40 20],'style','togglebutton','String','Log');

				end

				% also add an axes to show the distribution 
				m.handles.dist_axes = axes();
				m.handles.dist_axes.Position = [.45 .1 .5 .8];

				% also make a plot, so we can redraw it directly 
				m.handles.dist_plot = plot(m.handles.dist_axes,NaN,NaN,'k-','LineWidth',2);

				m.evaluate;
				m.handles.dist_plot.XData = m.x;
				m.handles.dist_plot.YData = m.probability;

			end % end if make-gui

		end % end manipulate 

		function m = sliderCallback(m,src,~)
			this_param = find(m.handles.control == src);
			if m.handles.log_control(this_param).Value == 1
				% we're moving in log space
				temp = src.Value; 
				% find the fractional position
				frac_pos = (temp-m.lb(this_param))/(m.ub(this_param)-m.lb(this_param));
				temp = exp(log(m.ub(this_param))*frac_pos + log(m.lb(this_param))*(1-frac_pos));
				m.parameters.(m.parameter_names{this_param}) = temp;

			else
				m.parameters.(m.parameter_names{this_param}) = src.Value;
			end

			% update the values shown in text 
			m.handles.controllabel(this_param).String = [m.parameter_names{this_param} '=',mat2str(m.parameters.(m.parameter_names{this_param}))];

			% plot the distribution 
			m.evaluate;

			m.handles.dist_plot.XData = m.x;
			m.handles.dist_plot.YData = m.probability;


		end % end sliderCallback


		function m = checkStringNum(m,value)
			assert(~isnan(str2double(value)),'Enter a real number')
		end % end checkStringNum

		function m = resetSliderBounds(m,src,~)
			checkStringNum(m,src.String);
			if any(m.handles.lbcontrol == src)
				% some lower bound being changed
				this_param = find(m.handles.lbcontrol == src);
				new_bound = str2double(src.String);
				m.lb(this_param) = new_bound;
				
				if m.handles.control(this_param).Value < new_bound
					m.handles.control(this_param).Value = new_bound;
					m.parameters.(m.parameter_names{this_param}) = new_bound;
				end
				checkBounds(m);
				m.handles.control(this_param).Min = new_bound;
			elseif any(m.handles.ubcontrol == src)
				% some upper bound being changed
				this_param = find(m.handles.ubcontrol == src);
				new_bound = str2double(src.String);
				m.ub(this_param) = new_bound;
				
				if m.handles.control(this_param).Value > new_bound
					m.handles.control(this_param).Value = new_bound;
					m.parameters.(m.parameter_names{this_param}) = new_bound;
				end
				checkBounds(m);
				m.handles.control(this_param).Max = new_bound;
			else
				error('error 142')
			end
		end % end resetSliderBounds

		function [m] = quitManipulateCallback(m,~,~)
			% destroy every object in m.handles
			d = fieldnames(m.handles);
			for i = 1:length(d)
				try
					delete(m.handles.(d{i}))
					m.handles = rmfield(m.handles,d{i});
				catch
				end
			end

		end % end quitManipulateCallback 

		function m = disableManipulateControls(m,~,~)
			try
				for i = 1:length(m.handles.control)
					m.handles.control(i).Enable = 'off';
				end
			catch
			end
		end % end disableManipulateControls

		function m = enableManipulateControls(m,~,~)
			try
				for i = 1:length(m.handles.control)
					m.handles.control(i).Enable = 'on';
				end
			catch
			end
		end % end enableManipulateControls


	end % end all methods
end	% end classdef


