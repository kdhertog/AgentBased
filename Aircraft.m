classdef Aircraft
    
    properties
        position
        velocity
        vision
        seperation
        turncount
        heading
    end
    
    methods
        function obj = Aircraft(position_x, position_y)
            obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            % The postion of the aircraft is given in a x & y component
            % The postion is duplicated over 8 other maps which are placed
            % around the main plane. This makes it possible for individual
            % aircraft to see other aircraft which are close to the on the
            % other side of the border.
        
            
            obj.heading = (2*pi).*rand; %Aircraft are spawned with a random heading
            obj.velocity = [cos(obj.heading), sin(obj.heading)]; % The velocity vector has an x & y component
        
            obj.vision = 50; % vision of the aircraft
            obj.seperation = 20; %Min allowed seperation
            obj.turncount =0; % Property for reactive agent which makes sure that the aircraft does not turn at every tick.
            
        end
        
        function obj = reactiveturn(obj, near_aircraft)
            
            if near_aircraft == 1 
                if obj.turncount <= 0
                    obj.heading = obj.heading+pi/6; % Change the heading by 30 degrees
                    obj.velocity = [cos(obj.heading), sin(obj.heading)]; % update velocity
                    obj.turncount = 3; % The aircraft is now not allowed to turn for 3 ticks
                else
                    obj.turncount = obj.turncount - 1;
                end
            else
                obj.turncount = obj.turncount - 1;
            end
        end
        
        function obj = proactiveturn(obj, near_aircraft_list)
            near_aircraft_headings = []; %List of the relative position (angle) of the near aircraft
            for i = 1:length(near_aircraft_list) %Near_aircraft_list compasses the id's of all near aircraft
                distance_aircraft=100000;
                for j=1:length(obj.position)/2
                   distance_x_option = (obj.position(1) - near_aircraft_list(i).position(2*j-1));
                   distance_y_option = (obj.position(2) - near_aircraft_list(i).position(2*j));
                   distance_option=sqrt(distance_x_option^2+distance_y_option^2);
                            
                   if distance_option<distance_aircraft
                       distance_aircraft=distance_option;
                       distance_x = distance_x_option;
                       distance_y = distance_y_option;
                   end
                    
                end
                 
                near_aircraft_relative_position = atan2d(distance_y,distance_x) + 360*(distance_y<0); %For every near aircraft the relative position_angle gets calculated, and stored in a list
                temp=[near_aircraft_headings,near_aircraft_relative_position];
                near_aircraft_headings=temp; %In the end of the for loop, near_aircraft_headings compasses the relative positions off all near aircraft, tough they are not cooupled to a certain aircraft
                     
            end
            
            compass_divisions = 72;
            divided_compass = 360/compass_divisions;
            heading_score = [];
            for i = 1:compass_divisions
                temp1 = length(near_aircraft_headings(i*divided_compass-divided_compass <= near_aircraft_headings & near_aircraft_headings < i*divided_compass));
                temp2 = [heading_score,temp1];
                heading_score = temp2;
            end
            
%             [~, optimal_heading] = min(heading_score);
%             obj.heading = deg2rad(optimal_heading * divided_compass);
%             obj.velocity = [cos(obj.heading), sin(obj.heading)];

            [~, worst_heading] = max(heading_score);
            obj.heading = worst_heading * divided_compass + 180;
            obj.velocity = [cos(obj.heading), sin(obj.heading)];
            
%             disp(obj.position)
%             disp(heading_score)
%             disp(optimal_heading)
%             disp(" ")
%             disp(" ")
            
            
        end
               
        function obj = update(obj)
           position_x = obj.position(1) + obj.velocity(1); %Add the velocity in x direction to the x coordinate
           position_y = obj.position(2) + obj.velocity(2); %Add the velocity in x direction to the x coordinate
           obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
           % Create the position vector again for all of the maps around the main map 
        end
        
        function obj = borders(obj, airspace_size)
            if obj.position(1) < 0 %transfer the aircraft to the right side of the map
                position_x = obj.position(1)+airspace_size;
                position_y = obj.position(2);
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            end
            
            if obj.position(2) < 0 %transfer the aircraft to the top side of the map
                position_x = obj.position(1);
                position_y = obj.position(2)+airspace_size;
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            end
            
            if obj.position(1) > airspace_size %transfer the aircraft to the left side of the map
                position_x = obj.position(1)-airspace_size;
                position_y = obj.position(2);
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            end
            
            if obj.position(2) > airspace_size %transfer the aircraft to the bottom side of the map
                position_x = obj.position(1);
                position_y = obj.position(2)-airspace_size;
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x+200, position_y-200];
            end 
            
        end
        
    end 
    
end
           