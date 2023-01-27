classdef PathwayState
  properties
      Code
      State
   end
   methods
      function c = PathwayState(code)
         c.Code = code;
         c.State = state(code);
      end
   end
   
   methods (Static)
       function State = state(code)
           switch code
               case 0
                   State = 'IDLE'; 
               case 1
                   State = 'READY'; 
               case 2
                   State = 'TEST'; 
           end
       end
   end
   
end

