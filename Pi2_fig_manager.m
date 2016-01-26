classdef Pi2_fig_manager < handle
    properties (Access = private)
        model;
        fig;
    end
    
    methods
        function obj = Pi2_fig_manager()
            obj.fig = openfig('Pi2.fig');
        end
    end 
end
