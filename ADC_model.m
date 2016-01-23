classdef ADC_model < handle
    properties(Access = private, Constant)
        SPREAD = 10;
        FREQ = 102400;
    end

    properties(Access = private)
        freq;
        listeners;
    end

    properties (SetObservable)
        dir_path;

        X, X_filth, X_filter;
        Y, Y_filth, Y_filter;
        P, P_filth, P_filter;
        T;

        S;

        model_lenght;
        t_0;
        t_1;

        phi;
        L;
        u;

        K_phi;
    end

    properties(Dependent, SetObservable)
        dP;
        G;
        T_diff;
    end

    events
        on_filter_XY;
    end

    methods
        function obj = ADC_model()
            obj.freq = obj.FREQ / obj.SPREAD;
        end

        function obj = set.dP(obj,~)
        end

        function val = get.dP(obj)
            val = diff(obj.P) .* obj.freq;
        end

        function obj = set.G(obj,G)
            obj.X = real(G);
            obj.Y = imag(G);
        end

        function val = get.G(obj)
            val = complex(obj.X, obj.Y);
        end

        function obj = set.T_diff(obj,~)
        end

        function val = get.T_diff(obj)
            val = obj.T(1:end-1);
        end

        function load(obj, filename, pathname)
            obj.reset();

            obj.dir_path = pathname;

            filename = fullfile(pathname, filename);
            M = dlmread(filename, '', 1, 0);

            obj.T       = M(1:obj.SPREAD:end, 1);            
            obj.X_filth = M(1:obj.SPREAD:end, 2);
            obj.Y_filth = M(1:obj.SPREAD:end, 3);
            obj.P_filth = M(1:obj.SPREAD:end, 4);

            obj.X_filter = obj.X_filth;
            obj.Y_filter = obj.Y_filth;
            obj.P_filter = obj.P_filth;

            obj.X = obj.X_filter;
            obj.Y = obj.Y_filter;
            obj.P = obj.P_filter;

            obj.t_0 = obj.T(1);
            obj.t_1 = obj.T(end);

            obj.on_load();
        end
    end

    methods(Access = private)
        function listener_filter(obj, src, ~)
            field = strrep(src.Name, '_filter', '');
            obj.(field) = obj.(src.Name);

            if strcmp(field, 'X') || strcmp(field, 'Y')
                notify(obj, 'on_filter_XY');
            end
        end

        function listener_G(obj, ~, ~)
            obj.phi = unwrap(angle(obj.G));
        end

        function listener_phi(obj, ~, ~)
            sample_0 = int64(obj.t_0 * obj.freq) + 1;
            sample_1 = int64(obj.t_1 * obj.freq);

            phi_0 = obj.phi(sample_0);
            phi_1 = obj.phi(sample_1);

            obj.K_phi = obj.model_lenght / abs(phi_0 - phi_1);
        end

        function listener_K_phi(obj, ~, ~)
            obj.L = obj.phi .* obj.K_phi;
        end

        function listener_L(obj, ~, ~)
            obj.u = diff(obj.L) .* obj.freq;
        end

        function listener_S(obj, ~, ~)
            temp_G = complex(obj.X_filter, obj.Y_filter);
            obj.G = restore_G2(temp_G, obj.S);
        end

        function listener_P(obj, ~, ~)
            obj.notify_dP();
        end

        function notify_dP(obj)
            obj.dP = 1;
        end

        function notify_T_diff(obj)
            obj.T_diff = 1;
        end

        function on_load(obj)
            obj.fill_listeners();

            obj.notify_T_diff();
            obj.notify_dP();

            notify(obj, 'on_filter_XY');
        end

        function add_listener(obj, lh)
            obj.listeners = [obj.listeners lh];
        end

        function fill_listeners(obj)
            obj.add_listener(addlistener(obj, 'X_filter', 'PostSet', @obj.listener_filter));
            obj.add_listener(addlistener(obj, 'Y_filter', 'PostSet', @obj.listener_filter));
            obj.add_listener(addlistener(obj, 'P_filter', 'PostSet', @obj.listener_filter));

            obj.add_listener(addlistener(obj, 'on_filter_XY', @obj.listener_G));

            obj.add_listener(addlistener(obj, 'G', 'PostSet', @obj.listener_G));
            obj.add_listener(addlistener(obj, 'P', 'PostSet', @obj.listener_P));

            obj.add_listener(addlistener(obj, 'phi', 'PostSet', @obj.listener_phi));
            obj.add_listener(addlistener(obj, 'K_phi', 'PostSet', @obj.listener_K_phi));
            obj.add_listener(addlistener(obj, 'L', 'PostSet', @obj.listener_L));

            obj.add_listener(addlistener(obj, 't_0', 'PostSet', @obj.listener_phi));
            obj.add_listener(addlistener(obj, 't_1', 'PostSet', @obj.listener_phi));
            obj.add_listener(addlistener(obj, 'model_lenght', 'PostSet', @obj.listener_phi));

            obj.add_listener(addlistener(obj, 'S', 'PostSet', @obj.listener_S));
        end

        function remove_listeners(obj)
            delete(obj.listeners);
            obj.listeners = [event.proplistener.empty];
        end

        function reset(obj)
            obj.remove_listeners();

            obj.S = [
                complex(0), complex(1, 0);
                complex(1, 0), complex(0, 0)
            ];
            obj.model_lenght = 38;
        end
    end
end
