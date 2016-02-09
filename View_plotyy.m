classdef View_plotyy < View_plot
    properties (Access = protected)
        x2_prop_name;
        y2_prop_name;

        hline2;

        haxes;
    end

    methods
        function obj = View_plotyy(hobj, model, xy1_xy2_prop_name)
            [x1_prop_name, y1_prop_name, x2_prop_name, y2_prop_name] = View_plotyy.split_input(xy1_xy2_prop_name);
            xy1_prop_name = [x1_prop_name, ', ', y1_prop_name];

            obj@View_plot(hobj, model, xy1_prop_name);

            obj.x2_prop_name = x2_prop_name;
            obj.y2_prop_name = y2_prop_name;

            obj.init_plot();
            obj.init_listeners();
        end
    end

    methods (Access = private)
        function init_plot(obj)
            axes(obj.hobj);
            hold off;
            [obj.haxes, obj.hline, obj.hline2] = plotyy(0, 0, 0, 0);
            hold on;

            arrayfun(@View_plotyy.setup_axes, obj.haxes);
        end

        function init_listeners(obj)           
            addlistener(obj.model, obj.x2_prop_name, 'PostSet', @obj.on_x2_change);
            addlistener(obj.model, obj.y2_prop_name, 'PostSet', @obj.on_y2_change);
        end

        function on_x2_change(obj, ~, ~)
            obj.hline2.XData = obj.model.(obj.x2_prop_name);
        end

        function on_y2_change(obj, ~, ~)
            obj.hline2.YData = obj.model.(obj.y2_prop_name);
        end
    end

    methods (Static)
        function setup_axes(h)
            h.XLimMode = 'auto';

            h.YLimMode = 'auto';
            h.YTickMode = 'auto';
        end

        function [x1, y1, x2, y2] = split_input(str)
            c = strsplit(str, ', ');
            x1 = c{1};
            y1 = c{2};
            x2 = c{3};
            y2 = c{4};
        end
    end
end
