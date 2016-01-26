classdef View_plot < View_base
    properties (Access = protected)
        x_prop_name;
        y_prop_name;
        hline;
    end

    methods
        function obj = View_plot(hobj, model, xy_prop_name)
            [x_prop_name, y_prop_name] = View_plot.split_input(xy_prop_name);

            obj@View_base(hobj, model);

            obj.x_prop_name = x_prop_name;
            obj.y_prop_name = y_prop_name;

            obj.init_plot();
            obj.init_listeners();
        end
    end

    methods (Access = private)
        function init_plot(obj)
            axes(obj.hobj);
            obj.hline = plot(0,0);
        end

        function init_listeners(obj)
            addlistener(obj.model, obj.x_prop_name, 'PostSet', @obj.on_x_change);
            addlistener(obj.model, obj.y_prop_name, 'PostSet', @obj.on_y_change);
        end

        function on_x_change(obj, ~, ~)
            obj.hline.XData = obj.model.(obj.x_prop_name);
        end

        function on_y_change(obj, ~, ~)
            obj.hline.YData = obj.model.(obj.y_prop_name);
        end
    end

    methods (Static)
        function [x, y] = split_input(str)
            c = strsplit(str, ', ');
            x = c(1);
            y = c(2);
        end
    end
end
