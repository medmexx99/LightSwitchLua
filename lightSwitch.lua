function switchLights(payload)
    for k,v in pairs(payload) do
        print(k)
        print(v)
        if k == "light1" then
           if v == "ON" then
              gpio.write(led1Pin, gpio.HIGH)
              led1State = gpio.HIGH
           elseif v == "OFF" then
              gpio.write(led1Pin, 0)
              led1State = 0
           end
        elseif k == "light2" then
           if v == "ON" then
              gpio.write(led2Pin, gpio.HIGH)
              led2State = gpio.HIGH
           elseif v == "OFF" then
              gpio.write(led2Pin, 0)
              led2State = 0
           end
        end
    end
    return getLightStatus()
end
function getLightStatus() 
    responseStr = "{\"status\":"
    responseStr = responseStr .. "{\"light1\":" .. (gpio.read(led1Pin) == gpio.HIGH and "\"ON\"" or "\"OFF\"")
    responseStr = responseStr .. ",\"light2\":" .. (gpio.read(led2Pin) == gpio.HIGH and "\"ON\"" or "\"OFF\"") .. "}"
    responseStr = responseStr .. "}"
    return responseStr
end
print(wifi.sta.getip())
wifi.setmode(wifi.STATION)
wifi.sta.config("Belkin.5BDA","E43C23BF")
wifi.sta.setip({ip="192.168.0.150",netmask="255.255.255.0",gateway="192.168.0.1"})
print(wifi.sta.getip())
led1Pin = 1
led2Pin = 2
led1State = 0
led2State = 0
gpio.mode(led1Pin,gpio.OUTPUT)
gpio.mode(led2Pin,gpio.OUTPUT)
gpio.write(led1Pin,gpio.HIGH)
gpio.write(led2Pin,gpio.HIGH)
srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn,payload) 
    print(payload)
    data = cjson.decode(payload)
    for k,v in pairs(data) do
        if k == "requestStatus" then
            response = getLightStatus()
        elseif k == "switchLights" then
            switchLights(v)
            response = getLightStatus()
        end
    end
    conn:send(response)
    conn:close()
    end) 
end)
