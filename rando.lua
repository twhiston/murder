function init()
    -- input[1].mode( 'change', threshold, hysteresis, direction )
    input[1].mode('change', 10., 0.001, 'both')
    input[2].mode('stream', 0.2)

    -- slew in seconds
    output[1].slew  = 0.001
    output[2].slew  = 0.3
    output[3].slew  = 3
    output[4].slew  = 0.001

    -- slew in ms
    ii.er301.cv_slew(1, 1)
    ii.er301.cv_slew(2, 300)
    ii.er301.cv_slew(3, 3000)
    ii.er301.cv_slew(4, 1)
    print('clocked random')
end

input[1].change = function(state)
    -- bipolar scaled output
    local out1 = math.random() * 10 - 5
    --print(out1)
    for i=1,3 do
        output[i].volts = out1
        ii.er301.cv(i,out1)
    end

    if state then 
        output[4].volts = 5
        ii.er301.tr(1, 5)
    else
        output[4].volts = 0
        ii.er301.tr(1, 0)
    end
end   


local oldvolt = 0;
local smoothing = 0.1
input[2].stream = function(volts)
    -- expects 0 - 10 volts from frames
    if volts >= (oldvolt + smoothing) then
        doNewTimings(volts)
    elseif volts <= (oldvolt - smoothing) then
        doNewTimings(volts)
    end
end

function doNewTimings(volts)

    local a = {}
    -- as input will never be higher than 10 we can limit it like this
    local random = math.random() * volts
    for i=1,3 do
        local randoMult = math.random() * volts * 10 * i
        local val = volts * randoMult
        table.insert(a, val)
    end
    table.sort(a)
    for i=1,3 do
        output[i].slew = a[i] -- in s
        ii.er301.cv_slew(i,a[i]*1000) -- in ms
    end
    oldvolt = volts
end