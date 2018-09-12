classdef Aircraft
    
    properties
        position
        velocity
        vision
        seperation 
    end
    
    methods
        function obj = Aircraft(position_x, position_y)
            obj.position = [ position_x, position_y, position_x-200., position_y+200, position_x, position_y+200, position_x+200, position_y+200, position_x-200, position_y, position_x+200, position_y, position_x-200, position_y-200, position_x, position_y-200, position_x-200, position_y-200];
            
            %[position_x, position_y]
            %OR check for other borders
            %[[position_x, position_y] [position_x-200., position_y+200]
            %[position_x, position_y+200] [position_x+200, position_y+200] [position_x-200,
            %position_y] [position_x+200, position_y] [position_x-200, position_y-200]
            %[position_x, position_y-200] [position_x-200, position_y-200]]
            
            angle = (2*pi).*rand;
            obj.velocity = [cos(angle), sin(angle)];
        
            obj.vision = 50;
            obj.seperation = 20;
            
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
           