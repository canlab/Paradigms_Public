function t(varargin)

a = 5;

cleanupobj = onCleanup(@() save('crashsave'));

while 1
    pause(1);
end

end