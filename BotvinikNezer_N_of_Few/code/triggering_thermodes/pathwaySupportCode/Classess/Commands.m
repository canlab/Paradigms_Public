classdef Commands
  properties
      Code
      Id
   end
   methods
      function c = Commands(code)
         c.Code = code;
         c.Id = commandid(code);
      end
   end
   
   methods (Static)
       function id = commandid(code)
           switch code
               case 0
                   id = 'STATUS'; 
               case 1
                   id = 'TEST_PROGRAM'; 
               case 2
                   id = 'START'; 
               case 3
                   id = 'PAUSE'; 
               case 4
                   id = 'TRIGGER'; 
               case 5
                   id = 'STOP'; 
               case 6
                   id = 'ABORT'; 
               case 7
                   id = 'YES'; 
               case 8
                   id = 'NO'; 
           end
       end
   end
   
end

