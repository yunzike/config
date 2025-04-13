--------------------------------------------------------------------------------------
--                               Tab + h、j、k、l：左、下、上、右                      --
--                               Tab + forwarddelete：delete                        --
--                               Tab + 数字/-、+：F1 ~ F12                           --
--------------------------------------------------------------------------------------
modifierMode = hs.hotkey.modal.new()
-- 设置热键：方向键左
modifierMode:bind({}, 'h', function()
    -- 自定义一个标识，表示调用了该热键
    modifierMode.triggered = true
    -- do something
    hs.eventtap.keyStroke({}, "left")
end, nil, function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "left")
end)
-- 设置热键：方向键右
modifierMode:bind({}, 'l', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "right")
end, nil, function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "right")
end)
-- 设置热键：方向键上
modifierMode:bind({}, 'k', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "up")
end, nil, function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "up")
end)
-- 设置热键：方向键下
modifierMode:bind({}, 'j', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "down")
end, nil, function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "down")
end)
-- 设置热键：向后删除
modifierMode:bind({}, 'delete', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "forwarddelete")
end, nil, function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "forwarddelete")
end)
-- 设置热键：f1 ~ f12
modifierMode:bind({}, '1', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f1")
end)
modifierMode:bind({}, '2', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f2")
end)
modifierMode:bind({}, '3', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f3")
end)
modifierMode:bind({}, '4', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f4")
end)
modifierMode:bind({}, '5', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f5")
end)
modifierMode:bind({}, '6', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f6")
end)
modifierMode:bind({}, '7', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f7")
end)
modifierMode:bind({}, '8', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f8")
end)
modifierMode:bind({}, '9', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f9")
end)
modifierMode:bind({}, '0', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f10")
end)
modifierMode:bind({}, '-', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f11")
end)
modifierMode:bind({}, '=', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f12")
end)
modifierMode:bind({}, '7', function()
    modifierMode.triggered = true
    hs.eventtap.keyStroke({}, "f7")
end)

myModifier = hs.hotkey.bind({}, "tab", -- 按下
function()
    modifierMode.triggered = false
    -- 启用热键
    modifierMode:enter()
end, -- 抬起
function()
    -- 禁用热键
    modifierMode:exit()
    if not modifierMode.triggered then
        myModifier:disable()
        hs.eventtap.keyStroke({}, "tab")
        hs.timer.doAfter(0.1, function()
            myModifier:enable()
        end)
    end
end)


--------------------------------------------------------------------------------------
--                               "esc" 键和 "~" 键进行互换                            --
-- 不能直接使用键盘事件来触发按键，会导致死循环。可以使用 hs.eventtap 来拦截按键事件           --
--------------------------------------------------------------------------------------
local function swapKeys(event)
    -- 50 是 "~" 键的按键码, 53 是 "esc" 键的按键码
    if event:getKeyCode() == 50 then
        event:setKeyCode(53)
    elseif event:getKeyCode() == 53 then -- "esc" 键设置为 "~" 键
        event:setKeyCode(50)
    end
end
-- 拦截按键事件
local keyTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, swapKeys)
keyTap:start()