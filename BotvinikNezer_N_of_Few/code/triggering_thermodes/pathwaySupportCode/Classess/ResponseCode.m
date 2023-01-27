classdef ResponseCode
  properties
      Code
      ResponseId = '';
   end
   methods
      function rc = Commands(code)
         rc.Code = uint16(code);
         rc.ResponseId = responseid(code);
      end
   end
   
  methods (Static)
      function responseId = responseid(code)
           switch code
               case 0
                   responseId = 'RESULT_OK';
               case 1
                   responseId = 'RESULT_ILLEGAL_ARG';
               case 2
                   responseId = 'RESULT_ILLEGAL_STATE';
               case 3
                   responseId = 'RESULT_ILLEGAL_TEST_STATE';
               case 4096
                   responseId = 'RESULT_DEVICE_COMM_ERROR';
               case 8192
                   responseId = 'RESULT_SAFETY_WARNING';
               case 16384
                   responseId = 'RESULT_SAFETY_ERROR';
               case 12288
                   responseId = 'Wait_Manual_Operation';
               otherwise
                   responseId = "UNKNOWN";
           end
       end
  end
end