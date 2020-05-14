local descEN = [[This mod helps you building bridges everywhere, both for rail and road.

Due to the limit of API open for modding, this mod gets following limitations:
- Only recgonizes vanilla track types, if the track type choosen on creating is a mod track, it will be converted as "High-Speed" tracks. You need to convert them after construction.

So, it's a very basic mod, but I will try to contact for improve it.

Usage:
1. With mod loaded, there is an "H0 Bridge" label at the bottom bar of the screen, after it the state "On" or "Off" is indicated.
2. Toggle to state to "On" to enable the function
3. Click on the "H0 Bridge" open the option window.
4. Lay rail/road directly, they will be converted to the rail/road on bridge

* This mod can be safely removed from gamesaves.

Stay strong Italy, Iran and Spain!
Stay strong and united before COVID-19, the human beings around the world!
]]

local descFR = [[Ce mod vous permet de construit les ponts rail ou pont route à n'import où

A casue de la limite des APIs disponibles, ce mod port ces limitations suivant :
- Que les rails du type d'originale sont reconnus, si la voie est créée avec rail de 3e partie, elle sera convertie en type "standard". Vous deverez les reconvertir après la construction.

Donc c'est un mod très basique, mais je vais commuinique à UG pour avoir la possiblité de faire l'amélioration

Mode d’emploi :
1. Avec ce mod chargé, il aura une libell "Pont H0" en bas d'écran, puis "Activé" ou "Désactivé" pour indiquer son état
2. Cliquez sur indicateur, quand il affiche "Activé" c'est activé.
3. Cliquez sur "Pont H0" pour ouvrir la fenêtre d'option
4. Posez les voies/routes en directement, ils seront converit tant en pont automatiquement.

* Ce mod pourrait être désactivé sans souci.

Soyons solidaires depuis chez nous!
Soyons fort les humaines pour lutter contre COVID-19!
]]

local descCN = [[该模组能够在任意高度放置铁路桥或公路桥

由于游戏开放API的限制，目前该模组有以下局限：
-只能识别原生的两种轨道类型，如果铺设的是第三方轨道，该模组会将其转成高速轨道。铺设后需要手动转换轨道类型。

所以这个模组的功能不多，不过我会尽力联系UG开放更多的信息给模组，这样功能就完整了。

使用：
1.若模组开启，屏幕最下方的信息条中显示“零高度桥梁”的标签，后面有标签表示该功能是否开启。
2.点击“开启”或者“关闭”切换状态
3.点击“零高度桥梁”可以打开参数菜单
4.直接铺设铁路或者道路，之后会自动转为设定的桥梁

* 该模组可以安全地从存档中移除

愿全人类能够团结一致，消灭COVID-19！
]]

local descTC = [[該模組能夠在任意高度放置鐵路橋或公路橋

由於遊戲開放API的限制，目前該模組有以下局限：
-只能識別原生的兩種軌道類型，如果鋪設的是協力廠商軌道，該模組會將其轉成高速軌道。鋪設後需要手動轉換軌道類型。

所以這個模組的功能不多，不過我會盡力聯繫UG開放更多的資訊給模組，這樣功能就完整了。

使用：
1.若模組開啟，螢幕最下方的資訊條中顯示“零高度橋樑”的標籤，後面有標籤表示該功能是否開啟。
2.點擊“開啟”或者“關閉”切換狀態
3.點擊“零高度橋樑”可以打開參數功能表
4.直接鋪設鐵路或者道路，之後會自動轉為設定的橋樑

* 該模組可以安全地從存檔中移除

願全人類能夠團結一致，消滅COVID-19！
]]

function data()
    return {
        en = {
            MOD_NAME = "Zero Height Bridge",
            MOD_DESC = descEN,
            TITLE = "Zero Height Bridge",
            BRIDGE_TYPE = "Type",
            FBRIDGE = "H0 Bridge",
            ON = "On",
            OFF = "Off"
        },
        fr = {
            MOD_NAME = "Pont à hauteur zéro",
            MOD_DESC = descFR,
            TITLE = "Pont à hauteur zéro",
            BRIDGE_TYPE = "Type",
            FBRIDGE = "Pont H0",
            ON = "Activé",
            OFF = "Désactivé"
        },
        zh_CN = {
            MOD_NAME = "零高度桥梁",
            MOD_DESC = descCN,
            TITLE = "零高度桥梁",
            BRIDGE_TYPE = "桥梁类型",
            FBRIDGE = "零高度桥梁",
            ON = "开启",
            OFF = "关闭"
        },
        zh_TW = {
            MOD_NAME = "零高度橋樑",
            MOD_DESC = descTC,
            TITLE = "零高度橋樑",
            BRIDGE_TYPE = "橋樑類型",
            FBRIDGE = "零高度橋樑",
            ON = "開啟",
            OFF = "關閉"
        }
    }
end
