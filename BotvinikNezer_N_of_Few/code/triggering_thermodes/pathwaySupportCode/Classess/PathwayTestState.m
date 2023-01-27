classdef PathwayTestState
  properties
      Code
      TestState
   end
   methods
      function c = PathwayTestState(code)
         c.Code = code;
         c.TestState = teststate(code);
      end
   end
   
   methods (Static)
       function TestState = teststate(code)
           switch code
               case 0
                   TestState = 'IDLE'; 
               case 1
                   TestState = 'RUNNING'; 
               case 2
                   TestState = 'PAUSED'; 
               case 3
                   TestState = 'READY';
           end
       end
   end
   
end

