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
%                 x=[aircraft(i).position(1) aircraft(i).position(1)+1 aircraft(i).position(1)+1 aircraft(i).position(1)];
%                 y=[aircraft(i).position(2) aircraft(i).position(2) aircraft(i).position(2)+1 aircraft(i).position(2)+1];
                
                %Drawing circels
                t = linspace(0, 2*pi);
                r1 = aircraft.seperation;
                x1 = aircraft(i).position(1)+0.5*r1*cos(t);
                y1 = aircraft(i).position(2)+0.5*r1*sin(t);
                

                obj.aircraft_figure_handles(i) = patch(x1,y1,'red');
%                 obj.aircraft_figure_handles(i) = patch(x,y,'green') ;
            end
            alpha(0.3)
        end
    end
end