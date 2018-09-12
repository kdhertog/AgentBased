classdef Manouvre

    properties
        aircraft
        airspace_size
        step_counter=1;
        max_step=100;
    end
    
    methods
        
        function obj = Manouvre(aircraft, airspace_size)
            obj.aircraft=aircraft;
            obj.airspace_size=airspace_size;
        end
        
        function run(obj, airspace)
            while true
                obj = update_aircraft(obj);
                obj = borders(obj);
                
                [obj,airspace] = render(obj,airspace);
                obj.step_counter=obj.step_counter+1;
                if obj.step_counter >= obj.max_step
                    1
                    break
                end
            end
        end
        
        function obj = update_aircraft(obj)
            for i=1:length(obj.aircraft)
                obj.aircraft(i)=obj.aircraft(i).update();
            end
        end
        
        function obj = borders(obj)
            for i=1:length(obj.aircraft)
                obj.aircraft(i)=obj.aircraft.borders(obj.airspace_size);
            end
        end
        
        function [obj,airspace] = render(obj,airspace)
           for i=1:lengt(obj.aircraft)
               delete(airspace.aircraft_figure_handles(i));
               x=[obj.aircraft(i).position(1) obj.aircraft(i).position(1)+1 obj.aircraft(i).position(1)+1 obj.aircraft(i).position(1)];
               y=[obj.aircraft(i).position(2) obj.aircraft(i).position(2) obj.aircraft(i).position(2)+1 obj.aircraft(i).position(2)+1];
               obj.aircraft_figure_handles(i) = patch(x,y,'green') ;
           end
           drawnow;
            
        end
        
        
    end  
end
