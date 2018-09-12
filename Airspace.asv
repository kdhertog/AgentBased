classdef Airspace
    %Define the airspace for the aircraft
    
    properties 
        aircraft_figure_handles
        airspace_handle
        airspace_size
    end
    
    methods
        function obj = Airspace(airspace_handle, airspace_size, aircraft)
            obj.airspace_handle = airspace_handle;
            obj.airspace_size = airspace_size;
            
            plot(0,0)
            xlim([0 airspace_size(1)]);
            ylim([0 airspace_size(2)]);
            
            for i = 1:length(aircraft)
                x=[aircraft(i).position(1) aircraft(i).position(1)+1 aircraft(i).position(1)+1 aircraft(i).position(1)];
                y=[aircraft(i).position(2) aircraft(i).position(2) aircraft(i).position(2)+1 aircraft(i).position(2)+1];
                obj.aircraft_figure_handles(i) = patch(x,y,'green') ;
            end
        end
    end
end