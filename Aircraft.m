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
            
            %[position_x, position_y]
            %OR check for other borders
            %[[position_x, position_y] [position_x-200., position_y+200]
            %[position_x, position_y+200] [position_x+200, position_y+200] [position_x-200,
            %position_y] [position_x+200, position_y] [position_x-200, position_y-200]
            %[position_x, position_y-200] [position_x-200, position_y-200]]
            
            obj.heading = (2*pi).*rand;
            obj.velocity = [cos(obj.heading), sin(obj.heading)];
        
            obj.vision = 50;
            obj.seperation = 20;
            
        end
        
        function obj = reactiveturn(obj, near_aircraft)
            if (near_aircraft) && (obj.turncount <= 0)
                
                obj.heading = obj.heading + pi/6;
                obj.velocity = [cos(obj.heading), sin(obj.heading)];
                obj.turncount = 10;
            
            else %Either their are no aircraft nearby, or the aircraft turned recently
                
                obj.turncount = obj.turncount - 1;
                
            end
            
        end
        
%         function obj = proactiveturn(obj, near_aircraft_list)
%             
%             for i = 1:length(near_aircraft_list)
%                 
%                 near_aircraft_relative_postition = %relative position of the near aircraft (0 - 2pi)
%                 %positionlist.append(near_aircraft_relative_postition)
%                     
%             end
%             
            %For each 5 degrees of heading count the amount of aircraft and their distace
            %Assign a heading score for each aircraft
            %Change heading to heading with the best heading score
          
        end
               
        function obj = update(obj)
           position_x = obj.position(1) + obj.velocity(1);
           position_y = obj.position(2) + obj.velocity(2);
           obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x-200, position_y-200];
            
        end
        
        function obj = borders(obj, airspace_size)
            if obj.position(1) < 0
                position_x = obj.position(1)+airspace_size;
                position_y = obj.position(2);
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x-200, position_y-200];
            end
            
            if obj.position(2) < 0
                position_x = obj.position(1);
                position_y = obj.position(2)+airspace_size;
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x-200, position_y-200];
            end
            
            if obj.position(1) > airspace_size
                position_x = obj.position(1)-airspace_size;
                position_y = obj.position(2);
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x-200, position_y-200];
            end
            
            if obj.position(2) > airspace_size
                position_x = obj.position(1);
                position_y = obj.position(2)-airspace_size;
                obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x-200, position_y-200];
            end 
            
        end
        
    end 
    
end
           