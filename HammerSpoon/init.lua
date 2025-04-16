local hyperKey = {'shift', 'alt', 'ctrl', 'cmd'}

require('windows')

hs.loadSpoon("PopupTranslateSelection")
hs.hotkey.bind(hyperKey, '1', function() spoon.PopupTranslateSelection:translateSelectionPopup() end)

-- 自动重新加载config
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")
