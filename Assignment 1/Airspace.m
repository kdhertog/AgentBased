classdef Airspace
    %Define the airspace for the aircraft
    
    properties 
        aircraft_figure_handles
        airspace_handle
        airspace_size
    end
    
    methods
        function obj = Airspace(airspace_handle, airspace_size, aircraft)
            obj.airspace_handle = airspace_handle; % Import the figure
            obj.airspace_size = airspace_size; %Import size of the airspace
            
            plot(0,0)
            xlim([0 airspace_size(1)]); % Set the size of the map
            ylim([0 airspace_size(2)]); 
            
            for i = 1:length(aircraft)                
                %Drawing circels
                t = linspace(0, 2*pi);
                r1 = aircraft.seperation;
                x1 = aircraft(i).position(1)+0.5*r1*cos(t);
                y1 = aircraft(i).position(2)+0.5*r1*sin(t);
                

                obj.aircraft_figure_handles(i) = patch(x1,y1,'red'); 
                % A circle with a radius of half the allowed seperation is
                % drawn around each aircraft. If two circles collide this
                % is counted as a conflict. 
            end
            alpha(0.3) % Transparency of the circles.
        end
    end
end