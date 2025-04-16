local hyperKey = {'shift', 'alt', 'ctrl', 'cmd'}




-- url encode 和decode函数
function urlEncode(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end
function urlDecode(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

--------------------------------------------------------------------------------------
--                                        Send key                                  --
--------------------------------------------------------------------------------------
-- 触发指定的键 a，例如方向键左为 left
function sendKey(a)
    return function()
        hs.eventtap.keyStroke({}, a)
    end
end

-- 下一个标签页
function nextTab()
    hs.eventtap.keyStroke({"cmd", "shift"}, ']')
end
-- 上一个标签页
function prevTab()
    hs.eventtap.keyStroke({"cmd", "shift"}, '[')
end

--------------------------------------------------------------------------------------
--                                        窗口管理                                   --
--------------------------------------------------------------------------------------
-- 移动当前窗口
function moveFocusedWindow(mode)
    return function()
        local win = hs.window.focusedWindow()
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()

        if mode == "Edge Left" then
            f.x = max.x
            f.y = 0
        end
        if mode == "Edge Right" then
            f.x = max.x + (max.w - f.w)
            f.y = 0
        end
        if mode == "Center" then
            f.x = max.x + (max.w - f.w) / 2
            f.y = max.y + (max.h - f.h) * (1-0.618)
            f.x = f.x > 0 and f.x or 0
            f.y = f.y > 0 and f.y or 0
        end

        win:setFrame(f, 0) -- 0 取消动画
    end
end

-- 隐藏当前窗口
function hideFocusedWindow()
    hs.application.frontmostApplication():hide()
end

--------------------------------------------------------------------------------------
--                                 多屏管理                                          --
--------------------------------------------------------------------------------------

-- 在屏幕间移动光标
function moveCursorBetweenDesktops()
    local screen = hs.mouse.getCurrentScreen()
    local nextScreen = screen:next()
    local rect = nextScreen:fullFrame()
    local center = hs.geometry.rectMidPoint(rect)
  
    hs.mouse.absolutePosition(center)
    hs.alert.show('🐶', nextScreen)
    -- hs.alert.show('🐻‍❄️🦮🐶🦅🐘🦁', nextScreen)

    -- -- 以下为方式2
    -- -- get the focused window
    -- local win = hs.window.focusedWindow()
    -- -- get the screen where the focused window is displayed, a.k.a. current screen
    -- local screen = win:screen()
    -- -- compute the unitRect of the focused window relative to the current screen
    -- -- and move the window to the next screen setting the same unitRect 
    -- win:move(win:frame():toUnitRect(screen:frame()), screen:next(), true, 0)
end

-- 在屏幕间移动程序，并保持位置和比例一致
function moveWindowToNextScreen()
    local win = hs.window.focusedWindow()  -- 获取当前焦点窗口
    local nextScreen = win:screen():next()  -- 获取下一个屏幕

    local currentFrame = win:frame()  -- 获取当前窗口位置和大小
    local currentScreenFrame = win:screen():frame()  -- 获取当前屏幕大小
    local nextScreenFrame = nextScreen:frame()  -- 获取下一个屏幕大小

    -- 计算位置和比例
    local xRatio = (currentFrame.x - currentScreenFrame.x) / currentScreenFrame.w
    local yRatio = (currentFrame.y - currentScreenFrame.y) / currentScreenFrame.h
    local widthRatio = currentFrame.w / currentScreenFrame.w
    local heightRatio = currentFrame.h / currentScreenFrame.h

    -- 计算新位置和大小
    local newX = nextScreenFrame.x + xRatio * nextScreenFrame.w
    local newY = nextScreenFrame.y + yRatio * nextScreenFrame.h
    local newWidth = widthRatio * nextScreenFrame.w
    local newHeight = heightRatio * nextScreenFrame.h

    -- 将窗口移动到下一个屏幕并设置新位置和大小
    win:moveToScreen(nextScreen)
    win:setFrame({x = newX, y = newY, w = newWidth, h = newHeight})
end

--------------------------------------------------------------------------------------
--                                        蓝牙管理                                   --
--------------------------------------------------------------------------------------
-- 去掉字符串后面的空白字符
function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- 打开与关闭蓝牙，需要安装蓝牙工具 brew install blueutil
function toggleBlueTooth()
    -- 打开或关闭蓝牙
    hs.execute("/opt/homebrew/bin/blueutil -p toggle")

    -- 检查蓝牙状态
    local state = trim(hs.execute("/opt/homebrew/bin/blueutil -p"))

    if state == "1" then
        hs.alert.show("蓝牙已打开")
    else
        hs.alert.show("蓝牙已关闭")
    end
end

-- 系统事件监听回调函数，事件类型可参考 https://www.hammerspoon.org/docs/hs.caffeinate.watcher.html
-- 系统休眠时关闭蓝牙: https://gist.github.com/ysimonson/fea48ee8a68ed2cbac12473e87134f58
function watchCallback(event)
    -- 18 点后休眠时才自动关闭蓝牙
    local hour = os.date("*t").hour
    if event == hs.caffeinate.watcher.systemWillSleep and hour >= 18 then
        hs.execute("/opt/homebrew/bin/blueutil -p 0")
    end
end

watcher = hs.caffeinate.watcher.new(watchCallback)
watcher:start()

--------------------------------------------------------------------------------------
--                                          Misc                                    --
--------------------------------------------------------------------------------------

-- 显示当前时间
function showTime()
    local weekdays = {"周一", "周二", "周三", "周四", "周五", "周六", "周日"}
    local weekday = tonumber(os.date("%w"))
    local t = os.date(weekdays[weekday] .. "  %H 点 %M")
    hs.alert.show(t)
end


--------------------------------------------------------------------------------------
--                                        快捷键绑定                                  --
--------------------------------------------------------------------------------------
-- 显示 Finder
function activateFinder()
    -- 如果没有 Finder 窗口打开，则返回 nil
    local focusedFinder = hs.application.get("com.apple.finder"):focusedWindow()

    if (focusedFinder == nil) then
        -- 创建 Finder 窗口并让其获得焦点
        hs.application.launchOrFocus("finder")
    else
        -- 打开的 Finder 窗口获得焦点
        hs.application.get("com.apple.finder"):setFrontmost(true)
    end
end

-- 按下 "option+键" 会打开或激活对应的应用，如果应用不是绝对路径，则指的是 /Applications 中的应用 --
function openAppUsingAltAndkey(keyAppPairs)
    for key, app in pairs(keyAppPairs) do
        -- local app = entry[2]
        -- local key = entry[1]

        -- 路径不以 / 开头，则指的是 /Applications 中的应用，把路径补充完整
        if string.sub(app, 0, 1) ~= "/" then
            app = "/Applications/" .. app
        end

        -- hs.alert.show(app)

        hs.hotkey.bind({"option"}, key .. "", function()
            hs.application.open(app)

            -- 解决某些应用 x 全屏的时候 (如 Safari)，切换到桌面 n，当前应用仍然为应用 x，按下激活应用 x 的快捷键不生效的问题
            hs.application.frontmostApplication():setFrontmost(true)
        end)
    end
end

-- 键和应用对
-- 按下 option+对应的键切换程序，例如按 option+e 启动或激活 edge
-- 提示: 数字作为键，需要使用 [Number] 的格式
local KEY_APP_PAIRS = {
    E = "Microsoft Edge.app",
    W = "WeChat.app",
    I = "IntelliJ IDEA.app",
    V = "Visual Studio Code.app",
    N = "Navicat Premium.app",
    T = "iTerm.app",
    Q = "企业微信.app",
    O = "Obsidian.app",
    
    [1] = "Listen1.app",
}
openAppUsingAltAndkey(KEY_APP_PAIRS) 
hs.hotkey.bind({"option"}, "f", activateFinder)               -- 显示 Finder

--------------------------------------------------------------------------------------
--                                    其他操作                                       --
--------------------------------------------------------------------------------------

-- 隐藏/显示桌面文件
function toggleDesktopFiles()
    -- 找到可见文件个数，如果可见文件数为 0 则说明文件都隐藏了或者没有文件执行显示操作，否则隐藏
    script = [[
        n=$(ls -lO ~/Desktop | grep -v hidden | grep -v total | wc -l | xargs);
        [ $n -eq '0' ] && chflags nohidden ~/Desktop/* || chflags hidden ~/Desktop/*
    ]]
    hs.execute(script)
end

-- 切换 Light 和 Dark 模式
function toggleDarkAnLight()
    script = [[
        tell application "System Events"
            tell appearance preferences
                set dark mode to not dark mode
            end tell
        end tell
    ]]
    hs.osascript.applescript(script)
end

-- 窗口管理
hs.hotkey.bind(hyperKey, 'a', function() hs.window.focusedWindow():moveToUnit({0, 0, 0.5, 1}) end)      -- 左半屏
hs.hotkey.bind(hyperKey, 'd', function() hs.window.focusedWindow():moveToUnit({0.5, 0, 0.5, 1}) end)    -- 右半屏
hs.hotkey.bind(hyperKey, 'w', function() hs.window.focusedWindow():moveToUnit({0, 0, 1, 0.5}) end)      -- 上半屏
hs.hotkey.bind(hyperKey, 's', function() hs.window.focusedWindow():moveToUnit({0, 0.5, 1, 0.5}) end)    -- 下半屏
hs.hotkey.bind(hyperKey, "c", moveFocusedWindow("Center"))                                              -- 窗口居中
hs.hotkey.bind(hyperKey, "z", function() hs.window.focusedWindow():toggleZoom() end)                    -- 窗口最大化/还原（zoom模式）
hs.hotkey.bind(hyperKey, "x", hideFocusedWindow)                                                        -- 隐藏当前窗口
local savedWindowFrames = {}
-- 将当前窗口移动到屏幕左上角并全屏
hs.hotkey.bind(hyperKey, 'f', function()
    local win = hs.window.focusedWindow()
    savedWindowFrames[win:id()] = win:frame()
    win:moveToUnit({0, 0, 1, 1})
end)
-- 恢复窗口到之前保存的位置和大小
hs.hotkey.bind(hyperKey, 'r', function()
    local win = hs.window.focusedWindow()
    local winId = win:id()
    if savedWindowFrames[winId] then    
        win:setFrame(savedWindowFrames[winId])
        savedWindowFrames[winId] = nil
    end
end)

-- 切换到下一个窗口
hs.hotkey.bind({"option"}, "tab", function() hs.window.switcher.nextWindow() end)
-- 切换到上一个窗口
hs.hotkey.bind({"option", "shift"}, "tab", function() hs.window.switcher.previousWindow() end)
--标签页切换
hs.hotkey.bind(hyperKey,  "h", prevTab)                          -- 上一个标签页
hs.hotkey.bind(hyperKey,  "l", nextTab)                          -- 下一个标签页

-- 多屏管理
hs.hotkey.bind(hyperKey, "n", moveWindowToNextScreen)            -- 在屏幕间移动程序
hs.hotkey.bind(hyperKey, "m", moveCursorBetweenDesktops)         -- 在屏幕间移动光标

-- 百度搜索
hs.hotkey.bind(hyperKey, "1", function()
    -- local clipboardText = tostring(hs.pasteboard.getContents())
    -- print("what is in the clipboard?:a"..clipboardText)
    -- hs.notify.new({title="百度搜索", informativeText=clipboardText}):send()
    local clipboardText = current_selection()
    hs.urlevent.openURL("https://www.baidu.com/s?wd="..urlEncode(clipboardText)) 
    -- hs.urlevent.openURL("https://www.google.com/search?q="..urlEncode(clipboardText)) 
end)