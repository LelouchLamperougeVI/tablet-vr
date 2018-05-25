% Container
% Facilitate data exchange from event listeners.
% Container methods:
%   set - Set or update dynamic properties in the container object.

% 2016-05-12. Leonardo Molina.
% 2018-05-09. Last modified.
classdef Container < dynamicprops & event.EventData
    methods
        function obj = Container(varargin)
            % Container(key1, value1, key2, value2, ...)
            % Returns a Container object.
            % Set dynamic properties in the container object.
            %
            % Example: 
            %   container = Container('tag1', 1, ...)
            %   container.tag1 %==> 1
            % 
            % See also Container.set.
            obj.set(varargin{:});
        end
        
        function set(obj, varargin)
            % Container.set(key1, value1, key2, value2, ...)
            % Set dynamic properties in the container object, if a property
            % already exists, modify its value.
            % 
            % Example:
            %   container = Container();
            %   container.set('tag1', 1, 'tag2', 1:5, 'anotherTag', {'Hello', 123});
            %   container.tag1 %==> 1
            % 
            %  MyClass.m:
            %     classdef MyClass < handle
            %         events
            %             MessageReceived;
            %         end
            % 
            %         methods
            %             function call(obj)
            %                 notify(obj, 'MessageReceived', Container('Message', 'Hello world'));
            %             end
            %         end
            %     end
            % 
            %  test.m:
            %     function test()
            %         myObject = MyClass();
            %         addlistener(myObject, 'MessageReceived', @printMessage);
            %         myObject.call();
            %     end
            % 
            %     function printMessage(container)
            %         disp(container.Message);
            %     end
            %  
            %  test();
            n = numel(varargin);
            for i = 1:2:n
                if ~isprop(obj, varargin{i})
                    obj.addprop(varargin{i});
                end
                obj.(varargin{i}) = varargin{i + 1};
            end
        end
    end
    
    % Hide methods inherited from dynamicprops.
    methods (Hidden)
        function lh = addlistener(varargin)
            lh = addlistener@dynamicprops(varargin{:});
        end
        function notify(varargin)
            notify@dynamicprops(varargin{:});
        end
        function delete(varargin)
            delete@dynamicprops(varargin{:});
        end
        function Hmatch = findobj(varargin)
            Hmatch = findobj@dynamicprops(varargin{:});
        end
        function p = findprop(varargin)
            p = findprop@dynamicprops(varargin{:});
        end
        function TF = eq(varargin)
            TF = eq@handle(varargin{:});
        end
        function TF = ne(varargin)
            TF = ne@handle(varargin{:});
        end
        function TF = lt(varargin)
            TF = lt@handle(varargin{:});
        end
        function TF = le(varargin)
            TF = le@handle(varargin{:});
        end
        function TF = gt(varargin)
            TF = gt@handle(varargin{:});
        end
        function TF = ge(varargin)
            TF = ge@handle(varargin{:});
        end
        function p = addprop(varargin)
            p = addprop@dynamicprops(varargin{:});
        end
    end
end