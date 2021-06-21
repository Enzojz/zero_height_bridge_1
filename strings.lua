local descEN = [[This mod helps you building bridges everywhere, both for rail and road.

Usage:
1. With mod loaded, there is an "H0 Bridge" label at the bottom bar of the screen, after it the state "On" or "Off" is indicated.
2. Toggle to state to "On" to enable the function
3. Click on the "H0 Bridge" open the option window.
4. Lay rail/road directly, they will be converted to the rail/road on bridge, if the rail/road is connected to an existing bridge, it will take the same bridge type.

* This mod can be safely removed from gamesaves.

Changelog:
1.2
- New GUI
1.1
- Adaptation to the new API
- Resolved dysfunction when the segment is short
- Compatibility to all roads and bridges
- Auto-select of bridge when build with existing ones
- GUI improvement
]]

local descFR = [[Ce mod vous permet de construit les ponts rail ou pont route à n'import où

Mode d’emploi :
1. Avec ce mod chargé, il aura une libell "Pont H0" en bas d'écran, puis "Activé" ou "Désactivé" pour indiquer son état
2. Cliquez sur indicateur, quand il affiche "Activé" c'est activé.
3. Cliquez sur "Pont H0" pour ouvrir la fenêtre d'option
4. Posez les voies/routes en directement, ils seront converit tant en pont automatiquement, si les voies/routes sont connectées sur un pont exisitant, le mod va prendre le pont du même type.

* Ce mod pourrait être désactivé sans souci.

Changelog:
1.2
- Nouvelle IHM
1.1 
- Adaptation à l'api nouvelle.
- Résoulution du dysfonctionnement quand la section crée est court
- Compatibilité avec tous les routes et ponts
- Auto-sélectionement des ponts lors la construction avec celui existant
- Amélioration d'IHM
]]

local descCN = [[该模组能够在任意高度放置铁路桥或公路桥

使用：
1.若模组开启，屏幕最下方的信息条中显示“零高度桥梁”的标签，后面有标签表示该功能是否开启。
2.点击“开启”或者“关闭”切换状态
3.点击“零高度桥梁”可以打开参数菜单
4.直接铺设铁路或者道路，之后会自动转为设定的桥梁，如果铺设的铁路或者道路直接和其他桥梁连接，则会使用一致的桥梁类型。

* 该模组可以安全地从存档中移除

更新日志:
1.2
- 重新设计了界面
1.1
- 使用了新的API
- 解决了在创建轨道很短的情况下失效的问题
- 兼容所有的桥梁和道路
- 在连接既有桥梁时自动选择
- 改进了用户界面
]]

local descTC = [[該模組能夠在任意高度放置鐵路橋或公路橋

使用：
1.若模組開啟，螢幕最下方的資訊條中顯示“零高度橋樑”的標籤，後面有標籤表示該功能是否開啟。
2.點擊“開啟”或者“關閉”切換狀態
3.點擊“零高度橋樑”可以打開參數功能表
4.直接鋪設鐵路或者道路，之後會自動轉為設定的橋樑，如果鋪設的鐵路或者道路直接和其他橋樑連接，則會使用一致的橋樑類型。

* 該模組可以安全地從存檔中移除

更新日誌:
1.2
- 重新設計了介面
1.1
- 使用了新的API
- 解決了在創建軌道很短的情況下失效的問題
- 相容所有的橋樑和道路
- 在連接既有橋樑時自動選擇
- 改進了使用者介面]]

function data()
    return {
        en = {
            MOD_NAME = "Zero Height Bridge",
            MOD_DESC = descEN,
            TITLE = "",
            FBRIDGE = "H0 Bridge",
            ON = "On",
            OFF = "Off"
        },
        fr = {
            MOD_NAME = "Pont à hauteur zéro",
            MOD_DESC = descFR,
            TITLE = "",
            FBRIDGE = "Pont H0",
            ON = "Activé",
            OFF = "Désactivé"
        },
        zh_CN = {
            MOD_NAME = "零高度桥梁",
            MOD_DESC = descCN,
            TITLE = "",
            FBRIDGE = "零高度桥梁",
            ON = "开启",
            OFF = "关闭"
        },
        zh_TW = {
            MOD_NAME = "零高度橋樑",
            MOD_DESC = descTC,
            TITLE = "",
            FBRIDGE = "零高度橋樑",
            ON = "開啟",
            OFF = "關閉"
        }
    }
end
