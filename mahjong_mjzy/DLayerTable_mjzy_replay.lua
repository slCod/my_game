--[[
    仙桃晃晃的重播的方法
    为0 的时候进行了操作
    TABLE_OP_DRAWCARD           = -1;   // 摸牌
    TABLE_OP_OUTCARD            = -2;   // 打牌
    TABLE_OP_END                = -3;   // 流局
    TABLE_OP_BET                = -4;   // 下注
    TABLE_OP_JIALAIZI           = -5;   // 架癞子

    TABLE_OP_PENG               = 1;     // 碰
    TABLE_OP_GANG               = 2;     // 杠
    TABLE_OP_HU                 = 3;     // 胡
    TABLE_OP_ZIMO               = 4;     // 自摸
    TABLE_OP_CHAOTIAN           = 5;     // 朝天
    TABLE_OP_BUZHUOCHONG        = 6;     // 不捉铳
    TABLE_OP_QIANGXIAO          = 7;     // 抢笑
    TABLE_OP_CHI                = 8;     // 吃
    TABLE_OP_HUANBAO            = 9;     // 换宝
    TABLE_OP_DG                 = 10;    // 对光
    TABLE_OP_CAIGANG            = 11;    // 猜杠
    TABLE_OP_TING               = 12;    // 听牌

]]
require( REQUIRE_PATH.."DDefine")
require( REQUIRE_PATH.."DCCBLayer")
require( REQUIRE_PATH.."DTKDScene")
require( REQUIRE_PATH.."_tkd_tbmenu")
require( "mahjong_mjzy.mahjong_mjzy_ai")
local casinoclient = require("script.client.casinoclient")
local platform_help = require("platform_help")

DEF_MJZY_REPLAY_MAX_PLAYER      = 4     -- 最大玩家数(0下,1右,2上,3左)
DEF_MJZY_REPLAY_MAX_MAHJONGS    = 14    -- 最大牌数量 (正常)
DEF_MJZY_REPLAY_DEF_MAHJONGS    = 13    -- 默认牌数量

DEF_MJZY_REPLAY_MAHJONG_SELECT_Y= 40    -- 选中的Y轴偏移
DEF_MJZY_REPLAY_MAHJONG_SELECT_S= 1.2   -- 选中的缩放

DEF_MJZY_REPLAY_MIN_MOVE_Y      = 150   -- 最小移动Y轴，超过这个高度就可以选中拖动的

DEF_MJZY_REPLAY_BUT_TYPE_PENG   = 1     -- 碰 按钮
DEF_MJZY_REPLAY_BUT_TYPE_GANG   = 2     -- 杠 按钮
DEF_MJZY_REPLAY_BUT_TYPE_HU     = 3     -- 胡 按钮

DEF_MJZY_REPLAY_TING_LIST_MAX   = 9     -- 听牌列表最大罗列牌数
DEF_MJZY_REPLAY_TING_FRAME_SPACE= 120   -- 听牌底框宽带附加
DEF_MJZY_REPLAY_TING_ITEM_SPACE = 70    -- 听牌牌面之间的间距
DEF_MJZY_REPLAY_TING_ITEM_SCALE = 0.85  -- 听牌显示的牌缩放

DEF_MJZY_REPLAY_VAILD_SPACE     = 10    -- 有效牌与无效牌之间的距离
DEF_MJZY_REPLAY_MYTABLE_SPACE   = 10    -- 我的桌子左右的间隔

DEF_MJZY_REPLAY_MAX_OUTMAHJONG  = 27    -- 打出的最多牌数
DEF_MJZY_REPLAY_MAX_GETMAHJONG  = 20    -- 最多牌

DEF_SOUND_MJ_CLICK      = "mj_click"..DEF_TKD_SOUND   -- 点中牌
DEF_SOUND_MJ_OUT        = "mj_out"..DEF_TKD_SOUND     -- 出牌
DEF_SOUND_MJ_MO         = "mj_mo"..DEF_TKD_SOUND      -- 摸牌
DEF_SOUND_MJ_KJ         = "mj_kj"..DEF_TKD_SOUND      -- 开局
DEF_SOUND_MJ_ZHSZ       = "mj_zhsz"..DEF_TKD_SOUND    -- 最后四张
DEF_SOUND_MJ_FLASH      = "mj_flash"..DEF_TKD_SOUND   -- 捉铳闪电
DEF_SOUND_MJ_LZ_PIAO    = "mj_piao"..DEF_TKD_SOUND    -- 飘
-- DEF_SOUND_MJ_PZ_PIAO    = "mj_pz_piao"..DEF_TKD_SOUND    -- 飘
DEF_SOUND_MJ_SCORE      = "mj_score"..DEF_TKD_SOUND   -- 桌面结算

DEF_MJZY_REPLAY_OUT_IDX         = 1000                        -- 打出牌的tag索引的开始
DEF_MJZY_REPLAY_ICO_IDX         = 100                         -- 扑到牌的对象tag索引开始

DEF_MJZY_REPLAY_BT_OUTSCALE     = 0.82--0.75   -- 上下两家出牌缩放值
DEF_MJZY_REPLAY_LR_OUTSCALE     = 0.88--0.81   -- 左右两家出牌缩放值
-----------------------------------------
-----------------------------------------
-- 回放对应的大类型
local TABLE_OP_DRAWCARD         = -1    -- 摸牌
local TABLE_OP_OUTCARD          = -2    -- 打牌
local TABLE_OP_END              = -3    -- 流局
local TABLE_OP_BET              = -4    -- 飘
local TABLE_OP_JIALAIZI         = -5    -- 架配子

local TABLE_OP_PENG             = 1     -- 碰
local TABLE_OP_GANG             = 2     -- 杠
local TABLE_OP_HU               = 3     -- 胡
local TABLE_OP_ZIMO             = 4     -- 自摸
local TABLE_OP_CHAOTIAN         = 5     -- 朝天
local TABLE_OP_BUZHUOCHONG      = 6     -- 不做冲
local TABLE_OP_QIANGXIAO        = 7     -- 抢笑
local TABLE_OP_CHI              = 8     -- 吃
local TABLE_OP_FANGFENG         = 9     -- 放风
local TABLE_OP_DG               = 10    -- 对光
local TABLE_OP_CAIGANG          = 11    -- 猜杠
local TABLE_OP_TING             = 12    -- 听牌


                  
local DEF_MJZY_REPLAY_OP_GANG_M = 1                   -- 明杠
local DEF_MJZY_REPLAY_OP_GANG_B = 2                   -- 补杠
local DEF_MJZY_REPLAY_OP_GANG_A = 3                   -- 暗杠

local DEF_MJZY_REPLAY_OP_PENG   = 9                 -- 碰


local DEF_MJZY_REPLAY_OP_XIAOCHAOTIAN   = 101         -- 小朝天
local DEF_MJZY_REPLAY_OP_DACHAOTIAN     = 102         -- 大朝天

local DEF_MJZY_REPLAY_OP_ZHUOCHONG        = 20         -- 捉铳
local DEF_MJZY_REPLAY_OP_QIANGXIAO        = 21         -- 抢笑
local DEF_MJZY_REPLAY_OP_HEIMO            = 40         -- 黑摸
local DEF_MJZY_REPLAY_OP_RUANMO           = 41         -- 软摸
local DEF_MJZY_REPLAY_OP_HEIMOX2          = 50         -- 黑摸
local DEF_MJZY_REPLAY_OP_RUANMOX2         = 51         -- 软摸


local DEF_MJZY_REPLAY_LAI                 = 0          -- 当前的赖子
local DEF_MJZY_REPLAY_FAN                 = 0          -- 当前的翻牌

--  MJZY_OP_TYPE_DIANXIAO            = 1;    // 点笑   
--  MJZY_OP_TYPE_HUITOUXIAO          = 2;    // 回头笑  
--  MJZY_OP_TYPE_MENGXIAO            = 3;    // 闷笑       

--  MJZY_OP_TYPE_FANGXIAO            = 9;    // 放笑
--  MJZY_OP_TYPE_PIAOLAIZI           = 10;   // 飘癞子

--  MJZY_OP_TYPE_ZHUOCHONG           = 20;   // 捉铳(无赖子)
--  MJZY_OP_TYPE_QIANGXIAO           = 21;   // 抢笑
--  MJZY_OP_TYPE_XIAOHOUCHONG        = 22;   // 笑后铳
--  MJZY_OP_TYPE_BEIQIANGXIAO        = 23;   // 被抢笑(只做统计)

--  MJZY_OP_TYPE_FANGCHONG           = 30;   // 放铳
--  MJZY_OP_TYPE_RECHONG             = 31;   // 热铳

--  MJZY_OP_TYPE_HEIMO               = 40;   // 黑摸
--  MJZY_OP_TYPE_RUANMO              = 41;   // 软摸

--  MJZY_OP_TYPE_HEIMOX2             = 50;   // 黑摸x2
--  MJZY_OP_TYPE_RUANMOX2            = 51;   // 软摸x2

--  MJZY_OP_TYPE_FANGCHAOTIAN        = 100;  // 放朝天
--  MJZY_OP_TYPE_XIAOCHAOTIAN        = 101;  // 小朝天(点笑) (MJZY_OP_TYPE_FANGCHAOTIAN)
--  MJZY_OP_TYPE_DACHAOTIAN          = 102;  // 大朝天(闷笑)

--读取数据的时间
local TABLE_READRPLAYDATA_TIME    = 2     -- 读取数据的时间间隔
local TABLE_ENTERSCORE_TIME       = 5     -- 进入得分界面的时间
local TABLE_QUITSCORE_TIME        = 5     -- 退出得分界面的时间
local TABLE_READRPLAYDATA_SPACRE  = 1     -- 读取数据的时间速率


-- 回放
local DEF_MJZY_REPLAY_MAX_ROUND = 1     --当前最大局数的索引
local DEF_MJZY_REPLAY_OP_MAX_INDEX = 1  --当前局数最大op的索引

local DEF_MJZY_REPLAY_ROUND     = 1     --当前读取的局数的索引
local DEF_MJZY_REPLAY_OP_INDEX  = 1     --当前读取的op索引
-----------------------------------------
-----------------------------------------
-- 索引转换索引到使用的编号（手牌）
-- order四方向(0~3), i(索引从1开始)
function INDEX_ITOG( order, i)

    if  order == 0 or order == 2 or order == 3 then
        return i
    else
        return (DEF_MJZY_REPLAY_MAX_GETMAHJONG - i + 1)
    end
end
-----------------------------------------
-- 桌子上的牌结构
X_MAHJONG = class( "X_MAHJONG")
X_MAHJONG.__index = X_MAHJONG
-- 构造函数
function X_MAHJONG:ctor()
    self:init()
end

X_MAHJONG.m_nMahjong = nil       -- 数值
X_MAHJONG.m_pMahjong = nil       -- 牌对象
X_MAHJONG.m_bSelect = false      -- 是否选中
X_MAHJONG.m_bVaild = true        -- 是否有效
X_MAHJONG.m_sPosition = cc.p( 0, 0)

function X_MAHJONG:init()
    --cclog("X_MAHJONG::init")
    self.m_nMahjong = 0
    self.m_pMahjong = nil
    self.m_bSelect = false
    self.m_bVaild = true
    self.m_sPosition = cc.p( 0, 0)
end

function X_MAHJONG:release()
    --cclog("X_MAHJONG::release")

    self:init()
end

function X_MAHJONG.create()
    --cclog("X_MAHJONG::create")
    local instance = X_MAHJONG.new()
    return instance
end

-----------------------------------------
-- 类定义
CDLayerTable_mjzy_replay = class("CDLayerTable_mjzy_replay", CDCCBLayer)
CDLayerTable_mjzy_replay.__index = CDLayerTable_mjzy_replay
CDLayerTable_mjzy_replay.name = "CDLayerTable_mjzy_replay"

-- 构造函数
function CDLayerTable_mjzy_replay:ctor()
    cclog("CDLayerTable_mjzy_replay::ctor")
    CDLayerTable_mjzy_replay.super.ctor(self)
    CDLayerTable_mjzy_replay.initialMember(self)
    --reg enter and exit
    local function onNodeEvent(event)
        if "enter" == event then
            CDLayerTable_mjzy_replay.onEnter(self)
        elseif "exit" == event then
            CDLayerTable_mjzy_replay.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDLayerTable_mjzy_replay:onEnter()
    cclog("CDLayerTable_mjzy_replay::onEnter")
    DEF_MJZY_REPLAY_ROUND  = 1 
    DEF_MJZY_REPLAY_OP_INDEX = 1
    -- g_pGlobalManagement:setIsReplay(false)
    dtCloseWaiting( self)

end

function CDLayerTable_mjzy_replay:onExit()
    cclog("CDLayerTable_mjzy_replay::onExit")
    self:stopAllActions()

    if self.handPingId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.handPingId)   
        self.handPingId=nil
    end

    CDLayerTable_mjzy_replay.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
-- 排序（有效判断，和牌面判断）
function mahjong_mjzy_table_comps_stb_Replay( a, b)

    if  a and b and a.mahjong and b.mahjong then
        if  a.mahjong ~= b.mahjong then

            if  a.mahjong == DEF_MJZY_REPLAY_LAI then
                return true
            end
    
            if  b.mahjong == DEF_MJZY_REPLAY_LAI then
                return false
            end

            if a.mahjong == 51 then
                return true
            end

            if b.mahjong == 51 then
                return false
            end

        end
        return a.mahjong < b.mahjong
    end
    
end
function mahjong_mjzy_table_stb_replay( a, b)
    if  a and b then
        if  a ~= b then
    
            if  a == DEF_MJZY_REPLAY_LAI then
                return true
            end
    
            if  b == DEF_MJZY_REPLAY_LAI then
                return false
            end

            if a == 51 then
                return true
            end

            if b == 51 then
                return false
            end
        end
        return a < b
    end
end
----------------------------------------------------------------------------
-- 初始化
function CDLayerTable_mjzy_replay:init()
    cclog("CDLayerTable_mjzy::init")
    
    -- touch事件
    local function onTouchBegan(touch, event)
        cclog("CDLayerTable_mjzy:onTouchBegan")
        local point = touch:getLocation()
        -- 玩家头像点击处理
        for i = 1, DEF_MJZY_REPLAY_MAX_PLAYER-1 do

            local sRect = self.m_pPlayer[i].m_pFrame:getBoundingBox()
            if  cc.rectContainsPoint( sRect, point) then

                self:openPlayerInfo( i)
                break
            end
        end
       
        return true
    end

    local function onTouchMoved(touch, event)
        cclog("CDLayerTable_mjzy:onTouchMoved")

    end

    local function onTouchEnded(touch, event)
        cclog("CDLayerTable_mjzy:onTouchEnded")

    end

    self.m_pListener = cc.EventListenerTouchOneByOne:create()
    self.m_pListener:setSwallowTouches(true)
    self.m_pListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_pListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.m_pListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pListener, self)
end
----------------------------------------------------------------------------
-- 初始化
function CDLayerTable_mjzy_replay:initialMember()
    cclog("CDLayerTable_mjzy_replay::initialMember")
    
    self.m_pListener = nil          -- 监听对象

    self.m_pMahjongOut = nil        -- 打出的牌放置节点
    self.m_pMahjongOwn = nil        -- 拥有的牌
    self.m_pMahjongEff = nil        -- 特效层

    self.m_pBut_Ready = nil         -- 准备按钮
    self.m_pPic_Ready = nil         -- 准备图示
    self.m_pBut_Cancel = nil        -- 取消托管按钮
    self.m_pRobotFlag = nil         -- 托管遮挡
    self.m_pTxt_Robot = nil         -- 托管提示文字

    self.m_pGroupButton = nil       -- 按钮组
    self.m_pBut_Type = {}           -- 功能类型按钮组
    self.m_pBut_Text = {}           -- 功能按钮组文字

    self.m_bTrusteeship = false     -- 是否托管
    self.m_pNewLayerRoot = nil      -- 新层根节点

    self.m_nOrderType = 0           -- 出牌顺序, 0我，1右, 2上, 3左
    self.m_pOrderIco = nil          -- 顺序指针
    self.m_pOrderIcoP = nil 

    self.m_pLaiZiDemo = nil         -- 赖子放置节点
    self.m_pLaiGenDemo = nil        -- 赖根放置节点
    self.m_pLZMahjong = nil         -- 赖子牌
    self.m_pLGMahjong = nil         -- 赖根牌

    self.m_pCenterDire = nil        -- 中心指向放置容器（自己的）
    self.m_pCenterDemo = {}         -- 中心点参考坐标对象
    self.m_pOutDemo = {}            -- 出牌位置参考对象
    self.m_sOutStart = {}           -- 出牌开始位置
    self.m_sOutSpace = {}           -- 两个牌之间的距离
    self.m_sOutWrap = {}            -- 两行之间的距离

    self.m_sOutNumber = {}          -- 出牌数量
    self.m_sUseNumber = {}          -- 使用手牌数量

    self.m_pIcoDemo = {}            -- 放风牌节点

    self.m_nLastMoMahjong = 0       -- 最后一张膜的牌
    self.m_nLastOutPlayer = 0       -- 最后一个出牌的玩家
    self.m_nLastOutMahjong = 0      -- 最后一张摸的牌
    self.m_nLastSelect = 0          -- 最后选中的牌索引
    self.m_bCanOutMahjong = false   -- 可出牌

    self.m_pTingGroup = nil         -- 听牌展现组
    self.m_sTingPosition = cc.p( 0, 0)
    self.m_pTingFrame = nil         -- 听牌展现底
    self.m_pTingList = nil          -- 听牌列表
    self.m_pTingNumFrame = {}       -- 听牌数字底
    self.m_pTingNumText = {}        -- 听牌数字
    self.m_pTingMahjong = {}        -- 听的牌

    self.m_bThinkJustOut = false    -- 只能思考出牌
    self.m_bOPSelf = false          -- 是否询问我OP

    self.m_pOutMahjong = nil        -- 打出的牌演示
    self.m_pOutMahjongGroup = nil   -- 打出的牌演示组
    self.m_bReConnection = false    -- 是否在重连创建中

    self.m_nLordID = 0              -- 庄家编号
    self.m_nSaveLordIdx = -1        -- 庄索引
    self.m_nScoreTime = 0           -- 排名停留时间

    self.m_nEndCardType = 0         -- 最后四张表现类型
    self.m_nEndCard = 0             -- 最后一张牌

    self.m_nArrangeType = 0         -- 整牌过程类型(0整理，1完成)
    self.m_nLicensingType = 0       -- 整理牌的表现类型(0表现赖子，1表现整牌)

    self.m_pPlayTable = {}          -- 玩家自己的桌面
    self.m_nLicensingOrder = -1     -- 发牌玩家索引
    self.m_sLicensingTotal = {}

    self.m_pPMahjongs = {}          -- 手上的牌
    self.m_nPMahjongs = {}          -- 手上牌总数

    self.m_nPlayers = 4             -- 玩家人数
    self.m_pPlayer = {}             -- 桌子中的玩家:m_pName, m_pGold, data, number
    for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do

        self.m_pPlayTable[i] = nil
        self.m_sLicensingTotal[i] = 1
        self.m_pCenterDemo[i] = nil
        self.m_pIcoDemo[i] = nil

        self.m_pPMahjongs[i] = {}
        self.m_nPMahjongs[i] = 0

        self.m_sOutNumber[i] = 0
        self.m_sUseNumber[i] = 0

        self.m_pPlayer[i] = {}

        self.m_pPlayer[i].m_pData = casino.table_player()

        self.m_pPlayer[i].m_nID = nil
        self.m_pPlayer[i].m_nSex = 0
        self.m_pPlayer[i].m_nAvatar = 0

        self.m_pPlayer[i].m_pName = nil
        self.m_pPlayer[i].m_pGold = nil
        self.m_pPlayer[i].m_pFrame = nil
        self.m_pPlayer[i].m_pHead = nil
        self.m_pPlayer[i].m_pNumber1 = nil          -- 减少的字
        self.m_pPlayer[i].m_pNumber2 = nil          -- 增加的字
        self.m_pPlayer[i].m_pNumDemo = nil          -- 文字容器
        self.m_pPlayer[i].m_sNumSpace = cc.p( 0, 0) -- 增加减少字的偏移
        self.m_pPlayer[i].m_pStart = nil
        self.m_pPlayer[i].m_sPosBeg = cc.p( 0, 0)
        self.m_pPlayer[i].m_sPosEnd = cc.p( 0, 0)

        self.m_pPlayer[i].m_pBubbleGroup = nil
        self.m_pPlayer[i].m_pBubbleBox = nil
        self.m_pPlayer[i].m_pBubbleMsg = nil

        self.m_pPlayer[i].m_pIcoReady = nil          -- 准备提示
        self.m_pPlayer[i].m_pIcoOutLine = nil        -- 离线提示
        self.m_pPlayer[i].m_pIcoYK = nil             -- 游客标志

        self.m_pPlayer[i].m_pSpeakDemo= nil          -- 语音播放效果容器
        self.m_pPlayer[i].m_pSpeakEff = nil          -- 语音播放效果

        self.m_pPlayer[i].tab_gaps = cc.p( 0, 0)     -- 摊牌与手牌原始间隔
        self.m_pPlayer[i].tab_ori_scal = 0           -- 原始缩放值
        self.m_pPlayer[i].tab_out_scal = 0           -- 摊牌缩放值
        self.m_pPlayer[i].tab_size = cc.p( 0, 0)     -- 原始牌尺寸
        self.m_pPlayer[i].tab_spce = cc.p( 0, 0)     -- 原始牌间隔
        self.m_pPlayer[i].tab_percent  = 0           -- 玩家桌面尺寸百分比
        self.m_pPlayer[i].tab_center   = cc.p( 0, 0) -- 玩家桌子中心位置
        self.m_pPlayer[i].tab_max = 0                -- 本回合中出现的最大尺寸
        self.m_pPlayer[i].tab_min_scale = 1.0        -- 本回合中出现的最小缩放
        self.m_pPlayer[i].tab_tag_scale = 1.0        -- OP指示对象缩放值
        self.m_pPlayer[i].tab_tag_space = cc.p( 0, 0)-- OP指示对象的偏移
        self.m_pPlayer[i].tab_fangFeng_space = cc.p( 0, 0)--放风牌偏移位置

        -- self.m_pPlayer[i].m_pFanTxt = nil            -- 番数显示
        -- self.m_pPlayer[i].betType = nil              -- 纪录玩家是否飘
        -- self.m_pPlayer[i].m_pBet = nil               -- 飘的特效
        -- 名字
        self.m_pPlayer[i].nickname = nil
        self.m_pPlayer[i].channel_nickname = nil
        -- 经纬度
        self.m_pPlayer[i].lat = nil                    -- 经度
        self.m_pPlayer[i].lng = nil                    -- 纬度
        self.m_pPlayer[i].address = nil                -- 地址
        self.m_pPlayer[i].ip_address = nil                -- ip地址
    end
    self.m_pPlayAI = nil            -- 玩家AI

    self.m_pSelfInfo = nil          -- 我的信息
    self.m_pTableInfo = nil         -- 桌子信息

    CDLayerTable_mjzy_replay.m_pMyMahjong = {}
    self.m_nSaveSelectIndex = 0     -- 记录选中的牌索引
    self.m_bMoveSelect = false      -- 移动选中的

    self.m_pTimeLeft = nil          -- 剩余时间容器
    self.m_pTimeLeftTTF = nil       -- 剩余时间文字
    self.m_pTimeLeftNum = nil       -- 倒计时数字
    self.m_nTimeLeft = 0            -- 倒计时

    self.m_pGroupBar = nil          -- 下工具条
    self.m_pGroupSelfBuild = nil    -- 自建房信息
    self.m_pSelfBuildInfo = nil     -- 自建房信息
    self.m_bInTheGame = false
    self.m_pRoomIDDemo = nil        -- 房号容器
    self.m_pRoomIDTTF = nil         -- 房号字体

    self.m_pButToOther = nil        -- 为他人开房
    self.m_pTxtToOther = nil
    self.m_pButOver = nil           -- 解散房间
    self.m_pTxtOver = nil
    self.m_pButLeave = nil          -- 离开房间
    self.m_pTxtLeave = nil

    self.m_pButSetting = nil        -- 设置按钮
    self.m_pButChat = nil           -- 聊天按钮
    self.m_pButShare = nil          -- 分享
    self.m_pTxtShare = nil          -- 分享文字
    self.m_pButRobot = nil          -- 托管按钮
    self.m_pButSponsor = nil        -- 发起解散
    self.m_pTxtSponsor = nil        -- 发起解散的倒计时文字

    self.m_bInTheGame = false       -- 游戏中

    self.m_pGroupLeftTop = nil      -- 左顶部信息组

    self.m_pGroupPushMsg = nil      -- 信息输出组
    self.m_pPushMessage = nil       -- 压入显示的信息
    self.m_nPauseTime = 0           -- 暂停时间
    self.m_nPausePlayer = 0         -- 暂停造成的玩家编号

    self.m_pGroupTip = nil          -- Tip提示组
    self.m_pTipMessage = nil        -- Tip提示组文字
    self.m_sGroupTipPos = cc.p( 0, 0)
    self.m_pEffFlagLast = nil       -- 最后一张牌的特效

    self.m_nLastOutMahjongTag = 0   -- 最后一张牌的对象编号
    self.m_pIcoPower = nil          -- 电池图标
    self.m_pStageDemo = nil         -- 状态容器

    self.m_pLighting = nil          -- 灯光

    self.m_nOutMahjong_p = 0        -- 出牌记录玩家编号
    self.m_nOutMahjong_m = 0        -- 出牌记录牌

    self.m_nDrawCard_p = 0          -- 摸牌角色
    self.m_nDrawCard_m = 0          -- 摸到的牌

    self.m_bSaveZCHFlag = false     -- 储存捉铳OP标志
    self.m_bSaveOPGFlag = false     -- 储存杠的OP标志
    self.m_bSaveSlfFlag = false     -- 自己打出牌的标志
    self.m_nSaveOPGMahjong = 0      -- 储存杠的OP文字
    self.m_uDisbandTime = 0         -- 解散发起的时间

    self.m_pEffNetLow = nil         -- 网络连接缓慢提示特效
    self.m_nTimeOut = 0             -- 超时时间记录
    self.m_bPreCreate = false       -- 是否预创建过

    self.m_pGroupForgo = nil        -- 放弃的信息组
    self.m_pForgoMessage = nil      -- 放弃的信息

    self.m_pRecordingEff = nil      -- 录制中特效
    self.m_pRecordCancel = nil      -- 取消录制提示效果
    self.m_pRecordButton = nil      -- 录制点击按钮
    self.m_pRecordEffect = nil      -- 录制按钮效果
    self.m_pJoinTypeMsg = nil       -- 加入类型的文字显示

    -- 定位相关
    self.isShowLocation = true
    self.isShowPosTip = false       -- 主动显示权限提示
    self.isShowPos = false
    self.m_pButLocation = nil       -- 定位按钮
    self.m_pGroupLocation = nil     -- 定位组
    self.m_pIcoLocation = {}        -- 定位显示按钮
    self.m_pTxtLocation = {}        -- 定位显示距离
    self.m_pPosLocation = {}        -- 坐标
    self.m_pGroupAddress= {}        -- 地址组
    self.m_pTxtAddress  = {}        -- 地址
    for i = 1, DEF_MJZY_REPLAY_MAX_PLAYER-1 do

        self.m_pIcoLocation[i] = nil
        self.m_pTxtLocation[i] = nil
        self.m_pGroupAddress[i]= nil
        self.m_pTxtAddress[i] = nil
        self.m_pPosLocation[i] = cc.p( 0, 0)
    end

    -- IP相关
    self.isFirstSendIp = false
    self.m_pIPFrame = {}
    self.m_pIPString = {}
    for i = 1, DEF_MJZY_REPLAY_MAX_PLAYER-1 do

        self.m_pIPFrame[i] = nil
        self.m_pIPString[i] = nil
    end

    -- 回放
    self.mjzy_replaydata = nil      -- 回放的数据
    self.curRoundOPData = nil       -- 当前局数的数据
    self.isMyTable = false          -- 是否是自己的回放
    self.headIsClick = false        -- 是否点击过这个玩家的头像

end

function CDLayerTable_mjzy_replay:releaseMember()
    cclog("CDLayerTable_mjzy_replay::releaseMember")

    if  self.m_pRoomIDDemo ~= nil then
        self.m_pRoomIDDemo:removeAllChildren()
    end

    if  self.m_pTimeLeft ~= nil then
        self.m_pTimeLeft:removeAllChildren()
    end

    if  self.m_pButSponsor ~= nil then
        self.m_pButSponsor:stopAllActions()
    end
    
    if  self.m_pOrderIcoP ~= nil then
        self.m_pOrderIcoP:removeAllChildren()
    end

    for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do

        if  self.m_pPlayer[i] ~= nil and 
            self.m_pPlayer[i].m_pBubbleGroup ~= nil then
            self.m_pPlayer[i].m_pBubbleGroup:removeAllChildren()
        end

        if  self.m_pPlayer[i] ~= nil and
            self.m_pPlayer[i].m_pSpeakDemo ~= nil then
            self.m_pPlayer[i].m_pSpeakDemo:removeAllChildren()
            self.m_pPlayer[i].m_pSpeakEff = nil
        end

        if  self.m_pCenterDemo ~= nil and
            self.m_pCenterDemo[i] ~= nil then
            self.m_pCenterDemo[i]:removeAllChildren()
        end

        if  self.m_pPlayTable[i] ~= nil then
            self.m_pPlayTable[i]:removeAllChildren()
        end
    end

    if  self.m_pSZM_demo_eff then
        self.m_pSZM_demo_eff:removeAllChildren()
    end

    if  self.m_pCenterDire ~= nil then
        self.m_pCenterDire:removeAllChildren()
    end

    if  self.m_pMahjongOut ~= nil then
        self.m_pMahjongOut:removeAllChildren()
    end

    if  self.m_pMahjongOwn ~= nil then
        self.m_pMahjongOwn:removeAllChildren()
    end

    if  self.m_pMahjongEff ~= nil then
        self.m_pMahjongEff:removeAllChildren()
    end

    if  self.m_pLaiZiDemo ~= nil then
        self.m_pLaiZiDemo:removeAllChildren()
    end

    if  self.m_pLaiGenDemo ~= nil then
        self.m_pLaiGenDemo:removeAllChildren()
    end

    if  self.m_pTingList ~= nil then
        self.m_pTingList:removeAllChildren()
    end

    if  self.m_pOutMahjongGroup ~= nil then
        self.m_pOutMahjongGroup:removeAllChildren()
    end

    if  self.m_pNewLayerRoot ~= nil then
        self.m_pNewLayerRoot:removeAllChildren()
        self.m_pEffNetLow = nil
    end

    if  self.m_pRecordButton ~= nil then
        self.m_pRecordButton:removeAllChildren()
        self.m_pRecordEffect = nil
    end
    self.m_pRecordingEff = nil
    self.m_pRecordCancel = nil

    --模拟析构父类
    CDLayerTable_mjzy_replay.super.releaseMember(self)
    if  DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end

    if self.m_pListener then

        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.m_pListener)
        self.m_pListener = nil
    end
end

----------------------------------------------------------------------------
function CDLayerTable_mjzy_replay:getTableIndexWithID( id)
    cclog( "CDLayerTable_mjzy_replay:getTableIndexWithID( id[%u])", id)

    local data = casinoclient:getInstance():getTable()
    local count = TABLE_SIZE( data.players)

    local index = -1
    for i = 1, count do

        if  data.players[i].id == id then
            index = i
            break
        end
    end

    if  index > 0 then

        if  self.m_nPlayers == 2 then
            return g_pGlobalManagement:getTableIndex2( index)
        else
            return g_pGlobalManagement:getTableIndex4( index)
        end
    end
    return -1
end
----------------------------------------------------------------------------
-- 转换玩家索引位置根据游戏人数(4人、2人转换用）
function CDLayerTable_mjzy_replay:changeOrder( order)

    local change_order = order
    if  self.m_nPlayers == 2 then
        if  order == 1 then
            change_order = 2
        end
    end
    return change_order
end

-- 转换获取打出的牌最大数(4人、2人转换用）
function CDLayerTable_mjzy_replay:changeMaxOutMahjongs()

    if  self.m_nPlayers == 2 then
        return 57
    else
        return DEF_MJZY_REPLAY_MAX_OUTMAHJONG
    end
end

-- 转换最大出牌数量
function CDLayerTable_mjzy_replay:changeNowOutMahjongs( order_type)

    local max = self:changeMaxOutMahjongs()
    if  self.m_sOutNumber[order_type] > max then
        self.m_sOutNumber[order_type] = max
    end
end

-- 转换获取X轴上最大牌数量(4人、2人转换用）
function CDLayerTable_mjzy_replay:changeXMahjongs()

    if  self.m_nPlayers == 2 then
        return 19
    else
        return 9
    end
end

----------------------------------------------------------------------------
-- 初始化桌面
-- 初始化根据玩家自建房状态
function CDLayerTable_mjzy_replay:initWith_SBTableStatus( data)

    self.m_pBut_Ready:setVisible( false)
    self.m_pPic_Ready:setVisible( false)

    self.m_pGroupBar:setVisible( false)
    self.m_pGroupSelfBuild:setVisible( true)

    self.m_pSelfBuildInfo:setString( 
        string.format( casinoclient:getInstance():findString("table_info3"), data.base, data.round))

    self.m_pGroupLeftTop:setVisible( false)
    self.m_pRoomIDTTF:setString( string.format( "%u", data.tag))

    self.m_pJoinTypeMsg:setString( casinoclient.getInstance():findString(string.format("table_join%d", data.join)))
    self.m_pJoinTypeMsg:enableOutline( cc.c4b( 50, 50, 50, 255), 2)

    local bImMaster = false
    if  self.isMyTable then
        if  data.master_id == casinoclient:getInstance():getPlayerData():getId() then
            bImMaster = true
        end
    end
    self.m_pButToOther:setVisible( bImMaster)
    self.m_pTxtToOther:setVisible( bImMaster)

    self.m_pButOver:setVisible( bImMaster)
    self.m_pTxtOver:setVisible( bImMaster)

    self.m_pButLeave:setVisible( not bImMaster)
    self.m_pTxtLeave:setVisible( not bImMaster)

    if  self.m_nPlayers > 2 then
        -- 四人
        local rand_idx = {}
        for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do
            rand_idx[i] = i
        end
        local index = 0
        local random_num = 0
        for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do
            index = rand_idx[i]
            random_num = math.random( 0, DEF_MJZY_REPLAY_MAX_PLAYER-1)
            rand_idx[i] = rand_idx[random_num]
            rand_idx[random_num] = index
        end
        for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do
            self.m_pPlayer[i].m_pFrame:setVisible( true)
            self.m_pPlayer[i].m_pFrame:setScale( 1.0)
            self.m_pPlayer[i].m_pFrame:setPosition( self.m_pPlayer[rand_idx[i]].m_sPosBeg)
        end
    else
        -- 两人
        self.m_pPlayer[0].m_pFrame:setVisible( true)
        self.m_pPlayer[0].m_pFrame:setScale( 1.0)
        self.m_pPlayer[0].m_pFrame:setPosition( self.m_pPlayer[1].m_sPosBeg)
        self.m_pPlayer[2].m_pFrame:setVisible( true)
        self.m_pPlayer[2].m_pFrame:setScale( 1.0)
        self.m_pPlayer[2].m_pFrame:setPosition( self.m_pPlayer[2].m_sPosBeg)
        self.m_pPlayer[1].m_pFrame:setVisible( false)
        self.m_pPlayer[3].m_pFrame:setVisible( false)
    end

end

function CDLayerTable_mjzy_replay:sendHangPing( ... )

    local needWaitTime=0
    local function palyAudioDelay( ... )
        -- print("needWaitTime---->",needWaitTime)
        needWaitTime=needWaitTime+1
        if needWaitTime>=60 then
            needWaitTime=0
            
            casinoclient:getInstance():sendPong()
        end
    end
    if  self.handPingId==nil then
        self.handPingId=cc.Director:getInstance():getScheduler():scheduleScriptFunc(palyAudioDelay,1,false)
    end
end

-- 创建用户界面
function CDLayerTable_mjzy_replay:createUserInterface()
    cclog("CDLayerTable_mjzy_replay::createUserInterface")
    
    -- 创建桌面需要的出牌层、其他玩家手牌放置层、特效放置层
    self.m_pMahjongOwn = cc.Layer:create()
    self.m_pNewLayerRoot:addChild( self.m_pMahjongOwn)

    self.m_pMahjongOut = cc.Layer:create()
    self.m_pNewLayerRoot:addChild( self.m_pMahjongOut)

    self.m_pMahjongEff = cc.Layer:create()
    self.m_pNewLayerRoot:addChild( self.m_pMahjongEff)

    -- 创建所有玩家的桌面
    for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do
        self.m_pPlayTable[i] = cc.Layer:create()
        self:addChild( self.m_pPlayTable[i])
    end

    -- 只有当微信开启的时候才有分享
    if  not g_pGlobalManagement:getWeiXinLoginEnable() then
        self.m_pButShare:setVisible( false)
        self.m_pTxtShare:setVisible( false)
    end

    -- 初始化玩家出牌位置，出牌间隔等基础数据
    if  self.m_nPlayers == 2 then
        self.m_sOutStart[0] = cc.p( self.m_pOutDemo[0]:getPositionX() - 322 - 45*1.5, self.m_pOutDemo[0]:getPositionY())
    else
        self.m_sOutStart[0] = cc.p( self.m_pOutDemo[0]:getPositionX() - 168, self.m_pOutDemo[0]:getPositionY())
    end
    self.m_sOutSpace[0] = cc.p(  42,   0)
    self.m_sOutWrap[0]  = cc.p(   0, -48)

    self.m_sOutStart[1] = cc.p( self.m_pOutDemo[1]:getPositionX(), self.m_pOutDemo[1]:getPositionY()+136)
    self.m_sOutSpace[1] = cc.p(   0, -32)
    self.m_sOutWrap[1]  = cc.p( -52,   0)

    if  self.m_nPlayers == 2 then
        self.m_sOutStart[2] = cc.p( self.m_pOutDemo[2]:getPositionX() + 270 + 45*1.5, self.m_pOutDemo[2]:getPositionY()-25)
    else
        self.m_sOutStart[2] = cc.p( self.m_pOutDemo[2]:getPositionX() + 168, self.m_pOutDemo[2]:getPositionY())
    end

    self.m_sOutSpace[2] = cc.p( -42,   0)
    self.m_sOutWrap[2]  = cc.p(   0, -48)

    self.m_sOutStart[3] = cc.p( self.m_pOutDemo[3]:getPositionX(), self.m_pOutDemo[3]:getPositionY()+136)
    self.m_sOutSpace[3] = cc.p(   0, -32)
    self.m_sOutWrap[3]  = cc.p(  52,   0)

    -- 四个玩家牌相关的参考数据
    self.m_pPlayer[0].tab_gaps = cc.p( 10, 0)
    self.m_pPlayer[0].tab_ori_scal = 0.96
    self.m_pPlayer[0].tab_out_scal = 0.89
    self.m_pPlayer[0].tab_size = cc.p( 82, 136)
    self.m_pPlayer[0].tab_spce = cc.p( 76, 0) 
    self.m_pPlayer[0].tab_percent  = 1.0
    self.m_pPlayer[0].tab_center = cc.p( self.m_pCenterDemo[0]:getPositionX(), self.m_pCenterDemo[0]:getPositionY())
    self.m_pPlayer[0].tab_tag_scale = 0.9
    self.m_pPlayer[0].tab_tag_space = cc.p( 0, -46)
    self.m_pPlayer[0].m_sNumSpace = cc.p( 0, 20)
    self.m_pPlayer[0].tab_fangFeng_space = cc.p( 0, 0)

    self.m_pPlayer[1].tab_gaps = cc.p( 0, 5)
    self.m_pPlayer[1].tab_ori_scal = 0.70   --0.85
    self.m_pPlayer[1].tab_out_scal = 0.67
    self.m_pPlayer[1].tab_size = cc.p( 48, 80)
    self.m_pPlayer[1].tab_spce = cc.p( 0, 24)
    self.m_pPlayer[1].tab_percent = 0.56
    self.m_pPlayer[1].tab_center = cc.p( self.m_pCenterDemo[1]:getPositionX(), self.m_pCenterDemo[1]:getPositionY())
    self.m_pPlayer[1].tab_tag_scale = 0.82
    self.m_pPlayer[1].tab_tag_space = cc.p( 18, 7)
    self.m_pPlayer[1].m_sNumSpace = cc.p( -50, 50)
    self.m_pPlayer[1].tab_fangFeng_space = cc.p( -155, -160)

    self.m_pPlayer[2].tab_gaps = cc.p( -5, 0)
    self.m_pPlayer[2].tab_ori_scal = 0.85
    self.m_pPlayer[2].tab_out_scal = 0.82
    self.m_pPlayer[2].tab_size = cc.p( 53, 76)
    self.m_pPlayer[2].tab_spce = cc.p( -42, 0)
    self.m_pPlayer[2].tab_percent = 0.6
    self.m_pPlayer[2].tab_center = cc.p( self.m_pCenterDemo[2]:getPositionX(), self.m_pCenterDemo[2]:getPositionY())
    self.m_pPlayer[2].tab_tag_scale = 0.98
    self.m_pPlayer[2].tab_tag_space = cc.p( 0, -23)
    self.m_pPlayer[2].m_sNumSpace = cc.p( 0, -20)
    self.m_pPlayer[2].tab_fangFeng_space = cc.p( 0, 0)

    self.m_pPlayer[3].tab_gaps = cc.p( 0, -5)
    self.m_pPlayer[3].tab_ori_scal = 0.70  --0.85
    self.m_pPlayer[3].tab_out_scal = 0.67
    self.m_pPlayer[3].tab_size = cc.p( 48, 80)
    self.m_pPlayer[3].tab_spce = cc.p( 0, -24)
    self.m_pPlayer[3].tab_percent = 0.56
    self.m_pPlayer[3].tab_center = cc.p( self.m_pCenterDemo[3]:getPositionX(), self.m_pCenterDemo[3]:getPositionY())
    self.m_pPlayer[3].tab_tag_scale = 0.82
    self.m_pPlayer[3].tab_tag_space = cc.p( -18, 7)
    self.m_pPlayer[3].m_sNumSpace = cc.p( 50, 50)
    self.m_pPlayer[3].tab_fangFeng_space = cc.p( 200, 250)

    -- 获取动作组坐标、停牌提示组坐标
    self.m_sGroupPosition = cc.p( self.m_pGroupButton:getPositionX(), self.m_pGroupButton:getPositionY())
    self.m_sTingPosition = cc.p( self.m_pTingGroup:getPositionX(), self.m_pTingGroup:getPositionY())

    -- 倒计时创建时钟
    if  self.m_pTimeLeft ~= nil then

        self.m_pTimeLeftNum = cc.LabelAtlas:_create( "0", "x_number_flash.png", 17, 24, string.byte("0"))
        self.m_pTimeLeftNum:setAnchorPoint( cc.p( 0.5, 0.5))
        self.m_pTimeLeftNum:setVisible( false)
        self.m_pTimeLeft:addChild( self.m_pTimeLeftNum)
    end

    -- 语音相关的先关闭
    if  self.m_pRecordButton ~= nil then
        self.m_pRecordButton:setVisible( false)
    end

    -- 预创建牌
    self.m_bPreCreate = false
    self:preCreateMahjong()

    -- 玩家输出文字创建（减积分、加积分）
    for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do

        if  self.m_pPlayer[i].m_pNumber1 == nil then
            self.m_pPlayer[i].m_pNumber1 = cc.LabelAtlas:_create( "0", "x_number_ex1.png", 34, 44, string.byte("*"))
            self.m_pPlayer[i].m_pNumber1:setAnchorPoint( cc.p( 0.5, 0.5))
            self.m_pPlayer[i].m_pNumber1:setVisible( false)
            self:addChild( self.m_pPlayer[i].m_pNumber1)
        end

        if  self.m_pPlayer[i].m_pNumber2 == nil then
            self.m_pPlayer[i].m_pNumber2 = cc.LabelAtlas:_create( "0", "x_number_ex2.png", 34, 44, string.byte("*"))
            self.m_pPlayer[i].m_pNumber2:setAnchorPoint( cc.p( 0.5, 0.5))
            self.m_pPlayer[i].m_pNumber2:setVisible( false)
            self:addChild( self.m_pPlayer[i].m_pNumber2)
        end
    end

    -- 房号文字
    if  self.m_pRoomIDTTF == nil then
        self.m_pRoomIDTTF = cc.LabelAtlas:_create( "0", "x_number_ex2.png", 34, 44, string.byte("*"))
        self.m_pRoomIDTTF:setAnchorPoint( cc.p( 0.5, 0.5))
        self.m_pRoomIDTTF:setVisible( true)
        self.m_pRoomIDDemo:addChild( self.m_pRoomIDTTF)
    end

    -- 倒计时文字
    if  self.m_pTimeLeftTTF == nil then
        self.m_pTimeLeftTTF = cc.LabelAtlas:_create( "0", "x_number_ex3.png", 34, 44, string.byte("*"))
        self.m_pTimeLeftTTF:setAnchorPoint( cc.p( 0.5, 0.5))
        self.m_pTimeLeftTTF:setVisible( false)
        self.m_pTimeLeft:addChild( self.m_pTimeLeftTTF)
    end
    self.m_pTimeLeft:setVisible( true)

    -- 超时特效
    local pos = cc.p( g_pGlobalManagement:getWinCenter().x, g_pGlobalManagement:getWinHeight() - 50)
    self.m_pEffNetLow = CDCCBAniTxtObject.createCCBAniTxtObject( self.m_pNewLayerRoot, "x_tx_netlow.ccbi", pos, 0)
    if  self.m_pEffNetLow then

        self.m_pEffNetLow:endRelease( false)
        self.m_pEffNetLow:endVisible( false)
        self.m_pEffNetLow:setVisible( false)
    end
    -- self:resetFanTxt()
    -- 初始化桌子玩家开始坐标
    self.m_bInTheGame = false
    self.m_nSaveLordIdx = -1
    -- 初始化桌子玩家开始位置
    self:initWith_SBTableStatus( self.mjzy_replaydata)
    -- 之后创建用户，或者加入牌桌
    self:runAction( cc.Sequence:create( cc.DelayTime:create( 0.5), cc.CallFunc:create( CDLayerTable_mjzy_replay.initTablePlayer)))
    self:sendHangPing()
end

-- 初始化桌子上的所有玩家
-- 参数: nil
function CDLayerTable_mjzy_replay:initTablePlayer()
    cclog( "CDLayerTable_mjzy_replay:initTablePlayer")

    -- 检测是否是自己的回放 用于确定位置
    self.isMyTable = self:checkMyIDIsInTheTable()

    local count = TABLE_SIZE( self.mjzy_replaydata.players)

    -- 搜索自己的索引
    local my_index = 1
    if  self.isMyTable then
        local my_id = casinoclient:getInstance():getPlayerData():getId()
        
        for i = 1, count do
    
            if  self.mjzy_replaydata.players[i].id == my_id then
    
                my_index = i
                break
            end
        end
    end

    -- 设置桌子上的玩家
    local index = my_index
    for i = 1, count do

        cclog( "CDLayerTable_mjzy_replay:initTablePlayer count = %u, i = %u, index = %u", count, i, index)
        self:joinTablePlayer( self:changeOrder(i-1), self.mjzy_replaydata.players[index])
        index = index + 1
        if  index > count then
            index = 1
        end
    end
    self:reStartPlay()
end

function CDLayerTable_mjzy_replay:reStartPlay( ... )
    -- 获取一共多少局的数据
    DEF_MJZY_REPLAY_MAX_ROUND = TABLE_SIZE(self.mjzy_replaydata.replay.rounds)
    -- 获取本局的op数据
    self.curRoundOPData = self.mjzy_replaydata.replay.rounds[DEF_MJZY_REPLAY_ROUND]
    DEF_MJZY_REPLAY_OP_INDEX = 1
    -- 获取本局一共多少个的操作数据
    DEF_MJZY_REPLAY_OP_MAX_INDEX = TABLE_SIZE(self.curRoundOPData.ops)
    self:showReplayBtn(true)
    self:showCurRound()
    self:initTable()
    -- self:resetFanTxt()
    -- self:releaseEffect()
    -- self:startReadOPIndex()
    self:Handle_mjzy_StartPlay()
end

function CDLayerTable_mjzy_replay:checkMyIDIsInTheTable(  )
    local my_id = casinoclient:getInstance():getPlayerData():getId()
    for i,v in ipairs(self.mjzy_replaydata.players) do
        if  v.id == my_id then
            return true
        end
    end
    return false
end

function CDLayerTable_mjzy_replay:getPlayerIndex( target_id )

    for i = 0,3 do

        if  self.m_pPlayer[i].m_nID == target_id then
            return i
        end
    end
    return -1
end

----------------------------------------------------------------------------
-- 预创建麻将牌
function CDLayerTable_mjzy_replay:preCreateMahjong()
    cclog( "CDLayerTable_mjzy_replay:preCreateMahjong")

    if  self.m_bPreCreate then
        return
    end

    -- 最大打出牌数量,假如是二人那么要翻倍
    local nMaxOutMahjongs = self:changeMaxOutMahjongs()

    -- 手牌、打出去的牌预创建
    self.m_pPMahjongs = {}
    for j = 0, self.m_nPlayers-1 do

        local order_idx = self:changeOrder( j)
        -- 手上的牌
        self.m_pPMahjongs[order_idx] = {}
        self.m_nPMahjongs[order_idx] = 0
        for i = 1, DEF_MJZY_REPLAY_MAX_GETMAHJONG do

            local mahjong = X_MAHJONG:new()
            if  order_idx == 0 then
                mahjong.m_pMahjong = CDMahjong.createCDMahjong( self.m_pCenterDemo[0])
            else
                mahjong.m_pMahjong = CDMahjong.createCDMahjong( self.m_pMahjongOwn)
            end
            mahjong.m_nMahjong = 11
            mahjong.m_pMahjong:setMahjongNumber( 11)
            if     order_idx == 0 then
                mahjong.m_pMahjong:initMahjongWithFile( "my_b_11.png",   "mj_b_back.png")
            elseif order_idx == 1 then
                mahjong.m_pMahjong:initMahjongWithFile( "mj_r_side.png", "mj_lr_back.png")
            elseif order_idx == 2 then
                mahjong.m_pMahjong:initMahjongWithFile( "mj_s_def.png",  "mj_s_back.png")
            elseif order_idx == 3 then
                mahjong.m_pMahjong:initMahjongWithFile( "mj_l_side.png", "mj_lr_back.png")
            end
            mahjong.m_pMahjong:setVisible( false)
            mahjong.m_pMahjong:setScale( 1.0)
            mahjong.m_pMahjong:setMahjongScale( 1.0)
            if  order_idx == 1 or order_idx == 3 then
                mahjong.m_pMahjong:setScale( 0.8)
                mahjong.m_pMahjong:setMahjongScale( 0.8)
            elseif order_idx == 2 then
                mahjong.m_pMahjong:setScale( 0.9)
                mahjong.m_pMahjong:setMahjongScale( 0.9)
            end
            table.insert( self.m_pPMahjongs[order_idx], mahjong)
        end

        -- 打出的牌
        for i = 1, nMaxOutMahjongs do

            local pMahjong = CDMahjong.createCDMahjong( self.m_pMahjongOut)
            if  pMahjong ~= nil then

                if     order_idx == 0 then
                    pMahjong:initMahjongWithFile( string.format( "t_%u.png", 11))
                    pMahjong:setMahjongScale( DEF_MJZY_REPLAY_BT_OUTSCALE)
                elseif order_idx == 1 then
                    pMahjong:initMahjongWithFile( string.format( "l_%u.png", 11))
                    pMahjong:setMahjongScale( DEF_MJZY_REPLAY_LR_OUTSCALE)
                elseif order_idx == 2 then
                    pMahjong:initMahjongWithFile( string.format( "t_%u.png", 11))
                    pMahjong:setMahjongScale( DEF_MJZY_REPLAY_BT_OUTSCALE)
                elseif order_idx == 3 then
                    pMahjong:initMahjongWithFile( string.format( "r_%u.png", 11))
                    pMahjong:setMahjongScale( DEF_MJZY_REPLAY_LR_OUTSCALE)
                end

                pMahjong:setTag( (order_idx+1)*DEF_MJZY_REPLAY_OUT_IDX+i)
                pMahjong:setVisible( false)
            end
        end
    end

    -- 听牌预创建
    if  self.m_pTingGroup ~= nil and self.m_pTingList ~= nil then
    
        self.m_pTingList:removeAllChildren()
        for i = 1, DEF_MJZY_REPLAY_TING_LIST_MAX do

            self.m_pTingMahjong[i] = CDMahjong.createCDMahjong( self.m_pTingList)
            self.m_pTingMahjong[i]:initMahjongWithFile( "mj_b_back.png")
            self.m_pTingMahjong[i]:setVisible( false)
            self.m_pTingMahjong[i]:setScale( 0.85)

            self.m_pTingNumText[i]:setVisible( false)
            self.m_pTingNumFrame[i]:setVisible( false)
        end
        self.m_pTingGroup:setVisible( false)
    end

    -- 演示牌预创建
    if  self.m_pOutMahjongGroup ~= nil and self.m_pOutMahjong == nil then

        self.m_pOutMahjong = X_MAHJONG:new()
        self.m_pOutMahjong.m_pMahjong = CDMahjong.createCDMahjong( self.m_pOutMahjongGroup)
        self.m_pOutMahjong.m_nMahjong = 11

        self.m_pOutMahjong.m_pMahjong:initMahjongWithFile( "out_b_11.png", "mj_b_back.png")
        self.m_pOutMahjong.m_pMahjong:setMahjongNumber( self.m_pOutMahjong.m_nMahjong)
        self.m_pOutMahjong.m_pMahjong:setMahjongScale( 0.85)
    end

    -- 赖子赖皮
    if  self.m_pLaiZiDemo then

        self.m_pLZMahjong = CDMahjong.createCDMahjong( self.m_pLaiZiDemo)
        self.m_pLZMahjong:initMahjongWithFile( "t_11.png", "mj_b_back.png")
        self.m_pLZMahjong:setScale( 0.0)
        self.m_pLZMahjong:setIcoLaiVisible( false, true)
    end
    if  self.m_pLaiGenDemo then

        self.m_pLGMahjong = CDMahjong.createCDMahjong( self.m_pLaiGenDemo)
        self.m_pLGMahjong:initMahjongWithFile( "t_11.png", "mj_b_back.png")
        self.m_pLGMahjong:setScale( 0.0)
    end

    self.m_bPreCreate = true
end

----------------------------------------------------------------------------
-- 加入玩家
-- 参数: index位置, table_player数据
function CDLayerTable_mjzy_replay:joinTablePlayer(index,table_player)
    self.m_pPlayer[index].m_pData:CopyFrom( table_player)

    self.m_pPlayer[index].m_nID = table_player.id
    self.m_pPlayer[index].m_nSex = table_player.sex
    self.m_pPlayer[index].m_nAvatar = table_player.avatar
    self.m_pPlayer[index].m_pHead:removeAllChildren()
    if  table_player.id ~= 0 then

        self:refreshTablePlayer( index, table_player,false,table_player.id)
        
        dtCreateHead( self.m_pPlayer[index].m_pHead, table_player.sex, table_player.avatar, table_player.channel_head)
        self.m_pPlayer[index].m_pHead:setScale( 1.3)
        self.m_pPlayer[index].m_pHead:runAction( cc.EaseBackOut:create( cc.ScaleTo:create( 0.3, 1.0)))
        

        if  table_player.channel == "mac" then
            self.m_pPlayer[index].m_pIcoYK:setVisible( true)
        else
            self.m_pPlayer[index].m_pIcoYK:setVisible( false)
        end
    else

        self.m_pPlayer[index].m_pIcoYK:setVisible( false)
        self:refreshTablePlayer( index)
    end

end

function CDLayerTable_mjzy_replay:getNameById( table_data,id )

    local player_data = table_data.players
    if  player_data then
        for i,v in ipairs(player_data) do

            if  v.id == id then
                return v.nickname,v.channel_nickname
            end
        end
    end
    return false
end

-- 设置玩家信息
function CDLayerTable_mjzy_replay:refreshTablePlayer( index, table_player,isClick,playerid)
    cclog( "CDLayerTable_mjzy_replay:refreshTablePlayer")

    if  table_player ~= nil then
        local curNickname,curChannel_nickname = self:getNameById(self.mjzy_replaydata,playerid)
        if  self.m_bInTheGame and not isClick then

            if  index == 0 then
                self:refreshSelfInfo( table_player)
            else
                if  curNickname then
                    self.m_pPlayer[index].nickname = curNickname
                    self.m_pPlayer[index].channel_nickname = curChannel_nickname
                end
                self.m_pPlayer[index].m_pGold:setString( dtGetFloatString( table_player.score_total))
                                    
            end
            return
        else
            if  curNickname then
                self.m_pPlayer[index].nickname = curNickname
                self.m_pPlayer[index].channel_nickname = curChannel_nickname
                dtSetNickname( self.m_pPlayer[index].m_pGold, curNickname, curChannel_nickname)
            end
        end
        if  index == 0 then

            self:refreshSelfInfo()
        end
    else

        self.m_pPlayer[index].m_pName:setString( casinoclient.getInstance():findString("null"))
        self.m_pPlayer[index].m_pGold:setString( casinoclient.getInstance():findString("null"))
        if  index == 0 then

            self:refreshSelfInfo()
        end
    end
end

-- 设置自己的信息
function CDLayerTable_mjzy_replay:refreshSelfInfo( table_player)

    local my_id = self.m_pPlayer[0].m_nID
    local my_name = nil
    local my_channel_nickname = nil
    local my_nickname = nil
    for i,v in ipairs(self.mjzy_replaydata.players) do
        if  v.id == my_id then
            my_channel_nickname = v.channel_nickname
            my_nickname = v.nickname    
        end
    end

    my_name = dtGetNickname(my_nickname,my_channel_nickname)

    if  my_name then
        if  string.len( my_name) > 5 then
            my_name =  dtSubStringUTF8( my_name, 1, 5)
        end
    end

    if  table_player == nil then
        self.m_pSelfInfo:setString( my_name)
        return
    end

    self.m_pSelfInfo:setString( my_name..":"..dtGetFloatString(table_player.score_total))
   
end

-- 初始化桌子
-- 删除所有打出以及手上的牌，并且清除所有玩家桌面
function CDLayerTable_mjzy_replay:initTable()
    cclog("CDLayerTable_mjzy_replay::initTable")

    if  self.m_pMahjongOut ~= nil then
        self.m_pMahjongOut:stopAllActions()
        -- 这里释放为了不重复创建打出牌
        self:initAllMahjongOut()
    end

    if  self.m_pMahjongOwn ~= nil then
        self.m_pMahjongOwn:stopAllActions()
        self.m_pEffFlagLast = nil
        self:initAllMahjongOwm()
    end

    if  self.m_pMahjongEff ~= nil then
        self.m_pMahjongEff:stopAllActions()
        self.m_pMahjongEff:removeAllChildren()
    end

    if  self.m_pLZMahjong ~= nil then
        self.m_pLZMahjong:setScale( 0.0)
    end

    if  self.m_pLGMahjong ~= nil then
        self.m_pLGMahjong:setScale( 0.0)
    end

    self:setGroupButtonVisible( false)
    if  self.m_pOutMahjongGroup then
        self.m_pOutMahjongGroup:setVisible( false)
    end

    self.m_nSaveSelectIndex = 0
    self.m_bMoveSelect = false
    self.m_nOrderType = 0

    self.m_nLastMoMahjong = 0
    self.m_nLastOutMahjong = 0
    self.m_nLastOutPlayer = 0
    self.m_nLastSelect = 0

    self.m_nOutMahjong_p = 0
    self.m_nOutMahjong_m = 0

    self.m_nDrawCard_p = 0
    self.m_nDrawCard_m = 0

    self.m_bSaveSlfFlag = false
    self.m_bSaveZCHFlag = false
    self.m_bSaveOPGFlag = false
    self.m_bSaveOPPFlag = false

    self.m_nSaveOPGMahjong = 0
    self.m_nSaveOPPMahjong = 0

    self.m_bCanOutMahjong = false

    self.m_bThinkJustOut = false
    
    self:setTimeLeftVisible( false)

    local bCreate = false
    if  self.m_pPlayAI == nil then
        self.m_pPlayAI = {}
        bCreate = true
    end

    self:setOrderType( 0,false,true)
    -- self:resetFanTxt()

    for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do
        self.m_pIcoDemo[i]:removeAllChildren()
        self:clearTable( i)
        if  bCreate then
            self.m_pPlayAI[i] = CDMahjongMJZY_AI.create()
        end
        self.m_pPlayAI[i]:clearAllMahjongs()
        if  self.m_pPlayer ~= nil then

            if  self.m_pPlayer[i].m_pIcoReady ~= nil then
                self.m_pPlayer[i].m_pIcoReady:setVisible( false)
            end
        end
    end

    if  self.m_pCenterDire ~= nil then
        self.m_pCenterDire:removeAllChildren()
    end

    if  self.m_pTimeLeftTTF ~= nil then
        self.m_pTimeLeftTTF:setVisible( false)
        self.m_nTimeLeft = 0
    end

    if  self.m_pGroupForgo ~= nil then
        self.m_pGroupForgo:setVisible( false)
    end

end

----------------------------------------------------------------------------
-- function CDLayerTable_mjzy_replay:resetFanTxt( ... )
--     for i=0,DEF_MJZY_REPLAY_MAX_PLAYER-1 do
--         if  self.m_pPlayer[i].m_pFanTxt then
--             self.m_pPlayer[i].m_pFanTxt:setString("")
--             self.m_pPlayer[i].m_pFanTxt:setVisible(false)
--         end
--     end
-- end
-- 获取番数 位置索引
-- function CDLayerTable_mjzy_replay:checkEveryFan( index )
--     if  index and self.m_pPlayer[index].m_pFanTxt then
--         local outGroup = self.m_pPlayAI[index]:getNMahjong()
--         local putCards = self.m_pPlayAI[index]:getOutCards()
--         local curFan = self.mahjong_mjzy:checkTableFanWithPlayer(outGroup,putCards)
--         if  curFan >0 then
--             self.m_pPlayer[index].m_pFanTxt:setString(string.format("+%d番",curFan))
--             self.m_pPlayer[index].m_pFanTxt:setVisible(true)
--         else
--             self.m_pPlayer[index].m_pFanTxt:setVisible(false)
--         end
--     end
-- end
-- 清空指定位置的桌子
-- 参数: 位置
function CDLayerTable_mjzy_replay:clearTable( order_type)
    cclog("CDLayerTable_mjzy_replay::clearTable")

    if  order_type >= 0 and order_type < DEF_MJZY_REPLAY_MAX_PLAYER then

        self.m_pPlayTable[order_type]:removeAllChildren()
        self.m_sOutNumber[order_type] = 0
        self.m_pPlayer[order_type].tab_max = 0.0
        self.m_pPlayer[order_type].tab_min_scale = 1.0
    end
end

-- 初始化已经创建过的打出牌
function CDLayerTable_mjzy_replay:initAllMahjongOut()
    cclog("CDLayerTable_mjzy_replay::initAllMahjongOut")

    local nOutMaxMahjongs = self:changeMaxOutMahjongs()
    for i = 0, self.m_nPlayers-1 do

        local order_idx = self:changeOrder( i)
        local count = TABLE_SIZE( self.m_pPMahjongs[order_idx])
        if  count > 0 then

            for j = 1, nOutMaxMahjongs do

                cclog( "initAllMahjongOut(idx=%u,nOMM=%u,idx=%u",order_idx, nOutMaxMahjongs, (order_idx+1)*DEF_MJZY_REPLAY_OUT_IDX+j)
                local pMahjong = self.m_pMahjongOut:getChildByTag( (order_idx+1)*DEF_MJZY_REPLAY_OUT_IDX+j)
                if  pMahjong ~= nil then

                    if  i%2 == 0 then
                        pMahjong:setMahjongScale( DEF_MJZY_REPLAY_BT_OUTSCALE)
                    else
                        pMahjong:setMahjongScale( DEF_MJZY_REPLAY_LR_OUTSCALE)
                    end
                    pMahjong:setVisible( false)
                end
            end
        end
    end
end

-- 初始化所有玩家手牌
function CDLayerTable_mjzy_replay:initAllMahjongOwm()
    cclog("CDLayerTable_mjzy_replay::initAllMahjongOwm")

    for i = 0, self.m_nPlayers-1 do

        local order_idx = self:changeOrder( i)
        self.m_nPMahjongs[ order_idx] = 0
        local count = TABLE_SIZE( self.m_pPMahjongs[order_idx])
        if  count > 0 then

            for j = 1, DEF_MJZY_REPLAY_MAX_GETMAHJONG do

                local mahjong = self.m_pPMahjongs[order_idx][j]
                mahjong.m_nMahjong = 11
                mahjong.m_pMahjong:setMahjongNumber( 11)
                if     order_idx == 0 then
                    mahjong.m_pMahjong:initMahjongWithFile( "my_b_11.png",   "mj_b_back.png")
                elseif order_idx == 1 then
                    mahjong.m_pMahjong:initMahjongWithFile( "mj_r_side.png", "mj_lr_back.png")
                elseif order_idx == 2 then
                    mahjong.m_pMahjong:initMahjongWithFile( "mj_s_def.png",  "mj_s_back.png")
                elseif order_idx == 3 then
                    mahjong.m_pMahjong:initMahjongWithFile( "mj_l_side.png", "mj_lr_back.png")
                end

                mahjong.m_pMahjong:setVisible( false)
                mahjong.m_pMahjong:setScale( 1.0)
                mahjong.m_pMahjong:setIcoLaiVisible( false, false)

                mahjong.m_bSelect = false
                mahjong.m_bVaild = true
            end
        end
    end
end

----------------------------------------------------------------------------
-- 设置桌面信息
function CDLayerTable_mjzy_replay:refreshTableInfo()

    self.m_pButRobot:setVisible(false)
    self.m_pButChat:setVisible(false)
    self.m_pButSponsor:setVisible(false)
    self.m_pTxtSponsor:setVisible(false)

    local total = 1
    if  self.mahjong_mjzy ~= nil then
        total = self.mahjong_mjzy:mahjongTotal_get()
        if  total < 0 then
            total = 0
        end
    end

    local round_str = nil
    if  DEF_MJZY_REPLAY_ROUND >= DEF_MJZY_REPLAY_MAX_ROUND then
        round_str = casinoclient.getInstance():findString("round_last")
    else
        round_str = string.format( casinoclient:getInstance():findString("round_num"), DEF_MJZY_REPLAY_MAX_ROUND-DEF_MJZY_REPLAY_ROUND)
    end

    self.m_pTableInfo:setString(
        string.format( casinoclient.getInstance():findString("table_info1"), 
        total, dtGetFloatString( self.mjzy_replaydata.base), round_str))
    
end

function CDLayerTable_mjzy_replay:openPlayerInfo( index )
    print("openPlayerInfo::index---->",index)
    --  玩家不存在或者ID为0
    if  self.m_pPlayer == nil or
        self.m_pPlayer[index] == nil or
        self.m_pPlayer[index].m_nID == nil or 
        self.m_pPlayer[index].m_nID == 0 then
        return
    end
    --  头像如果是空那么
    if  self.m_pPlayer[index].m_pHead == nil or
        self.m_pPlayer[index].m_pHead:getChildrenCount() == 0 then
        return
    end

    if  self.headIsClick then
        self.headIsClick = false
    else
        self.headIsClick = true
    end

    for i=1,self.m_nPlayers-1 do
        local curIndex = self:changeOrder(i)
        for j,k in ipairs(self.curRoundOPData.scores) do
            if  self.m_pPlayer[curIndex].m_nID == k.player_id then
                self:refreshTablePlayer(curIndex,k,self.headIsClick,k.player_id)
            end
        end
    end

end

----------------------------------------------------------------------------

-- 所有玩家准备结束，可以进行发牌的反馈
function CDLayerTable_mjzy_replay:Handle_mjzy_StartPlay( )
    g_pSceneTable:closeAllUserInterface()
    
    if  not self.mahjong_mjzy then
        self.mahjong_mjzy = CDMahjongMJZY.create()
    end

    if  DEF_MJZY_REPLAY_ROUND == 1 then
        self.m_nSaveLordIdx = -1
    end

    self.mahjong_mjzy:setMahjongLaiZi( self.curRoundOPData.laizi)
    self.mahjong_mjzy:setMahjongFan( self.curRoundOPData.fanpai)
    -- self.mahjong_mjzy:setFlagPiao( false)

    DEF_MJZY_REPLAY_LAI = self.curRoundOPData.laizi
    DEF_MJZY_REPLAY_FAN = self.curRoundOPData.fanpai

    --  初始化桌子
    self:initTable()
    self.mahjong_mjzy:mahjongTotal_set()
    self.mahjong_mjzy:mahjongTotal_lower( self:changeLowerMahjongTotal()) -- 每人13张且1张翻牌
    self:refreshTableInfo()
    --   避免游戏开始了还要进入之前没有进入的计算画面
    self.m_pTimeLeftTTF:stopAllActions()
    if  g_pSceneTable.m_pLayerMJScore:isVisible() then
        g_pSceneTable.m_pLayerMJScore:close()
    end
    
    --  分配四家牌
    for i,v in ipairs(self.curRoundOPData.scores) do
        local curIndex = self:getPlayerIndex(v.player_id)
        self.mahjong_mjzy:randomMahjongs( v.initcards)
        -- dumpArray(v.initcards)
        -- dumpArray(v.cards)
        self.m_pPlayAI[curIndex]:addVMahjong_withArray( v.initcards)
    end

    -- 初始化指针
    self.m_nLordID = self.curRoundOPData.lord_id
    self:setOrderType( self:getPlayerIndex(self.m_nLordID),false,true)
    --  发牌
    self.m_bInTheGame = true
    self:round_startLicensing()
end

-- 发牌
function CDLayerTable_mjzy_replay:round_startLicensing()
    cclog("CDLayerTable_mjzy_replay::round_startLicensing")

    -- 发牌需要的数据记录
    for i = 0, self.m_nPlayers-1 do

        local order_idx = self:changeOrder( i)
        self.m_sLicensingTotal[order_idx] = self.m_pPlayAI[order_idx]:getVMahjongsSize()
        -- 设置摸到的牌        
        for j = 1, DEF_MJZY_REPLAY_DEF_MAHJONGS do

            self.m_nPMahjongs[order_idx] = j

            local pMahjong = self.m_pPMahjongs[order_idx][INDEX_ITOG(order_idx,j)]
            pMahjong.m_nMahjong = self.m_pPlayAI[order_idx]:getVMahjong( j)
            pMahjong.m_pMahjong:setMahjongNumber( pMahjong.m_nMahjong)
            if  order_idx == 0 then
                pMahjong.m_pMahjong:setMahjong( string.format( "my_b_%u.png", pMahjong.m_nMahjong))
            end
        end
        -- 重置桌子
        self:resetTableMahjongs(order_idx)
        -- 准备图标隐藏
        self.m_pPlayer[order_idx].m_pIcoReady:setVisible( false)
    end
    -- 最后一张牌标记
    if  self.m_pEffFlagLast == nil then
        self.m_pEffFlagLast = CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_last.ccbi", cc.p( 0, 0), 0)

        if  self.m_pEffFlagLast ~= nil then
            self.m_pEffFlagLast:endRelease( false)
            self.m_pEffFlagLast:endVisible( false)
            self.m_pEffFlagLast:setVisible( false)
        end
    end
    -- 开始动态发牌
    self:stopAllActions()

    self.m_nLicensingType = 0
   
    self:round_licensingPlayer()
end


-- 向玩家发牌
function CDLayerTable_mjzy_replay:round_licensingPlayer()
    cclog("CDLayerTable_mjzy_replay::round_licensingPlayer")

    if  self.m_nLicensingType == 0 then -- 开局文字(自建房才有)    
        local effect = CDCCBAniObject.createCCBAniObject(self.m_pMahjongEff, "x_tx_kaiju.ccbi", g_pGlobalManagement:getWinCenter(), 0)
        if  effect then
            effect:endVisible( true)
            effect:endRelease( true)
        end

        self.m_nLicensingType = 1
        self:runAction( cc.Sequence:create( cc.DelayTime:create( 0.7), cc.CallFunc:create( CDLayerTable_mjzy_replay.round_licensingPlayer)))
        dtPlaySound( DEF_SOUND_MJ_KJ)

    elseif  self.m_nLicensingType == 1 then -- 进入位置(自建房才有）
        for i = 0, self.m_nPlayers-1 do
            local order_idx = self:changeOrder( i)
            self.m_pPlayer[order_idx].m_pFrame:runAction( 
                cc.Sequence:create(cc.EaseBackOut:create(cc.MoveTo:create(0.3, self.m_pPlayer[order_idx].m_sPosEnd)), cc.ScaleTo:create(0.1, 0.85)))
        end

        self.m_nLicensingType = 2
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(CDLayerTable_mjzy_replay.round_licensingPlayer)))

        self.m_pGroupSelfBuild:setVisible( false)

        local e_pos = cc.p(self.m_pGroupBar:getPositionX(), self.m_pGroupBar:getPositionY())
        local b_pos = cc.p(e_pos.x, e_pos.y - 50)
        self.m_pGroupBar:setVisible(true)
        self.m_pGroupBar:setPosition(b_pos)
        self.m_pGroupBar:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.2, e_pos)))
        dtPlaySound(DEF_SOUND_MOVE)

    elseif self.m_nLicensingType == 2 then -- 定庄

        self.m_pPlayer[0].m_pFrame:setVisible( false)
        local zhuang_idx = self:getPlayerIndex( self.m_nLordID)
        if  zhuang_idx >= 0 and zhuang_idx <= self.m_nPlayers then

            if  self.m_nSaveLordIdx >= 0 then

                local zhuang_eff = nil
                if  self.m_nSaveLordIdx == zhuang_idx then
                    zhuang_eff = CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_lianzhuang.ccbi", g_pGlobalManagement:getWinCenter(), 0)
                else
                    zhuang_eff = CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_huanzhuang.ccbi", g_pGlobalManagement:getWinCenter(), 0)
                end
                if  zhuang_eff then
                    zhuang_eff:endRelease( true)
                    zhuang_eff:endVisible( true)
                end
            end
            self.m_nSaveLordIdx = zhuang_idx

            local zhuang_ico = CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_zhuang.ccbi", g_pGlobalManagement:getWinCenter(), 0)
            if  zhuang_ico then
                zhuang_ico:endRelease( false)
                zhuang_ico:endVisible( false)
                local e_pos = cc.p( self.m_pPlayer[zhuang_idx].m_pFrame:getPositionX()+22, self.m_pPlayer[zhuang_idx].m_pFrame:getPositionY()-20)
                zhuang_ico:runAction( cc.Sequence:create( cc.DelayTime:create( 1.2), cc.MoveTo:create( 0.3, e_pos)))
                dtPlaySound( DEF_SOUND_ZHUANG)
            end
        end

        self.m_pGroupLeftTop:setVisible( true)

        self.m_nLicensingType = 3
        self:runAction( cc.Sequence:create( cc.DelayTime:create( 1.5), cc.CallFunc:create( CDLayerTable_mjzy_replay.round_licensingPlayer)))
    elseif self.m_nLicensingType == 3 then -- 翻赖子

        local b_pos = cc.p( 0, 0)
        local center= cc.p( 0, 0)

        --  显示赖根
        if  self.m_pLGMahjong then
            self.m_pLGMahjong:setMahjong( string.format( "t_%u.png", self.mahjong_mjzy:getMahjongFan()))
            center = cc.p( g_pGlobalManagement:getWinWidth()*0.5-40, g_pGlobalManagement:getWinHeight()*0.5)
            b_pos = self.m_pLaiGenDemo:convertToNodeSpace( center)

            self.m_pLGMahjong:setScale( 1.2)
            self.m_pLGMahjong:setPosition( b_pos)
            self.m_pLGMahjong:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.3, 0.98)), cc.DelayTime:create( 0.3), cc.EaseBackOut:create( cc.MoveTo:create( 0.3, cc.p( 0, 0)))))
        end

        --  显示赖子
        if  self.m_pLZMahjong then
            self.m_pLZMahjong:setMahjong( string.format( "t_%u.png", self.mahjong_mjzy:getMahjongLaiZi()))
            center = cc.p( g_pGlobalManagement:getWinWidth()*0.5+40, g_pGlobalManagement:getWinHeight()*0.5)
            b_pos = self.m_pLaiZiDemo:convertToNodeSpace( center)

            self.m_pLZMahjong:setScale( 0.0)
            self.m_pLZMahjong:setPosition( b_pos)
            self.m_pLZMahjong:runAction( cc.Sequence:create( cc.DelayTime:create( 0.5), cc.ScaleTo:create( 0.01, 1.2), cc.EaseBackOut:create( cc.ScaleTo:create( 0.3, 0.98)), cc.DelayTime:create( 0.3), cc.EaseBackOut:create( cc.MoveTo:create( 0.5, cc.p( 0, 0)))))
            self.m_pLZMahjong:setIcoLaiVisible( false, true)
        end
        dtPlaySound( DEF_SOUND_MJ_OUT)

        self.m_nLicensingOrder = 0
        self.m_nLicensingType = 4
        self:runAction( cc.Sequence:create( cc.DelayTime:create( 0.6), cc.CallFunc:create( CDLayerTable_mjzy_replay.round_licensingPlayer)))
    elseif self.m_nLicensingType == 4 then -- 发牌

        local size = self.m_pPlayAI[self.m_nLicensingOrder]:getVMahjongsSize()
        local index = size - self.m_sLicensingTotal[ self.m_nLicensingOrder]
        local number = 0

        if  self.m_sLicensingTotal[self.m_nLicensingOrder] > 0 then

            number = self.m_sLicensingTotal[self.m_nLicensingOrder]
            if  number >= 4 then
                number = 4
            end
        end

        for i = 1, number do

            self.m_pPMahjongs[self.m_nLicensingOrder][ INDEX_ITOG(self.m_nLicensingOrder, index+i)].m_pMahjong:stopAllActions()
            self.m_pPMahjongs[self.m_nLicensingOrder][ INDEX_ITOG(self.m_nLicensingOrder, index+i)].m_pMahjong:setScale( 1.0)
            self.m_pPMahjongs[self.m_nLicensingOrder][ INDEX_ITOG(self.m_nLicensingOrder, index+i)].m_pMahjong:setVisible( true)
        end

        dtPlaySound( DEF_SOUND_MJ_CLICK)
        self.m_sLicensingTotal[self.m_nLicensingOrder] = self.m_sLicensingTotal[self.m_nLicensingOrder] - number

        local over = true
        for i = 0, self.m_nPlayers-1 do
            local order_idx = self:changeOrder( i)
            if  self.m_sLicensingTotal[order_idx] > 0 then
                over = false
                break
            end
        end

        if  not over then

            self.m_nLicensingOrder = self.m_nLicensingOrder + 1
            if  self.m_nLicensingOrder >= self.m_nPlayers then
                self.m_nLicensingOrder = 0
            end
            self.m_nLicensingOrder = self:changeOrder( self.m_nLicensingOrder)            
            self:runAction( cc.Sequence:create( cc.DelayTime:create( 0.1), cc.CallFunc:create( CDLayerTable_mjzy_replay.round_licensingPlayer)))
        else

            -- 确保所有牌已经正常显示(遍历一边)
            for i = 0, self.m_nPlayers-1 do

                local order_idx = self:changeOrder(i)
                size = self.m_pPlayAI[order_idx]:getVMahjongsSize()
                for j = 1, size do
                    self.m_pPMahjongs[order_idx][ INDEX_ITOG(order_idx, j)].m_pMahjong:stopAllActions()
                    self.m_pPMahjongs[order_idx][ INDEX_ITOG(order_idx, j)].m_pMahjong:setScale( 1.0)
                    self.m_pPMahjongs[order_idx][ INDEX_ITOG(order_idx, j)].m_pMahjong:setVisible( true)
                end
            end
  
            -- 进入到下一个阶段round_arrangeMahjongs
            self.m_nArrangeType = 0        
            self:runAction( cc.Sequence:create( cc.DelayTime:create( 0.1), cc.CallFunc:create( CDLayerTable_mjzy_replay.round_arrangeMahjongs)))
        end
    end
end
----------------------------------------------------------------------------
-- 整理牌效果
function CDLayerTable_mjzy_replay:round_arrangeMahjongs()
    cclog("CDLayerTable_mjzy_replay::round_arrangeMahjongs")

    local index = 0
    dtPlaySound( DEF_SOUND_MJ_OUT)
    if  self.m_nArrangeType == 0 then

        for i = 0, self.m_nPlayers-1 do

            local order_idx = self:changeOrder( i)
            local size = self.m_nPMahjongs[order_idx]
            for j = 1, size do

                index = INDEX_ITOG( order_idx, j)
                self.m_pPMahjongs[order_idx][index].m_pMahjong:setBackVisible( true)
                self.m_pPMahjongs[order_idx][index].m_pMahjong:setFaceVisible( false)
            end
        end

        self.m_nArrangeType = 1
        self:runAction( cc.Sequence:create( cc.DelayTime:create( 0.5), cc.CallFunc:create( CDLayerTable_mjzy_replay.round_arrangeMahjongs)))
    else

        for i = 0, self.m_nPlayers-1 do

            local order_idx = self:changeOrder( i)
            local array = self.m_pPlayAI[order_idx]:getAllVMahjongs()
            local size = self.m_nPMahjongs[order_idx]
            table.sort( array, mahjong_mjzy_table_comps_stb_Replay)--显示排序，赖子放到最左边
            for j = 1, size do

                index = INDEX_ITOG( order_idx, j)
                self.m_pPMahjongs[order_idx][index].m_pMahjong:setBackVisible( false)
                self.m_pPMahjongs[order_idx][index].m_pMahjong:setFaceVisible( true)

                self.m_pPMahjongs[order_idx][index].m_nMahjong = array[j].mahjong
                if  order_idx == 0 then
            
                    self.m_pPMahjongs[order_idx][index].m_pMahjong:setMahjong( string.format( "out_b_%u.png", self.m_pPMahjongs[order_idx][index].m_nMahjong))
          
                elseif order_idx == 1 then
                    
                    self.m_pPMahjongs[order_idx][index].m_pMahjong:setMahjong( string.format( "l_%u.png", self.m_pPMahjongs[order_idx][index].m_nMahjong))

                elseif order_idx == 2 then
                    
                    self.m_pPMahjongs[order_idx][index].m_pMahjong:setMahjong( string.format( "t_%u.png", self.m_pPMahjongs[order_idx][index].m_nMahjong))

                elseif order_idx == 3 then  
                    
                    self.m_pPMahjongs[order_idx][index].m_pMahjong:setMahjong( string.format( "r_%u.png", self.m_pPMahjongs[order_idx][index].m_nMahjong))
                    
                end
                self.m_pPMahjongs[order_idx][index].m_pMahjong:setMahjongNumber( self.m_pPMahjongs[order_idx][index].m_nMahjong)
                self:myMahjong_setIcoLai( self.m_pPMahjongs[order_idx][index])
            end
        end


        for i,v in ipairs(self.curRoundOPData.scores) do

            local order_type = self:getPlayerIndex( v.player_id)

            self:refreshTablePlayer( order_type, v,false,v.player_id)
            self.m_pPlayAI[order_type]:sortAllVMahjongs( self.mahjong_mjzy)
        end
        self.m_nOrderType = -1
        self:resetOrderText()
    end
    self:runAction( cc.Sequence:create( cc.DelayTime:create( 0.5), cc.CallFunc:create( CDLayerTable_mjzy_replay.startReadOPIndex)))
end

function CDLayerTable_mjzy_replay:resetOrderText(bool)
    cclog( "CDLayerTable_mjzy_replay:resetOrderText")

    -- 设置空
    if  self.m_pOrderIcoP ~= nil then
        self.m_pOrderIcoP:removeAllChildren()

        for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do
            self.m_pPlayer[i].m_pOrderText = nil
        end
    end

    if  bool then
        if  self.m_pOrderIcoP then
            self.m_pOrderIcoP:setVisible(false)
        end
        return
    end

    local my_id = self.m_pPlayer[0].m_nID
    local index = -1
    for i,v in ipairs(self.mjzy_replaydata.players) do
        if  v.id == my_id then
            index = i-1
            break
        end
    end

    -- 加入是两个人并且我不是东那么我一定是西
    if  self.m_nPlayers == 2 and index == 1 then
        index = 2
    end

    local pos = { cc.p(  29, -13), cc.p(  74,  30), cc.p(  29,  73), cc.p( -14,  30)}

    if  index >= 0 then

        for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do

            local file_name = string.format( "x_mj_vec%d.png", index)
            self.m_pPlayer[i].m_pOrderText = cc.Sprite:createWithSpriteFrameName( file_name)
            self.m_pPlayer[i].m_pOrderText:setPosition( pos[i+1])
            self.m_pOrderIcoP:addChild( self.m_pPlayer[i].m_pOrderText)
            index = index + 1
            if  index > DEF_MJZY_REPLAY_MAX_PLAYER-1 then
                index = 0
            end
        end
        self.m_pOrderIcoP:setVisible(true)
    end
end
----------------------------------------------------------------------------
-- 回合位置变更及摸牌处理
function CDLayerTable_mjzy_replay:round_MoMahjong( order_type, mahjong)
    cclog("CDLayerTable_mjzy::round_MoMahjong")

    self:setOrderType( order_type,true,false)

    self.m_nLastMoMahjong = mahjong
    -- 对应位置处理回合出牌
    self.m_pPlayAI[order_type]:addVMahjong( mahjong)
    self.m_pPlayAI[order_type]:sortAllVMahjongs( self.mahjong_mjzy)
    self:round_addMahjong( mahjong, order_type)

    self:resetTableMahjongs( order_type, nil, true)
    dtPlaySound( DEF_SOUND_MJ_MO)
end
-- 回合添加／删除牌
-- 参数: 牌，位置
function CDLayerTable_mjzy_replay:round_addMahjong( mahjong, order_type)
    cclog("CDLayerTable_mjzy::round_addMahjong")

    self.m_nPMahjongs[order_type] = self.m_nPMahjongs[order_type] + 1
    if  self.m_nPMahjongs[order_type] > DEF_MJZY_REPLAY_MAX_GETMAHJONG then
        self.m_nPMahjongs[order_type] = DEF_MJZY_REPLAY_MAX_GETMAHJONG
    end

    local index = INDEX_ITOG( order_type, self.m_nPMahjongs[order_type])

    self.m_pPMahjongs[ order_type][index].m_nMahjong = mahjong
    self.m_pPMahjongs[ order_type][index].m_pMahjong:setMahjongNumber( mahjong)
    self.m_pPMahjongs[ order_type][index].m_pMahjong:setVisible( true)

    if  mahjong ~= 0 then
        if  order_type == 0 then
            self.m_pPMahjongs[ order_type][index].m_pMahjong:setMahjong( string.format( "out_b_%u.png", mahjong))
            
        elseif order_type == 1 then
            self.m_pPMahjongs[ order_type][index].m_pMahjong:setMahjong( string.format( "l_%u.png", mahjong))
        elseif order_type == 2 then
            self.m_pPMahjongs[ order_type][index].m_pMahjong:setMahjong( string.format( "t_%u.png", mahjong))
        elseif order_type == 3 then
            self.m_pPMahjongs[ order_type][index].m_pMahjong:setMahjong( string.format( "r_%u.png", mahjong))
        end
        self:myMahjong_setIcoLai( self.m_pPMahjongs[ order_type][index])
    end
end

function CDLayerTable_mjzy_replay:round_delMahjong( order_type)
    cclog("CDLayerTable_mjzy::round_delMahjong")

    local index = INDEX_ITOG( order_type, self.m_nPMahjongs[order_type])
    self.m_nPMahjongs[order_type] = self.m_nPMahjongs[order_type]-1
    if  self.m_nPMahjongs[order_type] < 1 then
        self.m_nPMahjongs[order_type] = 1
    end

    self.m_pPMahjongs[ order_type][index].m_nMahjong = 0
    self.m_pPMahjongs[ order_type][index].m_pMahjong:setMahjongNumber( 0)
    self.m_pPMahjongs[ order_type][index].m_pMahjong:setVisible( false)
end
----------------------------------------------------------------------------
--出牌
function CDLayerTable_mjzy_replay:putOutCard( order,mahjong )

    self:round_SendOutMahjong( order,mahjong)
    
end

----------------------------------------------------------------------------
-- 出牌处理效果(自己)
-- 参数: 所出的牌索引
function CDLayerTable_mjzy_replay:round_SendOutMahjong( order,mahjong)

    dtPlaySound( DEF_MJZY_SOUND_MJ_OUT)

    self.m_nLastOutMahjong = mahjong
    self.m_nLastOutPlayer = order
    self:round_OutMahjongShow_Front(mahjong,order)

    self.m_pPlayAI[order]:addIMahjong( mahjong)
    
end

----------------------------------------------------------------------------
-- 出牌(前半段)
-- 参数: mahjong牌, order_type位置
function CDLayerTable_mjzy_replay:round_OutMahjongShow_Front( mahjong, order_type)
    cclog( "CDLayerTable_mjzy:round_OutMahjongShow_Front mahjong = (%u)", mahjong)

    if  order_type < 0 then
        return
    end

    -- 大牌显示，打出的牌
    self.m_pOutMahjong.m_pMahjong:setMahjong( string.format( "my_b_%u.png", mahjong))
    self.m_pOutMahjong.m_pMahjong:setMahjongNumber( mahjong)
    self.m_pOutMahjong.m_nMahjong = mahjong
    self:myMahjong_setIcoLai( self.m_pOutMahjong)

    local start = cc.p( 0, 0)
    local index = 0
    local size = 0
    if  order_type == 0 then

        index = self:myMahjong_getIndexWithOutMahjong( order_type,mahjong)
        if  index > 0 then
            index = INDEX_ITOG( 0, index)
            start = cc.p( self.m_pPMahjongs[0][index].m_pMahjong:getPositionX(), self.m_pPMahjongs[0][index].m_pMahjong:getPositionY())
            start = self.m_pCenterDemo[0]:convertToWorldSpace( start)
        end
    else

        index = self.m_nPMahjongs[order_type]
        index = INDEX_ITOG( order_type, index)
        start = cc.p(   self.m_pPMahjongs[order_type][index].m_pMahjong:getPositionX(),
                        self.m_pPMahjongs[order_type][index].m_pMahjong:getPositionY())
    end
    local pos = cc.p( self.m_pOutDemo[order_type]:getPositionX(), self.m_pOutDemo[order_type]:getPositionY())

    self.m_pOutMahjongGroup:stopAllActions()
    self.m_pOutMahjongGroup:setVisible( true)
    self.m_pOutMahjongGroup:setPosition( start)
    self.m_pOutMahjongGroup:setScale( 1.0)
    self.m_pOutMahjongGroup:runAction( cc.EaseBackOut:create( cc.MoveTo:create( 0.15, pos)))

    -- 玩家出牌数量加1，并且朗读牌面，记录出牌索引及牌
    self.m_sOutNumber[order_type] = self.m_sOutNumber[order_type] + 1
    self:changeNowOutMahjongs( order_type) -- 新增加
    self:readMahjong( mahjong, 0, order_type)
    self.m_nOutMahjong_p = order_type
    self.m_nOutMahjong_m = mahjong

    -- 假如是自己那么删除打出的牌

    self.m_pPlayAI[order_type]:delVMahjong( mahjong)

    self:round_delMahjong( order_type)
    self:myMahjongs_refresh(order_type)
    self:resetTableMahjongs( order_type)
end

----------------------------------------------------------------------------
-- 刷新自己的牌，排序后的调整
function CDLayerTable_mjzy_replay:myMahjongs_refresh(order_type)
    cclog("CDLayerTable_mjzy_replay::myMahjongs_refresh")

    local array = self.m_pPlayAI[order_type]:getAllVMahjongs()
    table.sort( array, mahjong_mjzy_table_comps_stb_Replay)         --显示排序，赖子放到最左边

    print("array----------------->")
    local  temp= self.mahjong_mjzy:getValueFromArr(array) 
    dumpArray(temp)

    local size  = TABLE_SIZE( array)

    if  order_type ~=1 then
        
        local index = self:getMahjongIndexWithVaild( order_type, true)
        local count = self.m_nPMahjongs[order_type]
    
        for i = 1, size do
    
            if  index <= count then

                if  self.m_pPMahjongs[order_type][index].m_nMahjong ~= array[i].mahjong then
    
                    self.m_pPMahjongs[order_type][index].m_nMahjong = array[i].mahjong
                    if  order_type == 0 then
                        self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjong( string.format( "out_b_%u.png", array[i].mahjong))
                    elseif order_type == 1 then
                        self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjong( string.format( "l_%u.png", array[i].mahjong))
                    elseif order_type == 2 then
                        self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjong( string.format( "t_%u.png", array[i].mahjong))
                    elseif order_type == 3 then
                        self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjong( string.format( "r_%u.png", array[i].mahjong))
                    end 
    
                    self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjongNumber( array[i].mahjong)
                    
                    self.m_pPMahjongs[order_type][index].m_pMahjong:setVisible( true)
    
                    self:myMahjong_setIcoLai( self.m_pPMahjongs[order_type][index])
                end
    
                self.m_pPMahjongs[order_type][index].m_bSelect = false
                self.m_pPMahjongs[order_type][index].m_pMahjong:setIcoTingVisible( false) -- 取消听牌ICO的显示
            end
            index = index + 1
        end
    else

        local index = INDEX_ITOG(order_type,self:getMahjongIndexWithVaild( order_type, true))

        local minIndex = INDEX_ITOG( order_type, self.m_nPMahjongs[order_type])
 
        for i = 1, size do

            if  index >= minIndex then
                if  self.m_pPMahjongs[order_type][index].m_nMahjong ~= array[i].mahjong then
        
                    self.m_pPMahjongs[order_type][index].m_nMahjong = array[i].mahjong 
                    self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjong( string.format( "l_%u.png", array[i].mahjong))
                    self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjongNumber( array[i].mahjong)
                      
                    self.m_pPMahjongs[order_type][index].m_pMahjong:setVisible( true)

                    self:myMahjong_setIcoLai( self.m_pPMahjongs[order_type][index])
                end
        
                self.m_pPMahjongs[order_type][index].m_bSelect = false
                self.m_pPMahjongs[order_type][index].m_pMahjong:setIcoTingVisible( false) -- 取消听牌ICO的显示
            end
            index = index - 1
            
        end
    end
    if  order_type == 0 then
        self.m_nSaveSelectIndex = 0
    end
end

-- 搜索有效牌索引
-- 参数: 位置索引, vaild有效/无效
function CDLayerTable_mjzy_replay:getMahjongIndexWithVaild( order, vaild)
    cclog("CDLayerTable_mjzy::getMahjongIndexWithVaild")

    if  order < 0 or order > DEF_MJZY_REPLAY_MAX_PLAYER-1 then
        return -1
    end

    if  vaild == nil then
        vaild = true
    end

    for i = 1, self.m_nPMahjongs[order] do

        local index = INDEX_ITOG( order, i)
        if  self.m_pPMahjongs[order][index].m_bVaild == vaild and 
            self.m_pPMahjongs[order][index].m_pMahjong and 
            self.m_pPMahjongs[order][index].m_pMahjong:isVisible() then
            return i
        end
    end
    return -1
end

----------------------------------------------------------------------------
-- 出牌(后半段)
-- 参数: mahjong牌, order_type位置
function CDLayerTable_mjzy_replay:round_OutMahjongShow_Back( op_ack)
    cclog( "CDLayerTable_mjzy:round_OutMahjongShow_Back ok_ack = (%u)", op_ack)

    -- 打出的牌放下后的处理
    local function playOutMahjongSound()

        dtPlaySound( DEF_SOUND_MJ_OUT)
        self:showLastMahjongFlag( true)

        if  self.m_nLastOutMahjongTag <= 0 then
            return
        end

        local child = self.m_pMahjongOut:getChildByTag( self.m_nLastOutMahjongTag)
        if  child == nil then
            return
        end

        -- if  child:isLaiZi( self.mahjong_mjzy:getMahjongLaiZi()) then
        --     local curEffect = "x_lz_gang.ccbi"
        --     local pos = cc.p( child:getPositionX(), child:getPositionY())
        --     local eff = CDCCBAniObject.createCCBAniObject( self, curEffect, pos, 0)
        --     if  eff ~= nil then
        --         self.m_pEffFlagLast:endRelease( true)
        --         self.m_pEffFlagLast:endVisible( true)
        --     end
        --     dtPlaySound( DEF_SOUND_MJ_LZ_PIAO)
        -- end 

    end

    self.m_pOutMahjongGroup:setVisible( false)

    if  self.m_nOutMahjong_p < 0 or self.m_nOutMahjong_m == 0 then
        return
    end
    local order_type = self.m_nOutMahjong_p
    local mahjong = self.m_nOutMahjong_m

    -- 碰、点笑、笑朝天不进行牌放出，直接返回
    if  op_ack == DEF_MJZY_REPLAY_OP_PENG or 
        op_ack == DEF_MJZY_REPLAY_OP_XIAOCHAOTIAN or 
        op_ack == DEF_MJZY_REPLAY_OP_GANG_M or 
        op_ack == TABLE_OP_CHI or 
        op_ack == DEF_MJZY_REPLAY_OP_GANG_B then

        self.m_nOutMahjong_p = -1
        self.m_nOutMahjong_m = 0
        self.m_bSaveSlfFlag = false
        return
    end

    -- 找到与创建牌后使用
    local number = self:getPlayerOutNumber( order_type)
    local nTag = (order_type+1)*DEF_MJZY_REPLAY_OUT_IDX+number
    local pMahjong = self.m_pMahjongOut:getChildByTag( nTag)
    print("pMahjong----->",pMahjong)
    if  pMahjong then

        if     order_type == 0 then
            -- 是自己的话那么这里退出，因为进入这里只是为了纠正打出的牌而已
            if  self.m_bSaveSlfFlag then

                if  pMahjong:getMahjongNumber() ~= mahjong then
                    pMahjong:setMahjong( string.format( "t_%u.png", mahjong))
                    pMahjong:setMahjongNumber( mahjong)
                end
                self.m_bSaveSlfFlag = false
                return
            else
                pMahjong:setMahjong( string.format( "t_%u.png", mahjong))
            end
            pMahjong:setMahjongScale( DEF_MJZY_REPLAY_BT_OUTSCALE)
        elseif order_type == 1 then
            pMahjong:setMahjong( string.format( "l_%u.png", mahjong))
            pMahjong:setMahjongScale( DEF_MJZY_REPLAY_LR_OUTSCALE)
        elseif order_type == 2 then
            pMahjong:setMahjong( string.format( "t_%u.png", mahjong))
            pMahjong:setMahjongScale( DEF_MJZY_REPLAY_BT_OUTSCALE)
        elseif order_type == 3 then
            pMahjong:setMahjong( string.format( "r_%u.png", mahjong))
            pMahjong:setMahjongScale( DEF_MJZY_REPLAY_LR_OUTSCALE)
        end

        pMahjong:setMahjongNumber( mahjong)
        self.m_nLastOutMahjongTag = nTag
        if  mahjong == self.mahjong_mjzy:getMahjongLaiZi() then -- or mahjong == 51 then
            pMahjong:setLaiZiColor()
        end

        local w_total = self:changeXMahjongs()
        local start = cc.p( self.m_pOutMahjongGroup:getPositionX(), self.m_pOutMahjongGroup:getPositionY())
        local toPos = cc.p( 0, 0)
        local nWarp = math.floor( (number-1)/w_total)
        local nNum = (number-1)%w_total

        toPos = cc.p(   self.m_sOutStart[order_type].x + nNum * self.m_sOutSpace[order_type].x + nWarp * self.m_sOutWrap[order_type].x, 
                        self.m_sOutStart[order_type].y + nNum * self.m_sOutSpace[order_type].y + nWarp * self.m_sOutWrap[order_type].y)

        pMahjong:setVisible( true)

        -- 假如op不是胡那么播放牌动画，否则直接放下牌
        if  op_ack ~= TABLE_OP_HU and op_ack ~= TABLE_OP_ZIMO then

            pMahjong:setPosition( start)
            pMahjong:setScale( 1.25)
            pMahjong:stopAllActions()
            pMahjong:runAction( cc.Sequence:create( 
                cc.MoveTo:create( 0.15, toPos), cc.ScaleTo:create( 0.15, 1), cc.CallFunc:create( playOutMahjongSound)))
        else

            pMahjong:setPosition( toPos)
            pMahjong:setScale( 1.0)
            playOutMahjongSound()
        end
    end
end

----------------------------------------------------------------------------
-- 玩家出牌的网络反馈
-- 参数: 数据包
function CDLayerTable_mjzy_replay:Handle_mjzy_OutCard_Ack( player_id,mahjong)
    cclog("CDLayerTable_mjzy:Handle_mjzy_OutCard_Ack")

    local index = self:getPlayerIndex(player_id)
    self.m_nLastOutMahjong = mahjong
    self.m_nLastOutPlayer = index
    self:round_OutMahjongShow_Front( mahjong, index)

    -- 记录一张已经用掉的牌
    if  index ~= - 1 then

        self.m_pPlayAI[index]:addIMahjong( pAck.card)
    end

    return true
end

----------------------------------------------------------------------------
-- 搜索指定牌在自己牌组中的位置
-- 参数: 指定牌
function CDLayerTable_mjzy_replay:myMahjong_getMahjongIndex( order,mahjong)
    cclog("CDLayerTable_mjzy::myMahjong_getMahjongIndex")

    local count = self.m_nPMahjongs[order]
    local index = 0
    for i = 1, count do

        if  self.m_pPMahjongs[order][i].m_bVaild and self.m_pPMahjongs[order][i].m_nMahjong == mahjong then
            return i
        end
    end
    return -1
end

-- 搜索索引根据打出的牌
-- 参数: 指定牌
function CDLayerTable_mjzy_replay:myMahjong_getIndexWithOutMahjong( order,mahjong)

    local count = self.m_nPMahjongs[0]
    local index = 0
    for i = 1, count do

        index = INDEX_ITOG( 0, i)
        if  self.m_pPMahjongs[order][index].m_nMahjong == mahjong and
            self.m_pPMahjongs[order][index].m_pMahjong:getPositionY() > self.m_pPMahjongs[order][index].m_sPosition.y then
            return i
        end
    end
    return self:myMahjong_getMahjongIndex( order,mahjong)
end

-- 显示最后一张牌的指示标记
function CDLayerTable_mjzy_replay:showLastMahjongFlag( visible)
    cclog( "CDLayerTable_mjzy:showLastMahjongFlag")

    if  self.m_pEffFlagLast == nil then
        return
    end

    if  visible then

        if  self.m_nLastOutPlayer >= 0 and self.m_nLastOutPlayer < DEF_MJZY_REPLAY_MAX_PLAYER then

            if  self.m_sOutNumber[ self.m_nLastOutPlayer] > 0 then

                local x_total = self:changeXMahjongs()
                local number = self:getPlayerOutNumber( self.m_nLastOutPlayer)
                local nWarp = math.floor( (number-1)/x_total)
                local nNum = (number-1)%x_total
                toPos = cc.p(   self.m_sOutStart[self.m_nLastOutPlayer].x + nNum * self.m_sOutSpace[self.m_nLastOutPlayer].x + nWarp * self.m_sOutWrap[self.m_nLastOutPlayer].x, 
                                self.m_sOutStart[self.m_nLastOutPlayer].y + nNum * self.m_sOutSpace[self.m_nLastOutPlayer].y + nWarp * self.m_sOutWrap[self.m_nLastOutPlayer].y)
                self.m_pEffFlagLast:setPosition( toPos)
                self.m_pEffFlagLast:setVisible( true)
            end
        end
    else

        self.m_pEffFlagLast:setVisible( false)
    end
end

----------------------------------------------------------------------------
-- 吃牌之后 服务器返回的处理 
function CDLayerTable_mjzy_replay:operateChi( order_type, array, target_idx,target_card)
    cclog("CDLayerTable_mjzy_replay::operateChi(type = %u, id = %u)", order_type, target_idx)

    self:showEffectWithOperate( order_type, 200)  -- 吃的特效
    self:readMahjong( 1, 200, order_type)        -- 吃 语音

    self.m_pPlayAI[order_type]:addSMahjong( array)               -- 把牌加到摊派组中
    self.m_pPlayAI[order_type]:addNMahjong( array, target_idx, DEF_MJZY_OP_CHI,order_type,target_card)
    
    local del_mahjong = {}

    del_mahjong = self.mahjong_mjzy:getOwnArrFromArr( array, target_card)

    self.m_pPlayAI[order_type]:delVMahjongs( del_mahjong)        --  把自己的两张牌添加到无效的牌组中

    self:round_addMahjong( target_card, order_type)
    self:resetMahjongWithArray( order_type, array)
    self:myMahjongs_refresh( order_type)

    self:resetTableMahjongs( order_type)
    -- 删除被吃的玩家的碰牌
    self:deleteMahjong( order_type, target_idx)
    -- 添加已经用掉的牌
    for i = 1, TABLE_SIZE( del_mahjong) do
        self.m_pPlayAI[order_type]:addIMahjong( del_mahjong[i])
    end
    -- 关闭最后牌指定标记
    self:showLastMahjongFlag( false)

end
----------------------------------------------------------------------------
-- 显示碰牌处理
-- 参数: 位置对象, 碰牌组
function CDLayerTable_mjzy_replay:operatePeng( order_type, array, targetIndex)
    cclog("CDLayerTable_mjzy::operatePeng(type = %u, id = %u)", order_type, targetIndex)

    self:showEffectWithOperate( order_type, DEF_MJZY_REPLAY_OP_PENG)
    self:readMahjong( 1, DEF_MJZY_REPLAY_OP_PENG, order_type)

    self.m_pPlayAI[order_type]:addSMahjong( array)
    self.m_pPlayAI[order_type]:addNMahjong( array, targetIndex, DEF_MJZY_OP_PENG,order_type )
                                            

    local del_mahjong = {}
    self.mahjong_mjzy:push_back( del_mahjong, array, 1, 2)

    self.m_pPlayAI[order_type]:delVMahjongs( del_mahjong)
  
    self:round_addMahjong( array[1],order_type)
    self:resetMahjongWithArray( order_type, array)
    self:myMahjongs_refresh(order_type)

    self:resetTableMahjongs( order_type)
    -- 删除被碰的玩家的碰牌
    self:deleteMahjong( order_type, targetIndex)
    -- 添加已经用掉的牌
    for i = 1, TABLE_SIZE( array)-1 do
        self.m_pPlayAI[order_type]:addIMahjong( array[i])
    end
    -- 关闭最后牌指定标记
    self:showLastMahjongFlag( false)
end
----------------------------------------------------------------------------
-- 补杠带来的刷新
-- 参数: 位置
function CDLayerTable_mjzy_replay:operateGang_buRefresh( order_type)
    cclog("CDLayerTable_mjzy::operateGang_buRefresh")

    -- 找出按顺序排列的第一个有效对象转为无效对象
    local ref_idx = self:getMahjongIndexWithVaild( order_type, true)
    local index = INDEX_ITOG( order_type, ref_idx)

    self.m_pPMahjongs[order_type][index].m_bVaild = false
    self.m_pPMahjongs[order_type][index].m_nMahjong = 0

    -- 根据无效牌，和摊牌组的对象比对来进行刷新
    ref_idx = self:getMahjongIndexWithVaild( order_type, false)
    local size = self.m_pPlayAI[order_type]:getNMahjongSize()
    for i = 1, size do

        local group_s = self.m_pPlayAI[order_type]:getNMahjongWithIndex( i)
        local count = TABLE_SIZE( group_s.mahjongs)
        for j = 1, count do

            index = INDEX_ITOG( order_type, ref_idx)
            if  self.m_pPMahjongs[order_type][index].m_nMahjong ~= group_s.mahjongs[j] then

                self.m_pPMahjongs[order_type][index].m_nMahjong = group_s.mahjongs[j]
                self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjongNumber( group_s.mahjongs[j])
                if order_type == 0 then
                    self.m_pPMahjongs[0][index].m_pMahjong:setMahjong( string.format( "out_b_%u.png", group_s.mahjongs[j]))
                    self:myMahjong_setIcoLai( self.m_pPMahjongs[0][index])
                elseif order_type == 1 then
                    self.m_pPMahjongs[1][index].m_pMahjong:setMahjong( string.format( "l_%u.png", group_s.mahjongs[j]))
                elseif order_type == 2 then
                    self.m_pPMahjongs[2][index].m_pMahjong:setMahjong( string.format( "t_%u.png", group_s.mahjongs[j]))
                elseif order_type == 3 then
                    self.m_pPMahjongs[3][index].m_pMahjong:setMahjong( string.format( "r_%u.png", group_s.mahjongs[j]))
                end
            end
            ref_idx = ref_idx + 1
        end
    end
end

----------------------------------------------------------------------------
-- 杠牌处理
function CDLayerTable_mjzy_replay:operateGang( mahjong, gang_type, order_type,tag_idx )
    cclog( "CDLayerTable_mjzy:operateGang(%u)", gang_type)

    local s_count = 0
    local v_count = 0
    local type = 0
    if  gang_type == DEF_MJZY_REPLAY_OP_GANG_M then            --点笑
        s_count = 4
        v_count = 3
        type = DEF_MJZY_OP_GANG_M
        self:deleteMahjong( order_type, tag_idx)
    elseif gang_type == DEF_MJZY_REPLAY_OP_GANG_A then        --闷笑
        s_count = 4
        v_count = 4
        type = DEF_MJZY_OP_GANG_A
    elseif gang_type == DEF_MJZY_REPLAY_OP_GANG_B then      --回头笑
        s_count = 1
        v_count = 1
        type = DEF_MJZY_OP_GANG_B
    elseif gang_type == DEF_MJZY_REPLAY_OP_XIAOCHAOTIAN then    --翻牌点笑
        s_count = 3
        v_count = 2
        type = DEF_MJZY_OP_GANG_M
        self:deleteMahjong( order_type, tag_idx)
    elseif gang_type == DEF_MJZY_REPLAY_OP_DACHAOTIAN then      --翻牌闷笑
        s_count = 3
        v_count = 3
        type = DEF_MJZY_OP_GANG_A
    end

    if  s_count <= 0 then
        return
    end

    local array = {}
    for i = 1, s_count do
        array[i] = mahjong
    end

    self:showEffectWithOperate( order_type, gang_type)
    self:readMahjong( 1, gang_type, order_type)

    self.m_pPlayAI[order_type]:addSMahjong( array)
    self.m_pPlayAI[order_type]:addNMahjong( array, tag_idx, type, order_type)


    self.m_pPlayAI[order_type]:delVMahjongs( array)
    -- 只有明杠才需要补充一张牌，自己要在这里先加
    if  type == DEF_MJZY_OP_GANG_M then
        self:round_addMahjong( mahjong, order_type)
    end       

    if  type == DEF_MJZY_OP_GANG_B then
        self:operateGang_buRefresh( order_type, mahjong)
    else
        self:resetMahjongWithArray( order_type, array)
    end

    self:myMahjongs_refresh(order_type)
 
    self:resetTableMahjongs( order_type)
    for i = 1, v_count do
        self.m_pPlayAI[order_type]:addIMahjong( mahjong)
    end

    if  type == DEF_MJZY_OP_GANG_M then
        self:showLastMahjongFlag( false)
    end
    -- self:checkEveryFan(order_type)
end

----------------------------------------------------------------------------
-- 删除被别人碰或者杠的已经打出的牌
-- 参数:
function CDLayerTable_mjzy_replay:deleteMahjong( order_type, target_idx)

    if  target_idx ~= order_type and target_idx >= 0 then

        local nTag = ( target_idx+1)*DEF_MJZY_REPLAY_OUT_IDX+self:getPlayerOutNumber(target_idx)
        local pUsefulMahjong = self.m_pMahjongOut:getChildByTag( nTag)
        if  pUsefulMahjong then

            -- local pMahjong = self.m_pMahjongOut:getChildByTag( nTag)
            -- if  pMahjong then
                -- pMahjong:setVisible( false)
            -- end
            pUsefulMahjong:setVisible( false)
            self.m_sOutNumber[target_idx] = self.m_sOutNumber[target_idx] - 1
        end
    end
end
----------------------------------------------------------------------------

-- 刷新牌在它定义的范围内
-- 参数: 位置, 数量（默认空), 是否摸牌排列（默认空)
-- 返回: 所占用的范围尺寸
function CDLayerTable_mjzy_replay:resetTableMahjongs( idx, number, is_mo)
    cclog( "CDLayerTable_mjzy_replay:resetTableMahjongs")

    if  idx < 0 or idx >= DEF_MJZY_REPLAY_MAX_PLAYER then
        return 0
    end

    local count = self.m_nPMahjongs[idx]
    if  count <= 0 and number == nil then
        return 0
    end

    if  is_mo == nil then
        is_mo = false
    end
    -- 偏移使用X，还是Y的定义
    local spce = self.m_pPlayer[idx].tab_spce.x   -- 牌间
    local size = self.m_pPlayer[idx].tab_size.x   -- 尺寸
    local scal = self.m_pPlayer[idx].tab_ori_scal -- 手牌
    local smin = self.m_pPlayer[idx].tab_out_scal -- 摊牌缩放
    local gaps = self.m_pPlayer[idx].tab_gaps.x   -- 摊牌与手牌间隔

    if  idx%2 == 1 then
        spce = self.m_pPlayer[idx].tab_spce.y
        size = self.m_pPlayer[idx].tab_size.y
        gaps = self.m_pPlayer[idx].tab_gaps.y
    end

    local abs_spce = math.abs( spce)
    local abs_gaps = math.abs( gaps)
    -- 获取要使用的范围（注意不可少于14张牌）
    local need_size = 0
    local bValue = true
    local notValueNum = 0
    local nowValueNum = 0
    if  number ~= nil then

        if  number < 14 then
            number = 14
        end
        need_size = abs_spce * (number-1) + size*scal
    else
        -- 获取无效有（摊牌），有效牌（手牌）数量
        for i = 1, count do

            if  not self.m_pPMahjongs[idx][INDEX_ITOG(idx,i)].m_bVaild then
                notValueNum = notValueNum + 1
            else
                nowValueNum = nowValueNum + 1
            end
        end
        if  notValueNum > 0 then -- 摊牌范围
            bValue = false
            if  idx == 0 then
                need_size = abs_spce*(smin/scal) * (notValueNum-1) + size*smin + abs_gaps
            else
                need_size = abs_spce*(notValueNum-1) + abs_gaps
            end
        end
        if  nowValueNum > 0 then -- 手牌范围
            need_size = need_size + abs_spce*(nowValueNum-1) + size*scal
        end

        if  (nowValueNum + notValueNum) < 14 and idx == 0 then
            need_size = need_size + abs_spce*( 14 - nowValueNum - notValueNum)
        end
    end
    -- 假如是自己那么再加上左右间隔以及最后一张牌的间隔
    if  idx == 0 then
        need_size = need_size + 10 + DEF_MJZY_REPLAY_MYTABLE_SPACE*2
    end
    -- 沿用最大尺寸
    if  need_size > self.m_pPlayer[idx].tab_max then
        self.m_pPlayer[idx].tab_max = need_size
    else
        need_size = self.m_pPlayer[idx].tab_max
    end
    -- 获取整体缩放值
    local now_scale = 1.0
    local ori_size = g_pGlobalManagement:getWinWidth()*self.m_pPlayer[idx].tab_percent
    if  idx%2 == 1 then
        ori_size = g_pGlobalManagement:getWinHeight()*self.m_pPlayer[idx].tab_percent
    end
    now_scale = ori_size/need_size
    if  now_scale < self.m_pPlayer[idx].tab_min_scale then
        self.m_pPlayer[idx].tab_min_scale = now_scale
    else-- 沿用最小缩放
        now_scale = self.m_pPlayer[idx].tab_min_scale
    end
    if  idx == 0 then -- 自己要设置缩放到节点
        self.m_pCenterDemo[0]:setScale( now_scale)
        self.m_pCenterDire:setScale( now_scale)
    end

    -- 麻将开始位置
    local pos = 0
    if  idx == 0 then                   -- 自己

        if  bValue then
            pos = -need_size*0.5 + size*smin*0.5
        else
            pos = -need_size*0.5 + size*scal*0.5
        end
        pos = pos + DEF_MJZY_REPLAY_MYTABLE_SPACE
    elseif idx == 1 then                -- 右边

        if  bValue then
            pos = self.m_pPlayer[idx].tab_center.y - need_size*now_scale*0.5 + size*scal*now_scale*0.5
        else
            pos = self.m_pPlayer[idx].tab_center.y - need_size*now_scale*0.5 + abs_gaps
        end
    elseif idx == 3 then                -- 左边

        if  bValue then
            pos = self.m_pPlayer[idx].tab_center.y + need_size*now_scale*0.5 - size*scal*now_scale*0.5
        else
            pos = self.m_pPlayer[idx].tab_center.y + need_size*now_scale*0.5 -- - abs_gaps
        end
    elseif idx == 2 then                -- 顶上玩家

        if  bValue then
            pos = self.m_pPlayer[idx].tab_center.x + need_size*now_scale*0.5 - size*smin*now_scale*0.5
        else
            pos = self.m_pPlayer[idx].tab_center.x + need_size*now_scale*0.5 - size*scal*now_scale*0.5
        end
    end

    -- 设置所有牌的位置，以及缩放值
    local addTimes = 0
    local maxTimes = 0
    local bak_total = 0
    local bak_index = 0
    local bak_center = cc.p( 0, 0)
    for i = 1, count do

        local index = INDEX_ITOG( idx, i)
        local next  = INDEX_ITOG( idx, i+1)
        -- 当牌的有效标志发生变化时，坐标增加间隔
        if  self.m_pPMahjongs[idx][index].m_bVaild ~= bValue then

            bValue = self.m_pPMahjongs[idx][index].m_bVaild
            if  idx == 0 then
                pos = pos + gaps
            else
                pos = pos + gaps*now_scale
            end
        end

        -- self.m_pPMahjongs[idx][index].m_pMahjong:stopAllActions()
        -- self.m_pPMahjongs[idx][index].m_pMahjong:setVisible( true)
        self.m_pPMahjongs[idx][index].m_pMahjong:setScale( 1.0)

        -- 区分X、Y双轴的变化
        if  idx == 0 then
            self.m_pPMahjongs[idx][index].m_sPosition.x = pos
            self.m_pPMahjongs[idx][index].m_sPosition.y = 0
        elseif idx == 1 or idx == 3 then
            self.m_pPMahjongs[idx][index].m_sPosition.y = pos
            self.m_pPMahjongs[idx][index].m_sPosition.x = self.m_pPlayer[idx].tab_center.x
        elseif idx == 2 then
            self.m_pPMahjongs[idx][index].m_sPosition.x = pos
            self.m_pPMahjongs[idx][index].m_sPosition.y = self.m_pPlayer[idx].tab_center.y
        end
        self.m_pPMahjongs[idx][index].m_pMahjong:setPosition( self.m_pPMahjongs[idx][index].m_sPosition)
        -- 有效、无效的缩放值设置，以及Y轴的设置
        if  self.m_pPMahjongs[idx][index].m_bVaild then
            if  idx == 0 then
                self.m_pPMahjongs[idx][index].m_pMahjong:setMahjongScale( scal)
            else
                self.m_pPMahjongs[idx][index].m_pMahjong:setMahjongScale( scal*now_scale)
            end
        else
            if  idx == 0 then
                local y_spc = size*smin - size*scal
                self.m_pPMahjongs[idx][index].m_pMahjong:setPositionY( y_spc*0.5)
                self.m_pPMahjongs[idx][index].m_pMahjong:setMahjongScale( smin)
            else
                self.m_pPMahjongs[idx][index].m_pMahjong:setMahjongScale( smin*now_scale)
            end
        end
        -- 当还有下一个对象的时候设置坐标偏移
        if  i < count then

            if  self.m_pPMahjongs[idx][ INDEX_ITOG( idx, i+1)].m_bVaild then
                if  idx == 0 then
                    pos = pos + spce
                else
                    pos = pos + spce*now_scale
                end
            else
                if  idx == 0 then
                    pos = pos + spce*(smin/scal)
                else
                    pos = pos + spce*now_scale
                end
            end
        elseif i == count and nowValueNum > 1 then

            if  is_mo then

                if  idx%2 == 1 then
                    self.m_pPMahjongs[idx][index].m_sPosition.y = self.m_pPMahjongs[idx][index].m_sPosition.y + gaps
                else
                    self.m_pPMahjongs[idx][index].m_sPosition.x = self.m_pPMahjongs[idx][index].m_sPosition.x + gaps 
                end
                self.m_pPMahjongs[idx][index].m_pMahjong:setPosition( self.m_pPMahjongs[idx][index].m_sPosition)
            end
        end
        -- 摊牌标记添加
        if  not self.m_pPMahjongs[idx][index].m_bVaild and i < count then

            bak_center.x = bak_center.x + self.m_pPMahjongs[idx][index].m_sPosition.x
            bak_center.y = bak_center.y + self.m_pPMahjongs[idx][index].m_sPosition.y
            bak_total = bak_total + 1


            local group_s = self.m_pPlayAI[idx]:getNMahjongWithMahjong( self.m_pPMahjongs[idx][index].m_pMahjong:getMahjongNumber(),i)
            if  group_s ~= nil then
                
                if  group_s.type_op == DEF_MJZY_OP_PENG then
                    maxTimes = 3
                end
                if  group_s.type_op == DEF_MJZY_OP_GANG_M or group_s.type_op == DEF_MJZY_OP_GANG_A or 
                    group_s.type_op == DEF_MJZY_OP_GANG_B then
                    maxTimes = 4
                end
                addTimes = addTimes + 1
        
                if  addTimes == maxTimes then
                    addTimes = 0
                    bak_index = bak_index + 1
                    local ico_tag = nil
                    if  idx == 0 then
                        ico_tag = self.m_pCenterDire:getChildByTag( (idx+1)*DEF_MJZY_REPLAY_ICO_IDX+bak_index)
                    else
                        ico_tag = self.m_pMahjongEff:getChildByTag( (idx+1)*DEF_MJZY_REPLAY_ICO_IDX+bak_index)
                    end
                    if  ico_tag == nil then
                        if  idx == 0 then
                            ico_tag = cc.Sprite:createWithSpriteFrameName( "xn_ico_tag.png")
                            self.m_pCenterDire:addChild( ico_tag)
                        else
                            ico_tag = cc.Sprite:createWithSpriteFrameName( "xn_ico_tags.png")
                            self.m_pMahjongEff:addChild( ico_tag)
                        end
                        ico_tag:setTag( (idx+1)*DEF_MJZY_REPLAY_ICO_IDX+bak_index)
                    end
                    local rotate = group_s.tag_idx * (-90.0)
                    ico_tag:setRotation( rotate)
                       
                    if  idx == 0 then                       
                        ico_tag:setPosition( 
                            cc.p( bak_center.x/bak_total+self.m_pPlayer[idx].tab_tag_space.x, 
                            bak_center.y/bak_total+self.m_pPlayer[idx].tab_tag_space.y))
                    else
                        ico_tag:setPosition( 
                            cc.p( bak_center.x/bak_total+self.m_pPlayer[idx].tab_tag_space.x*now_scale, 
                            bak_center.y/bak_total+self.m_pPlayer[idx].tab_tag_space.y*now_scale))
                    end
                    ico_tag:setScale( self.m_pPlayer[idx].tab_tag_scale)
                    bak_total = 0
                    bak_center = cc.p( 0, 0)
                end

               
            end
        end
    end
    return need_size
end

----------------------------------------------------------------------------
-- 获取玩家出牌数
-- 参数: index玩家索引
function CDLayerTable_mjzy_replay:getPlayerOutNumber( order_type)

    local x_total = self:changeXMahjongs()
    local x_total2 = x_total * 2

    -- 从上排到下排
    if      order_type == 0 then

        return self.m_sOutNumber[0]
    elseif  order_type == 1 then

        return (DEF_MJZY_REPLAY_MAX_OUTMAHJONG+1 - self.m_sOutNumber[1])
    elseif  order_type == 2 then

        if  self.m_sOutNumber[2] > x_total2 then
            return (self.m_sOutNumber[2] - x_total2)
        elseif self.m_sOutNumber[2] < x_total+1 then
            return (self.m_sOutNumber[2] + x_total2)
        else
            return self.m_sOutNumber[2]
        end
    elseif  order_type == 3 then

        if  self.m_sOutNumber[3] > x_total2 then
            return ( self.m_sOutNumber[3] - x_total2)
        elseif self.m_sOutNumber[3] < x_total+1 then
            return ( self.m_sOutNumber[3] + x_total2)
        else
            return self.m_sOutNumber[3]
        end
    end
end

----------------------------------------------------------------------------
-- 设置当前指针根据玩家位置(指针表现)
-- 参数:方向, 是否动态改变(默认true)
function CDLayerTable_mjzy_replay:setOrderType( order, ani,bool)
    cclog("CDLayerTable_mjzy_replay::setOrderType(%d)", order)

    if  ani == nil then
        ani = true
    end

    if  bool then
        self.m_pOrderIco:setVisible(false)
        self.m_pOrderIcoP:setVisible(false)
    else
        self.m_pOrderIco:setVisible(true)
        self.m_pOrderIcoP:setVisible(true)
    end

    local idx = self:changeOrder( order)

    for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do
        if  idx == i then
            if  self.m_pPlayer[i].m_pOrderText ~= nil then
                self.m_pPlayer[i].m_pOrderText:setOpacity( 255)
            end
        else
            if  self.m_pPlayer[i].m_pOrderText ~= nil then
                self.m_pPlayer[i].m_pOrderText:setOpacity( 150)
            end
        end
    end

    local rotate = -90 * idx
    if  ani then
        self.m_pOrderIco:stopAllActions()
        self.m_pOrderIco:runAction( cc.EaseBackOut:create( cc.RotateTo:create( 0.15, rotate)))
    else
        self.m_pOrderIco:setRotation( rotate)
    end
end

----------------------------------------------------------------------------
-- 重置麻将牌，根据数组
-- 参数: 位置对象, 用于改变的牌组
function CDLayerTable_mjzy_replay:resetMahjongWithArray( order_type, array, hu_pai)
    cclog("CDLayerTable_mjzy::resetMahjongWithArray(%u)size=[%u]", order_type, TABLE_SIZE(array))

    if  hu_pai == nil then
        hu_pai = false
    end

    local size = TABLE_SIZE( array)
    local index = 0
    local mahjong = 0
    local count = self.m_nPMahjongs[order_type]

    for i = 1, size do

        if  hu_pai then
            index = i
        else
            index = self:getMahjongIndexWithVaild( order_type, true)
        end

        mahjong = array[i]
        if  index <= count then

            index = INDEX_ITOG( order_type, index)
            if  order_type == 0 then

                self.m_pPMahjongs[0][index].m_bVaild = false
                self.m_pPMahjongs[0][index].m_nMahjong = mahjong
                self.m_pPMahjongs[0][index].m_pMahjong:setMahjong( string.format( "out_b_%u.png", mahjong))
                self.m_pPMahjongs[0][index].m_pMahjong:setMahjongNumber( mahjong)

                self:myMahjong_setIcoLai( self.m_pPMahjongs[0][index])
                self.m_pPMahjongs[0][index].m_pMahjong:setIcoTingVisible( false)
            else

                if  order_type == 1 then
                    self.m_pPMahjongs[1][index].m_pMahjong:setMahjong( string.format( "l_%u.png", mahjong))
                elseif order_type == 2 then
                    self.m_pPMahjongs[2][index].m_pMahjong:setMahjong( string.format( "t_%u.png", mahjong))
                elseif order_type == 3 then
                    self.m_pPMahjongs[3][index].m_pMahjong:setMahjong( string.format( "r_%u.png", mahjong))
                end

                if  hu_pai and mahjong == self.mahjong_mjzy:getMahjongLaiZi() then

                    self.m_pPMahjongs[order_type][index].m_pMahjong:setLaiZiColor()
                end

                self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjongNumber( mahjong)
                self.m_pPMahjongs[order_type][index].m_nMahjong = mahjong
                self.m_pPMahjongs[order_type][index].m_bVaild = false
            end
        end
    end
end
----------------------------------------------------------------------------
-- 设置牌中的赖子标示是否显示
-- 参数: 需要判断的牌对象
function CDLayerTable_mjzy_replay:myMahjong_setIcoLai( pMahjong)
    cclog("CDLayerTable_mjzy_replay::myMahjong_setIcoLai")

    if  pMahjong == nil then
        return
    end

    if  pMahjong.m_pMahjong ~= nil then

        if  pMahjong.m_nMahjong == self.mahjong_mjzy:getMahjongLaiZi() then

            pMahjong.m_pMahjong:setIcoLaiVisible( false, true)
        else

            pMahjong.m_pMahjong:setIcoLaiVisible( false, false)
        end
        --pMahjong.m_pMahjong:setTipHZP( 0)
    end
end

----------------------------------------------------------------------------
-- 转换获取开局用掉的牌数(4人、2人转换用）
function CDLayerTable_mjzy_replay:changeLowerMahjongTotal()

    if  self.m_nPlayers == 2 then
        return 13*2 
    else
        return 13*4 
    end
end
----------------------------------------------------------------------------
-- 退出桌子到大厅
function CDLayerTable_mjzy_replay:onGotoHall()
    cclog("CDLayerTable_mjzy_replay::onExit")
    DEF_MJZY_REPLAY_ROUND  = 1 
    DEF_MJZY_REPLAY_OP_INDEX = 1
    TABLE_READRPLAYDATA_SPACRE = 1
    g_pSceneTable:gotoSceneHall()
    dtPlaySound( DEF_SOUND_TOUCH)
end
----------------------------------------------------------------------------
-- 音乐设置
function CDLayerTable_mjzy_replay:onMusic()

    local bMusic = g_pGlobalManagement:isEnableMusic()
    g_pGlobalManagement:enableMusic( not bMusic)
end

----------------------------------------------------------------------------
-- 音效设置
function CDLayerTable_mjzy_replay:onSound()

    local bSound = g_pGlobalManagement:isEnableSound()
    g_pGlobalManagement:enableSound( not bSound)
end

----------------------------------------------------------------------------
-- 切换AI的卡牌显示
function CDLayerTable_mjzy_replay:onInfo()
    cclog("CDLayerTable_mjzy_replay::onInfo")

end

----------------------------------------------------------------------------
-- 胡牌
function CDLayerTable_mjzy_replay:onHuPai()
    cclog("CDLayerTable_mjzy_replay::onHuPai")

    self:setGroupButtonVisible( false)

end

----------------------------------------------------------------------------
-- 碰牌
function CDLayerTable_mjzy_replay:onPengPai()
    cclog("CDLayerTable_mjzy_replay::onPengPai")

    self:setGroupButtonVisible( false)
   
end

----------------------------------------------------------------------------
-- 杠牌
function CDLayerTable_mjzy_replay:onGangPai()
    cclog("CDLayerTable_mjzy_replay::onGangPai")

    self:setGroupButtonVisible( false)

end

----------------------------------------------------------------------------
-- 关闭按钮组处理
function CDLayerTable_mjzy_replay:onCloseFrame()
    cclog("CDLayerTable_mjzy_replay::onCloseFrame")

    self:setGroupButtonVisible( false)
end

----------------------------------------------------------------------------
-- 设置操作按钮组开启状态
-- 参数:是否开启
function CDLayerTable_mjzy_replay:setGroupButtonVisible( bVisible)

    if  self.m_pGroupButton == nil or 
        self.m_pGroupButton:isVisible() == bVisible then
        return false
    end

    self.m_pGroupButton:setVisible( bVisible)
    if  bVisible then

        local position = cc.p( self.m_sGroupPosition.x + 200, self.m_sGroupPosition.y)
        self.m_pGroupButton:setPosition( position)
        self.m_pGroupButton:runAction( cc.EaseBackOut:create( cc.MoveTo:create( 0.15, self.m_sGroupPosition)))
        dtPlaySound( DEF_SOUND_MOVE)
    
    end
    return true
end

----------------------------------------------------------------------------
-- 设置中间倒计时时钟是否显示
-- 参数:是否显示
function CDLayerTable_mjzy_replay:setTimeLeftVisible(visible)
    cclog( "CDLayerTable_mjzy:setTimeLeftVisible")

    self.m_pOrderIco:setVisible( visible)
    self.m_pTimeLeftNum:setVisible( visible)

    if  not visible then
        self.m_pTimeLeftNum:stopAllActions()
    end
end


----------------------------------------------------------------------------
-- 进入结算的反馈，已经有玩家胡牌
-- 参数: 数据包
function CDLayerTable_mjzy_replay:Handle_Table_Score( scoreData)
    cclog("CDLayerTable_mjzy:Handle_Table_Score")
    self:setOrderType( 0,false,true)
    self:resetOrderText(true)
    -- 设置胡牌效果
    local count = TABLE_SIZE( scoreData.scores)
    for i = 1, count do

        local player_score = scoreData.scores[i]
        if  player_score.hupai_card > 0 then

            local index = self:getPlayerIndex( player_score.player_id)
            self:displayHu( index, scoreData.scores[i])
        end            
    end
    -- 离开游戏状态并且设置倒计时
    self.m_bInTheGame = false

    self.m_nTimeLeft = 3
    self.m_nScoreTime = 9 - self.m_nTimeLeft

    self:showLeftTimeGotoScore()

end

----------------------------------------------------------------------------
-- 倒计时转到结算
function CDLayerTable_mjzy_replay:showLeftTimeGotoScore()
    cclog( "CDLayerTable_mjzy:showLeftTimeGotoScore")

    local enterScoreTime = TABLE_ENTERSCORE_TIME/TABLE_READRPLAYDATA_SPACRE

    if  not self.m_pTimeLeftTTF:isVisible() then
        self.m_pTimeLeftTTF:setVisible( true)
    end

    local function leftTime_low()

        self.m_pTimeLeftTTF:stopAllActions()
        if  self.m_nTimeLeft <= 0 then

            -- 临时增加的判断为了避免在下一局开始的时候进入到结算画面
            if  not self.m_bInTheGame then

                g_pSceneTable:closeAllUserInterface()
                g_pSceneTable.m_pLayerMJScore:open( self.curRoundOPData,self.mjzy_replaydata,self.mahjong_mjzy, self.m_nLordID,self)
                if  self.m_pPlayAI then
                    for i,v in ipairs(self.m_pPlayAI) do
                        v:release()
                    end
                end
                if  self.m_pReplayBtnPlay:isVisible() then
                    cc.Director:getInstance():getActionManager():resumeTarget(self)
                end
                self:showReplayBtn(false)
                self:initTable()
                self:runAction( cc.Sequence:create( cc.DelayTime:create( enterScoreTime), cc.CallFunc:create( CDLayerTable_mjzy_replay.replayNextData)))

            end
        else
            local waitTime = 0.75 /TABLE_READRPLAYDATA_SPACRE
            self.m_pTimeLeftTTF:setString( string.format( "%d", self.m_nTimeLeft))
            self.m_pTimeLeftTTF:setScale( 3.0)
            self.m_pTimeLeftTTF:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1.0)), cc.DelayTime:create( waitTime), cc.CallFunc:create( leftTime_low)))

            self.m_nTimeLeft = self.m_nTimeLeft - 1
            if  self.m_nTimeLeft < 0 then
                self.m_nTimeLeft = 0
            end
        end
    end
    leftTime_low()
end

function CDLayerTable_mjzy_replay:round_addFangFengMah( order_type, index, mahjong,isFf_Or_Pf ,bEff, waitTime)

    if  bEff == nil then
        bEff = false
    end
    if  waitTime == nil then
        waitTime = 0.0
    end

    local sBPos = cc.p( 0, 0)
    local sEPos = cc.p( 0, 0)

    local hSpace = 40
    local vSpace = 40

    local  offsetIndex = -1
    if isFf_Or_Pf then
        offsetIndex = 3 
    end

    if  order_type == 0 then
            
        sEPos = cc.p(self.m_pPlayer[order_type].tab_fangFeng_space.x + hSpace*(index+offsetIndex),
                          self.m_pPlayer[order_type].tab_fangFeng_space.y)
        sBPos = cc.p( sEPos.x + 30, sEPos.y)
    elseif  order_type == 2 then
            
        sEPos = cc.p( self.m_pPlayer[order_type].tab_fangFeng_space.x - hSpace*(index+offsetIndex),
                          self.m_pPlayer[order_type].tab_fangFeng_space.y)
        sBPos = cc.p( sEPos.x + 30, sEPos.y)
            
    elseif  order_type ==3 then
        sEPos = cc.p( self.m_pPlayer[order_type].tab_fangFeng_space.x , 
                          self.m_pPlayer[order_type].tab_fangFeng_space.y - vSpace*(index+offsetIndex))
        sBPos = cc.p( sEPos.x - 30, sEPos.y)
    elseif order_type ==1 then
        sEPos = cc.p( self.m_pPlayer[order_type].tab_fangFeng_space.x , 
                          self.m_pPlayer[order_type].tab_fangFeng_space.y + vSpace*(index+offsetIndex))
        sBPos = cc.p( sEPos.x + 30, sEPos.y)
    end

    if  bEff then

        local eff = CDCCBAniObject.createCCBAniObject( self.m_pIcoDemo[order_type], "x_tx_buhua.ccbi", sBPos, 0)
        if  eff then
            eff:endRelease( true)
            eff:endVisible( true)
        end
    end
    local hua_ico = cc.Sprite:createWithSpriteFrameName( string.format( "t_%u.png", mahjong))
    if order_type == 1 then
        hua_ico:setRotation(-90)
    elseif order_type == 3 then
        hua_ico:setRotation(90)
    end
    --local hua_ico = cc.Sprite:createWithSpriteFrameName( string.format( "mj_ico_%u.png", mahjong))
    self.m_pIcoDemo[order_type]:addChild( hua_ico)
    if  bEff then
        hua_ico:setPosition( sBPos)
        hua_ico:setScale( 1.5)
        hua_ico:runAction( 
            cc.Sequence:create(
                cc.DelayTime:create( waitTime), cc.ScaleTo:create( 0.15, 0.85), 
                cc.EaseBackOut:create( cc.MoveTo:create( 0.15, sEPos))))  
    else
        hua_ico:setPosition( sEPos)
        hua_ico:setScale(0.85)
    end
end


----------------------------------------------------------------------------

-- 显示胡牌处理
-- 参数: 位置对象, 胡牌组
function CDLayerTable_mjzy_replay:displayHu( order_type, score)
    cclog("CDLayerTable_mjzy::displayHu")
 
    -- 获取胡的类型
    local hu_type = DEF_MJZY_REPLAY_OP_RUANMO
    local op_count = TABLE_SIZE(score.opscores)
    for i = 1, op_count do

        local op_scores = score.opscores[i]
        if  op_scores.type == DEF_MJZY_TYPE_ZC  then

            hu_type = DEF_MJZY_REPLAY_OP_ZHUOCHONG
        end
    end

    self:showEffectWithOperate( order_type, hu_type)
    self:readMahjong( 1, hu_type, order_type)

    -- 排除已经扑到的牌后，用胡牌来进行牌型组合
    local copy_array = {}
    self.mahjong_mjzy:push_back( copy_array, score.cards, 1, TABLE_SIZE( score.cards))
    local s_array = self.m_pPlayAI[ order_type]:getAllSMahjongs_define()
    self.mahjong_mjzy:pop_array( copy_array, s_array)
    self.mahjong_mjzy:defMahjongSort_stb( copy_array)
    local bHu, mahjongs = self.mahjong_mjzy:canHuPai_def( copy_array,self.m_pPlayAI[order_type]:getNMahjong())
    if  not bHu then
        return
    end

    self.mahjong_mjzy:push_back( s_array, mahjongs, 1, TABLE_SIZE( mahjongs))

    -- 绘制胡牌
    if  order_type == 0 then

        if  TABLE_SIZE( score.cards) > self.m_nPMahjongs[0] then
            self:round_addMahjong( score.cards[1], 0)
        end
        self:resetMahjongWithArray( order_type, s_array, true)

    else

        if  TABLE_SIZE( score.cards) > self.m_nPMahjongs[order_type] then
            self:round_addMahjong( 0, order_type)
        end
        self:resetMahjongWithArray( order_type, s_array, true)
    end
    self:resetTableMahjongs( order_type)
    self:showHuPaiEffect( order_type)

    -- 假如最后打出的牌就是胡的对手牌那么标记最后打的这张牌
    if  hu_type == DEF_MJZY_REPLAY_OP_ZHUOCHONG then

        local nTag = (self.m_nLastOutPlayer+1)*DEF_MJZY_REPLAY_OUT_IDX + self:getPlayerOutNumber( self.m_nLastOutPlayer) --self.m_sOutNumber[ self.m_nLastOutPlayer]
        local pUsefulMahjong = self.m_pMahjongOut:getChildByTag( nTag)
        if  pUsefulMahjong then
            pUsefulMahjong:setGrey( true)

            -- local pos = cc.p( pUsefulMahjong:getPositionX(), pUsefulMahjong:getPositionY())
            local pos = self:getFlashEffectPos()
            if  pos then
                local eff = CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_flash.ccbi", pos, 0)
                if  eff ~= nil then
                    self.m_pEffFlagLast:endRelease( true)
                    self.m_pEffFlagLast:endVisible( true)
                end
                dtPlaySound( DEF_SOUND_MJ_FLASH)
            end
        end
    end
end
----------------------------------------------------------------------------
function CDLayerTable_mjzy_replay:getFlashEffectPos( ... )
    if  self.m_nLastOutPlayer >= 0 and self.m_nLastOutPlayer < DEF_MJZY_REPLAY_MAX_PLAYER then
        if  self.m_sOutNumber[ self.m_nLastOutPlayer] > 0 then
            local x_total = self:changeXMahjongs()
            local number = self:getPlayerOutNumber( self.m_nLastOutPlayer)
            local nWarp = math.floor( (number-1)/x_total)
            local nNum = (number-1)%x_total
            toPos = cc.p(   self.m_sOutStart[self.m_nLastOutPlayer].x + nNum * self.m_sOutSpace[self.m_nLastOutPlayer].x + nWarp * self.m_sOutWrap[self.m_nLastOutPlayer].x, 
                            self.m_sOutStart[self.m_nLastOutPlayer].y + nNum * self.m_sOutSpace[self.m_nLastOutPlayer].y + nWarp * self.m_sOutWrap[self.m_nLastOutPlayer].y)
            return toPos
        end
    end
    return nil
end
----------------------------------------------------------------------------
-- 胡牌效果
-- 参数: 位置对象
function CDLayerTable_mjzy_replay:showHuPaiEffect( order_type)
    cclog("CDLayerTable_mjzy::showHuPaiEffect")

    -- 小于两张牌不可能胡
    if  self.m_nPMahjongs[order_type] < 2 then
        return
    end
    -- 假如是自己那么播放胡牌火烧效果
    if  order_type == 0 then
        local time_spc = 0.5/self.m_nPMahjongs[order_type]
        for i = 1, self.m_nPMahjongs[order_type] do
            if  self.m_pPMahjongs[order_type][i].m_pMahjong ~= nil then 
                self.m_pPMahjongs[order_type][i].m_pMahjong:addEffect( "x_tx_fire.ccbi", 1.0 + i*time_spc)
            end
        end
        dtPlaySound( DEF_SOUND_FIRE)
    end
end
----------------------------------------------------------------------------
-- 播放特效根据操作
-- 参数:位置索引，操作类型
function CDLayerTable_mjzy_replay:showEffectWithOperate( order_type, operate_type)
    cclog( "CDLayerTable_mjzy:showEffectWithOperate => (%u)", operate_type)

    local pos = cc.p(   self.m_pPlayer[order_type].tab_center.x + self.m_pPlayer[order_type].m_sNumSpace.x,
                        self.m_pPlayer[order_type].tab_center.y + self.m_pPlayer[order_type].m_sNumSpace.y)

    if      operate_type == DEF_MJZY_REPLAY_OP_PENG then

        CDCCBAniObject.createCCBAniObject( self, "x_tx_peng.ccbi", pos, 0)
    elseif  operate_type == DEF_MJZY_REPLAY_OP_GANG_M then    --点笑

        CDCCBAniObject.createCCBAniObject( self, "x_tx_gang.ccbi", pos, 0)
    elseif  operate_type == DEF_MJZY_REPLAY_OP_GANG_A then    -- 闷笑

        CDCCBAniObject.createCCBAniObject( self, "x_tx_gang.ccbi", pos, 0)
    elseif  operate_type == DEF_MJZY_REPLAY_OP_GANG_B then  -- 回头笑

        CDCCBAniObject.createCCBAniObject( self, "x_tx_gang.ccbi", pos, 0)
    -- elseif  operate_type == DEF_MJZY_REPLAY_OP_ZHUOCHONG then    -- 捉铳

    --     CDCCBAniObject.createCCBAniObject( self, "x_tx_hu_zc.ccbi", pos, 0)

    --     dtPlaySound( DEF_SOUND_WIN)

    elseif operate_type == 98 then  -- 放风

         CDCCBAniObject.createCCBAniObject( self, "x_tx_fangfeng.ccbi", pos, 0)

    elseif operate_type == 99 then  -- 跑风

        CDCCBAniObject.createCCBAniObject( self, "x_tx_paofeng.ccbi", pos, 0)

    elseif  operate_type == DEF_MJZY_REPLAY_OP_RUANMO or 
            operate_type == DEF_MJZY_REPLAY_OP_HEIMO then        -- 软摸

        CDCCBAniObject.createCCBAniObject( self, "x_tx_hu.ccbi", pos, 0)
        
        dtPlaySound( DEF_SOUND_WIN)
         
    end

    -- 灯光亮起来
    if  self.m_pLighting ~= nil then

        self.m_pLighting:stopAllActions()
        self.m_pLighting:runAction( cc.Sequence:create( cc.FadeTo:create( 0.2, 1), cc.DelayTime:create( 0.3), cc.FadeTo:create( 0.5, 50)))
    end
end

----------------------------------------------------------------------------
function CDLayerTable_mjzy_replay:addLastCard( data )
    local order = self:getPlayerIndex(data.player_id)
    local endCard = data.card
    if  order~=-1 and endCard ~= 0 then
        return order,endCard
    end
    return false
end

function CDLayerTable_mjzy_replay:getLastSocre( ... )
    self:Handle_Table_Score(self.curRoundOPData)
end
----------------------------------------------------------------------------
-- 朗读出的牌
-- 参数: 要出的牌组, 牌组类型, 出牌的位置
function CDLayerTable_mjzy_replay:readMahjong( mahjong, out_type, order_type)
    cclog("CDLayerTable_mjzy::readMahjong")
    -- 性别获取
    local file = ""
    local sex = ""
    if  order_type >= 0 and order_type < DEF_MJZY_REPLAY_MAX_PLAYER and 
        self.m_pPlayer[order_type].m_nSex == 0 then
        sex = "m"
    else
        sex = "w"
    end
    -- 说明读情景语言( out_type顶替为id)
    if  mahjong == 0 then
        file = DEF_CASINO_REPLAY_AREA.."_chat"..out_type.."_"..sex..".mp3"
        dtPlaySound( file)
        return
    end
    -- 其他音（出牌、飘赖子、碰、杠、胡、自摸)
    if  out_type == 0 then-- 出牌
        if  mahjong == self.mahjong_mjzy:getMahjongLaiZi() then
            file = string.format( "%d_mj_gang_%s.mp3",DEF_CASINO_REPLAY_AREA, sex)-- 赖子
        else
            file = string.format( "%d_mj_%u_%s%d.mp3",DEF_CASINO_REPLAY_AREA, mahjong, sex,0)
        end
        
    elseif out_type == DEF_MJZY_REPLAY_OP_PENG then-- 碰

        file = string.format( "%d_mj_peng_%s.mp3",DEF_CASINO_REPLAY_AREA, sex)

    elseif  out_type == DEF_MJZY_REPLAY_OP_GANG_M then

        file = string.format( "%d_mj_gang_%s.mp3",DEF_CASINO_REPLAY_AREA, sex)
    elseif  out_type == DEF_MJZY_REPLAY_OP_GANG_A then

        file = string.format( "%d_mj_gang_%s.mp3",DEF_CASINO_REPLAY_AREA, sex)
    elseif  out_type == DEF_MJZY_REPLAY_OP_GANG_B then

        file = string.format( "%d_mj_gang_%s.mp3",DEF_CASINO_REPLAY_AREA, sex)
    elseif  out_type == DEF_MJZY_REPLAY_OP_RUANMO or
            out_type == DEF_MJZY_REPLAY_OP_RUANMOX2 then

        file = string.format( "%d_mj_zimo_%s.mp3",DEF_CASINO_REPLAY_AREA, sex)
    elseif  out_type == DEF_MJZY_REPLAY_OP_ZHUOCHONG then

        file = string.format( "%d_mj_hu_%s.mp3",DEF_CASINO_AREA, sex)
    elseif  out_type == 200 then

        file = string.format( "%d_mj_chi_%s.mp3",DEF_CASINO_AREA, sex)
    end
    dtPlaySound( file)
end

function CDLayerTable_mjzy_replay:replayNextData( ... )
    if  DEF_MJZY_REPLAY_ROUND < DEF_MJZY_REPLAY_MAX_ROUND then
        DEF_MJZY_REPLAY_ROUND = DEF_MJZY_REPLAY_ROUND+1
        self:reStartPlay()
    else
        local waitTime = 5/TABLE_READRPLAYDATA_SPACRE
        g_pSceneTable.m_pLayerMJ4Score:open( self.mjzy_replaydata)
        -- self:runAction( cc.Sequence:create( cc.DelayTime:create( waitTime), cc.CallFunc:create( CDLayerTable_mjzy_replay.onGotoHall)))
        
    end
end
----------------------------------------------------------------------------
-- ccb处理
-- 变量绑定
function CDLayerTable_mjzy_replay:onAssignCCBMemberVariable(loader)
    cclog("CDLayerTable_mjzy_replay::onAssignCCBMemberVariable")

    self.m_pBut_Ready   = loader["button_ready"]
    self.m_pPic_Ready   = loader["button_pic_ready"]
    self.m_pBut_Cancel  = loader["button_qxtg"]
    self.m_pRobotFlag   = loader["robot_flag"]
    self.m_pTxt_Robot   = loader["robot_msg"]

    self.m_pNewLayerRoot= loader["new_layer"]
    self.m_pGroupButton = loader["button_group"]
    self.m_pLaiZiDemo   = loader["laizi_demo"]
    self.m_pLaiGenDemo  = loader["laigen_demo"]
    self.m_pOrderIco    = loader["ico_zhizhen"]
    self.m_pOrderIcoP   = loader["ico_zhizhen1"]

    self.m_pTingGroup   = loader["ting_group"]
    self.m_pTingFrame   = loader["ting_group_frame"]
    self.m_pTingList    = loader["ting_list"]

    self.m_pTimeLeft    = loader["time_left"]
    self.m_pOutMahjongGroup = loader["out_group"]

    self.m_pSelfInfo    = loader["self_info"]
    self.m_pTableInfo   = loader["table_info"]

    self.m_pGroupBar    = loader["group_bar"]
    self.m_pGroupSelfBuild = loader["selfbuild_group"]
    self.m_pSelfBuildInfo = loader["selfbuild_info"]
    self.m_pRoomIDDemo  = loader["room_id_demo"]

    for i = 1, DEF_MJZY_REPLAY_TING_LIST_MAX do
        self.m_pTingNumFrame[i] = loader["lost_frame_"..i]
        self.m_pTingNumText[i] = loader["lost_number_"..i]        
    end

    for i = 0, DEF_MJZY_REPLAY_MAX_PLAYER-1 do
        self.m_pCenterDemo[i] = loader["mahjong_demo_"..i]
        self.m_pOutDemo[i] = loader["out_demo_"..i]
        self.m_pIcoDemo[i] = loader["ico_demo_"..i]

        self.m_pPlayer[i].m_pIcoReady = loader["ready_player"..i]
        self.m_pPlayer[i].m_pIcoOutLine = loader["outline_player"..i]
        self.m_pPlayer[i].m_pIcoYK = loader["ico_yk"..i]

        self.m_pPlayer[i].m_pName = loader["player_name"..i]
        self.m_pPlayer[i].m_pGold = loader["player_gold"..i]
        self.m_pPlayer[i].m_pFrame= loader["player_frame"..i]
        self.m_pPlayer[i].m_pHead = loader["head_demo"..i]
        self.m_pPlayer[i].m_pStart= loader["head_start"..i]
        self.m_pPlayer[i].m_sPosBeg = cc.p( self.m_pPlayer[i].m_pStart:getPositionX(), self.m_pPlayer[i].m_pStart:getPositionY()) 
        self.m_pPlayer[i].m_sPosEnd = cc.p( self.m_pPlayer[i].m_pFrame:getPositionX(), self.m_pPlayer[i].m_pFrame:getPositionY())

        self.m_pPlayer[i].m_pBubbleGroup = loader["group_tip"..i]
        self.m_pPlayer[i].m_pBubbleBox = loader["group_tip_back"..i]
        self.m_pPlayer[i].m_pBubbleMsg = loader["group_tip_text"..i]

        self.m_pPlayer[i].m_pNumDemo = loader["num_demo"..i]
        self.m_pPlayer[i].m_pSpeakDemo = loader["speak_demo"..i]
        -- self.m_pPlayer[i].m_pFanTxt = loader["player_fan_"..i]
    end
    self.m_pRecordButton = loader["record_demo"]

    self.m_pCenterDire = loader["dire_demo"]

    for i = 1, DEF_MJZY_REPLAY_BUT_TYPE_HU do
        self.m_pBut_Type[i] = loader["button_type"..i]
        self.m_pBut_Text[i] = loader["button_text"..i]
    end
    self.m_pButSetting = loader["but_setting"]
    self.m_pButChat = loader["but_chat"]
    self.m_pButRobot = loader["but_robot"]

    self.m_pButToOther = loader["but_wtrkf"]
    self.m_pButOver = loader["but_jsfj"]
    self.m_pButLeave = loader["but_lkfj"]
    self.m_pButShare = loader["but_fxfh"]
    self.m_pTxtShare = loader["pic_fxfh"]
    self.m_pButSponsor = loader["but_fqjs"]
    self.m_pTxtSponsor = loader["txt_fqjs"]

    self.m_pTxtToOther = loader["xn_txt_wtrkf"]
    self.m_pTxtOver = loader["xn_txt_jsfj"]
    self.m_pTxtLeave = loader["xn_txt_lkfj"]

    self.m_pGroupPushMsg = loader["group_push_msg"]
    self.m_pGroupLeftTop = loader["group_left_top"]
    self.m_pPushMessage = loader["push_message"]

    self.m_pIcoPower = loader["power"]
    self.m_pGroupTip = loader["group_tip"]
    self.m_sGroupTipPos = cc.p( self.m_pGroupTip:getPositionX(), self.m_pGroupTip:getPositionY())

    self.m_pStageDemo = loader["stage_demo"]
    self.m_pLighting = loader["pic_alpha"]

    self.m_pGroupForgo = loader["group_forgo"]
    self.m_pForgoMessage = loader["message_forgo"]

    self.m_pJoinTypeMsg = loader["join_type"]

    -- 定位相关变量绑定
    self.m_pButLocation = loader["but_location"]
    self.m_pGroupLocation = loader["group_location"]
    for i = 1, DEF_MJZY_REPLAY_MAX_PLAYER-1 do
        self.m_pIcoLocation[i] = loader["location"..i]
        self.m_pTxtLocation[i] = loader["space"..i]
        self.m_pGroupAddress[i]= loader["group_address"..i]
        self.m_pTxtAddress[i]  = loader["txt_address"..i]
        if  self.m_pIcoLocation[i] ~= nil then
            self.m_pPosLocation[i] = cc.p( self.m_pIcoLocation[i]:getPositionX(), self.m_pIcoLocation[i]:getPositionY())
        end
    end

    -- IP相关
    for i = 1, DEF_MJZY_REPLAY_MAX_PLAYER-1 do
        self.m_pIPFrame[i] = loader["player_ipframe"..i]
        self.m_pIPString[i] = loader["player_ip"..i]
    end

    -- 回放
    self.m_pReplayBtnGroup  = loader["replay_btngroup"]
    self.m_pReplayBtnFast   = loader["button_fast"]
    self.m_pReplayBtnReplay = loader["button_replay"]
    self.m_pReplayBtnPause  = loader["button_pause"]
    self.m_pReplayBtnPlay   = loader["button_play"]
    self.m_pReplayTxtFast   = loader["fast_txt"]
    self.m_pReplayTxtProcess= loader["process_txt"]
    self.m_pReplayBtnPre    = loader["button_previous"]
    self.m_pReplayBtnNext   = loader["button_replaynext"]
end
----------------------------------------------------------------------------
function CDLayerTable_mjzy_replay:onChat()
end

function CDLayerTable_mjzy_replay:onSetting()
    if  not self.m_pGroupBar:isVisible() then
        return
    end

    g_pSceneTable:closeAllUserInterface()

    local pos = cc.p( 0.0, self.m_pButSetting:getPositionY())
    g_pSceneTable.m_pLayerTipBar:setPosition( pos)
    g_pSceneTable.m_pLayerTipBar:open(  casinoclient.getInstance():isSelfBuildTable())
end

function CDLayerTable_mjzy_replay:onReady()
end

function CDLayerTable_mjzy_replay:onDeal()
end

function CDLayerTable_mjzy_replay:onCancelRobot()
end

function CDLayerTable_mjzy_replay:onOverRoom()
end

function CDLayerTable_mjzy_replay:onLeaveRoom()
end

function CDLayerTable_mjzy_replay:onToOther()
end

function CDLayerTable_mjzy_replay:onShareRoomID()
end

function CDLayerTable_mjzy_replay:onRobot()
end

function CDLayerTable_mjzy_replay:onSponsor()
end

function CDLayerTable_mjzy_replay:onLocation()
end

function CDLayerTable_mjzy_replay:onTing()
end

function CDLayerTable_mjzy_replay:onGTing()
end
----------------------------------------------------------------------------
-- ccb处理
-- 函数绑定
function CDLayerTable_mjzy_replay:onResolveCCBCCControlSelector(loader)

    cclog("CDLayerTable_mjzy_replay::onResolveCCBCCControlSelector")
    -- loader["onExit"] = function() self:onGotoHall() end
    loader["onChat"] = function() self:onChat() end
    loader["onSetting"] = function() self:onSetting() end

    loader["onReady"] = function() self:onReady() end
    loader["onDeal"] = function() self:onDeal() end
    loader["onCancelRobot"] = function() self:onCancelRobot() end
    loader["onCloseFrame"] = function() self:onCloseFrame() end

    loader["onHu"] = function() self:onHuPai() end
    loader["onPeng"] = function() self:onPengPai() end
    loader["onGang"] = function() self:onGangPai() end

    loader["onOverRoom"] = function() self:onOverRoom() end
    loader["onLeaveRoom"] = function() self:onLeaveRoom() end
    loader["onToOther"] = function() self:onToOther() end
    loader["onShareRoomID"] = function() self:onShareRoomID() end

    loader["onRobot"] = function() self:onRobot() end
    loader["onSponsor"] = function() self:onSponsor() end
    loader["onLocation"] = function() self:onLocation() end

    -- 上听
    loader["onTing"] = function() self:onTing() end 
    loader["onGTing"] = function() self:onGTing() end 

    -- 回放 
    loader["onFastPlay"] = function() self:onFastPlay() end
    loader["onReplayAgin"] = function() self:onReplayAgin() end
    loader["pauseCurAction"] = function() self:pauseCurAction() end
    loader["resumeCurAction"] = function() self:resumeCurAction() end
    loader["onPreviousRound"] = function() self:onPreviousRound() end
    loader["onNextRound"] = function() self:onNextRound() end

end

----------------------------------------------------------------------------
-- create
function CDLayerTable_mjzy_replay.createCDLayerTable_mjzy_replay(pParent)
    cclog("CDLayerTable_mjzy_replay::createCDLayerTable_mjzy_replay")
    if not pParent then
        return nil
    end
    local layer = CDLayerTable_mjzy_replay.new()
    layer:init()
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerTable_mjzy.ccbi",proxy,loader)
    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild(node)
    pParent:addChild(layer)
    return layer
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- 获取回放的数据
function CDLayerTable_mjzy_replay:setReplayData( data )
    if  data then
        self.mjzy_replaydata = data
    end

end
-- 回放还是退出
function CDLayerTable_mjzy_replay:replayORReback( data )

    if  data then
        self:setReplayData(data)
        self:setPlayers()
        return true
    else
        self:onGotoHall()
        return false
    end
end

-- 开始加载数据 进行回放
function CDLayerTable_mjzy_replay:setPlayers( ... )
    if  TABLE_SIZE(self.mjzy_replaydata.players) > 0 then
        self.m_nPlayers = TABLE_SIZE(self.mjzy_replaydata.players)
    end
end

function CDLayerTable_mjzy_replay:startReadOPIndex( ... )
    
    if  self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX] then 
        local curTimeSpace = TABLE_READRPLAYDATA_TIME/TABLE_READRPLAYDATA_SPACRE

        local curOP_ID = self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX].player_id
        local curOP_Index = self:getPlayerIndex(curOP_ID)
        local curOP = self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX].op
        local curOP_Type = self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX].type
        local curOP_TargetID = self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX].target_id
        local curOP_TargetIndex = self:getPlayerIndex(curOP_TargetID)
        local curDrawCard = self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX].card

        if  curDrawCard == 0 then
            curDrawCard = self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX].cards[1]
        end
        print("curOP_Index---->",curOP_Index)
        print("curOP_TargetIndex---->",curOP_TargetIndex)
        print("curOP---->",curOP)
        print("curDrawCard---->",curDrawCard)
        print("DEF_MJZY_REPLAY_OP_INDEX---->",DEF_MJZY_REPLAY_OP_INDEX)
        print("DEF_MJZY_REPLAY_OP_MAX_INDEX---->",DEF_MJZY_REPLAY_OP_MAX_INDEX)

        if  curOP == TABLE_OP_DRAWCARD then  -- 摸牌
            self.mahjong_mjzy:mahjongTotal_lower()
            self:round_MoMahjong(curOP_Index,curDrawCard)
            self:round_OutMahjongShow_Back(0)
            self:refreshTableInfo()
        elseif curOP == TABLE_OP_OUTCARD then -- 打牌
            self:putOutCard(curOP_Index,curDrawCard)
            self.m_pPlayAI[curOP_Index]:setOwnOutCard(curDrawCard)
            -- self:checkEveryFan(curOP_Index)

        elseif curOP == TABLE_OP_END then -- 流局
            self:getLastSocre()
        elseif curOP == TABLE_OP_PENG then -- 碰
            local curCards = {}
            for i=1,3 do
                self.mahjong_mjzy:push_mahjong(curCards,curDrawCard)
            end
            self:setOrderType( curOP_Index,true,false)
            self:operatePeng( curOP_Index, curCards, curOP_TargetIndex)
            dtPlaySound( DEF_SOUND_EVENT)
            self:round_OutMahjongShow_Back(DEF_MJZY_REPLAY_OP_PENG )
        elseif curOP == TABLE_OP_GANG or curOP == TABLE_OP_CHAOTIAN then -- 杠
        
            self:operateGang( curDrawCard, curOP_Type, curOP_Index, curOP_TargetIndex)
            dtPlaySound( DEF_SOUND_EVENT)
            self:round_OutMahjongShow_Back( curOP_Type)
        elseif curOP == TABLE_OP_HU or curOP == TABLE_OP_ZIMO or curOP == TABLE_OP_QIANGXIAO then -- 胡

            dtPlaySound( DEF_SOUND_MJ_SCORE)
            self:round_OutMahjongShow_Back( TABLE_OP_HU)
            self:Handle_Table_Score(self.curRoundOPData)
     
        elseif curOP == TABLE_OP_CHI then -- 吃
            local curCards = self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX].cards

            self:operateChi(curOP_Index, curCards, curOP_TargetIndex, curDrawCard)
            dtPlaySound( DEF_SOUND_EVENT)
            self:round_OutMahjongShow_Back( TABLE_OP_CHI )
        elseif curOP == TABLE_OP_FANGFENG then -- 放风
            local curType = self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX].type
            local curFangFCards = self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX].cards
            local paoFCard = self.curRoundOPData.ops[DEF_MJZY_REPLAY_OP_INDEX].card
            --跑风
            if curType == 2 then
                self:showEffectWithOperate(curOP_Index,99)
                self.m_pPlayAI[curOP_Index]:delVMahjong(paoFCard)
                self.m_pPlayAI[curOP_Index]:addPaoFMahjong(paoFCard)
                local curIndex = self.m_pPlayAI[curOP_Index]:getPaoFMahjongSize()
                self:round_addFangFengMah(curOP_Index, curIndex,paoFCard,true,false,0)
                self:round_delMahjong(curOP_Index)
            else --放风
                self:showEffectWithOperate(curOP_Index,98)
                self.m_pPlayAI[curOP_Index]:delVMahjongs(curFangFCards)
                self.m_pPlayAI[curOP_Index]:addFangFMahjong(curFangFCards)
                for i = 1 ,TABLE_SIZE(curFangFCards) do 
                    self:round_addFangFengMah(curOP_Index,i,curFangFCards[i],false,false,0)
                    self:round_delMahjong(curOP_Index)
                end
            end

            self:myMahjongs_refresh(curOP_Index)
            self:resetTableMahjongs(curOP_Index)
        else

            self:round_OutMahjongShow_Back( 0)
        end
        
        DEF_MJZY_REPLAY_OP_INDEX = DEF_MJZY_REPLAY_OP_INDEX+1
        self:showCurRound(true)

        if  DEF_MJZY_REPLAY_OP_INDEX < DEF_MJZY_REPLAY_OP_MAX_INDEX then

            self:runAction( cc.Sequence:create( cc.DelayTime:create( curTimeSpace), cc.CallFunc:create( CDLayerTable_mjzy_replay.startReadOPIndex)))
        end
    end
end

function CDLayerTable_mjzy_replay:showReplayBtn( bool )
    if  self.m_pReplayBtnGroup then
        if  bool then
            self.m_pReplayBtnGroup:setVisible(true)
            self.m_pReplayBtnFast:setVisible(true)
            self.m_pReplayBtnReplay:setVisible(true)
            self.m_pReplayBtnPause:setVisible(true)
            self.m_pReplayBtnPlay:setVisible(false)
            self.m_pReplayTxtFast:setVisible(true)
            self.m_pReplayTxtProcess:setVisible(false)
            self:showCurSpeed()
            self:getMaxProcedss()
            self:isShowJumpBtn()
        else
            self.m_pReplayBtnGroup:setVisible(false)
        end
    end

end

function CDLayerTable_mjzy_replay:isShowJumpBtn( ... )
    if  self.m_pReplayBtnPre and self.m_pReplayBtnNext then
        if  DEF_MJZY_REPLAY_ROUND<DEF_MJZY_REPLAY_MAX_ROUND then
            self.m_pReplayBtnNext:setGrey(false)
        else
            self.m_pReplayBtnNext:setGrey(true)
        end

        if  DEF_MJZY_REPLAY_ROUND>1 then
            self.m_pReplayBtnPre:setGrey(false)
        else
            self.m_pReplayBtnPre:setGrey(true)
        end
    end

end

function CDLayerTable_mjzy_replay:getMaxProcedss( ... )
    self.maxProcess = 0
    self.curProcess = 0
    for i = 1,DEF_MJZY_REPLAY_MAX_ROUND do
        local curOPNum = TABLE_SIZE(self.mjzy_replaydata.replay.rounds[i].ops)
        self.maxProcess = self.maxProcess+curOPNum
    end

    local finishProcess = 0
    for i = 1,DEF_MJZY_REPLAY_ROUND-1 do
        local curOPNum = TABLE_SIZE(self.mjzy_replaydata.replay.rounds[i].ops)
        finishProcess = finishProcess + curOPNum
    end
    self.curProcess = finishProcess + DEF_MJZY_REPLAY_OP_INDEX
    return self.maxProcess,self.curProcess
end
--显示进度
function CDLayerTable_mjzy_replay:showCurRound( bValue )

    if  self.maxProcess and self.curProcess then

        if  bValue then
            self.curProcess = self.curProcess+1
        end

        local curProcessInfo = self.curProcess.."/"..self.maxProcess

        if  self.m_pReplayTxtProcess then
            self.m_pReplayTxtProcess:setString(curProcessInfo)
            self.m_pReplayTxtProcess:setVisible(true)
        end
    end
end

function CDLayerTable_mjzy_replay:showCurSpeed( ... )
    if  self.m_pReplayTxtFast then
        self.m_pReplayTxtFast:setString("X"..TABLE_READRPLAYDATA_SPACRE)
    end
end
-- 快进
function CDLayerTable_mjzy_replay:onFastPlay( ... )
    TABLE_READRPLAYDATA_SPACRE = TABLE_READRPLAYDATA_SPACRE+1
    if  TABLE_READRPLAYDATA_SPACRE >4 then
        TABLE_READRPLAYDATA_SPACRE = 1
    end
    self:showCurSpeed()
end
-- 重新播放
function CDLayerTable_mjzy_replay:onReplayAgin( ... )
    self:stopAllActions()
    DEF_MJZY_REPLAY_ROUND  = 1 
    DEF_MJZY_REPLAY_OP_INDEX = 1
    self:reStartPlay()
    
end

-- 暂停
function CDLayerTable_mjzy_replay:pauseCurAction( ... )
    if  self.m_pReplayBtnPause:isVisible() then
        cc.Director:getInstance():getActionManager():pauseTarget(self)

        self.m_pReplayBtnPause:setVisible(false)
        self.m_pReplayBtnPlay:setVisible(true)
    end
end
-- 继续
function CDLayerTable_mjzy_replay:resumeCurAction( ... )
    if  self.m_pReplayBtnPlay:isVisible() then
        cc.Director:getInstance():getActionManager():resumeTarget(self)

        self.m_pReplayBtnPause:setVisible(true)
        self.m_pReplayBtnPlay:setVisible(false)
    end
end

-- 下一局
function CDLayerTable_mjzy_replay:onNextRound( ... )
    if  not self.m_pReplayBtnNext:isGrey() then

        DEF_MJZY_REPLAY_ROUND  = DEF_MJZY_REPLAY_ROUND+1
        if  DEF_MJZY_REPLAY_ROUND <= DEF_MJZY_REPLAY_MAX_ROUND and DEF_MJZY_REPLAY_ROUND >= 1 then
            self:stopAllActions()
            DEF_MJZY_REPLAY_OP_INDEX = 1
            self:reStartPlay()
        end
        self:isShowJumpBtn()
    end
end

-- 上一局
function CDLayerTable_mjzy_replay:onPreviousRound( ... )
    if  not self.m_pReplayBtnPre:isGrey() then

        DEF_MJZY_REPLAY_ROUND  = DEF_MJZY_REPLAY_ROUND - 1
        if  DEF_MJZY_REPLAY_ROUND >= 1 and DEF_MJZY_REPLAY_ROUND <= DEF_MJZY_REPLAY_MAX_ROUND then
            self:stopAllActions()
            DEF_MJZY_REPLAY_OP_INDEX = 1
            self:reStartPlay()
        end
        self:isShowJumpBtn()
    end
end