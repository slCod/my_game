--[[
/******************************************************
//Project:      ProjectX
//Moudle:       CDLayerTable_mjzy 湖北江陵晃晃桌子
//File Name:    DLayerTable_MJZY.h
//Author:       GostYe
//Start Data:   2017.05.15
//Language:     XCode 9.3
//Target:       IOS, Android

--  在调用前，需要先设置 m_nPlayers 玩家

******************************************************/
]]

require( REQUIRE_PATH.."DDefine")
require( REQUIRE_PATH.."DCCBLayer")
require( REQUIRE_PATH.."DTKDScene")
require( REQUIRE_PATH.."_tkd_tbmenu")
require( "mahjong_mjzy.mahjong_mjzy_ai")
--require "CCBReaderLoad"

local casinoclient = require("script.client.casinoclient")
local platform_help = require("platform_help")

DEF_MJZY_MAX_PLAYER      = 4     -- 最大玩家数(0下,1右,2上,3左)
DEF_MJZY_MAX_MAHJONGS    = 14    -- 最大牌数量 (正常)
DEF_MJZY_DEF_MAHJONGS    = 13    -- 默认牌数量

DEF_MJZY_MAHJONG_SELECT_Y= 40    -- 选中的Y轴偏移
DEF_MJZY_MAHJONG_SELECT_S= 1.2   -- 选中的缩放
DEF_MJZY_MAHJONG_MAX_BUT = 4     -- 最大晃操作按钮数
DEF_MJZY_MAHJONG_SPC_BUT = 68    -- 晃操作按钮间隔

DEF_MJZY_MIN_MOVE_Y      = 150   -- 最小移动Y轴，超过这个高度就可以选中拖动的

DEF_MJZY_BUT_TYPE_PENG   = 1     -- 碰 按钮
DEF_MJZY_BUT_TYPE_GANG   = 2     -- 杠 按钮
DEF_MJZY_BUT_TYPE_HU     = 3     -- 胡 按钮
DEF_MJZY_BUT_TYPE_CHI    = 4     -- 吃 按钮
DEF_MJZY_CHI_LIST_MAX    = 3     -- 吃牌列表最大3组
DEF_MJZY_BUT_TYPE_PAOFENG = 5    -- 跑风 按钮

-- DEF_MJZY_MAX_BUT_PIAO     = 6     -- 飘 按钮

DEF_MJZY_TING_LIST_MAX   = 9     -- 听牌列表最大罗列牌数
DEF_MJZY_TING_FRAME_SPACE= 120   -- 听牌底框宽带附加
DEF_MJZY_TING_ITEM_SPACE = 70    -- 听牌牌面之间的间距
DEF_MJZY_TING_ITEM_SCALE = 0.85  -- 听牌显示的牌缩放

DEF_MJZY_GANG_LIST_MAX   = 4     -- 杠牌列表最大罗列牌数
DEF_MJZY_GANG_FRAME_SPACE= 160   -- 杠牌底框宽带附加
DEF_MJZY_GANG_ITEM_SPACE = 100   -- 杠牌之间的间距
DEF_MJZY_GANG_ITEM_SCALE = 1     -- 杠牌显示的牌缩放

DEF_MJZY_VAILD_SPACE     = 10    -- 有效牌与无效牌之间的距离
DEF_MJZY_MYTABLE_SPACE   = 10    -- 我的桌子左右的间隔

DEF_MJZY_MAX_OUTMAHJONG  = 27    -- 打出的最多牌数
DEF_MJZY_MAX_GETMAHJONG  = 20    -- 最多牌

DEF_MJZY_SOUND_MJ_CLICK      = "mj_click"..DEF_TKD_SOUND   -- 点中牌
DEF_MJZY_SOUND_MJ_OUT        = "mj_out"..DEF_TKD_SOUND     -- 出牌
DEF_MJZY_SOUND_MJ_MO         = "mj_mo"..DEF_TKD_SOUND      -- 摸牌
DEF_MJZY_SOUND_MJ_KJ         = "mj_kj"..DEF_TKD_SOUND      -- 开局
DEF_MJZY_SOUND_MJ_ZHSZ       = "mj_zhsz"..DEF_TKD_SOUND    -- 最后四张
DEF_MJZY_SOUND_MJ_FLASH      = "mj_flash"..DEF_TKD_SOUND   -- 捉铳闪电
-- DEF_MJZY_SOUND_MJ_PIAO       = "mj_piao"..DEF_TKD_SOUND    -- 飘
DEF_MJZY_SOUND_MJ_SCORE      = "mj_score"..DEF_TKD_SOUND   -- 桌面结算
DEF_MJZY_SOUND_MJ_SHOWB      = "mj_show_button"..DEF_TKD_SOUND    --显示按钮
-- DEF_MJZY_SOUND_MJ_JIAPEIZI   = "mj_jiapeizi"..DEF_TKD_SOUND      -- 架配子特效
DEF_MJZY_SOUND_MJ_LZ_PIAO    = "mj_piao"..DEF_TKD_SOUND    -- 飘
-- DEF_MJZY_SOUND_MJ_PZ_PIAO    = "mj_pz_piao"..DEF_TKD_SOUND    -- 飘

DEF_MJZY_OUT_IDX         = 1000  -- 打出牌的tag索引的开始
DEF_MJZY_ICO_IDX         = 100   -- 扑到牌的对象tag索引开始

DEF_MJZY_GANG_CARDS      = 1     -- 大于几张剩余牌才能杠

DEF_MJZY_BT_OUTSCALE     = 0.82--0.75   -- 上下两家出牌缩放值
DEF_MJZY_LR_OUTSCALE     = 0.88--0.81   -- 左右两家出牌缩放值
-----------------------------------------
-- 索引转换索引到使用的编号（手牌）
-- order四方向(0~3), i(索引从1开始)
function MJZY_INDEX_ITOG( order, i)

    if  order == 0 or order == 2 or order == 3 then
        return i
    else
        return (DEF_MJZY_MAX_GETMAHJONG - i + 1)
    end
end

-----------------------------------------
-- 类定义
CDLayerTable_mjzy = class("CDLayerTable_mjzy", CDCCBLayer)
CDLayerTable_mjzy.__index = CDLayerTable_mjzy
CDLayerTable_mjzy.name = "CDLayerTable_mjzy"

-- 构造函数
function CDLayerTable_mjzy:ctor()
    cclog("CDLayerTable_mjzy::ctor")
    CDLayerTable_mjzy.super.ctor(self)
    CDLayerTable_mjzy.initialMember(self)
    --reg enter and exit
    local function onNodeEvent(event)
        if "enter" == event then
            CDLayerTable_mjzy.onEnter(self)
        elseif "exit" == event then
            CDLayerTable_mjzy.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDLayerTable_mjzy:onEnter()
    cclog("CDLayerTable_mjzy::onEnter")

    if DEF_OPEN_NIMSDK  and G_SPEAK_CANUSE then
        if dtIsAndroid() then
            Channel:getInstance():getIdAndTime(CDLayerTable_mjzy.getIdAndTimeHandler)
            Channel:getInstance():isCanRecord(CDLayerTable_mjzy.playRecordAnimation)
        else
            NIMSDKopen:getInstance():getIdAndTime(CDLayerTable_mjzy.getIdAndTimeHandler) 
        end
    end

    NIM_SPREAK_MJZY = self
    -- 网络事件
    local   listeners = {

        { casino.MSG_PING,                    handler( self, self.Handle_Ping)},
        { casino.MSG_FRIEND_REQ,              handler( self, self.Handle_Friend_Req)},
        { casino.MSG_TABLE_READY,             handler( self, self.Handle_Table_Ready_Ack)},
        { casino.MSG_TABLE_ENTRY,             handler( self, self.Handle_Table_Entry)},
        { casino.MSG_TABLE_LEAVE,             handler( self, self.Handle_Table_Leave)},
        { casino.MSG_TABLE_SCORE,             handler( self, self.Handle_Table_Score)},
        { casino.MSG_PLAYER_JOIN_ACK,         handler( self, self.Handle_Player_Join_Ack)},
        { casino.MSG_TABLE_JOIN_ACK,          handler( self, self.Handle_Table_Join_Ack)}, -- 重新进入游戏
        { casino.MSG_TABLE_DISBAND,           handler( self, self.Handle_Table_Disband)},
        { casino.MSG_TABLE_PAUSE,             handler( self, self.Handle_Table_Pause)},
        { casino.MSG_TABLE_MANAGED,           handler( self, self.Handle_Table_Managed)},
        { casino.MSG_TABLE_CHAT,              handler( self, self.Handle_Table_Chat)},
        { casino.MSG_TABLE_DISBAND_ACK,       handler( self, self.Handle_Table_Disband_Ack)},
        { casino.MSG_TABLE_DISBAND_REQ,       handler( self, self.Handle_Table_Disband_Req)},

        { casino_mjzy.MJZY_MSG_SC_STARTPLAY,  handler( self, self.Handle_MJZY_StartPlay)},
        --{ casino_mjzy.MJZY_MSG_SC_SCORE,      handler( self, self.Handle_MJZY_Score)},
        { casino_mjzy.MJZY_MSG_SC_DRAWCARD,   handler( self, self.Handle_MJZY_DrawCard)},
        { casino_mjzy.MJZY_MSG_SC_OP,         handler( self, self.Handle_MJZY_OP)},
        { casino_mjzy.MJZY_MSG_SC_OP_ACK,     handler( self, self.Handle_MJZY_OP_Ack)},
        { casino_mjzy.MJZY_MSG_SC_OUTCARD_ACK,handler( self, self.Handle_MJZY_OutCard_Ack)},
        { casino_mjzy.MJZY_MSG_SC_RECONNECT,  handler( self, self.Handle_MJZY_Reconnect)},-- 桌子中断线重连

        -- 江陵晃晃没有飘的阶段，暂时注释掉
        -- { casino_mjzy.MJZY_MSG_SC_BET,        handler( self, self.Handle_MJZY_Bet)},     
        -- { casino_mjzy.MJZY_MSG_SC_BET_ACK,    handler( self, self.Handle_MJZY_Bet_Ack)},
        { casino.MSG_COORDINATE,              handler( self, self.Handle_MJZY_CoorDinate)},
    }
    casinoclient.getInstance():addEventListeners(self, listeners)
    
    -- 开始发送位置信息
    -- MapLocation
    -- self:getPosWithSelf()
    self:waitGetPosCB(false)
end

function CDLayerTable_mjzy:onExit()
    cclog("CDLayerTable_mjzy::onExit")

    if  NIM_SPREAK_MJZY ~= 0 then
        NIM_SPREAK_MJZY = 0
    end

    if self.playAudioID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.playAudioID)   
        self.playAudioID=nil
    end
    if self.speakID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.speakID)   
        self.speakID=nil
    end
    if self.recordID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.recordID)   
        self.recordID=nil
    end
    if self.showPraID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.showPraID)   
        self.showPraID=nil
    end
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
    if  self.waitGetPosID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.waitGetPosID)   
        self.waitGetPosID=nil
    end

    self:stopAllActions()
    casinoclient.getInstance():removeListenerAllEvents(self)
    CDLayerTable_mjzy.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
-- 排序（有效判断，和牌面判断）
function mahjong_MJZY_table_comps_stb(a, b)
    local mj_a = a.mahjong
    local mj_b = b.mahjong

    if  mj_a ~= mj_b then
        if  mj_a == g_pGlobalManagement:getLaiZi() then
            return true
        end

        if  mj_b == g_pGlobalManagement:getLaiZi() then
            return false
        end

    end

    return mj_a < mj_b
end

function mahjong_MJZY_table_stb(a, b)
    local mj_a = a
    local mj_b = b

    if  mj_a ~= mj_b then
        if  mj_a == g_pGlobalManagement:getLaiZi() then
            return true
        end

        if  mj_b == g_pGlobalManagement:getLaiZi() then
            return false
        end

    end

    return mj_a < mj_b
end

-----------------------------------------
-- 初始化
function CDLayerTable_mjzy:initialMember()
    cclog("CDLayerTable_mjzy::initialMember")
    
    self.m_pListener = nil          -- 监听对象

    self.m_pMahjongOut = nil        -- 打出的牌放置节点
    self.m_pMahjongOwn = nil        -- 拥有的牌
    self.m_pMahjongEff = nil        -- 特效层

    self.mahjong_MJZY = nil          -- 干瞪眼库

    self.m_pBut_Ready = nil         -- 准备按钮
    self.m_pPic_Ready = nil         -- 准备图示
    self.m_pBut_Cancel = nil        -- 取消托管按钮
    self.m_pRobotFlag = nil         -- 托管遮挡
    self.m_pTxt_Robot = nil         -- 托管文字提示

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

    self.m_pGangGroup = nil         -- 杠牌展现组
    self.m_sGangPosition = cc.p( 0, 0)
    self.m_pGangFrame = nil         -- 杠牌展现底
    self.m_pGangList = nil          -- 杠牌列表
    self.m_pGangMahjong = {}        -- 杠的牌

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
    for i = 0, DEF_MJZY_MAX_PLAYER-1 do

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

        self.m_pPlayer[i].tab_fangFeng_space= cc.p( 0, 0)--放风牌偏移位置

        -- self.m_pPlayer[i].betType = nil              -- 纪录玩家是否飘
        -- self.m_pPlayer[i].m_pBet = nil               -- 飘的特效

        -- MapLocation
        -- 名字
        self.m_pPlayer[i].nickname = nil
        self.m_pPlayer[i].channel_nickname = nil
        -- 经纬度
        self.m_pPlayer[i].lat = nil                    -- 经度
        self.m_pPlayer[i].lng = nil                    -- 纬度
        self.m_pPlayer[i].address = nil                -- 地址
        self.m_pPlayer[i].ip_address = nil             -- ip地址
    end
    self.m_pPlayAI = nil            -- 玩家AI

    self.m_pSelfInfo = nil          -- 我的信息
    self.m_pTableInfo = nil         -- 桌子信息

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

    self.m_pMahjongBut = {}         -- 麻将操作按钮
    for i = 1, DEF_MJZY_MAHJONG_MAX_BUT do
        self.m_pMahjongBut[i] = {}
        self.m_pMahjongBut[i].m_nMahjong = 0
        self.m_pMahjongBut[i].m_pEffect = nil
        self.m_pMahjongBut[i].m_bVaild = false
    end

    -- 吃
    self.m_pcanChi = false          -- 是否可以吃
    self.m_pChiGroup = nil          -- 吃 显示组
    self.m_pChiGroupFarme = nil     -- 吃 背景
    self.m_nChiList = nil           -- 吃 节点
    self.m_pChiFarme = {}
    for i=1,DEF_MJZY_CHI_LIST_MAX do
        self.m_pChiFarme[i] = {}
        self.m_pChiFarme[i].m_pChiButton = nil
    end

    self.m_pChiList = {}            -- 吃牌的数组 最多3组 {{1,2,3},{1,2,3},{1,2,3}}
    self.m_nSaveOPCMahjong = 0      -- 吃的牌    
    self.m_pButtonChi = nil         -- 关闭吃的按钮 
    self.m_sChiArr = {}             -- 用于检测明倒车的吃的牌组

    -- 飘
    -- self.m_pPiaoGroup = nil         -- 开局 飘 的按钮组
    -- self.m_pPiaoButton = {}         -- 按钮 飘和过
    -- for i=1,DEF_MJZY_MAX_BUT_PIAO do
    --     self.m_pPiaoButton[i] = {}
    --     self.m_pPiaoButton[i].m_pButton = nil
    --     self.m_pPiaoButton[i].m_pText = nil
    -- end

    -- 放风
    self.m_FangFengArr = {}             --保存点击的用于放风牌
    self.m_nNeedNumForFangFeng = 0      --点击数量
    self.m_bCanFangFeng = false
    self.m_pGroupFangFengBtn = nil  -- 放风的按钮组
    self.m_pFangFengBut_Type = {}
    self.m_pFangFengText = {}
    for i =1 ,2 do
        self.m_pFangFengBut_Type[i] = nil
        self.m_pFangFengText[i]     = nil
    end
    self.m_nPaoFengType   = 0         -- 保存跑风时出的牌的类型
    self.m_bPaoFeng = false           -- 是否放风
    self.m_nPaoFengOutMah = 0         -- 记录点击跑风之后打出的牌

    self.m_nPaoFengArr = {}

    self.m_bCanCheck   = true         -- 可以检测

    self.m_pGroupFangFengChooseBtn = nil
    self.m_pFangFengChooseBut = {}
    self.m_pFangFengChooseText = {}
    for i=1,2 do
        self.m_pFangFengChooseBut[i] = nil
        self.m_pFangFengChooseText = nil
    end

    self.m_pHuIndex = -1            -- 海底捞月胡牌玩家的索引

    self.isQianZhuang = false       -- 是否是牵庄阶段
    self.isReconnect = false        -- 是否是重连
    self.canhuNow = false           -- 本轮是否可以胡牌

    self.m_pLastOutCardIndex = -1   -- 上一个出牌玩家的ID
    self.m_pCurOutCardIndex = -1    -- 当前出牌玩家的ID

    self.m_pJoinTypeMsg = nil       -- 加入类型的文字显示

    -- 定位相关--MapLocation
    self.isShowLocation = true
    self.isShowPosTip = false      -- 是否需要显示提示
    self.isShowPos = false
    self.m_pButLocation = nil       -- 定位按钮
    self.m_pGroupLocation = nil     -- 定位组
    self.m_pIcoLocation = {}        -- 定位显示按钮
    self.m_pTxtLocation = {}        -- 定位显示距离
    self.m_pPosLocation = {}        -- 坐标
    self.m_pGroupAddress= {}        -- 地址组
    self.m_pTxtAddress  = {}        -- 地址
    for i = 1, DEF_MJZY_MAX_PLAYER-1 do

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
    for i = 1, DEF_MJZY_MAX_PLAYER-1 do

        self.m_pIPFrame[i] = nil
        self.m_pIPString[i] = nil
    end
end

function CDLayerTable_mjzy:releaseMember()
    cclog("CDLayerTable_mjzy::releaseMember")

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

    for i = 0, DEF_MJZY_MAX_PLAYER-1 do

        if  self.m_pPlayer[i] ~= nil and 
            self.m_pPlayer[i].m_pBubbleGroup ~= nil then
            self.m_pPlayer[i].m_pBubbleGroup:removeAllChildren()
        end

        if  self.m_pCenterDemo ~= nil and
            self.m_pCenterDemo[i] ~= nil then
            self.m_pCenterDemo[i]:removeAllChildren()
        end

        if  self.m_pPlayTable[i] ~= nil then
            self.m_pPlayTable[i]:removeAllChildren()
        end

        if  self.m_pPlayer[i].m_pBet then
            self:removeChild(self.m_pPlayer[i].m_pBet)
            self.m_pPlayer[i].m_pBet = nil
        end             
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
    CDLayerTable_mjzy.super.releaseMember(self)
    if  DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end

    if self.m_pListener then

        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.m_pListener)
        self.m_pListener = nil
    end
end

--============================压牌、摸牌后相关处理  云信模块============================--
-- 延迟一秒回调
function CDLayerTable_mjzy:daltyPlayer( ... )

    local needWaitTime=0
    local function palyAudioDelay( ... )
        -- print("needWaitTime---->",needWaitTime)
        needWaitTime=needWaitTime+0.5
        if needWaitTime>=1 then
            needWaitTime=0
            if dtIsAndroid() then
                platform_help.continuePlayAudio()
            else
                NIMSDKopen:getInstance():continuePlayAudio()
            end
            if self.playAudioID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.playAudioID)   
                self.playAudioID=nil
            end
        end
    end
    if  self.playAudioID==nil then
        self.playAudioID=cc.Director:getInstance():getScheduler():scheduleScriptFunc(palyAudioDelay,0.5,false)
    end
end

----------------------------------------------------------------------------
-- 参数：model 1 播放 0 播放结束  2 是给苹果用的  确定播放玩
function CDLayerTable_mjzy.getIdAndTimeHandler( model,useId,recordTime,params )
    -- print("返回的userId是",useId,"模式是",model)   
    g_sp_ClearMessage_Write()
    if  model==0 then

        NIM_SPREAK_MJZY:setVisiblePlayerSpeak(model,useId)
        if dtIsAndroid() then
            NIM_SPREAK_MJZY:daltyPlayer()
        end
    elseif model==1 then

        NIM_SPREAK_MJZY:setVisiblePlayerSpeak(model,useId)
    elseif model==2 then

        NIM_SPREAK_MJZY:daltyPlayer()
    end
end

----------------------------------------------------------------------------
-- 设置玩家对话状态显示
-- 参数1: type(0隐藏, 1显示)
-- 参数2: im_accid云信语音id
function CDLayerTable_mjzy:setVisiblePlayerSpeak( type, im_accid)
    cclog( "CDLayerTable_mjzy:setVisiblePlayerSpeak")

    for i = 0, self.m_nPlayers-1 do

        local order_idx = self:changeOrder( i)

        if  self.m_pPlayer[ order_idx].m_pData ~= nil and
            self.m_pPlayer[ order_idx].m_pData.im_accid == im_accid then
            self:setVisibleSpeakResource( type, order_idx)            
            break
        end
    end
end

----------------------------------------------------------------------------
-- 设置对话状态显示
-- 参数: type状态默认0（0隐藏，1开启）
-- 参数: index位置假如是nil那么只是操作录音按钮，否则是操作玩家播放语音状态
function CDLayerTable_mjzy:setVisibleSpeakResource( type, index)
    cclog( "CDLayerTable_mjzy:setVisibleSpeakResource")

    if  DEF_YYBA_REVIEW then
        return 
    end

    if  not casinoclient.getInstance():isSelfBuildTable() then
        return
    end

    if  index == nil then

        if  type == nil then
            type = 0
        end

        if  type == 0 then

            self.m_pRecordButton:setVisible( false)
            for i = 0, DEF_MJZY_MAX_PLAYER-1 do

                if  self.m_pPlayer[i] ~= nil and 
                    self.m_pPlayer[i].m_pSpeakDemo ~= nil and 
                    self.m_pPlayer[i].m_pSpeakEff ~= nil then
                    self.m_pPlayer[i].m_pSpeakEff:setVisible( false)
                end
            end
            if  self.m_pRecordingEff ~= nil then
                self.m_pRecordingEff:setVisible( false)
            end
        elseif type == 1 then

            self.m_pRecordButton:setVisible( true)
            if  self.m_pRecordEffect ~= nil then
                self.m_pRecordEffect:runAnimations( 0, 0)
            end
        end
    elseif (index >= 0 and index < DEF_MJZY_MAX_PLAYER) then

        if  self.m_pPlayer[index] ~= nil and 
            self.m_pPlayer[index].m_pSpeakDemo ~= nil and 
            self.m_pPlayer[index].m_pSpeakEff ~= nil then

            if  type == 0 then
                self.m_pPlayer[index].m_pSpeakEff:setVisible( false)
            else
                self.m_pPlayer[index].m_pSpeakEff:setVisible( true)
            end
        end
    end
end

----------------------------------------------------------------------------
-- 初始化所有语音聊天相关资源
function CDLayerTable_mjzy:initAllSpeakResource()
    cclog( "CDLayerTable_mjzy:initAllSpeakResource")

    if  self.m_pRecordButton == nil then
        return
    end

    self.m_pRecordButton:setVisible( false)
    self.m_pRecordButton:removeAllChildren()
    self.m_pRecordEffect = nil

    for i = 0, DEF_MJZY_MAX_PLAYER-1 do

        if  self.m_pPlayer[i] ~= nil and 
            self.m_pPlayer[i].m_pSpeakDemo ~= nil then
            self.m_pPlayer[i].m_pSpeakDemo:removeAllChildren()
            self.m_pPlayer[i].m_pSpeakEff = nil
        end
    end
    self.m_pRecordingEff = nil

    local pos = cc.p( 0, 0)
    self.m_pRecordEffect = CDCCBAniTxtObject.createCCBAniTxtObject( self.m_pRecordButton, "x_sp_button.ccbi", pos, 0)
    if  self.m_pRecordEffect ~= nil then

        self.m_pRecordEffect:endRelease( false)
        self.m_pRecordEffect:endVisible( false)
    end
    self:sp_enableSpeak()


    for i = 0, DEF_MJZY_MAX_PLAYER-1 do

        if  self.m_pPlayer[i] ~= nil and
            self.m_pPlayer[i].m_pSpeakDemo ~= nil then

            self.m_pPlayer[i].m_pSpeakEff = CDCCBAniTxtObject.createCCBAniTxtObject( self.m_pPlayer[i].m_pSpeakDemo, "x_sp_by"..i..".ccbi", pos, 0)
            if  self.m_pPlayer[i].m_pSpeakEff ~= nil then

                self.m_pPlayer[i].m_pSpeakEff:endRelease( false)
                self.m_pPlayer[i].m_pSpeakEff:endVisible( false)
                self.m_pPlayer[i].m_pSpeakEff:setVisible( false)
            end
        end

        if  i == 0 and self.m_pPlayer[i] ~= nil and
            self.m_pPlayer[i].m_pSpeakDemo ~= nil then

            self.m_pRecordingEff = CDCCBAniTxtObject.createCCBAniTxtObject( self.m_pPlayer[i].m_pSpeakDemo, "x_sp_record.ccbi", pos, 0)
            if  self.m_pRecordingEff ~= nil then

                self.m_pRecordingEff:endRelease( false)
                self.m_pRecordingEff:endVisible( false)
                self.m_pRecordingEff:setVisible( false)
            end

            self.m_pRecordCancel = CDCCBAniTxtObject.createCCBAniTxtObject( self.m_pPlayer[i].m_pSpeakDemo, "x_sp_cancel.ccbi", pos, 0)
            if  self.m_pRecordCancel ~= nil then

                self.m_pRecordCancel:endRelease( false)
                self.m_pRecordCancel:endVisible( false)
                self.m_pRecordCancel:setVisible( false)
            end
        end
    end
end

----------------------------------------------------------------------------
-- 云信定义
local DEF_SPMJZY_RECORD_MAX_TIME = 5         -- 录音最长时间

local g_spMJZY_isRecordEnd       = false     -- 是否执行过发送语音了
local g_spMJZY_tableNum          = 0         -- 玩家总人数
local g_spMJZY_speakTime         = 0         -- 自己说话时间
local g_spMJZY_speakSpace        = 1.5       -- 说话都间隔
local g_spMJZY_canSpeak          = true      -- 自己是否可以说话
local g_spMJZY_isClickRecord     = false     -- 是否点在录音上面
local g_spMJZY_isCancelRecord    = false     -- 是否取消录音
local g_spMJZY_ismoved           = false     -- 用来判断是否移出按钮位置以外
local g_spMJZY_isShowMessage     = true      -- 是否在可以录音期间


----------------------------------------------------------------------------
--登陆云信
function CDLayerTable_mjzy:onLoginYun( ... )
    cclog("CDLayerTable_mjzy:onLoginYun")
    if  G_SPEAK_CANUSE and not DEF_OPEN_NIMSDK then

        g_sp_ClearMessage_Read()
        if  casinoclient.getInstance().im_accid ~= nil and
            casinoclient.getInstance().im_token ~= nil then

            if dtIsAndroid() then

                if  platform_help.onLoginNIM(casinoclient.getInstance().im_accid,casinoclient.getInstance().im_token) then
                    DEF_OPEN_NIMSDK    = true
                end
            else

                if  NIMSDKopen:getInstance():login( casinoclient.getInstance().im_accid, casinoclient.getInstance().im_token) then
                    DEF_OPEN_NIMSDK    = true
                end
            end
        end
    end
end

function CDLayerTable_mjzy:onCheckLogin( ... )
    if  casinoclient:getInstance():isSelfBuildTable() then
        self:onLoginYun()
        
         --先获取群ID
        if  dtIsAndroid() and DEF_OPEN_NIMSDK then
            platform_help.regeTeamId()
        end
    end
end

function CDLayerTable_mjzy:setInGameToNIM( ... )
    if  casinoclient:getInstance():isSelfBuildTable() then
        if dtIsAndroid() then
                --安卓1 是在游戏中  0是不在游戏中
            platform_help.setIsGame(1)
    
        else
            NIMSDKopen:getInstance():setIsInGame(true)
        end
    end
end

----------------------------------------------------------------------------
--设置语音是否可用
function CDLayerTable_mjzy:sp_enableSpeak()

    local enable = g_pGlobalManagement:isEnableSpeak()

    -- 还要判断当前版本是否支持语音
    if  not G_SPEAK_CANUSE then
        enable = false
    end
    -- 如果不支持那么设置 enable = false

    if  self.m_pRecordButton ~= nil then
        self.m_pRecordButton:setGrey( not enable)
    end

    -- 应该还要设置语音播放bool值
    self:sp_isUseNIM(enable)
end

----------------------------------------------------------------------------
--说话间隔 防止有人捣乱
function CDLayerTable_mjzy:sp_speakStart( ... )

    self.curTime=g_spMJZY_speakSpace
    g_spMJZY_canSpeak = false
    g_spMJZY_isShowMessage = false
    local function speakSpaceTime( ... )

        -- print("当前等待时间——>",self.curTime)
        self.curTime = self.curTime - 0.5
        if  self.curTime <= 0 then
            self.curTime = g_spMJZY_speakSpace
            g_spMJZY_canSpeak = true
            if  self.speakID then
                
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.speakID)   
                self.speakID=nil
            end
        end
    end
    if self.speakID==nil then
        self.speakID=cc.Director:getInstance():getScheduler():scheduleScriptFunc(speakSpaceTime,0.5,false)
    end
end

----------------------------------------------------------------------------
-- 计时录音多长时间(开始计时)
function CDLayerTable_mjzy:sp_recordStart( ... )

    g_spMJZY_speakTime=0
    local function reportTime( ... )

        -- print("已经录了的时间——>",g_spMJZY_speakTime)
        g_spMJZY_speakTime = g_spMJZY_speakTime+0.5
        if  g_spMJZY_speakTime >= DEF_SPMJZY_RECORD_MAX_TIME then

            g_spMJZY_speakTime = DEF_SPMJZY_RECORD_MAX_TIME
            self:endRecord()
        end
    end
    self.recordID = cc.Director:getInstance():getScheduler():scheduleScriptFunc( reportTime,0.5,false)
end

----------------------------------------------------------------------------
-- 计时录音多长时间(结束计时)
function CDLayerTable_mjzy:sp_recordEnd( ... )

    if  self.recordID then

        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.recordID)   
        self.recordID=nil
    end
end

----------------------------------------------------------------------------
--自己录音播放显示特效 播放结束后通知云信继续播放
function CDLayerTable_mjzy:sp_showSelfPra( ... )

    self.selfAccid=casinoclient.getInstance().im_accid
    self:setVisiblePlayerSpeak(1,self.selfAccid)

    local function closeSelfPra( ... )

        -- print("自己播放的剩余时间——>", g_spMJZY_speakTime)
        g_spMJZY_speakTime = g_spMJZY_speakTime-0.5
        if  g_spMJZY_speakTime <= 0 then

            g_spMJZY_speakTime = 0
            self:setVisiblePlayerSpeak( 0,self.selfAccid)
            NIMSDKopen:getInstance():continuePlayAudio()
            if self.showPraID then

                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.showPraID)   
                self.showPraID=nil
            end
        end
    end
    if  self.showPraID==nil then

        self.showPraID=cc.Director:getInstance():getScheduler():scheduleScriptFunc(closeSelfPra,0.5,false)
    end
end

----------------------------------------------------------------------------
-- 是否可以开始录音
function CDLayerTable_mjzy:canBeginRecord()
    cclog( "CDLayerTable_mjzy:canBeginRecord")

    -- 检查是否有在播放的语音
    for  i = 0, DEF_MJZY_MAX_PLAYER-1 do

        if  self.m_pPlayer[i] ~= nil and 
            self.m_pPlayer[i].m_pSpeakDemo ~= nil and 
            self.m_pPlayer[i].m_pSpeakEff ~= nil and
            self.m_pPlayer[i].m_pSpeakEff:isVisible() then

            dtAddMessageToScene( self, casinoclient.getInstance():findString("sp_record_error1"), false)
            return false
        end
    end

    local function enableSpeak()

        g_pGlobalManagement:enableSpeak( true)
        self:sp_enableSpeak()
    end

    -- 目前是灰太不可用
    if  self.m_pRecordButton ~= nil and self.m_pRecordButton:isGrey() then

        -- 判断如果不支持语音那么提示需要最新的安装包并且返回
        if  not G_SPEAK_CANUSE then
            dtAddMessageToScene( self, casinoclient.getInstance():findString("sp_ver_error"))
            return false
        end

        -- 询问是否要开启语音
        g_pSceneTable.m_pPromptDialog:open(
            casinoclient.getInstance():findString("sp_open"), 
            cc.CallFunc:create( enableSpeak), 1)
        return false
    end

    return true
end

----------------------------------------------------------------------------
-- 开始录音
function CDLayerTable_mjzy:beginRecord()
    -- print("G_SPEAK_CANUSE----->",G_SPEAK_CANUSE)

    if  (not self:canBeginRecord()) then
        return
    end

    if  DEF_OPEN_NIMSDK  and G_SPEAK_CANUSE then
        
        if  dtIsAndroid() then
            if  g_spMJZY_canSpeak then
                platform_help.stopPlay()
                platform_help.startRecord( DEF_SPMJZY_RECORD_MAX_TIME)
            else
                local msg = string.format(casinoclient.getInstance():findString("sp_record_error"),tostring(self.curTime))
                dtAddMessageToScene( self, msg)
            end
        else
            if  NIM_SPREAK_CANRECORD_IPHONE then  
                g_spMJZY_isClickRecord = true
        
                if  g_spMJZY_canSpeak then
        
                    if  self.m_pRecordingEff ~= nil then
                        self.m_pRecordingEff:setVisible( true)
                    end
                
                    if  self.m_pRecordEffect ~= nil then
                        self.m_pRecordEffect:runAnimations( 1, 0)
                    end
                        --no over
                    
                    g_spMJZY_isRecordEnd = true
                    g_spMJZY_speakTime = 0
    
                    self:sp_recordStart()
                    self:setVisiblePlayerSpeak(0,self.selfAccid)
    
                    NIMSDKopen:getInstance():onStopPlay()
                    NIMSDKopen:getInstance():onStartRecording( DEF_SPMJZY_RECORD_MAX_TIME)
    
                    g_spMJZY_canSpeak = false
                else
                    --提示录音间隙
                    local msg = string.format(casinoclient.getInstance():findString("sp_record_error"),tostring(self.curTime))
                    dtAddMessageToScene( self, msg)
                end
        
            else
                self:sp_canRecord()--提示开起麦克风
            end
        end
    end
    
end
----------------------------------------------------------------------------
-- 安卓可以录音的时候通知播放动画 和苹果无关
-- type 1 可以录音     0 不可以录音
function CDLayerTable_mjzy.playRecordAnimation( type )
    -- print("------>g_sp_Android_Read()",g_sp_Android_Read())

    --首次打开游戏启用麦克风的时候用
    if  g_sp_Android_Read() then
        g_sp_Android_Write(false)
        if  type == 1 then
            NIM_SPREAK_CANRECORD_ANDROID = true
            platform_help.stopRecord(1)
        end
        return
    end

    if  type == 1 then
        NIM_SPREAK_CANRECORD_ANDROID = true
    else
        NIM_SPREAK_CANRECORD_ANDROID = false
    end

    if  NIM_SPREAK_CANRECORD_ANDROID then
        g_spMJZY_isClickRecord = true

        if  NIM_SPREAK_MJZY.m_pRecordingEff ~= nil then
            NIM_SPREAK_MJZY.m_pRecordingEff:setVisible( true)
        end    

        if  NIM_SPREAK_MJZY.m_pRecordEffect ~= nil then
            NIM_SPREAK_MJZY.m_pRecordEffect:runAnimations( 1, 0)
        end

        g_spMJZY_isRecordEnd = true
        g_spMJZY_speakTime = 0
        NIM_SPREAK_MJZY:sp_recordStart()
        g_spMJZY_canSpeak = false
    end
end
----------------------------------------------------------------------------
--取消录音
function CDLayerTable_mjzy:cancelRecord( point )
    -- print("------->",g_spMJZY_isShowMessage)
    if  g_spMJZY_isClickRecord and g_spMJZY_isShowMessage then

        local sRect = self.m_pRecordButton:getBoundingBox()
        if  cc.rectContainsPoint( sRect, point) then
            -- print("在录音中")
            if  g_spMJZY_ismoved then
                if  self.m_pRecordingEff ~= nil then
                    self.m_pRecordingEff:setVisible( true)
                end
            
                if  self.m_pRecordEffect ~= nil then
                    self.m_pRecordEffect:runAnimations( 1, 0)
                end
                if  self.m_pRecordCancel ~= nil then
                    self.m_pRecordCancel:setVisible( false)
                end
                if  self.m_pRecordCancel ~= nil then
                    self.m_pRecordCancel:runAnimations( 0, 0)
                end
                g_spMJZY_ismoved = false
            end
            g_spMJZY_isCancelRecord=false
            g_spMJZY_canSpeak = false
        else
            -- print("不在录音中")
            if  self.m_pRecordCancel ~= nil then
                self.m_pRecordCancel:setVisible( true)
            end
            if  self.m_pRecordingEff ~= nil then
                self.m_pRecordingEff:setVisible( false)
            end
            
            if  self.m_pRecordEffect ~= nil then
                self.m_pRecordEffect:runAnimations( 0, 0)
            end
            g_spMJZY_ismoved = true
            g_spMJZY_isCancelRecord=true
            g_spMJZY_canSpeak = true
        end
    end
end
----------------------------------------------------------------------------
-- 结束录音
function CDLayerTable_mjzy:endRecord()

    if  g_spMJZY_isRecordEnd then

        -- print("是否一只循环")
        if  self.m_pRecordingEff ~= nil then
            self.m_pRecordingEff:setVisible( false)
        end
    
        if  self.m_pRecordEffect ~= nil then
            self.m_pRecordEffect:runAnimations( 0, 0)
        end
    
        -- no over
        if  DEF_OPEN_NIMSDK  and G_SPEAK_CANUSE then
            if  dtIsAndroid() then
                if  g_spMJZY_isCancelRecord then

                    if  self.m_pRecordCancel ~= nil then
                        self.m_pRecordCancel:setVisible( false)
                    end

                    if  self.m_pRecordCancel ~= nil then
                        self.m_pRecordCancel:runAnimations( 0, 0)
                    end

                    platform_help.stopRecord(1)
                else 
                    --安卓 0 不取消  1取消
                    platform_help.stopRecord(0)
                    g_sp_ClearMessage_Write()
                end
            else
                if  g_spMJZY_isCancelRecord then

                    if  self.m_pRecordCancel ~= nil then
                        self.m_pRecordCancel:setVisible( false)
                    end

                    if  self.m_pRecordCancel ~= nil then
                        self.m_pRecordCancel:runAnimations( 0, 0)
                    end

                    NIMSDKopen:getInstance():onCancelRecording()
                else
                    NIMSDKopen:getInstance():onStopRecording()
                    self:sp_showSelfPra()
                    g_sp_ClearMessage_Write()
                end
            end
        end
        if  g_spMJZY_canSpeak == false then
            self:sp_speakStart()
        end

        g_spMJZY_isRecordEnd = false
        self:sp_recordEnd()
    end    
end

----------------------------------------------------------------------------
-- 是否先点击话筒再移动出去的
function CDLayerTable_mjzy:sp_ShowMessage( ... )
    if  g_spMJZY_canSpeak then

        if  NIM_SPREAK_CANRECORD_ANDROID or NIM_SPREAK_CANRECORD_IPHONE then
            g_spMJZY_isShowMessage=true
        end

    end
end
----------------------------------------------------------------------------
-- 选择性开启语音功能
function CDLayerTable_mjzy:sp_isUseNIM( boolean )
    
    if  DEF_OPEN_NIMSDK  and G_SPEAK_CANUSE then
        local curType=1
        if not boolean then
            curType=0
        end
        if dtIsAndroid() then
            --安卓1 是在游戏中  0是不在游戏中
            platform_help.setIsGame(curType)
        else
            NIMSDKopen:getInstance():setIsInGame(boolean)
        end
    end
end
----------------------------------------------------------------------------
-- 松开手指关闭效果 
function CDLayerTable_mjzy:sp_CloseALlPra( ... )

    if  self.m_pRecordCancel ~= nil then
        self.m_pRecordCancel:setVisible( false)
    end

    if  self.m_pRecordCancel ~= nil then
        self.m_pRecordCancel:runAnimations( 0, 0)
    end

end

----------------------------------------------------------------------------
--云信判断创建群
function CDLayerTable_mjzy:sp_startCreateTeam( ... )
    cclog("CDLayerTable_mjzy:sp_startCreateTeam")

    local isFull = false --是否全部是真实玩家
    local table_data=casinoclient:getInstance():getTable()
    g_spMJZY_tableNum = #table_data.players
    -- print("当前id是",table_data.players[1].id)
    -- print("当前userid是",table_data.players[1].im_accid)
    
    for i,v in ipairs(table_data.players) do
        if v.id==0 then
            isFull = false
            break
        else
            isFull = true
        end
    end

    if isFull then
        local selfId = casinoclient.getInstance():getPlayerData():getId()
        if table_data.players[1].id==selfId then

            if table_data.players[1].im_accid then

                for i=2, g_spMJZY_tableNum do

                    local userId=table_data.players[i].im_accid

                    if string.len(userId)>0 then
                        -- print("第"..i.."userId是",userId)
                        self:sp_createTeam(userId)
                        g_sp_ClearMessage_Write()
                        break
                    else
                        -- print("没有人有云信号")
                    end
                end
            else

                -- 
            end
        end
    end
end

----------------------------------------------------------------------------
--开始创建群租
function CDLayerTable_mjzy:sp_createTeam( userId )
    if dtIsAndroid() then
        if platform_help.createNormalTeam(userId) then
            self:sp_getTeamId()
        end
    else
        if NIMSDKopen:getInstance():onCreateTeam(userId) then
            self:sp_getTeamId()
        end
    end
end

----------------------------------------------------------------------------
--获取创建群的id
function CDLayerTable_mjzy:sp_getTeamId( ... )
    local waitTime=0
    local function waitTeamId( event )
        -- print("等待创建成功")
        if dtIsAndroid() then
            --安卓可以记录 所以不需要传teamid
            waitTime=waitTime+1
            if waitTime>1 then
                self:sp_addUsers()
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
                self.schedulerID=nil
            end
        else
            self.teamId=NIMSDKopen:getInstance():getTeamId()
            if self.teamId~=0 then
                self:sp_addUsers(self.teamId)
            end
            waitTime=waitTime+1
            if waitTime>5 or self.teamId~=0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
                self.schedulerID=nil
            end
        end
    end
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(waitTeamId,1,false)
end

----------------------------------------------------------------------------
--邀请好友
function CDLayerTable_mjzy:sp_addUsers( teamId )

    local table_data=casinoclient:getInstance():getTable()
    for i = 3, g_spMJZY_tableNum do

        local userId=table_data.players[i].im_accid
        -- print("邀请的userid是",userId)
        if  string.len(userId)>0 then

            if dtIsAndroid() then
                platform_help.addUser(userId)
            else
                NIMSDKopen:getInstance():onAddUsers(userId,teamId);
            end
        else

            -- no over
        end
    end
end
----------------------------------------------------------------------------
--苹果麦克风是否开启
function CDLayerTable_mjzy:sp_canRecord( ... )
    MyObject:getInstance():canRecord()
end

--===============================网络消息处理===============================--

-- 心跳包
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Ping( __event)
    cclog("CDLayerTable_mjzy:Handle_Ping")

    local function badNetWork() -- 网络恢复缓慢

        if  self.m_bInTheGame then

            self.m_pNewLayerRoot:stopAllActions()
            self.m_pEffNetLow:setVisible( false)

            casinoclient.getInstance().m_socket:onDisconnect() --超时太多断线重连
            dtPlaySound( DEF_SOUND_ERROR)
        end
    end

    local function netRefreshTimeOut()

        if  self.m_bInTheGame then

            self.m_nTimeOut = self.m_nTimeOut - 1
            if  self.m_nTimeOut < 0 then
                self.m_nTimeOut = 0
            end
            self.m_pEffNetLow:setDefineText( 
                string.format( casinoclient.getInstance():findString("net_low"), self.m_nTimeOut))

            if  self.m_nTimeOut > 0 then

                self.m_pNewLayerRoot:stopAllActions()
                self.m_pNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( netRefreshTimeOut)))
            else
                self.m_pNewLayerRoot:stopAllActions()
                self.m_pNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( badNetWork)))
            end
        end
    end

    local function netTimeOut() -- 超时提示

        if self.m_bInTheGame then

            self.m_nTimeOut = DEF_TIMEOUT1
            self.m_pEffNetLow:setVisible( true)
            self.m_pEffNetLow:setDefineText( 
                string.format( casinoclient.getInstance():findString("net_low"), self.m_nTimeOut))

            self.m_pNewLayerRoot:stopAllActions()
            self.m_pNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( netRefreshTimeOut)))
            dtPlaySound( DEF_SOUND_ERROR)
        end
    end

    -- 假如提示资源存在那么显示
    if  self.m_pNewLayerRoot ~= nil and self.m_pEffNetLow ~= nil then

        self.m_pEffNetLow:setVisible( false)
        self.m_pNewLayerRoot:stopAllActions()
        self.m_pNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( DEF_HEARTBEAT_TIME), cc.CallFunc:create( netTimeOut)))
    end

    return true
end

----------------------------------------------------------------------------
-- 解散
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Table_Disband( __event)
    cclog("CDLayerTable_mjzy:Handle_Table_Disband")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    dtCloseWaiting( self)
    local function leaveToHall()
        g_pSceneTable:gotoSceneHall()
    end

    if  pAck.reason == casino.TABLE_DISBAND_ROUNDEND or       -- 回合结束由结算去处理
        pAck.reason == casino.TABLE_DISBAND_NORMAL then       -- 自然结束
        return
    elseif pAck.reason == casino.TABLE_DISBAND_TIMEOUT then   -- 超时
        dtAddMessageToScene( self, casinoclient:getInstance():findString("disband1"))
    elseif pAck.reason == casino.TABLE_DISBAND_OVTE then      -- 投票解散
        dtAddMessageToScene( self, casinoclient:getInstance():findString("disband2"))
    elseif pAck.reason == casino.TABLE_DISBAND_MASTER then    -- 房主解散
        dtAddMessageToScene( self, casinoclient:getInstance():findString("disband3"))
    end

    casinoclient.getInstance():clearTable()
    casinoclient.getInstance():emptyPlayerTableID()
    self:runAction( cc.Sequence:create( cc.DelayTime:create( 2.0), cc.CallFunc:create( leaveToHall)))
end

----------------------------------------------------------------------------
-- 暂停
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Table_Pause( __event)
    cclog("CDLayerTable_mjzy:Handle_Table_Pause")

    local pAck = __event.packet
    if  not pAck then
        return false
    end    

    if  casinoclient.getInstance():isSelfBuildTable() then
        self:initTablePauseTime( pAck.quit_time)
    end
    return true
end

----------------------------------------------------------------------------
-- 下线，上线
function CDLayerTable_mjzy:Handle_Table_Managed( __event)
    cclog("CDLayerTable_mjzy:Handle_Table_Managed")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    local index = 0
    if  self.m_nPlayers == 2 then
        index = g_pGlobalManagement:getTableIndex2( pAck.idx+1)
    else
        index = g_pGlobalManagement:getTableIndex4( pAck.idx+1)
    end

    self:managedTablePlayer( index, pAck.managed)


    local table_data = casinoclient.getInstance():getTable()
    if  table_data ~= nil and table_data.id > 0 and
        casinoclient.getInstance():isSelfBuildTable() then

        self:initTablePauseTime( table_data.quit_time)
    end

    return true
end

----------------------------------------------------------------------------
-- 桌子上的对话反馈
function CDLayerTable_mjzy:Handle_Table_Chat( __event)
    cclog("CDLayerTable_mjzy:Handle_Table_Chat")

    local pAck = __event.packet
    if  not pAck then
        return false
    end
    self:showPlayerBubble( pAck.player_id, pAck.chat_id, pAck.text)
    return true
end

----------------------------------------------------------------------------
-- 桌子玩家准备网络反馈
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Table_Ready_Ack( __event)
    cclog("CDLayerTable_mjzy:Handle_Table_Ready_Ack")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    local index = 0
    if  self.m_nPlayers == 2 then
        index = self:changeOrder( g_pGlobalManagement:getTableIndex2( pAck.idx+1))
    else
        index = g_pGlobalManagement:getTableIndex4( pAck.idx+1)
    end

    if  index >= 0 and index < DEF_MJZY_MAX_PLAYER then

        if  ( self.m_pPlayer ~= nil and self.m_pPlayer[index].m_pIcoReady ~= nil) and
            ( not self.m_bInTheGame) and (not self.m_pGroupSelfBuild:isVisible()) then 
            -- ( not self.m_bInTheGame) and (not casinoclient.getInstance():isSelfBuildTable()) then

            self.m_pPlayer[index].m_pIcoReady:stopAllActions()
            self.m_pPlayer[index].m_pIcoReady:setScale( 1.3)
            self.m_pPlayer[index].m_pIcoReady:setVisible( true)
            self.m_pPlayer[index].m_pIcoReady:runAction( cc.EaseBackOut:create( cc.ScaleTo:create( 0.3, 1.0)))
        end
    end
    return true
end

----------------------------------------------------------------------------
-- 桌子玩家加入的网络反馈
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Table_Entry( __event)
    cclog("CDLayerTable_mjzy:Handle_Table_Entry")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    local index = 0
    if  self.m_nPlayers == 2 then
        index = self:changeOrder( g_pGlobalManagement:getTableIndex2( pAck.idx+1))
    else
        index = g_pGlobalManagement:getTableIndex4( pAck.idx+1)
    end

    self:joinTablePlayer( index, pAck.pdata)
    return true
end

----------------------------------------------------------------------------
-- 桌子玩家离开的网络反馈
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Table_Leave( __event)
    cclog("CDLayerTable_mjzy:Handle_Table_Leave")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    dtCloseWaiting( self)

    local index = 0
    if  self.m_nPlayers == 2 then
        index = self:changeOrder( g_pGlobalManagement:getTableIndex2( pAck.idx+1))
    else
        index = g_pGlobalManagement:getTableIndex4( pAck.idx+1)
    end

    if  index == 0 then -- 自己

        casinoclient:getInstance():emptyPlayerTableID()
        g_pSceneTable:gotoSceneHall()
    else
        self:clearTargetIPPos( index)
        self:leaveTablePlayer( index)
    end
    return true
end

----------------------------------------------------------------------------
-- 所有玩家准备结束，可以进行发牌的反馈
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_MJZY_StartPlay( __event)
    cclog("CDLayerTable_mjzy:Handle_MJZY_StartPlay")

    local pAck = __event.packet
    if  not pAck or self.m_bReConnection then
        return false
    end
    self.canhuNow = false
    self:releaseOnQianZzhuangTip()
     --创建云信
    if  not self.isCreateNIM then
        if  DEF_OPEN_NIMSDK and G_SPEAK_CANUSE then
            self:setInGameToNIM()
            if  casinoclient.getInstance():isSelfBuildTable() then
            
                self:sp_startCreateTeam()
            end
        end
    end

    dtCloseWaiting(self)
    g_pSceneTable:closeAllUserInterface()

    -- 创建湖北江陵晃晃数学库
    if  not self.mahjong_MJZY then
        self.mahjong_MJZY = CDMahjongMJZY.create()
    end

    -- 设置赖子数据
    self.mahjong_MJZY:setMahjongLaiZi(pAck.laizi)

    -- 设置赖皮数据
    self.mahjong_MJZY:setMahjongFan(pAck.fanpai)
    -- self.mahjong_MJZY:setFlagPiao( false)
    g_pGlobalManagement:setLaiZi(pAck.laizi)

    -- 初始化桌子
    self:initTable()
    self:setVisibleSpeakResource(1) -- 开启语音聊天按钮

    -- 避免游戏开始了还要进入之前没有进入的计算画面
    self.m_pTimeLeftTTF:stopAllActions()
    if  g_pSceneTable.m_pLayerMJScore:isVisible() then
        g_pSceneTable.m_pLayerMJScore:close()
    end

    -- 分配四家牌
    local other_mahjong = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    for i = 0, DEF_MJZY_MAX_PLAYER - 1 do
        if  i == 0 then
            self.mahjong_MJZY:randomMahjongs(pAck.cards)
            self.m_pPlayAI[i]:addVMahjong_withArray(pAck.cards)
        else
            self.m_pPlayAI[i]:addVMahjong_withArray(other_mahjong)
        end
    end

    -- 设置及显示麻将牌剩余总数
    self.mahjong_MJZY:mahjongTotal_set()

    -- 分配完牌后，更新余牌总数（每人13张，总共4人，庄多一张牌）
    self.mahjong_MJZY:mahjongTotal_lower(self:changeLowerMahjongTotal())
    self:refreshTableInfo()

    -- 获取庄家ID
    self.m_nLordID = pAck.lord_id

    -- 初始化指针，庄家先出牌
    self:setOrderType(self:changeOrder(self:getTableIndexWithID(pAck.lord_id)))

    -- 发牌
    self.m_bInTheGame = true
    self:round_startLicensing()
    self:Handle_Ping(nil) -- 断线提醒时间差

    -- 倒计时
    self:showTimeLeft(pAck.time)
    self:initTablePauseTime()

    return true
end

----------------------------------------------------------------------------
-- 最后四张牌的时候
-- 参数: 数据包
-- function CDLayerTable_mjzy:Handle_MJZY_EndCard( __event)
--     cclog("CDLayerTable_mjzy:Handle_MJZY_EndCard")

--     local pAck = __event.packet
--     if  not pAck or self.m_bReConnection then
--         return false
--     end

--     if  pAck.card ~= 0 then

--         self:round_OutMahjongShow_Back( 0)

--         self.mahjong_MJZY:mahjongTotal_set( 14+self.m_nPlayers)
--         self:refreshTableInfo()

--         self.m_nEndCardType = 0
--         self.m_nEndCard = pAck.card
--         self:showEndCard()
--     end
--     return true
-- end

----------------------------------------------------------------------------
-- 进入结算的反馈，已经有玩家胡牌
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Table_Score( __event)
    cclog("CDLayerTable_mjzy:Handle_Table_Score")

    local pAck = __event.packet
    if  not pAck or self.m_bReConnection then
        return false
    end
    
    self.m_pHuIndex = -1 
    -- 清空我的桌子记录
    casinoclient.getInstance():emptyPlayerTableID()
    -- 按钮组回到默认状态，并且关闭倒计时
    self:setGroupButtonToDefine()
    self:setTimeLeftVisible( false)
    -- 设置胡牌效果
    local count = TABLE_SIZE( pAck.scores)

    for i = 1, count do

        local player_score = pAck.scores[i]
        if  player_score.hupai_card > 0 then

            local index = self:changeOrder( self:getTableIndexWithID( player_score.data.id))
            self.m_pHuIndex = index
            self:displayHu( index, pAck.scores[i])
        end            
    end
    -- 隐藏所有晃按钮
    self:myMahjong_visibleHuangButton( false)
    -- 离开游戏状态并且设置倒计时
    self.m_bInTheGame = false
    if  casinoclient:getInstance():isSelfBuildTable() then
        self.m_nTimeLeft = 3
        self.m_nScoreTime = pAck.time - self.m_nTimeLeft
    else
        self.m_nTimeLeft = 3
        self.m_nScoreTime = 0
    end
    g_pGlobalManagement:setScoreData( pAck)
    self:showLeftTimeGotoScore()

    -- 开启语音聊天按钮
    self:setVisibleSpeakResource(0)
    return true
end

----------------------------------------------------------------------------
-- 中途获取的积分
-- 参数: 数据包
 function CDLayerTable_mjzy:Handle_MJZY_Score( __event)
     cclog("CDLayerTable_mjzy:Handle_MJZY_Score")

    local pAck = __event.packet
    if  not pAck or self.m_bReConnection then
        return false
    end

    -- self:showScoreNumber( pAck.scores)

    -- if  pAck.type == casino_mjzy.MJZY_OP_TYPE_XIAOHOUCHONG then
    --     self:round_OutMahjongShow_Back( DEF_MJZY_HU+1000)
    -- end
    return true
end

----------------------------------------------------------------------------
-- 发一张牌给玩家后的网络反馈
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_MJZY_DrawCard( __event)
    cclog("CDLayerTable_mjzy:Handle_MJZY_DrawCard")

    local pAck = __event.packet
    if  not pAck or self.m_bReConnection then
        return false
    end
    -- 字段 fangfeng
    -- TODO

    -- print("-----------------test----------------------")
    -- self.mahjong_MJZY:setMahjongLaiZi(11)
    -- --local temp = {11,11,12,12,13,13,14,14,15,15,16,16,17,17}
    -- local temp = {11,12,12,21,21,22,22,23,23,24,24,25,25,17}

    -- local mahjong = 17
    -- local  arr1 ,arr2 =self.mahjong_MJZY:getArray_hupai(temp,mahjong,false)
    -- dumpArray(arr1)
    -- dumpArray(arr2)


    self:setGroupButtonVisible(false)
    dtCloseWaiting( self) -- 新加

    if  not self.m_pOrderIco:isVisible() then
        self:resetOrderText()
        self:setTimeLeftVisible(true)
    end

    self:closeAllBtnGroup()
    self.m_bOPSelf = false
    local index = self:getTableIndexWithID(pAck.player_id)
    if index ~= -1 then
        -- 自己摸牌，那么清除不可捉铳标记
        if  index == 0 then
            self.m_pPlayAI[0]:setNotCatch(false)
        end

        self:showTimeLeft(pAck.time)
        self.m_bCanOutMahjong = false
        print("pAck.card---------------------->",pAck.card)
        if  (pAck.card == 0 or pAck.card == -1 ) and pAck.player_id == casinoclient:getInstance():getPlayerData():getId()  then
            if pAck.card ~= -1 then
                self:showGangEffect(0, true)    
            end

            --吃，碰后的操作
            if pAck.card == 0 then
                self.m_bCanCheck = false
            end

            --放风后的round_MyThink
            self:round_MyThink()

            self:setCanOutCards(false)
            self.m_bCanOutMahjong = true
        elseif pAck.card ~= 0 and pAck.card ~= -1 then
            
            self.mahjong_MJZY:mahjongTotal_lower()
            self:refreshTableInfo()
            self:round_MoMahjong(index, pAck.card,pAck.fangfeng)
        end

        if  index == 0 then
            self:setGroupTipVisible(true)
            self:myMahjong_setIcoTing()
        end
    end
    self:initTablePauseTime()
    self:round_OutMahjongShow_Back(0)
    return true
end

----------------------------------------------------------------------------
-- 有一个玩家可能有（碰、杠、胡)
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_MJZY_OP( __event)
    cclog("CDLayerTable_mjzy:Handle_MJZY_OP")

    local pAck = __event.packet
    if  not pAck or self.m_bReConnection then
        return false
    end

    -- TODO
    self:setGroupButtonVisible(false)
    dtCloseWaiting( self) -- 新加

    self:closeAllBtnGroup()
    if  pAck.player_id == casinoclient.getInstance():getPlayerData():getId() then

        self:showTimeLeft( pAck.time)
        self:round_MyOPThink(pAck.target_id, pAck.op, pAck.canchi)
        self.m_bOPSelf = true
    else

        self.m_bOPSelf = false
    end
    return true
end

----------------------------------------------------------------------------
function CDLayerTable_mjzy:getChiCardsWithReconnect(  )
    self.m_sChiArr={}
    local function getChiArr( group )
        local arr = {}
        if  group.mahjongs and TABLE_SIZE(group.mahjongs) > 0 then
            
            for i,v in ipairs(group.mahjongs) do
                arr[TABLE_SIZE(arr)+1] = v
            end
            
        end
        return arr
    end
    local myOutGroup = self.m_pPlayAI[0]:getNMahjong()
    local lastOutGroup = myOutGroup[TABLE_SIZE(myOutGroup)]
    if  lastOutGroup.type_op == DEF_MJZY_OP_CHI then
        local chiArr = getChiArr(lastOutGroup)
        self.m_sChiArr = self.mahjong_MJZY:getOwnArrFromArr(chiArr,lastOutGroup.target_card)
    end

end

function CDLayerTable_mjzy:setCanOutCards( isReset )
    if  self.m_sChiArr and TABLE_SIZE(self.m_sChiArr) == 2 and not isReset then
        local index = self:getMahjongIndexWithVaild( 0, true)
        if  index > self.m_nPMahjongs[0] or index <= 0 then
            self.m_sChiArr = {}
            return
        end

        for i = index, self.m_nPMahjongs[0] do
            if  self.m_pPMahjongs[0][i].m_nMahjong and 
                self.m_pPMahjongs[0][i].m_nMahjong ~= self.mahjong_MJZY:getMahjongLaiZi() then

                self.m_pPMahjongs[0][i].m_pMahjong:setGrey(false)
                -- if  self.mahjong_MJZY:canPutCard( self.m_sChiArr,self.m_pPMahjongs[0][i].m_nMahjong) then
                --     self.m_pPMahjongs[0][i].m_pMahjong:setGrey( false)
                -- else
                --     self.m_pPMahjongs[0][i].m_pMahjong:setGrey( true)
                -- end
            end
        end
    else
        self.m_sChiArr = {}
        local index = self:getMahjongIndexWithVaild( 0, true)
        if  index > self.m_nPMahjongs[0] or index <= 0 then
            return
        end
        for i = index, self.m_nPMahjongs[0] do
            if  self.m_pPMahjongs[0][i].m_nMahjong then
                self.m_pPMahjongs[0][i].m_pMahjong:setGrey( false)   
            end
        end
    end
end

-- 重连
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_MJZY_Reconnect( __event)
    cclog("CDLayerTable_mjzy:Handle_MJZY_Reconnect")

    local pAck = __event.packet
    if  not pAck then
        return false
    end
    self.isReconnect = true

    print("pAck.status------------------------------->",pAck.status)

    if  pAck.status == casino_mjzy.MJZY_STATUS_OUTCARD then -- 我出牌

        -- 这里可能导致碰过后重连
        if  pAck.player_id == casinoclient:getInstance():getPlayerData():getId() then

            -- -- 如果之前是碰活着笑（仅限小朝天）那么直接要求打牌跳过round_MyThink()
            if  pAck.op == DEF_MJZY_PENG or pAck.op == DEF_MJZY_GANG or 
                pAck.op == DEF_MJZY_CHI then

                print("pAck.op----------->",pAck.op)
                self:showGangEffect(0,true)
                self.m_bCanOutMahjong = true

                self.m_bSaveZCHFlag = false
                self.m_bSaveOPZCMahjong = 0
                self.m_bSaveOPGFlag = false
                self.m_nSaveOPGMahjong = 0 
                self.m_bSaveOPPFlag = false
                self.m_nSaveOPPMahjong = 0

                self:closeAllBtnGroup()

                if  pAck.op == DEF_MJZY_CHI then
                    self:getChiCardsWithReconnect()
                    self:setCanOutCards(false)
                end

            else
                print("-------另一个断线重连--------------")
             
                print("pAck.player_id---------->",pAck.player_id)
            
                print("pAck.op",pAck.op)
               
                self:round_MyThink()
                self.m_bCanOutMahjong = true

                if  self.m_pGroupButton:isVisible() then -- 说明我有选项可以操作
                    self:setGroupTipVisible( false)
                end
            end
        end
    elseif pAck.status == casino_mjzy.MJZY_STATUS_OP then -- 我的OP判断
        print("pAck.player_id----->",pAck.player_id)
         print("pAck.op",pAck.op)
        if  pAck.player_id == casinoclient:getInstance():getPlayerData():getId() then
            self:closeAllBtnGroup()
            self.m_nLastOutMahjong = pAck.card
            if  pAck.target_id ~= 0 and pAck.target_id ~= pAck.player_id then

                self.m_nLastOutPlayer = self:getTableIndexWithID( pAck.target_id)
                self:round_MyOPThink(pAck.target_id,pAck.op,pAck.canchi)
                self.m_bOPSelf = true
            else
              
                if pAck.op == DEF_MJZY_FANGFENG and pAck.op_id == 1 then
                    self.m_bCanFangFeng = true
                    self:setGroupFangFengBtnVisible(true)
                else
                    self:round_MyThink()
                end
                self.m_bCanOutMahjong = true
            end

            if  self.m_pGroupButton:isVisible() then
                self:setGroupTipVisible( false)
            end
        end
    -- elseif pAck.status == casino_mjzy.MJZY_STATUS_BET then -- 下注阶段
    --     self.m_pButSponsor:setVisible( true)
    end

    self:showWaitTime(pAck.quit_time)

    return true
end

-- function CDLayerTable_mjzy:checkMyLastOutCardWithReconnect( ... )
--     local myOutCards = self.m_pPlayAI[0]:getOutCards()
--     if  myOutCards[TABLE_SIZE(myOutCards)] == self.mahjong_MJZY:getMahjongLaiZi() or 
--         myOutCards[TABLE_SIZE(myOutCards)] == 51 then
--         return true
--     end
--     return false
-- end


----------------------------------------------------------------------------
-- 玩家处理（碰、杠、胡、吃）的反馈
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_MJZY_OP_Ack( __event)
    cclog( "CDLayerTable_mjzy:Handle_MJZY_OP_Ack")

    local pAck = __event.packet
    if  not pAck or self.m_bReConnection then
        return false
    end

    -- TODO
    self:setGroupButtonVisible(false)
    dtCloseWaiting( self) -- 新加

    local index = self:getTableIndexWithID( pAck.player_id)
    -- 没有任何操作，并且不是不捉铳，那么旋转指针到操作者
    if  pAck.op ~= 0 and pAck.op ~= DEF_MJZY_BUZHUOCHONG then
        self:setOrderType( index)
    end 

    if  index == 0 then -- 假如是自己
        
        if  pAck.op == 0 then -- 假如没有操作
            if  (not self.m_pBut_Type[ DEF_MJZY_BUT_TYPE_GANG]:isGrey()) and 
                self.m_bSaveOPGFlag and self.m_nSaveOPGMahjong ~= 0 then

                if  (not self.m_pBut_Type[ DEF_MJZY_BUT_TYPE_PENG]:isGrey()) and 
                    self.m_bSaveOPPFlag and self.m_nSaveOPPMahjong ~= 0 then
                    -- self:myMahjong_addForgo( 2, self.m_nSaveOPGMahjong, true)
                else
                    -- self:myMahjong_addForgo( 0, self.m_nSaveOPGMahjong, true)
                end
            else
                if  (not self.m_pBut_Type[ DEF_MJZY_BUT_TYPE_PENG]:isGrey()) and 
                    self.m_bSaveOPPFlag and self.m_nSaveOPPMahjong ~= 0 then
                    -- self:myMahjong_addForgo( 1, self.m_nSaveOPPMahjong, true)
                end
            end
        elseif  pAck.op == DEF_MJZY_BUZHUOCHONG then

            self.m_pPlayAI[0]:setNotCatch( true)
            self.m_bSaveZCHFlag = false
            self:myMahjong_updateForgoMessage()
        end
    end

    self:setGroupButtonToDefine()
    if  index ~= -1 then

        -- cclog( "CDLayerTable_mjzy:Handle_MJZY_OP_Ack(%u)", pAck.op)
        if  pAck.op == DEF_MJZY_PENG then --碰

            self:operatePeng( self:changeOrder( index), pAck.cards, pAck.target_id)
            
            dtPlaySound( DEF_SOUND_EVENT)
            self:round_OutMahjongShow_Back( DEF_MJZY_PENG+1000)
        elseif pAck.op == DEF_MJZY_GANG then --各种杠

            --  检测三种可能的错误（小于等于1张牌，三张牌但是闷笑，三张牌但是点笑）
            if  pAck.type == casino_mjzy.MJZY_OP_TYPE_DIANXIAO or
                pAck.type == casino_mjzy.MJZY_OP_TYPE_MENGXIAO or 
                pAck.type == casino_mjzy.MJZY_OP_TYPE_XIAOCHAOTIAN or
                pAck.type == casino_mjzy.MJZY_OP_TYPE_DACHAOTIAN then

                if  TABLE_SIZE( pAck.cards) <= 1 then

                    pAck.type = casino_mjzy.MJZY_OP_TYPE_HUITOUXIAO
                elseif TABLE_SIZE( pAck.cards) == 3 and pAck.type == casino_mjzy.MJZY_OP_TYPE_MENGXIAO then

                    pAck.type = casino_mjzy.MJZY_OP_TYPE_DACHAOTIAN
                elseif TABLE_SIZE( pAck.cards) == 3 and pAck.type == casino_mjzy.MJZY_OP_TYPE_DIANXIAO then

                    pAck.type = casino_mjzy.MJZY_OP_TYPE_XIAOCHAOTIAN
                end
            end
            self:operateGang( pAck.cards[1], pAck.type, self:changeOrder( index), pAck.target_id)
            dtPlaySound( DEF_SOUND_EVENT)
            self:round_OutMahjongShow_Back( pAck.type)
        elseif  pAck.op == DEF_MJZY_HU or pAck.op == DEF_MJZY_ZIMO or 
                pAck.op == DEF_MJZY_QIANGXIAO then -- 其他的事各种胡牌

            dtPlaySound( DEF_MJZY_SOUND_MJ_SCORE)
            self:round_OutMahjongShow_Back( DEF_MJZY_HU+1000)

            -- 增加被抢的人表现
            -- if  pAck.op == DEF_MJZY_QIANGXIAO then
            --     self:operateQiang( pAck.cards[1], pAck.target_id)
            -- end
        elseif pAck.op == DEF_MJZY_CHI then

            self:operateChi(self:changeOrder( index), pAck.cards, pAck.target_id, pAck.card)
            dtPlaySound( DEF_SOUND_EVENT)
            self:round_OutMahjongShow_Back( DEF_MJZY_CHI +1000 )

        elseif pAck.op == DEF_MJZY_FANGFENG   then
    
            if pAck.type == 2 then
                 print("---------跑风op----Ack-------------")
        
                 self:operatePaoFeng(self:changeOrder( index),pAck.card)
            else
                print("---------放风op----Ack-------------")
                self:operateFangFeng(self:changeOrder( index),pAck.cards)
            end
        else

            self:round_OutMahjongShow_Back( 0)
        end
    end
    self:initTablePauseTime()
    return true
end
----------------------------------------------------------------------------
-- 杠的提示按钮
-- 回头笑处理 显示按钮 当碰和笑同时出发时
function CDLayerTable_mjzy:showGangEffect( index,isPeng )
    local canshow,showGangArr,notGangValue = self.mahjong_MJZY:canGangAfterPeng(self.m_pPlayAI[0]:getAllVMahjongs(),isPeng,self.m_pPlayAI[0]:getNMahjong())
    if  canshow and TABLE_SIZE(showGangArr) > 0 then

        for i,v in ipairs(showGangArr) do
            self:myMahjong_addHuangButton(v)
        end
    end

    local canGang,gangArr = self.mahjong_MJZY:canPengWithReconnect(self.m_pPlayAI[0]:getAllVMahjongs())
        
    if  canGang and TABLE_SIZE(gangArr) > 0 then

        for i,v in ipairs(gangArr) do
            self:myMahjong_addHuangButton(v)
        end
    end
    if  index and index == 0 then
        self:myMahjong_vaildHuangButton( true,notGangValue) --晃晃牌按钮激活
    end

end
----------------------------------------------------------------------------
-- 检测 出牌后是否需要清除记录
-- 参数：出牌玩家的位置索引
function CDLayerTable_mjzy:checkIsClearReport( index )

    if  self.m_pLastOutCardIndex == -1 then
        self.m_pLastOutCardIndex = index
    else
        self.m_pCurOutCardIndex = index
    end

    if  self.m_pLastOutCardIndex ~= -1 and self.m_pCurOutCardIndex ~= -1 then
        if  self.m_pCurOutCardIndex - self.m_pLastOutCardIndex < 0 then
            self.m_pPlayAI[0]:setNotCatch( false)
            self.m_pPlayAI[0]:delAllForgoPeng()
            self.m_pPlayAI[0]:delAllForgoGang()
            self:myMahjong_updateForgoMessage()
        end
    end
    self.m_pLastOutCardIndex = index
    self.m_pCurOutCardIndex = -1

end

-- 玩家出牌的网络反馈
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_MJZY_OutCard_Ack( __event)
    cclog("CDLayerTable_mjzy:Handle_MJZY_OutCard_Ack")

    local pAck = __event.packet
    if  not pAck or m_bReConnection then
        return false
    end

    -- TODO
    self:setGroupButtonVisible(false)
    dtCloseWaiting(self) -- 新加

    self:setGroupTipVisible(false)

    local index = self:changeOrder(self:getTableIndexWithID(pAck.player_id))
    self.m_nLastOutMahjong = pAck.card
    self.m_nLastOutPlayer = index
    self:round_OutMahjongShow_Front(pAck.card, index)
    self:initTablePauseTime()

    -- 记录一张已经用掉的牌
    if  index ~= - 1 then
        self.m_pPlayAI[index]:addIMahjong( pAck.card)
        self.m_pPlayAI[index]:setOwnOutCard(pAck.card)
        -- self:checkIsClearReport(index)
        -- 假如是自己打的牌那么放弃不可捉铳标志，放弃碰
        if  index == 0 then
            self.canhuNow = false
            self:setCanOutCards(true)
            self.m_pPlayAI[0]:setNotCatch( false)
            self.m_pPlayAI[0]:setGangType(false)
            self.m_pPlayAI[0]:delAllForgoPeng()
            self.m_pPlayAI[0]:delAllForgoGang()
            self:myMahjong_updateForgoMessage()
        end
    end

    -- 假如是自己打出了牌那么清空相同牌显示
    self:setSameMahjongWithAll(0)

    if  self.m_pTingGroup then
        self.m_pTingGroup:setVisible( false)
    end

    return true
end

----------------------------------------------------------------------------
-- 玩家重连
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Player_Join_Ack( __event)
    cclog( "CDLayerTable_mjzy:Handle_Player_Join_Ack")
    local pAck = __event.packet
    if not pAck then
        return false
    end

    local table_id = casinoclient:getInstance():getPlayerTableID()
    if  table_id <= 0 then
        self:onGotoHall()
    end
    return true
end

----------------------------------------------------------------------------
-- 玩家重连入桌子
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Table_Join_Ack( __event)
    cclog( "CDLayerTable_mjzy:Handle_Table_Join_Ack")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    if  not DEF_OPEN_NIMSDK then
        self:onCheckLogin()
    end

    local function leaveToHall()
        g_pSceneTable:gotoSceneHall()
    end

    dtCloseWaiting( self)
    if  pAck.ret == casino.RETURN_SUCCEEDED then

        if  pAck.reconnect then

            self.m_bReConnection = true
            self:resetTableData( pAck.tdata)
        else
            -- 再来一局自动准备
            self:initTablePlayer()
            casinoclient:getInstance():sendTableReadyReq()
        end
    else

        if  pAck.ret == casino.RETURN_INVALID then
            g_pSceneTable.m_pPromptDialog:open(
                casinoclient.getInstance():findString("error_table_join_i"), 
                cc.CallFunc:create( leaveToHall), 1)
        else
            g_pSceneTable.m_pPromptDialog:open(
                casinoclient.getInstance():findString("join_table_error"), 
                cc.CallFunc:create( leaveToHall), 1)
        end
    end
    return true
end

----------------------------------------------------------------------------
-- 收到要添加我为好友的处理
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Friend_Req(__event)
    cclog( "CDLayerTable_mjzy:Handle_Friend_Req")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    if  pAck.op == casino.FRIEND_OP_REQUEST then

        local table_data = casinoclient:getInstance():getTable()
        local count = TABLE_SIZE( table_data.players)
        for i = 1, count do
            if  table_data.players[i].id == pAck.friend_id then
                g_pSceneTable:openPlayerInfo_withNetAck( table_data.players[i])
                break
            end
        end
    end
    return true
end

----------------------------------------------------------------------------
-- 发起解散后，有人返回同意或者不同意
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Table_Disband_Ack(__event)
    cclog( "CDLayerTable_mjzy:Handle_Table_Disband_Ack")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    if  pAck.disband then
        self:showPlayerBubble( pAck.player_id, 0, casinoclient.getInstance():findString("disband_ok"))
    else
        self:showPlayerBubble( pAck.player_id, 0, casinoclient.getInstance():findString("disband_no"))
    end
end

----------------------------------------------------------------------------
-- 发起解散
-- 参数: 数据包
function CDLayerTable_mjzy:Handle_Table_Disband_Req(__event)
    cclog( "CDLayerTable_mjzy:Handle_Table_Disband_Req")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    local function sendDisbandOK()
        casinoclient.getInstance():sendTableDisbandAck( true)
    end

    local function sendDisbandNO()
        casinoclient.getInstance():sendTableDisbandAck( false)
    end

    local function disbandRefresh()

        local time = dtIsTimeOver( self.m_uDisbandTime, casinoclient.getInstance():config_table_disband_time())
        if  time <= 0 then

            if  g_pSceneTable.m_pPromptDialog:isVisible() then
                g_pSceneTable.m_pPromptDialog:close()
            end
            self.m_pButSponsor:setVisible( true)
            self.m_pTxtSponsor:setVisible( false)
        else

            self.m_pTxtSponsor:setString( string.format("%u", time))
            self.m_pTxtSponsor:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( disbandRefresh)))
        end
    end

    local order_type = self:getTableIndexWithID( pAck.player_id)
    self:showPlayerBubble( pAck.player_id, 0, casinoclient.getInstance():findString("disband_my"))
    if  order_type ~= 0 and
        (not g_pSceneTable.m_pPromptDialog:isVisible()) and
        pAck.disband_time > 0 then

        g_pSceneTable.m_pPromptDialog:open( casinoclient.getInstance():findString("disband_start"),
            cc.CallFunc:create( sendDisbandOK), 2, cc.CallFunc:create( sendDisbandNO))
    end

    --  暂时关闭解散按钮使用状态
    if  self.m_pButSponsor:isVisible() and pAck.disband_time > 0 then

        self.m_uDisbandTime = pAck.disband_time
        self.m_pButSponsor:setVisible( false)
        self.m_pTxtSponsor:setVisible( true)
        self.m_pTxtSponsor:setString( string.format("%u", casinoclient.getInstance():config_table_disband_time()))
        self.m_pTxtSponsor:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( disbandRefresh)))
    end
end

----------------------------------------------------------------------------
-- 转换玩家索引位置根据游戏人数(4人、2人转换用）
function CDLayerTable_mjzy:changeOrder( order)

    local change_order = order
    if  self.m_nPlayers == 2 then
        if  order == 1 then
            change_order = 2
        end
    end
    return change_order
end

----------------------------------------------------------------------------
-- 转换获取打出的牌最大数(4人、2人转换用）
function CDLayerTable_mjzy:changeMaxOutMahjongs()

    if  self.m_nPlayers == 2 then
        return 57
    else
        return DEF_MJZY_MAX_OUTMAHJONG
    end
end
----------------------------------------------------------------------------
-- 转换最大出牌数量
function CDLayerTable_mjzy:changeNowOutMahjongs( order_type)

    local max = self:changeMaxOutMahjongs()
    if  self.m_sOutNumber[order_type] > max then
        self.m_sOutNumber[order_type] = max
    end
end
----------------------------------------------------------------------------
-- 转换获取X轴上最大牌数量(4人、2人转换用）
function CDLayerTable_mjzy:changeXMahjongs()

    if  self.m_nPlayers == 2 then
        return 19
    else
        return 9
    end
end

----------------------------------------------------------------------------
-- 转换获取开局用掉的牌数(4人、2人转换用）
function CDLayerTable_mjzy:changeLowerMahjongTotal()

    if  self.m_nPlayers == 2 then
        return 13*2 
    else 
        return 13*4
    end
end

----------------------------------------------------------------------------
-- 重置电量
function CDLayerTable_mjzy:resetPower()

    local function updatePower()

        local power = platform_help.getBatterLevel()
        if  power > 100 then
            power = 100
        elseif power < 0 then
            power = 0
        end
    
        local width = power * 0.01 * 33
        local size = self.m_pIcoPower:getContentSize()
        size.width = width
        self.m_pIcoPower:setContentSize( size)
        self.m_pIcoPower:runAction( cc.Sequence:create( cc.DelayTime:create( 60.0), cc.CallFunc:create( updatePower)))
    end
    updatePower()
end

----------------------------------------------------------------------------
-- 刷新牌在它定义的范围内
-- 参数: 位置, 数量（默认空), 是否摸牌排列（默认空) 
-- 返回: 所占用的范围尺寸
function CDLayerTable_mjzy:resetTableMahjongs( idx, number, is_mo)
    cclog( "CDLayerTable_mjzy:resetTableMahjongs")

    if  idx < 0 or idx >= DEF_MJZY_MAX_PLAYER then
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

            if  not self.m_pPMahjongs[idx][MJZY_INDEX_ITOG(idx,i)].m_bVaild then
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
        need_size = need_size + 10 + DEF_MJZY_MYTABLE_SPACE*2
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
        pos = pos + DEF_MJZY_MYTABLE_SPACE
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

        local index = MJZY_INDEX_ITOG( idx, i)
        local next  = MJZY_INDEX_ITOG( idx, i+1)
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
                self.m_pPMahjongs[idx][index].m_pMahjong:setIcoTingVisible( false)
            else
                self.m_pPMahjongs[idx][index].m_pMahjong:setMahjongScale( smin*now_scale)
            end
        end
        -- 当还有下一个对象的时候设置坐标偏移
        if  i < count then

            if  self.m_pPMahjongs[idx][ MJZY_INDEX_ITOG( idx, i+1)].m_bVaild then
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
                if  group_s.type_op == DEF_MJZY_OP_CHI then
  
                    if  self.m_pPMahjongs[idx][index].m_pMahjong:getMahjongNumber() ==  group_s.target_card then
                        
                        bak_index = bak_index + 1

                        local ico_tag = nil
                        if  idx == 0 then
                            ico_tag = self.m_pCenterDire:getChildByTag( (idx+1)*DEF_MJZY_ICO_IDX+bak_index)
                        else
                            ico_tag = self.m_pMahjongEff:getChildByTag( (idx+1)*DEF_MJZY_ICO_IDX+bak_index)
                        end
                        if  ico_tag == nil then
                            if  idx == 0 then
                                ico_tag = cc.Sprite:createWithSpriteFrameName( "xn_ico_tag.png")
                                self.m_pCenterDire:addChild( ico_tag)
                            else
                                ico_tag = cc.Sprite:createWithSpriteFrameName( "xn_ico_tags.png")
                                self.m_pMahjongEff:addChild( ico_tag)
                            end
                            ico_tag:setTag( (idx+1)*DEF_MJZY_ICO_IDX+bak_index)
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

                    end
                    bak_total = 0
                    bak_center = cc.p( 0, 0)
                else 
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
                            ico_tag = self.m_pCenterDire:getChildByTag( (idx+1)*DEF_MJZY_ICO_IDX+bak_index)
                        else
                            ico_tag = self.m_pMahjongEff:getChildByTag( (idx+1)*DEF_MJZY_ICO_IDX+bak_index)
                        end
                        if  ico_tag == nil then
                            if  idx == 0 then
                                ico_tag = cc.Sprite:createWithSpriteFrameName( "xn_ico_tag.png")
                                self.m_pCenterDire:addChild( ico_tag)
                            else
                                ico_tag = cc.Sprite:createWithSpriteFrameName( "xn_ico_tags.png")
                                self.m_pMahjongEff:addChild( ico_tag)
                            end
                            ico_tag:setTag( (idx+1)*DEF_MJZY_ICO_IDX+bak_index)
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
    end
    return need_size
end

----------------------------------------------------------------------------
-- 检车摊牌组中我这张牌属于什么类型的摊牌
-- 参数: groups摊牌组, mahjong牌, order检测的人
-- 返回: 摊牌类型
function CDLayerTable_mjzy:getSArrayType( groups, mahjong, order)

    local count = TABLE_SIZE( groups)
    for i = 1, count do

        if  TABLE_SIZE( groups[i].cards) > 0 and groups[i].cards[1] == mahjong then

            if  groups[i].op == DEF_MJZY_PENG then

                return DEF_MJZY_OP_PENG
            elseif groups[i].op == DEF_MJZY_GANG then

                if  order == self:changeOrder( self:getTableIndexWithID( groups[i].target_id)) then

                    if  TABLE_SIZE( groups[i].cards) == 1 then

                        return DEF_MJZY_OP_GANG_B
                    else

                        return DEF_MJZY_OP_GANG_A
                    end
                else

                    return DEF_MJZY_OP_GANG_M
                end
            end
        end
    end
    return 0
end
----------------------------------------------------------------------------
-- 重置桌子上的玩家
-- 参数: order_type索引, table_player玩家数据
function CDLayerTable_mjzy:resetTablePlayer( order_type, table_player)
    cclog("CDLayerTable_mjzy::resetTablePlayer")
    local value = 0
    local pointer = nil

    -- 将玩家加入桌子
    self:joinTablePlayer( order_type, table_player)

    -- 更新这个玩家的桌面信息
    local v_count = TABLE_SIZE( table_player.curcards)  -- 手牌总数
    local s_count = TABLE_SIZE( table_player.selcards)  -- 摊牌总数

    -- 压入手牌, 设置积分
    self:refreshTablePlayer( order_type, table_player)
    table.sort( table_player.curcards, mahjong_MJZY_table_stb)
    self.m_pPlayAI[order_type]:addVMahjong_withArray( table_player.curcards)

    -- 摊牌组压入
    local s_group_count = TABLE_SIZE( table_player.groups)
    print("s_group_count-------------------->",s_group_count)
    for i = 1, s_group_count do
        local s_group = table_player.groups[i]
        print("i------------>",i)
        print("s_group.cards")
        dumpArray(s_group.cards)
        local s_idx = self:changeOrder(self:getTableIndexWithID( s_group.target_id))
        local s_op = 0

        if  s_group.op == DEF_MJZY_PENG then

            s_op = DEF_MJZY_OP_PENG
        elseif s_group.op == DEF_MJZY_GANG then

            if  s_idx == order_type then

                if  TABLE_SIZE( s_group.cards) == 1 then

                    s_op = DEF_MJZY_OP_GANG_B
                else

                    s_op = DEF_MJZY_OP_GANG_A
                end
            else

                s_op = DEF_MJZY_OP_GANG_M
            end
        elseif s_group.op == DEF_MJZY_CHI then

            s_op = DEF_MJZY_OP_CHI
        end
        
        self.m_pPlayAI[order_type]:addSMahjong( s_group.cards)
        self.m_pPlayAI[order_type]:addNMahjong( s_group.cards, s_idx, s_op, order_type,s_group.type)
    end
    
    -- 创建摊牌
    self.m_sLicensingTotal[order_type] = self.m_pPlayAI[order_type]:getVMahjongsSize()
    local index = 0
    local pMahjong = nil
    local drawMahjongs = self.m_pPlayAI[order_type]:drawByOutPai()

    for i = 1, s_count do

        self.m_nPMahjongs[order_type] = self.m_nPMahjongs[order_type] + 1
        index = MJZY_INDEX_ITOG( order_type, self.m_nPMahjongs[order_type])
        -- value = table_player.selcards[i]
        value = drawMahjongs[i]

        if  order_type ~= 0 then
            nType = self:getSArrayType( table_player.groups, value, order_type)
        end

        pMahjong = self.m_pPMahjongs[order_type][index]
        if      order_type == 0 then
            pMahjong.m_pMahjong:setMahjong(string.format( "out_b_%u.png", value))
        elseif  order_type == 1 then
            -- if  nType == DEF_MJZY_OP_GANG_A then
            --     pMahjong.m_pMahjong:setMahjong( "l_back.png")
            -- else
                pMahjong.m_pMahjong:setMahjong(string.format( "l_%u.png", value))
            -- end
        elseif  order_type == 2 then
            -- if  nType == DEF_MJZY_OP_GANG_A then
            --     pMahjong.m_pMahjong:setMahjong( "t_back.png")
            -- else
                pMahjong.m_pMahjong:setMahjong(string.format( "t_%u.png", value))
            -- end
        elseif  order_type == 3 then
            -- if  nType == DEF_MJZY_OP_GANG_A then
            --     pMahjong.m_pMahjong:setMahjong( "r_back.png")
            -- else
                pMahjong.m_pMahjong:setMahjong(string.format( "r_%u.png", value))
            -- end
        end

        pMahjong.m_nMahjong = value
        pMahjong.m_pMahjong:setMahjongNumber( value)
        if  value == self.mahjong_MJZY:getMahjongLaiZi() then -- or value ==51 then
            pMahjong.m_pMahjong:setLaiZiColor()
        end
        pMahjong.m_bVaild = false
        pMahjong.m_pMahjong:setVisible( true)

        -- 添加已经用掉的牌
        self.m_pPlayAI[order_type]:addIMahjong( table_player.selcards[i])
    end

    -- 创建手牌(先把手牌排序)
    for i = 1, v_count do

        self.m_nPMahjongs[order_type] = self.m_nPMahjongs[order_type] + 1
        index = MJZY_INDEX_ITOG( order_type, self.m_nPMahjongs[order_type])

        pMahjong = self.m_pPMahjongs[order_type][index]

        if  order_type == 0 then
            pMahjong.m_nMahjong = table_player.curcards[i]
            pMahjong.m_pMahjong:setMahjongNumber( pMahjong.m_nMahjong)

            pMahjong.m_pMahjong:setMahjong( string.format( "my_b_%u.png", pMahjong.m_nMahjong))
            self:myMahjong_setIcoLai( pMahjong)
        else
            pMahjong.m_nMahjong = 0
            pMahjong.m_pMahjong:setMahjongNumber( 0)
        end
        pMahjong.m_bVaild = true
        pMahjong.m_pMahjong:setVisible( true)
    end

    --放风，跑风的牌
    local fangFArr = {}
    local PaoFArr = {}
    
    print("table_player.huacards")
    dumpArray(table_player.huacards)

    for i,v in ipairs(table_player.huacards) do
        if v >100 then
            self.mahjong_MJZY:push_mahjong(fangFArr,v-100)
        else
            self.mahjong_MJZY:push_mahjong(PaoFArr,v)
        end
    end

    table.sort(fangFArr,mahjong_MJZY_table_stb)

    if order_type == 0 then
        self.m_FangFengArr = {}
        self.mahjong_MJZY:push_back(self.m_FangFengArr,fangFArr,1,TABLE_SIZE(fangFArr))
    end

    table.sort(PaoFArr,mahjong_MJZY_table_stb)

    print("fangFArr")
    dumpArray(fangFArr)
    dumpArray(PaoFArr)

    self.m_pPlayAI[order_type]:addFangFMahjong(fangFArr)
    local count  = self.m_pPlayAI[order_type]:getFangFMahjongSize()
    for i=1 ,count do
        self:round_addFangFengMah(order_type,i,fangFArr[i],false,false,0)
    end

    for i,v in ipairs(PaoFArr) do
        self.m_pPlayAI[order_type]:addPaoFMahjong(v)
    end

    count  = self.m_pPlayAI[order_type]:getPaoFMahjongSize()
    for i=1 , count do
        self:round_addFangFengMah(order_type,i,PaoFArr[i],true,false,0)
    end      
    ------------------
    -- 创建打出的牌
    local o_count = TABLE_SIZE( table_player.outcards)
    local x_total = self:changeXMahjongs()
    self.m_sOutNumber[order_type] = 0

    for i = 1, o_count do

        self.m_sOutNumber[order_type] = self.m_sOutNumber[order_type] + 1
        self:changeNowOutMahjongs(order_type)

        local number = self:getPlayerOutNumber( order_type)
        local nWarp = math.floor( (number-1)/x_total)
        local nNum  = (number-1)%x_total

        local toPos = cc.p( self.m_sOutStart[order_type].x + nNum * self.m_sOutSpace[order_type].x + nWarp * self.m_sOutWrap[order_type].x, 
                            self.m_sOutStart[order_type].y + nNum * self.m_sOutSpace[order_type].y + nWarp * self.m_sOutWrap[order_type].y)

        local nTag = (order_type+1)*DEF_MJZY_OUT_IDX+self:getPlayerOutNumber(order_type)
        pointer = self.m_pMahjongOut:getChildByTag( nTag)
        if  pointer ~= nil then

            if  order_type == 0 then
                pointer:setMahjong( string.format( "t_%u.png", table_player.outcards[i]))
                pointer:setMahjongScale( DEF_MJZY_BT_OUTSCALE)
            elseif  order_type == 1 then
                pointer:setMahjong( string.format( "l_%u.png", table_player.outcards[i]))
                pointer:setMahjongScale( DEF_MJZY_LR_OUTSCALE)
            elseif  order_type == 2 then
                pointer:setMahjong( string.format( "t_%u.png", table_player.outcards[i]))
                pointer:setMahjongScale( DEF_MJZY_BT_OUTSCALE)
            elseif  order_type == 3 then
                pointer:setMahjong( string.format( "r_%u.png", table_player.outcards[i]))
                pointer:setMahjongScale( DEF_MJZY_LR_OUTSCALE)
            end
            pointer:setMahjongNumber( table_player.outcards[i])
            if  table_player.outcards[i] == self.mahjong_MJZY:getMahjongLaiZi() then -- or 
                -- table_player.outcards[i] == 51 then
                pointer:setLaiZiColor()
            end
            pointer:setPosition( toPos)
            pointer:setVisible( true)
        end

        -- 添加已经用掉的牌
        self.m_pPlayAI[order_type]:addIMahjong( table_player.outcards[i])
    end

    -- 压入不杠的牌
    local count = TABLE_SIZE( table_player.cancelcards)
    for i = 1, count do
        self.m_pPlayAI[order_type]:addForgoGang( table_player.cancelcards[i])
    end

    -- 压入不碰的牌
    local count = TABLE_SIZE( table_player.pengcards)
    for i = 1, count do
        self.m_pPlayAI[order_type]:addForgoPeng( table_player.pengcards[i])
    end

    -- 压入捉铳不铳的标志
    self.m_pPlayAI[order_type]:setNotCatch( table_player.cancel_zhuochong)
    self:myMahjong_updateForgoMessage()

    -- 是否托管判断
    if  order_type == 0 and (not casinoclient.getInstance():isSelfBuildTable()) then
        self:setTrusteeship( table_player.managed)
    end
    --self:showPiaoAfterReconect(order_type,table_player.jialaizi)
end

----------------------------------------------------------------------------
-- 重置桌子打出牌根据OP组
-- 参数: data桌子数据, iOP组对象索引， j出牌组对象索引
function CDLayerTable_mjzy:resetTableOutMahjong( data, g, o)
    cclog( "CDLayerTable_mjzy:resetTableOutMahjong")

    -- local g_index = self:getTableIndexWithID( data.players[g].id)
    local o_index = self:getTableIndexWithID( data.players[o].id)

    local g_count = TABLE_SIZE( data.players[g].groups)
    for i = 1, g_count do

        local group = data.players[g].groups[i]
        --  group.type 是牌 原来用的是第一张牌group.cards[1]来做判断因为之前只有碰、杠
        local findM = group.cards[1]
        if  group.type ~= 0 then
            findM = group.type
        end

        -- local target_idx = self:getTableIndexWithID( group.target_id)
        if  self:getTableIndexWithID( group.target_id) == o_index then

            local o_count = TABLE_SIZE( data.players[o].outcards)
            for j = 1, o_count do
                if  findM == data.players[o].outcards[j] then

                    table.remove( data.players[o].outcards, j)
                    break
                end
            end
        end
    end
end

----------------------------------------------------------------------------
-- 重置桌子数据
-- 参数: data桌子数据
function CDLayerTable_mjzy:resetTableData( data)
    cclog( "CDLayerTable_mjzy:resetTableData")

    self:setInGameToNIM()

    if  DEF_OPEN_NIMSDK then
        if  dtIsAndroid() then
            Channel:getInstance():getIdAndTime(CDLayerTable_mjzy.getIdAndTimeHandler)
            Channel:getInstance():isCanRecord(CDLayerTable_mjzy.playRecordAnimation)
        else
            NIMSDKopen:getInstance():getIdAndTime(CDLayerTable_mjzy.getIdAndTimeHandler) 
        end
    end  
    
    -- 定义自己的位置索引
    local count = TABLE_SIZE( data.players)
    local my_id = casinoclient:getInstance():getPlayerData():getId()
    local my_index = 1
    for i = 1, count do
        if  data.players[i].id == my_id then
            my_index = i
            g_pGlobalManagement:setMyTableIndex( i)
            break
        end
    end

    -- 桌面重置
    if  data.master_id > 0 then
        self:initWith_SBTableStatus( data)
    else
        self:initWith_TableStatus( data)
    end

    -- 庄家赋值
    self.m_nLordID = data.lord_id

    if  data.status == casino_mjzy.MJZY_STATUS_BET then
        self.m_pGroupLeftTop:setVisible(false)
        self:detailTableData(data)
        self:getPiaoPlayer(true,data.players)

    end
    -- 假如不是未开始状态
    if  data.status ~= casino_mjzy.MJZY_STATUS_STOP and 
        data.status ~= casino_mjzy.MJZY_STATUS_SCORE and 
        data.status ~= casino_mjzy.MJZY_STATUS_BET  then
        self.isQianZhuang = false
        self:detailTableData(data)

        if  self.m_pLZMahjong then
            self.m_pLZMahjong:setMahjong( string.format( "t_%u.png", self.mahjong_MJZY:getMahjongLaiZi()))
            self.m_pLZMahjong:setScale( 0.98)
            self.m_pLZMahjong:setIcoLaiVisible( false, true)
        end

        if  self.m_pLGMahjong then
            self.m_pLGMahjong:setMahjong( string.format( "t_%u.png", self.mahjong_MJZY:getMahjongFan()))
            self.m_pLGMahjong:setScale( 0.98)
        end

        -- 指定当前操作的玩家，假如是自己那么可以出牌
        local index = 0
        if  self.m_nPlayers == 2 then
            index = g_pGlobalManagement:getTableIndex2( data.cur_idx+1)
        else
            index = g_pGlobalManagement:getTableIndex4( data.cur_idx+1)
        end
        self:setOrderType( index)
        self.m_nLastOutPlayer = self:changeOrder( index)
        self.m_nLastOutMahjong = data.outcard
        self:showTimeLeft( data.time)
        if  self.m_nLastOutPlayer == 0 and 
            (self.m_nLastOutMahjong <= 0 or ( data.op_id == 0 and 
                data.target_id ~= casinoclient.getInstance():getPlayerData():getId())) then

            self:setGroupTipVisible( true)
            self.m_bCanOutMahjong = true
        end

        for i = 1, count do
            local table_player = data.players[i]
            index = self:changeOrder( self:getTableIndexWithID( table_player.id))

            for j,k in ipairs(table_player.outcards) do
                self.m_pPlayAI[index]:setOwnOutCard(k)
            end
        end

        -- 遍历玩家对象，清除打出的牌，根据OP组
        for i = 1, count do
            for j = 1, count do
                if  i ~= j then
                    self:resetTableOutMahjong( data, i, j)
                end
            end
        end

        -- 设置桌子上的玩家牌
        for i = 1, count do

            local table_player = data.players[i]
            index = self:changeOrder( self:getTableIndexWithID( table_player.id))
            self:resetTablePlayer( index, table_player)

            if  table_player.id == my_id then
                self.m_nLastMoMahjong = table_player.last_card -- 最后一张摸的牌
            end
            -- 麻将牌排列（自己要区分是否为出牌状态）
            if  index == 0 and self.m_bCanOutMahjong then
                self:resetTableMahjongs( index, nil, true)
                self:myMahjong_setIcoTing()
            else
                self:resetTableMahjongs( index)
            end
        end

        -- 标记最后一张打出的牌
        if  self.m_pEffFlagLast == nil then
            self.m_pEffFlagLast = CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_last.ccbi", cc.p( 0, 0), 0)
            if  self.m_pEffFlagLast ~= nil then
                self.m_pEffFlagLast:endRelease( false)
                self.m_pEffFlagLast:endVisible( false)
                self.m_pEffFlagLast:setVisible( false)
            end
        end
        self:showLastMahjongFlag( true)

        -- 庄图标设置
        local zhuang_idx = self:changeOrder( self:getTableIndexWithID( self.m_nLordID))
        if  zhuang_idx >= 0 and zhuang_idx <= self.m_nPlayers then
            local e_pos = cc.p( self.m_pPlayer[zhuang_idx].m_pFrame:getPositionX()+22, self.m_pPlayer[zhuang_idx].m_pFrame:getPositionY()-20)
            local zhuang_ico = CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_zhuang.ccbi", e_pos, 0)
            if  zhuang_ico then
                zhuang_ico:endRelease( false)
                zhuang_ico:endVisible( false)
            end
        end

        -- 假如有我的牌被OP那么进行OP牌表示（新添加)
        if  data.op_id ~= 0 and data.target_id ~= 0 then
            self:reset_OutMahjongShow_Front( self.m_nLastOutMahjong, self.m_nLastOutPlayer)
        end

        self.m_bReConnection = false
        self:resetOrderText()
        self:setTimeLeftVisible( true)

        if  not casinoclient.getInstance():isSelfBuildTable() then
            self.m_pButRobot:setVisible( true)
            self.m_pButSponsor:setVisible( false)
             --MapLocation
            self.m_pButLocation:setVisible( false)
        else
            self.m_pButRobot:setVisible( false)
            self.m_pButSponsor:setVisible( true)
            if  self.m_nPlayers==4 then
                self.m_pButLocation:setVisible( true)
            end
        end

        -- 设置倒记时提醒
        self.m_nSaveLordIdx = self:changeOrder( self:getTableIndexWithID( self.m_nLordID))

        -- 区分自建房与普通房进行提示倒计时
        if  casinoclient.getInstance():isSelfBuildTable() then
            self:initTablePauseTime( data.quit_time)
        else
            self:initTablePauseTime( 0)
        end
    elseif data.status == casino_mjzy.MJZY_STATUS_SCORE then -- 积分状态，应该让玩家默认点击准备

        self.m_bInTheGame = false
        for i = 1, count do
            index = self:changeOrder( self:getTableIndexWithID( data.players[i].id))
            self:joinTablePlayer( index, data.players[i])
        end

        -- dtOpenWaiting( self)
        self:myMahjong_ready()
        self.m_bReConnection = false
        casinoclient.getInstance():sendTableReadyReq()
        -- dtAddMessageToScene( self, "积分状态，现在还没有")
    else -- 没开始切
        -- 设置桌子上的玩家
        for i = 1, count do
            index = self:changeOrder( self:getTableIndexWithID( data.players[i].id))
            self:joinTablePlayer( index, data.players[i])
        end
    end
end

----------------------------------------------------------------------------
-- 重置麻将牌，根据数组
-- 参数: 位置对象, 用于改变的牌组
function CDLayerTable_mjzy:resetMahjongWithArray( order_type, array, hu_pai)
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

            index = MJZY_INDEX_ITOG( order_type, index)
            if  order_type == 0 then

                self.m_pPMahjongs[0][index].m_bVaild = false
                self.m_pPMahjongs[0][index].m_nMahjong = mahjong
                self.m_pPMahjongs[0][index].m_pMahjong:setMahjong( string.format( "out_b_%u.png", mahjong))
                self.m_pPMahjongs[0][index].m_pMahjong:setMahjongNumber( mahjong)

                self:myMahjong_setIcoLai( self.m_pPMahjongs[0][index])
                self.m_pPMahjongs[0][index].m_pMahjong:setIcoTingVisible( false)
            else
                if  order_type == 1 then
                    -- if  self.m_pPlayAI[1]:getNTypeWithMahjong( mahjong) == DEF_MJZY_OP_GANG_A then
                    --     self.m_pPMahjongs[1][index].m_pMahjong:setMahjong( "l_back.png")
                    -- else
                        self.m_pPMahjongs[1][index].m_pMahjong:setMahjong( string.format( "l_%u.png", mahjong))
                    -- end
                elseif order_type == 2 then
                    -- if  self.m_pPlayAI[2]:getNTypeWithMahjong( mahjong) == DEF_MJZY_OP_GANG_A then
                    --     self.m_pPMahjongs[2][index].m_pMahjong:setMahjong( "t_back.png")
                    -- else
                        self.m_pPMahjongs[2][index].m_pMahjong:setMahjong( string.format( "t_%u.png", mahjong))
                    -- end
                elseif order_type == 3 then
                    -- if  self.m_pPlayAI[3]:getNTypeWithMahjong( mahjong) == DEF_MJZY_OP_GANG_A then
                    --     self.m_pPMahjongs[3][index].m_pMahjong:setMahjong( "r_back.png")
                    -- else
                        self.m_pPMahjongs[3][index].m_pMahjong:setMahjong( string.format( "r_%u.png", mahjong))
                    -- end
                end
                if  hu_pai and (mahjong == self.mahjong_MJZY:getMahjongLaiZi()) then -- or mahjong ==51 )then
                    self.m_pPMahjongs[order_type][index].m_pMahjong:setLaiZiColor()
                end

                self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjongNumber( mahjong)
                self.m_pPMahjongs[order_type][index].m_nMahjong = mahjong
                self.m_pPMahjongs[order_type][index].m_bVaild = false
            end
        end
    end
end

--=================================基本方法=================================--

----------------------------------------------------------------------------
-- 显示出牌的Tip显示
function CDLayerTable_mjzy:setGroupTipVisible( visible)
    cclog( "CDLayerTable_mjzy:setGroupTipVisible")
    if  not self.isQianZhuang then
        if  visible then
    
            if  self.m_pGroupButton:isVisible() then
                return
            end
            self.m_pGroupTip:setVisible( true)
            self.m_pGroupTip:stopAllActions()
            self.m_pGroupTip:setPosition( cc.p( self.m_sGroupTipPos.x, self.m_sGroupTipPos.y - 80))
            self.m_pGroupTip:runAction( cc.EaseBackOut:create( cc.MoveTo:create( 0.3, self.m_sGroupTipPos)))
        else
    
            self.m_pGroupTip:stopAllActions()
            self.m_pGroupTip:setVisible( false)
        end
    end
end

----------------------------------------------------------------------------
-- 显示最后一张牌的指示标记
function CDLayerTable_mjzy:showLastMahjongFlag( visible)
    cclog( "CDLayerTable_mjzy:showLastMahjongFlag")

    if  self.m_pEffFlagLast == nil then
        return
    end

    if  visible then

        if  self.m_nLastOutPlayer >= 0 and self.m_nLastOutPlayer < DEF_MJZY_MAX_PLAYER then

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
-- 倒计时转到结算
function CDLayerTable_mjzy:showLeftTimeGotoScore()
    cclog( "CDLayerTable_mjzy:showLeftTimeGotoScore")

    if  not self.m_pTimeLeftTTF:isVisible() then
        self.m_pTimeLeftTTF:setVisible( true)
    end

    local function leftTime_low()

        self.m_pTimeLeftTTF:stopAllActions()
        if  self.m_nTimeLeft <= 0 then

            -- 临时增加的判断为了避免在下一局开始的时候进入到结算画面
            if  not self.m_bInTheGame then
                -- self:releaseEffect()
                self.m_pPlayAI[0]:resetCatch()
                g_pSceneTable:closeAllUserInterface()
                g_pSceneTable.m_pLayerMJScore:open( g_pGlobalManagement:getScoreData(), self.mahjong_MJZY, self.m_nLordID, self.m_nScoreTime, self)
                self:initTable()
                -- 再来一局 飘阶段脱光会出错 所以这里把他关闭
                self.m_pButRobot:setVisible( false)
                --MapLocation
                self:showLocation( false)
            end
        else

            self.m_pTimeLeftTTF:setString( string.format( "%d", self.m_nTimeLeft))
            self.m_pTimeLeftTTF:setScale( 3.0)
            self.m_pTimeLeftTTF:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1.0)), cc.DelayTime:create( 0.75), cc.CallFunc:create( leftTime_low)))

            self.m_nTimeLeft = self.m_nTimeLeft - 1
            if  self.m_nTimeLeft < 0 then
                self.m_nTimeLeft = 0
            end
        end
    end

    if self.m_pTingGroup then
        self.m_pTingGroup:setVisible( false)
    end

    leftTime_low()
end

----------------------------------------------------------------------------
-- 显示等待他人准备倒计时
-- 显示的时间
function CDLayerTable_mjzy:showLeftTimeWaitReady( time)

    -- 时间小于等于0或者游戏开始中那么关闭等待
    if  time <= 0 or self.m_bInTheGame then
        if  self.m_bInTheGame then
            dtCloseWaiting( self)
        end
        return
    end

    if  not self.m_pTimeLeftTTF:isVisible() then
        self.m_pTimeLeftTTF:setVisible( true)
        dtCloseWaiting( self)
        self.m_nTimeLeft = time
    end

    local function leftTime_lowToStop()

        self.m_pTimeLeftTTF:stopAllActions()
        if  self.m_nTimeLeft > 0 then

            self.m_pTimeLeftTTF:setString( string.format( "%d", self.m_nTimeLeft))
            self.m_pTimeLeftTTF:setScale( 3.0)
            self.m_pTimeLeftTTF:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1.0)), cc.DelayTime:create( 0.75), cc.CallFunc:create( leftTime_lowToStop)))

            self.m_nTimeLeft = self.m_nTimeLeft - 1
            if  self.m_nTimeLeft < 0 then
                self.m_nTimeLeft = 0
            end
        end
    end
    leftTime_lowToStop()
end

----------------------------------------------------------------------------
-- 设置自己的信息
function CDLayerTable_mjzy:refreshSelfInfo( table_player)

    local nickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
    if  nickname == nil or string.len( nickname) <= 0 then
        nickname = casinoclient:getInstance():getPlayerData():getNickname()
    end

    if  table_player == nil then
        self.m_pSelfInfo:setString( nickname)
        return
    end

    if  string.len( nickname) > 5 then
        nickname =  dtSubStringUTF8( nickname, 1, 5)
    end

    if  not casinoclient.getInstance():isSelfBuildTable() then

        self.m_pSelfInfo:setString( nickname..":"..dtNumberToStringWY(table_player.score_total+table_player.gold))
    else

        self.m_pSelfInfo:setString( nickname..":"..dtGetFloatString(table_player.score_total))
    end
end

----------------------------------------------------------------------------
-- 设置玩家信息
function CDLayerTable_mjzy:refreshTablePlayer( index, table_player)
    cclog( "CDLayerTable_mjzy:refreshTablePlayer")

    if  table_player ~= nil then

        if  self.m_bInTheGame then

            if  index == 0 then
                self:refreshSelfInfo( table_player)
            else

                if  not casinoclient.getInstance():isSelfBuildTable() then

                    self.m_pPlayer[index].m_pGold:setString( dtNumberToStringWY( table_player.score_total+table_player.gold))
                else

                    self.m_pPlayer[index].m_pGold:setString( dtGetFloatString( table_player.score_total))
                end                    
            end
            return
        else

            dtSetNickname( self.m_pPlayer[index].m_pGold, table_player.nickname, table_player.channel_nickname)
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

----------------------------------------------------------------------------
-- 设置桌面信息
function CDLayerTable_mjzy:refreshTableInfo()

    local total = 1
    if  self.mahjong_MJZY ~= nil then
        total = self.mahjong_MJZY:mahjongTotal_get()
        if  total < 0 then
            total = 0
        end
    end

    local data = casinoclient:getInstance():getTable()
    g_pGlobalManagement:setTableBase( data.base)

    if  casinoclient:getInstance():isSelfBuildTable() then

        cclog( "CDLayerTable_mjzy:refreshTableInfo(%d/%d)", data.play_total, data.round)
        local round_str = nil
        if  (data.play_total+1) >= data.round then
            round_str = casinoclient.getInstance():findString("round_last")
        else
            round_str = string.format( casinoclient:getInstance():findString("round_num"), data.round-data.play_total-1)
        end

        self.m_pTableInfo:setString(
            string.format( casinoclient.getInstance():findString("table_info1"), 
            total, dtGetFloatString( data.base), round_str))
    else

        self.m_pTableInfo:setString(
        string.format( casinoclient.getInstance():findString("table_info2"),
            total, dtGetFloatString( data.base)))
    end
end

----------------------------------------------------------------------------
-- 获取玩家位置根据编号
-- 参数: id 玩家编号
function CDLayerTable_mjzy:getTableIndexWithID( id)
    cclog( "CDLayerTable_mjzy:getTableIndexWithID( id[%u])", id)

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
-- 获取玩家出牌数
-- 参数: index玩家索引
function CDLayerTable_mjzy:getPlayerOutNumber( order_type)

    local x_total = self:changeXMahjongs()
    local x_total2 = x_total * 2

    -- 从上排到下排
    if      order_type == 0 then

        return self.m_sOutNumber[0]
    elseif  order_type == 1 then

        return (DEF_MJZY_MAX_OUTMAHJONG+1 - self.m_sOutNumber[1])
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
-- 开启玩家信息
-- 参数: index位置
function CDLayerTable_mjzy:openPlayerInfo( index)
    cclog( "CDLayerTable_mjzy:openPlayerInfo [%u]", self.m_pPlayer[index].m_nID)

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

    local data = casinoclient:getInstance():getTable()
    local count = TABLE_SIZE( data.players)

    for i = 1, count do
        if  data.players[i].id == self.m_pPlayer[index].m_nID then
            g_pSceneTable:openPlayerInfo_withTouch( data.players[i])
        end
    end
end

----------------------------------------------------------------------------
-- 加入玩家
-- 参数: index位置, table_player数据
function CDLayerTable_mjzy:joinTablePlayer( index, table_player)
    cclog( "CDLayerTable_mjzy:joinTablePlayer = [%u]", table_player.id)

    if  index < 0 or index >= DEF_MJZY_MAX_PLAYER then
        return false
    end

    self.m_pPlayer[index].m_pData:CopyFrom( table_player)

    self.m_pPlayer[index].m_nID = table_player.id
    self.m_pPlayer[index].m_nSex = table_player.sex
    self.m_pPlayer[index].m_nAvatar = table_player.avatar

    self.m_pPlayer[index].betType = table_player.jialaizi

    self.m_pPlayer[index].m_pHead:removeAllChildren()

    if  table_player.id ~= 0 then

        self:refreshTablePlayer( index, table_player)
        if  not table_player.managed then
            dtCreateHead( self.m_pPlayer[index].m_pHead, table_player.sex, table_player.avatar, table_player.channel_head)
            self.m_pPlayer[index].m_pHead:setScale( 1.3)
            self.m_pPlayer[index].m_pHead:runAction( cc.EaseBackOut:create( cc.ScaleTo:create( 0.3, 1.0)))
        end

        if  (not self.m_bInTheGame) and 
            (not casinoclient.getInstance():isSelfBuildTable()) then

            self.m_pPlayer[index].m_pIcoReady:stopAllActions()
            self.m_pPlayer[index].m_pIcoReady:setScale( 1.3)
            self.m_pPlayer[index].m_pIcoReady:setVisible( table_player.ready)
            self.m_pPlayer[index].m_pIcoReady:runAction( cc.EaseBackOut:create( cc.ScaleTo:create( 0.3, 1.0)))
        end

        if  table_player.channel == "mac" and 
            casinoclient.getInstance():isSelfBuildTable() then
            self.m_pPlayer[index].m_pIcoYK:setVisible( true)
        else
            self.m_pPlayer[index].m_pIcoYK:setVisible( false)
        end
    else

        self.m_pPlayer[index].m_pIcoYK:setVisible( false)
        self:refreshTablePlayer( index)
    end
end

----------------------------------------------------------------------------
-- 玩家离开
function CDLayerTable_mjzy:leaveTablePlayer( index)
    cclog( "CDLayerTable_mjzy:leaveTablePlayer index(%u)", index)

    self.m_pPlayer[index].m_pIcoYK:setVisible( false)    
    if  casinoclient:getInstance():isSelfBuildTable() or (not self.m_bInTheGame) then
        -- cclog( "CDLayerTable_mjzy:leaveTablePlayer => 1")

        self.m_pPlayer[index].m_nID = 0
        self.m_pPlayer[index].m_nSex = 0
        self.m_pPlayer[index].m_nAvatar = 0
        self.m_pPlayer[index].m_pHead:removeAllChildren()

        self:refreshTablePlayer( index)
    elseif self.m_bInTheGame then
        -- cclog( "CDLayerTable_mjzy:leaveTablePlayer => 2")

        self.m_pPlayer[index].m_pHead:removeAllChildren()
        local head = cc.Sprite:createWithSpriteFrameName( string.format("x_robot_m.png"))
        self.m_pPlayer[index].m_pHead:addChild( head)
    end
end

----------------------------------------------------------------------------
-- 托管玩家
function CDLayerTable_mjzy:managedTablePlayer( index, managed)
    cclog( "CDLayerTable_mjzy:managedTablePlayer index = %u", index)

    local order_idx = self:changeOrder( index)
    if  order_idx >= 0 and order_idx < DEF_MJZY_MAX_PLAYER then

        if  order_idx == 0 then

            if  (not casinoclient.getInstance():isSelfBuildTable()) and managed then
                self:setTrusteeship( true)
            elseif (not managed) then
                self:setTrusteeship( false)
            end
        else

            if  managed then

                self.m_pPlayer[order_idx].m_pHead:removeAllChildren()
                -- 假如不是自建房那么载入机器人头像
                if  (not casinoclient.getInstance():isSelfBuildTable()) and self.m_bInTheGame then

                    local head = cc.Sprite:createWithSpriteFrameName( string.format("x_robot_m.png"))
                    self.m_pPlayer[order_idx].m_pHead:addChild( head)
                end
            else

                dtCreateHead( self.m_pPlayer[order_idx].m_pHead, self.m_pPlayer[order_idx].m_nSex, self.m_pPlayer[order_idx].m_nAvatar, self.m_pPlayer[order_idx].m_pData.channel_head)
                self.m_pPlayer[order_idx].m_pHead:setScale( 1.3)
                self.m_pPlayer[order_idx].m_pHead:runAction( cc.EaseBackOut:create( cc.ScaleTo:create( 0.3, 1.0)))
            end
        end
    end
end

----------------------------------------------------------------------------
-- 初始化桌子上的所有玩家
-- 参数: nil
function CDLayerTable_mjzy:initTablePlayer()
    cclog( "CDLayerTable_mjzy:initTablePlayer")

    local data = casinoclient:getInstance():getTable()
    local count = TABLE_SIZE( data.players)
    -- 设置桌子底注
    self:refreshTableInfo()
    -- 搜索自己的索引
    local my_id = casinoclient:getInstance():getPlayerData():getId()
    local my_index = 1
    for i = 1, count do

        if  data.players[i].id == my_id then

            my_index = i
            g_pGlobalManagement:setMyTableIndex( i)
            break
        end
    end
    -- 设置桌子上的玩家
    local index = my_index
    for i = 1, count do

        self:joinTablePlayer( self:changeOrder(i-1), data.players[index])
        index = index + 1
        if  index > count then
            index = 1
        end
    end
end

----------------------------------------------------------------------------
-- 初始化暂停时间
function CDLayerTable_mjzy:initTablePauseTime( pause_time)
    cclog( "CDLayerTable_mjzy:initTablePauseTime")

    local function refreshPauseTime()
        local time = casinoclient:getInstance():getServerTime()
        if  self.m_nPauseTime > time then

            local sec = self.m_nPauseTime - time
            if  self.m_bInTheGame then

                self.m_pPushMessage:setString( string.format( casinoclient:getInstance():findString("pause_time2"), dtSetTimeSegment(sec)))
            else
                self.m_pPushMessage:setString( string.format( casinoclient:getInstance():findString("pause_time1"), dtSetTimeSegment(sec)))
            end
            self.m_pGroupPushMsg:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( refreshPauseTime)))
        else

            self.m_pGroupPushMsg:setVisible( false)
        end

    end

    if  self.m_pGroupPushMsg:isVisible() then
        self.m_pGroupPushMsg:setVisible(false)
        self.m_pGroupPushMsg:stopAllActions()
        self.m_pPushMessage:stopAllActions()
    end

    self.m_nPauseTime = 0
    if  pause_time ~= nil and pause_time ~= 0 then

        self.m_nPauseTime = pause_time
        self.m_pGroupPushMsg:setVisible( true)
        self.m_pGroupPushMsg:setScale( 0.7)
        self.m_pGroupPushMsg:runAction( cc.EaseBackOut:create( cc.ScaleTo:create( 0.2, 1.0)))
        dtPlaySound( DEF_SOUND_ERROR)
        refreshPauseTime()
        self:setGroupTipVisible( false)
    else


    end
end

----------------------------------------------------------------------------
-- 延后同步数据
function CDLayerTable_mjzy:initTablePlayerOrJoinTable()

    -- 假如是断线登入后进来，并且有房间ID那么发送进入房间信息
    if  casinoclient:getInstance():getPlayerTableID() ~= 0 then

        dtOpenWaiting( self)
        casinoclient:getInstance():sendTableJoinReq( 0, 0, casinoclient:getInstance():getPlayerTableID())
    else

        self:initTablePlayer()
        local data = casinoclient:getInstance():getTable()
        if  data.master_id > 0 then
            if  casinoclient:getInstance():getIsInTableGame() then
                casinoclient:getInstance():sendTableReadyReq()
            else
                local function leaveToHall()
                    g_pSceneTable:gotoSceneHall()
                end
                dtAddMessageToScene( self, casinoclient:getInstance():findString("disband3"))
                casinoclient.getInstance():clearTable()
                casinoclient.getInstance():emptyPlayerTableID()
                self:runAction( cc.Sequence:create( cc.DelayTime:create( 2.0), cc.CallFunc:create( leaveToHall)))
            end
        end
    end
end

----------------------------------------------------------------------------
-- 初始化根据玩家自建房状态
function CDLayerTable_mjzy:initWith_SBTableStatus( data)
    cclog( "CDLayerTable_mjzy:initWith_SBTableStatus(%u)", data.status)

    self.m_pBut_Ready:setVisible( false)
    self.m_pPic_Ready:setVisible( false)

    self:initAllSpeakResource() -- 自建房才使用语音

    if  data.status == casino_mjzy.MJZY_STATUS_STOP then

        self.m_pGroupBar:setVisible( false)
        self.m_pGroupSelfBuild:setVisible( true)

        self.m_pSelfBuildInfo:setString( 
            string.format( casinoclient:getInstance():findString("table_info3"), data.base, data.round))

        self.m_pGroupLeftTop:setVisible( false)
        self.m_pRoomIDTTF:setString( string.format( "%u", data.tag))

        self.m_pJoinTypeMsg:setString( casinoclient.getInstance():findString(string.format("table_join%d", data.join)))
        self.m_pJoinTypeMsg:enableOutline( cc.c4b( 50, 50, 50, 255), 2)

        local bImMaster = false
        if  data.master_id == casinoclient:getInstance():getPlayerData():getId() then
            bImMaster = true
        end
        self.m_pButToOther:setVisible( bImMaster)
        self.m_pTxtToOther:setVisible( bImMaster)

        self.m_pButOver:setVisible( bImMaster)
        self.m_pTxtOver:setVisible( bImMaster)

        self.m_pButLeave:setVisible( not bImMaster)
        self.m_pTxtLeave:setVisible( not bImMaster)

        -- 随机位置
        -- if  data.status == casino_mjzy.MJZY_STATUS_STOP then

        if  self.m_nPlayers > 2 then
            -- 四人
            local rand_idx = {}
            for i = 0, DEF_MJZY_MAX_PLAYER-1 do
                rand_idx[i] = i
            end
            local index = 0
            local random_num = 0
            for i = 0, DEF_MJZY_MAX_PLAYER-1 do
                index = rand_idx[i]
                random_num = math.random( 0, DEF_MJZY_MAX_PLAYER-1)
                rand_idx[i] = rand_idx[random_num]
                rand_idx[random_num] = index
            end

            for i = 0, DEF_MJZY_MAX_PLAYER-1 do
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
        -- end
    else -- 包括data.status == casino_mjzy.MJZY_STATUS_SCORE

        self:setVisibleSpeakResource(1)

        self.m_pGroupBar:setVisible( true)
        self.m_pGroupSelfBuild:setVisible( false)

        self.m_pGroupLeftTop:setVisible( true)

        self.m_pButOver:setVisible( false)
        self.m_pTxtOver:setVisible( false)

        self.m_pButToOther:setVisible( false)
        self.m_pTxtToOther:setVisible( false)

        self.m_pButLeave:setVisible( false)
        self.m_pTxtLeave:setVisible( false)

        self.m_pPlayer[0].m_pFrame:setVisible( false)
        if  self.m_nPlayers > 2 then 
            -- 四人
            for i = 1, DEF_MJZY_MAX_PLAYER-1 do
                self.m_pPlayer[i].m_pFrame:setVisible( true)
            end
        else
            --两人
            self.m_pPlayer[1].m_pFrame:setVisible( false)
            self.m_pPlayer[2].m_pFrame:setVisible( true)
            self.m_pPlayer[3].m_pFrame:setVisible( false)
        end
    end
end

-- 初始化根据普通房状态
function CDLayerTable_mjzy:initWith_TableStatus( data)
    cclog( "CDLayerTable_mjzy:initWith_TableStatus")

    self.m_pGroupBar:setVisible( true)
    self.m_pGroupSelfBuild:setVisible( false)

    self.m_pButOver:setVisible( false)
    self.m_pTxtOver:setVisible( false)

    self.m_pButToOther:setVisible( false)
    self.m_pTxtToOther:setVisible( false)

    self.m_pButLeave:setVisible( false)
    self.m_pTxtLeave:setVisible( false)

    if  data.status == casino_mjzy.MJZY_STATUS_STOP then

        self.m_pBut_Ready:setVisible( true)
        self.m_pPic_Ready:setVisible( true)
    else

        self.m_pBut_Ready:setVisible( false)
        self.m_pPic_Ready:setVisible( false)
    end

    self.m_pPlayer[0].m_pFrame:setVisible( false)
    for i = 1, DEF_MJZY_MAX_PLAYER-1 do
        self.m_pPlayer[i].m_pFrame:setVisible( true)
    end
end

----------------------------------------------------------------------------
-- 初始化桌子玩家开始位置
function CDLayerTable_mjzy:initTablePlayerStartPosition()

    --  假如有编号，那么不在这里初始化，这里先豆隐藏
    if  casinoclient:getInstance():getPlayerTableID() ~= 0 then

        self.m_pGroupBar:setVisible( false)
        self.m_pGroupSelfBuild:setVisible( false)
        self.m_pGroupLeftTop:setVisible( true)
        self.m_pButOver:setVisible( false)
        self.m_pTxtOver:setVisible( false)
        self.m_pButToOther:setVisible( false)
        self.m_pTxtToOther:setVisible( false)
        self.m_pButLeave:setVisible( false)
        self.m_pTxtLeave:setVisible( false)
        self.m_pBut_Ready:setVisible( false)
        self.m_pPic_Ready:setVisible( false)
        for i = 0, DEF_MJZY_MAX_PLAYER-1 do
            self.m_pPlayer[i].m_pFrame:setVisible( false)
        end
        return
    end

    local table_data = casinoclient:getInstance():getTable()
    if  table_data ~= nil then

        if  casinoclient:getInstance():isSelfBuildTable() then

            self:initWith_SBTableStatus( table_data)
            self:initTablePauseTime( table_data.quit_time)
        else

            self:initWith_TableStatus( table_data)
            self:initTablePauseTime( )
        end
    end
end
----------------------------------------------------------------------------
-- 创建用户界面
function CDLayerTable_mjzy:createUserInterface()
    cclog("CDLayerTable_mjzy::createUserInterface")

    -- 获取玩家人数
    local room_id = casinoclient.getInstance():getPlayerRoomID()
    if  room_id ~= 0 then
        local room = casinoclient.getInstance():findRoom(room_id)
        if  room ~= nil then
            self.m_nPlayers = room.ply_max
        end
    end

    self:onCheckLogin()

    -- 创建桌面需要的出牌层、其他玩家手牌放置层、特效放置层
    self.m_pMahjongOwn = cc.Layer:create()
    self.m_pNewLayerRoot:addChild(self.m_pMahjongOwn)

    if  not self.m_pMahjongOut then
        self.m_pMahjongOut = cc.Layer:create()
    end
    self.m_pNewLayerRoot:addChild(self.m_pMahjongOut)

    self.m_pMahjongEff = cc.Layer:create()
    self.m_pNewLayerRoot:addChild(self.m_pMahjongEff)

    -- 创建所有玩家的桌面
    for i = 0, DEF_MJZY_MAX_PLAYER - 1 do
        self.m_pPlayTable[i] = cc.Layer:create()
        self:addChild(self.m_pPlayTable[i])
    end

    -- 只有当微信开启的时候才有分享
    if  not g_pGlobalManagement:getWeiXinLoginEnable() then
        self.m_pButShare:setVisible(false)
        self.m_pTxtShare:setVisible(false)
    end

    -- 初始化玩家出牌位置，出牌间隔等基础数据
    if  self.m_nPlayers == 2 then
        self.m_sOutStart[0] = cc.p(self.m_pOutDemo[0]:getPositionX() - 322 - 45 * 1.5, self.m_pOutDemo[0]:getPositionY())
    else
        self.m_sOutStart[0] = cc.p(self.m_pOutDemo[0]:getPositionX() - 168, self.m_pOutDemo[0]:getPositionY())
    end

    self.m_sOutSpace[0] = cc.p(42, 0)
    self.m_sOutWrap[0]  = cc.p(0, -48)

    self.m_sOutStart[1] = cc.p(self.m_pOutDemo[1]:getPositionX(), self.m_pOutDemo[1]:getPositionY() + 136)
    self.m_sOutSpace[1] = cc.p(0, -32)
    self.m_sOutWrap[1]  = cc.p(-52, 0)

    if  self.m_nPlayers == 2 then
        self.m_sOutStart[2] = cc.p(self.m_pOutDemo[2]:getPositionX() + 270 + 45 * 1.5, self.m_pOutDemo[2]:getPositionY() - 25)
    else
        self.m_sOutStart[2] = cc.p(self.m_pOutDemo[2]:getPositionX() + 168, self.m_pOutDemo[2]:getPositionY())
    end

    self.m_sOutSpace[2] = cc.p(-42, 0)
    self.m_sOutWrap[2]  = cc.p(0, -48)

    self.m_sOutStart[3] = cc.p(self.m_pOutDemo[3]:getPositionX(), self.m_pOutDemo[3]:getPositionY() + 136)
    self.m_sOutSpace[3] = cc.p(0, -32)
    self.m_sOutWrap[3]  = cc.p(52, 0)

    -- 四个玩家牌相关的参考数据
    self.m_pPlayer[0].tab_gaps = cc.p(10, 0)
    self.m_pPlayer[0].tab_ori_scal = 0.96
    self.m_pPlayer[0].tab_out_scal = 0.89
    self.m_pPlayer[0].tab_size = cc.p(82, 136)
    self.m_pPlayer[0].tab_spce = cc.p(76, 0)
    self.m_pPlayer[0].tab_percent  = 1.0
    self.m_pPlayer[0].tab_center = cc.p( self.m_pCenterDemo[0]:getPositionX(), self.m_pCenterDemo[0]:getPositionY())
    self.m_pPlayer[0].tab_tag_scale = 0.9
    self.m_pPlayer[0].tab_tag_space = cc.p(0, -46)
    self.m_pPlayer[0].m_sNumSpace = cc.p(0, 20)
    self.m_pPlayer[0].tab_fangFeng_space = cc.p( 0, 0)
   
    self.m_pPlayer[1].tab_gaps = cc.p(0, 5)
    self.m_pPlayer[1].tab_ori_scal = 0.92
    self.m_pPlayer[1].tab_out_scal = 0.67
    self.m_pPlayer[1].tab_size = cc.p(48, 80)
    self.m_pPlayer[1].tab_spce = cc.p(0, 24)
    self.m_pPlayer[1].tab_percent = 0.56
    self.m_pPlayer[1].tab_center = cc.p(self.m_pCenterDemo[1]:getPositionX(), self.m_pCenterDemo[1]:getPositionY())
    self.m_pPlayer[1].tab_tag_scale = 0.82
    self.m_pPlayer[1].tab_tag_space = cc.p(18, 7)
    self.m_pPlayer[1].m_sNumSpace = cc.p(-50, 50)
    self.m_pPlayer[1].tab_fangFeng_space = cc.p( -155, -160)
   
    self.m_pPlayer[2].tab_gaps = cc.p(-5, 0)
    self.m_pPlayer[2].tab_ori_scal = 0.95
    self.m_pPlayer[2].tab_out_scal = 0.82
    self.m_pPlayer[2].tab_size = cc.p(53, 76)
    self.m_pPlayer[2].tab_spce = cc.p(-42, 0)
    self.m_pPlayer[2].tab_percent = 0.6
    self.m_pPlayer[2].tab_center = cc.p(self.m_pCenterDemo[2]:getPositionX(), self.m_pCenterDemo[2]:getPositionY())
    self.m_pPlayer[2].tab_tag_scale = 0.98
    self.m_pPlayer[2].tab_tag_space = cc.p(0, -23)
    self.m_pPlayer[2].m_sNumSpace = cc.p(0, -20)
    self.m_pPlayer[2].tab_fangFeng_space = cc.p( 0, 0)
    
    self.m_pPlayer[3].tab_gaps = cc.p(0, -5)
    self.m_pPlayer[3].tab_ori_scal = 0.92
    self.m_pPlayer[3].tab_out_scal = 0.67
    self.m_pPlayer[3].tab_size = cc.p(48, 80)
    self.m_pPlayer[3].tab_spce = cc.p(0, -24)
    self.m_pPlayer[3].tab_percent = 0.56
    self.m_pPlayer[3].tab_center = cc.p(self.m_pCenterDemo[3]:getPositionX(), self.m_pCenterDemo[3]:getPositionY())
    self.m_pPlayer[3].tab_tag_scale = 0.82
    self.m_pPlayer[3].tab_tag_space = cc.p(-18, 7)
    self.m_pPlayer[3].m_sNumSpace = cc.p(50, 50)
    self.m_pPlayer[3].tab_fangFeng_space = cc.p( 200, 250)
    
    -- 获取动作组坐标、停牌提示组坐标
    self.m_sGroupPosition = cc.p(self.m_pGroupButton:getPositionX(), self.m_pGroupButton:getPositionY())
    self.m_sTingPosition = cc.p(self.m_pTingGroup:getPositionX(), self.m_pTingGroup:getPositionY())

    --self.m_sPiaoPosition = cc.p(self.m_pPiaoGroup:getPositionX(), self.m_pPiaoGroup:getPositionY())
    self.m_sChiPosition = cc.p(self.m_pChiGroup:getPositionX(), self.m_pChiGroup:getPositionY())
    -- 倒计时创建时钟
    if  self.m_pTimeLeft ~= nil then
        self.m_pTimeLeftNum = cc.LabelAtlas:_create("0", "x_number_flash.png", 17, 24, string.byte("0"))
        self.m_pTimeLeftNum:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_pTimeLeftNum:setVisible(false)
        self.m_pTimeLeft:addChild(self.m_pTimeLeftNum)
    end

    -- 预创建牌
    self.m_bPreCreate = false
    self:preCreateMahjong()

    -- 玩家输出文字创建（减积分、加积分）
    for i = 0, DEF_MJZY_MAX_PLAYER - 1 do

        if  self.m_pPlayer[i].m_pNumber1 == nil then
            self.m_pPlayer[i].m_pNumber1 = cc.LabelAtlas:_create("0", "x_number_ex1.png", 34, 44, string.byte("*"))
            self.m_pPlayer[i].m_pNumber1:setAnchorPoint(cc.p(0.5, 0.5))
            self.m_pPlayer[i].m_pNumber1:setVisible(false)
            self:addChild(self.m_pPlayer[i].m_pNumber1)
        end

        if  self.m_pPlayer[i].m_pNumber2 == nil then
            self.m_pPlayer[i].m_pNumber2 = cc.LabelAtlas:_create("0", "x_number_ex2.png", 34, 44, string.byte("*"))
            self.m_pPlayer[i].m_pNumber2:setAnchorPoint(cc.p(0.5, 0.5))
            self.m_pPlayer[i].m_pNumber2:setVisible(false)
            self:addChild(self.m_pPlayer[i].m_pNumber2)
        end
    end

    -- 房号文字
    if  self.m_pRoomIDTTF == nil then
        self.m_pRoomIDTTF = cc.LabelAtlas:_create("0", "x_number_ex2.png", 34, 44, string.byte("*"))
        self.m_pRoomIDTTF:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_pRoomIDTTF:setVisible(true)
        self.m_pRoomIDDemo:addChild(self.m_pRoomIDTTF)
    end

    -- 倒计时文字
    if  self.m_pTimeLeftTTF == nil then
        self.m_pTimeLeftTTF = cc.LabelAtlas:_create("0", "x_number_ex3.png", 34, 44, string.byte("*"))
        self.m_pTimeLeftTTF:setAnchorPoint(cc.p(0.5, 0.5))
        self.m_pTimeLeftTTF:setVisible(false)
        self.m_pTimeLeft:addChild(self.m_pTimeLeftTTF)
    end
    self.m_pTimeLeft:setVisible(true)

    -- 超时特效
    local pos = cc.p(g_pGlobalManagement:getWinCenter().x, g_pGlobalManagement:getWinHeight() - 50)
    self.m_pEffNetLow = CDCCBAniTxtObject.createCCBAniTxtObject(self.m_pNewLayerRoot, "x_tx_netlow.ccbi", pos, 0)
    if  self.m_pEffNetLow then

        self.m_pEffNetLow:endRelease(false)
        self.m_pEffNetLow:endVisible(false)
        self.m_pEffNetLow:setVisible(false)
    end

    -- 重置电量
    self:resetPower()
    -- 初始化桌子玩家开始坐标
    self.m_bInTheGame = false
    self.m_nSaveLordIdx = -1
    self:initTablePlayerStartPosition()
    -- 释放飘特效
    -- self:releaseEffect()
    -- 之后创建用户，或者加入牌桌
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(CDLayerTable_mjzy.initTablePlayerOrJoinTable)))
end

----------------------------------------------------------------------------
-- 设置当前指针根据玩家位置(指针表现)
-- 参数:方向, 是否动态改变(默认true)
function CDLayerTable_mjzy:setOrderType(order, ani)
    cclog("CDLayerTable_mjzy::setOrderType(%d)", order)

    if  ani == nil then
        ani = true
    end

    local idx = self:changeOrder(order)

    local rotate = -90 * idx
    if  ani then
        self.m_pOrderIco:stopAllActions()
        self.m_pOrderIco:runAction(cc.EaseBackOut:create(cc.RotateTo:create(0.15, rotate)))
    else
        self.m_pOrderIco:setRotation(rotate)
    end
end

----------------------------------------------------------------------------
-- 设置操作按钮组开启状态
-- 参数:是否开启
function CDLayerTable_mjzy:setGroupButtonVisible(bVisible)
    if  self.m_pGroupButton == nil or 
        self.m_pGroupButton:isVisible() == bVisible then
        return false
    end

    self.m_pGroupButton:setVisible(bVisible)
    if  bVisible then
        local position = cc.p(self.m_sGroupPosition.x + 200, self.m_sGroupPosition.y)
        self.m_pGroupButton:setPosition(position)
        self.m_pGroupButton:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.15, self.m_sGroupPosition)))
        dtPlaySound(DEF_SOUND_MOVE)
    else
        self:setSameMahjongWithMyMahjongs(0)
    end

    return true
end

----------------------------------------------------------------------------
-- 放风按钮组是否显示
function CDLayerTable_mjzy:setGroupFangFengBtnVisible(bVisible)
    if self.m_pGroupFangFengBtn == nil or
         self.m_pGroupFangFengBtn:isVisible() == bVisible then
        return false
    end

    self.m_pGroupFangFengBtn:setVisible(bVisible)
    if  bVisible then
        local position = cc.p(self.m_sGroupPosition.x+200, self.m_sGroupPosition.y+200)
        self.m_pGroupFangFengBtn:setPosition(position)
        self.m_pGroupFangFengBtn:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.15, self.m_sGroupPosition)))
        dtPlaySound(DEF_SOUND_MOVE)
    else
        self:setSameMahjongWithMyMahjongs(0)
    end

    return true
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
--点击放风按钮后除了用于放风的牌全部置灰
function CDLayerTable_mjzy:setMyMahjongGrayAfterFangFeng(array,boolean)
    print("CDLayerTable_mjzy:setMyMahjongGrayAfterFangFeng")
    if boolean == nil  then
        boolean = true
    end

    local size = self.m_nPMahjongs[0]
    local index = self:getMahjongIndexWithVaild(0,true)
    print("index----------->",index)

    if  index > self.m_nPMahjongs[0] or index <= 0 then     
        return
    end

    for i = index, size do
        if  self.m_pPMahjongs[0][i].m_pMahjong then
            self.m_pPMahjongs[0][i].m_pMahjong:setGrey(boolean)   
        end
    end

    if boolean then

        for j,k in pairs(array) do
            for i = index, size do
                if  self.m_pPMahjongs[0][i].m_pMahjong and k == self.m_pPMahjongs[0][i].m_nMahjong and 
                    self.m_pPMahjongs[0][i].m_pMahjong:isGrey() then
                    self.m_pPMahjongs[0][i].m_pMahjong:setGrey(not boolean)
                    break
                end
            end
        end
    else
        
        for j,k in pairs(array) do
            for i = index, size do
                if  self.m_pPMahjongs[0][i].m_pMahjong and k == self.m_pPMahjongs[0][i].m_nMahjong and 
                    not self.m_pPMahjongs[0][i].m_pMahjong:isGrey() then
                    self.m_pPMahjongs[0][i].m_pMahjong:setGrey(not boolean)
                    break
                end
            end
        end
    end    
end
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- 选中牌根据指定的索引
-- 参数: 索引（假如是0那么取消之前的选中)
function CDLayerTable_mjzy:selectFromIndex( index)
    cclog("CDLayerTable_mjzy::selectFromIndex")

    local size = self.m_nPMahjongs[0]
    if  index < 0 or index > size or size == 0 then
        return

    elseif self.m_nSaveSelectIndex ~= 0 and self.m_nSaveSelectIndex <= size then
        if not self.m_bCanFangFeng then
            self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_pMahjong:setPosition(self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_sPosition)
            self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_pMahjong:setScale(1.0)
            self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_bSelect = false
        end

        if  index == 0 then
            self.m_nSaveSelectIndex = 0
            self:setSameMahjongWithAll( 0)
            return
        end
    end

    if  index ~= 0 then
        self.m_pPMahjongs[0][index].m_bSelect = true
        self.m_pPMahjongs[0][index].m_pMahjong:setPositionY(self.m_pPMahjongs[0][index].m_sPosition.y + DEF_MJZY_MAHJONG_SELECT_Y)

        local scale = DEF_MJZY_MAHJONG_SELECT_S
        if self.m_bCanFangFeng then
            scale = scale - 0.2
        end
        self.m_pPMahjongs[0][index].m_pMahjong:setScale(scale)
        self.m_nSaveSelectIndex = index
        self:setSameMahjongWithAll(self.m_pPMahjongs[0][index].m_nMahjong)
    end
end

----------------------------------------------------------------------------
-- 根据指定的坐标点选择牌
-- 参数: 坐标点
function CDLayerTable_mjzy:touchMahjongFromPoint(point)
    cclog("CDLayerTable_mjzy::touchMahjongFromPoint")

    local size = self.m_nPMahjongs[0]
    if  size > TABLE_SIZE(self.m_pPMahjongs[0]) then
        size = TABLE_SIZE(self.m_pPMahjongs[0])
    end

    for i = 1, size do
        if  self.m_pPMahjongs[0][i].m_pMahjong ~= nil and
            self.m_pPMahjongs[0][i].m_bVaild and 
            (not self.m_pPMahjongs[0][i].m_pMahjong:isGrey()) and
            self.m_pPMahjongs[0][i].m_pMahjong:touchInFromPoint(point) then

            self:selectFromIndex(i)

            if  self.m_nLastSelect ~= i then
                self.m_nLastSelect = i
                dtPlaySound(DEF_MJZY_SOUND_MJ_CLICK)
            end
            return true
        end
    end
    return false
end
----------------------------------------------------------------------------
function CDLayerTable_mjzy:touchMahjongFromPointFangFeng(point)

    local size = self.m_nPMahjongs[0]
    if  size > TABLE_SIZE(self.m_pPMahjongs[0]) then
        size = TABLE_SIZE(self.m_pPMahjongs[0])
    end

    for i = 1, size do
        if  self.m_pPMahjongs[0][i].m_pMahjong ~= nil and
            self.m_pPMahjongs[0][i].m_bVaild and 
            (not self.m_pPMahjongs[0][i].m_pMahjong:isGrey()) and
            self.m_pPMahjongs[0][i].m_pMahjong:touchInFromPoint(point) then
            --如果牌已经被选择了
            if not self.m_pPMahjongs[0][i].m_bSelect then
                if self.m_nNeedNumForFangFeng <3 then
                    self:selectFromIndex(i)
                    table.insert(self.m_FangFengArr,self.m_pPMahjongs[0][i].m_nMahjong)
                    self.m_nNeedNumForFangFeng = self.m_nNeedNumForFangFeng +1
                end
            else
                self.m_nNeedNumForFangFeng = self.m_nNeedNumForFangFeng -1
                self.mahjong_MJZY:pop_mahjong(self.m_FangFengArr,self.m_pPMahjongs[0][i].m_nMahjong)
                self.m_pPMahjongs[0][i].m_pMahjong:setPosition(self.m_pPMahjongs[0][i].m_sPosition)
                self.m_pPMahjongs[0][i].m_pMahjong:setScale(1.0)
                self.m_pPMahjongs[0][i].m_bSelect = false
            end

            dumpArray(self.m_FangFengArr)
            local isFangFeng = self.mahjong_MJZY:canFangFeng(self.m_FangFengArr)
            if isFangFeng then
                self.m_pGroupFangFengChooseBtn:setVisible(true)
            else
                self.m_pGroupFangFengChooseBtn:setVisible(false)
            end

            dtPlaySound(DEF_MJZY_SOUND_MJ_CLICK)
        end
    end
end



----------------------------------------------------------------------------
-- 关闭所有界面
function CDLayerTable_mjzy:closeAllUserInterface()
    cclog("CDLayerTable_mjzy::closeAllUserInterface")

    local pTable = dtGetSceneTableFromParent(self)
    if  pTable then
        pTable:closeAllUserInterface()
        return
    end
end

----------------------------------------------------------------------------
-- 朗读出的牌
-- 参数: 要出的牌组, 牌组类型, 出牌的位置
function CDLayerTable_mjzy:readMahjong( mahjong, out_type, order_type)
    cclog("CDLayerTable_mjzy::readMahjong")
    -- 性别获取
    -- local file = ""
    -- local sex = ""
    -- if  order_type >= 0 and order_type < DEF_MJZY_MAX_PLAYER and 
    --     self.m_pPlayer[order_type].m_nSex == 0 then
    --     sex = "m"
    -- else
    --     sex = "w"
    -- end
    -- -- 说明读情景语言( out_type顶替为id)
    -- if  mahjong == 0 then
    --     file = DEF_CASINO_AREA.."_chat"..out_type.."_"..sex..".mp3"
    --     dtPlaySound( file)
    --     return
    -- end
    -- -- 其他音（出牌、飘赖子、碰、杠、胡、自摸)
    -- if  out_type == 0 then-- 出牌
    --     if  mahjong == self.mahjong_MJZY:getMahjongLaiZi() then
    --         -- file = string.format( "%d_mj_laizi_%s.mp3",DEF_CASINO_AREA, sex)-- 赖子
    --         file = string.format( "%d_mj_gang_%s.mp3",DEF_CASINO_AREA, sex)-- 赖子
    --     else
    --         file = string.format( "%d_mj_%u_%s0.mp3",DEF_CASINO_AREA, mahjong, sex)
    --     end
    -- elseif out_type == DEF_MJZY_PENG+1000 then-- 碰

    --     file = string.format( "%d_mj_peng_%s.mp3",DEF_CASINO_AREA, sex)
    -- elseif  out_type == casino_mjzy.MJZY_OP_TYPE_DIANXIAO then

    --     file = string.format( "%d_mj_gang_%s.mp3",DEF_CASINO_AREA, sex)
    -- elseif  out_type == casino_mjzy.MJZY_OP_TYPE_MENGXIAO then

    --     file = string.format( "%d_mj_gang_%s.mp3",DEF_CASINO_AREA, sex)
    -- elseif  out_type == casino_mjzy.MJZY_OP_TYPE_HUITOUXIAO then

    --     file = string.format( "%d_mj_gang_%s.mp3",DEF_CASINO_AREA, sex)
    -- elseif  out_type == DEF_MJZY_TYPE_ZM then

    --     file = string.format( "%d_mj_zimo_%s.mp3",DEF_CASINO_AREA, sex)
    -- elseif out_type == DEF_MJZY_TYPE_ZC then
            
    --     file = string.format( "%d_mj_hu_%s.mp3",DEF_CASINO_AREA, sex)
    -- elseif  out_type == 200 then

    --     file = string.format( "%d_mj_chi_%s.mp3",DEF_CASINO_AREA, sex)
    -- end
    -- dtPlaySound( file)
end

----------------------------------------------------------------------------
-- 清空指定位置的桌子
-- 参数: 位置
function CDLayerTable_mjzy:clearTable(order_type)
    cclog("CDLayerTable_mjzy::clearTable")

    if  order_type >= 0 and order_type < DEF_MJZY_MAX_PLAYER then
        self.m_pPlayTable[order_type]:removeAllChildren()
        self.m_sOutNumber[order_type] = 0
        self.m_pPlayer[order_type].tab_max = 0.0
        self.m_pPlayer[order_type].tab_min_scale = 1.0
    end
end

----------------------------------------------------------------------------
-- 初始化已经创建过的打出牌
function CDLayerTable_mjzy:initAllMahjongOut()
    cclog("CDLayerTable_mjzy::initAllMahjongOut")

    local nOutMaxMahjongs = self:changeMaxOutMahjongs()
    for i = 0, self.m_nPlayers - 1 do
        local order_idx = self:changeOrder(i)
        local count = TABLE_SIZE(self.m_pPMahjongs[order_idx])
        if  count > 0 then
            for j = 1, nOutMaxMahjongs do
                -- cclog( "initAllMahjongOut(idx=%u,nOMM=%u,idx=%u",order_idx, nOutMaxMahjongs, (order_idx+1)*DEF_MJZY_OUT_IDX+j)
                local pMahjong = self.m_pMahjongOut:getChildByTag( (order_idx + 1) * DEF_MJZY_OUT_IDX + j)
                if  pMahjong ~= nil then
                    if  i % 2 == 0 then
                        pMahjong:setMahjongScale( DEF_MJZY_BT_OUTSCALE)
                    else
                        pMahjong:setMahjongScale( DEF_MJZY_LR_OUTSCALE)
                    end
                    pMahjong:setVisible( false)
                end
            end
        end
    end
end

----------------------------------------------------------------------------
-- 初始化所有玩家手牌
function CDLayerTable_mjzy:initAllMahjongOwm()
    cclog("CDLayerTable_mjzy::initAllMahjongOwm")

    for i = 0, self.m_nPlayers-1 do
        local order_idx = self:changeOrder(i)
        self.m_nPMahjongs[order_idx] = 0
        local count = TABLE_SIZE(self.m_pPMahjongs[order_idx])
        if  count > 0 then
            for j = 1, DEF_MJZY_MAX_GETMAHJONG do
                local mahjong = self.m_pPMahjongs[order_idx][j]
                mahjong.m_nMahjong = 11
                mahjong.m_pMahjong:setMahjongNumber(11)
                if     order_idx == 0 then
                    mahjong.m_pMahjong:initMahjongWithFile("my_b_11.png",   "mj_b_back.png",nil,DEF_CASINO_MJZY)
                elseif order_idx == 1 then
                    mahjong.m_pMahjong:initMahjongWithFile("mj_r_side.png", "mj_lr_back.png",nil,DEF_CASINO_MJZY)
                elseif order_idx == 2 then
                    mahjong.m_pMahjong:initMahjongWithFile("mj_s_def.png",  "mj_s_back.png",nil,DEF_CASINO_MJZY)
                elseif order_idx == 3 then
                    mahjong.m_pMahjong:initMahjongWithFile("mj_l_side.png", "mj_lr_back.png",nil,DEF_CASINO_MJZY)
                end

                mahjong.m_pMahjong:setVisible(false)
                mahjong.m_pMahjong:setScale(1.0)
                mahjong.m_pMahjong:setIcoLaiVisible(false, false)

                mahjong.m_bSelect = false
                mahjong.m_bVaild = true
            end
        end
    end
end

----------------------------------------------------------------------------
-- 初始化桌子
-- 删除所有打出以及手上的牌，并且清除所有玩家桌面
function CDLayerTable_mjzy:initTable()
    cclog("CDLayerTable_mjzy::initTable")

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
    self:refreshTableInfo()
    self.m_bThinkJustOut = false
    
    self:managedTablePlayer(0, false)
    self:setTimeLeftVisible(false)

    local bCreate = false
    if  self.m_pPlayAI == nil then
        self.m_pPlayAI = {}
        bCreate = true
    end

    self:setOrderType(0)

    for i = 0, DEF_MJZY_MAX_PLAYER - 1 do
        self.m_pIcoDemo[i]:removeAllChildren()
        self:clearTable(i)
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

    self:setGroupTipVisible(false)

    self.m_FangFengArr = {}
    self.m_nNeedNumForFangFeng = 0
    self.m_nPaoFengOutMah = 0
end

----------------------------------------------------------------------------
-- 初始化
function CDLayerTable_mjzy:init()
    cclog("CDLayerTable_mjzy::init")
    
    -- touch事件
    local function onTouchBegan(touch, event)
        cclog("CDLayerTable_mjzy:onTouchBegan")

        -- 假如按钮组开启、放风按钮组开启或者现在事托管状态那么说明不能其他处理直接返回
        if  self.m_pGroupButton:isVisible() or self.m_pGroupFangFengBtn:isVisible() or self.m_bTrusteeship then
            --or self.m_pGroupFangFengChooseBtn:isVisible() then
            return
        end
        -- 假如听牌组显示那么关闭
        if  self.m_pGroupTip:isVisible() then
            self:setGroupTipVisible( false)
        end
        -- 点选自己的手牌(游戏中才能使用)
        local point = touch:getLocation()
        if  self.m_bInTheGame then

            local nOldTouchIndex = self.m_nSaveSelectIndex

            print("self.m_bCanFangFeng----------->",self.m_bCanFangFeng)
            if self.m_bCanFangFeng then
                self:touchMahjongFromPointFangFeng(point) 
            else

                if  not self:touchMahjongFromPoint( point) then
    
                    self:selectFromIndex( 0)
                    self:myMahjong_showTingGroup( 0)
                else
    
                    -- 假如选中，并且和之前选中的相同那么出牌
                    if  nOldTouchIndex == self.m_nSaveSelectIndex and nOldTouchIndex ~= 0 and self.m_bCanOutMahjong then
                        self.m_bCanOutMahjong = false
                        self:round_SendOutMahjong( self.m_nSaveSelectIndex)
                        self:myMahjong_showTingGroup( 0)
                    else
    
                        self:myMahjong_showTingGroup( self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_nMahjong)
                    end
                end
            end
        end
        -- 玩家头像点击处理
        for i = 1, DEF_MJZY_MAX_PLAYER-1 do

            local sRect = self.m_pPlayer[i].m_pFrame:getBoundingBox()
            if  cc.rectContainsPoint( sRect, point) then

                self:openPlayerInfo( i)
                break
            end
        end

        -- 语音聊天按下(开始录音)
        if  self.m_pRecordButton ~= nil and
            self.m_pRecordButton:isVisible() then
            local sRect = self.m_pRecordButton:getBoundingBox()
            if  cc.rectContainsPoint( sRect, point) then
                self:sp_ShowMessage()
                self:beginRecord()
            end
        end

        return true
    end

    local function onTouchMoved(touch, event)
        cclog("CDLayerTable_mjzy:onTouchMoved")

        -- 假如按钮组开启、或者是托管状态那么说明不能其他处理直接返回
        if self.m_bCanFangFeng then
            return 
        end

        if  self.m_pGroupButton:isVisible() or 
            self.m_pGroupFangFengBtn:isVisible() or 
            self.m_bTrusteeship or 
            (not self.m_bInTheGame) then
            return
        end
        print("移动选牌活着移动选中的牌")
        -- 移动选牌活着移动选中的牌
        local point = touch:getLocation()
        local move_pos = self.m_pCenterDemo[0]:convertToNodeSpace( point)
        if  not self.m_bMoveSelect then -- 假如目前没有移动种的选中牌那么判断滑动中的选择

            local nOldTouchIndex = self.m_nSaveSelectIndex
            self:touchMahjongFromPoint( point)

            if  self.m_nSaveSelectIndex ~= 0 and point.y >= DEF_MJZY_MIN_MOVE_Y and self.m_bCanOutMahjong then -- 拎起选中牌可以开始移动

                self.m_bMoveSelect = true
                self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_pMahjong:setPosition( cc.p( move_pos.x, move_pos.y))
            elseif  nOldTouchIndex ~= self.m_nSaveSelectIndex and self.m_bCanOutMahjong then

                self:myMahjong_showTingGroup( self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_nMahjong)
            end
        else -- 移动选中的牌

            if  self.m_nSaveSelectIndex ~= 0 then

                self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_pMahjong:setPosition( cc.p( move_pos.x, move_pos.y))
            end
        end

        --录音时 移出按钮位置取消发送
        self:cancelRecord(point)
    end

    local function onTouchEnded(touch, event)
        cclog("CDLayerTable_mjzy:onTouchEnded")
        -- 关闭位置显示MapLocation
        self:onCloseLocation()

         -- 语音聊天抬起结束录音
        if  self.m_pRecordButton ~= nil and
            self.m_pRecordButton:isVisible() then

            -- 最好再增加是否在录音中的判断..no over
            self:endRecord()
            self:sp_CloseALlPra()
        end

        g_spMJZY_isClickRecord = false

        if self.m_bCanFangFeng then
            return
        end

        -- 假如按钮组开启、或者是托管状态那么说明不能其他处理直接返回
        if  self.m_pGroupButton:isVisible() or 
            self.m_pGroupFangFengBtn:isVisible() or 
            self.m_bTrusteeship or 
            (not self.m_bInTheGame) then
            return
        end
        -- 判断是否有晃点击
        local point = touch:getLocation()
        if  self:myMahjong_touchHuangButton( point) then
            return
        end
        -- 自己的牌选择
        self.m_nLastSelect = 0
        if  self.m_bMoveSelect and self.m_nSaveSelectIndex  ~= 0 then

            if  point.y >= DEF_MJZY_MIN_MOVE_Y and self.m_bCanOutMahjong then -- 表示打出

                self:round_SendOutMahjong( self.m_nSaveSelectIndex)
                self.m_bCanOutMahjong = false
                self:myMahjong_showTingGroup( 0)
            else

                local position = cc.p(  self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_sPosition.x,
                                        self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_sPosition.y+DEF_MJZY_MAHJONG_SELECT_Y)
                self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_pMahjong:setPosition( position)
                self.m_pPMahjongs[0][self.m_nSaveSelectIndex].m_pMahjong:setScale( 1.0)
            end
            self.m_bMoveSelect = false
        end
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
-- 搜索有效牌索引
-- 参数: 位置索引, vaild有效/无效
function CDLayerTable_mjzy:getMahjongIndexWithVaild( order, vaild)
    cclog("CDLayerTable_mjzy::getMahjongIndexWithVaild")

    if  order < 0 or order > DEF_MJZY_MAX_PLAYER-1 then
        return -1
    end

    if  vaild == nil then
        vaild = true
    end

    for i = 1, self.m_nPMahjongs[order] do

        local index = MJZY_INDEX_ITOG( order, i)
        if  self.m_pPMahjongs[order][index].m_bVaild == vaild and 
            self.m_pPMahjongs[order][index].m_pMahjong and 
            self.m_pPMahjongs[order][index].m_pMahjong:isVisible() then
            return i
        end
    end
    return -1
end

----------------------------------------------------------------------------
-- 搜索剩余指定牌的数量
-- 参数: 指定牌
function CDLayerTable_mjzy:getMahjongLaveNumber( mahjong)
    cclog("CDLayerTable_mjzy::getMahjongLaveNumber")

    -- 普通牌最大数量是4张，翻牌最大数量就是3张
    local lave = 4
    if  mahjong == self.mahjong_MJZY:getMahjongFan() then
        lave = 3
    end
    -- 返回搜到的牌数量
    for i = 1, self.m_nPlayers-1 do

        local order_idx = self:changeOrder( i)
        lave = lave - self.m_pPlayAI[order_idx]:getMahjongCount_withI( mahjong)
        if  lave <= 0 then
            return 0
        end
    end
    lave = lave - self.m_pPlayAI[0]:getMahjongCount_withIV( mahjong)
    return lave
end


--============================压牌、摸牌后相关处理============================--

----------------------------------------------------------------------------
-- 胡牌效果
-- 参数: 位置对象
function CDLayerTable_mjzy:showHuPaiEffect( order_type)
    cclog("CDLayerTable_mjzy::showHuPaiEffect")

    -- 小于两张牌不可能胡
    if  self.m_nPMahjongs[order_type] < 2 then
        return
    end
    -- 假如是自己那么播放胡牌火烧效果
    if  order_type == 0 then
        local time_spc = 0.5/self.m_nPMahjongs[order_type]
        for i = 1, self.m_nPMahjongs[order_type] do
            if  self.m_pPMahjongs[0][i].m_pMahjong ~= nil then 
                self.m_pPMahjongs[0][i].m_pMahjong:addEffect( "x_tx_fire.ccbi", 1.0 + i*time_spc)
            end
        end
        dtPlaySound( DEF_SOUND_FIRE)
    end
end

----------------------------------------------------------------------------
-- 删除被别人碰或者杠的已经打出的牌
-- 参数:
function CDLayerTable_mjzy:deleteMahjong( order_type, target_id)

    local target_idx = self:changeOrder( self:getTableIndexWithID( target_id))

    if  target_idx ~= order_type and target_idx >= 0 then

        local nTag = ( target_idx+1)*DEF_MJZY_OUT_IDX+self:getPlayerOutNumber(target_idx)

        -- local pUsefulMahjong = self.m_pMahjongOut:getChildByTag( nTag)

        -- if  pUsefulMahjong then

            local pMahjong = self.m_pMahjongOut:getChildByTag( nTag)
            if  pMahjong then

                pMahjong:setVisible( false)
            end
            self.m_sOutNumber[target_idx] = self.m_sOutNumber[target_idx] - 1
        -- end
    end
end

----------------------------------------------------------------------------
-- 显示碰牌处理
-- 参数: 位置对象, 碰牌组
function CDLayerTable_mjzy:operatePeng( order_type, array, target_id)
    cclog("CDLayerTable_mjzy::operatePeng(type = %u, id = %u)", order_type, target_id)

    self:showEffectWithOperate( order_type, DEF_MJZY_PENG+1000)
    self:readMahjong( 1, DEF_MJZY_PENG+1000, order_type)

    self.m_pPlayAI[order_type]:addSMahjong( array)
    self.m_pPlayAI[order_type]:addNMahjong( array, self:changeOrder(self:getTableIndexWithID(target_id)), DEF_MJZY_OP_PENG, order_type)

    if  order_type == 0 then

        local del_mahjong = {}
        self.mahjong_MJZY:push_back( del_mahjong, array, 1, 2)
        self.m_pPlayAI[0]:delVMahjongs( del_mahjong)

        self:round_addMahjong( array[1], 0)
        self:resetMahjongWithArray( order_type, array)
        self:myMahjongs_refresh( false)

        --  可以杠的牌选择碰，那么也记录为下次不提醒杠
        -- if  self.m_pPlayAI[0]:getMahjongCount_withV( array[1]) > 0 then

        --     self:myMahjong_addForgo( 0, array[1], false)
        -- end
    else

        self:round_addMahjong( 0, order_type)
        self:resetMahjongWithArray( order_type, array)
    end

    self:resetTableMahjongs( order_type)
    -- 删除被碰的玩家的碰牌
    self:deleteMahjong( order_type, target_id)
    -- 添加已经用掉的牌
    for i = 1, TABLE_SIZE( array)-1 do
        self.m_pPlayAI[order_type]:addIMahjong( array[i])
    end
    -- 关闭最后牌指定标记
    self:showLastMahjongFlag( false)

end

--放风之后 服务器返回的处理
function CDLayerTable_mjzy:operateFangFeng(order_type,mahjongs)

    --放风的特效
     self:showEffectWithOperate( order_type,98)
    --放风的语音

    --将放风的牌加入到放风的牌组中去
    self.m_pPlayAI[order_type]:addFangFMahjong(mahjongs)

    local hua_wait = 0.01
    local count = TABLE_SIZE(mahjongs)
  
    for i = 1, count do
        self:round_addFangFengMah(order_type,i,mahjongs[i],false,true, hua_wait)
        hua_wait = hua_wait + 0.01
    end

    --如果是自己的话
    if order_type == 0 then
        self.m_nPaoFengType = self.mahjong_MJZY:judgePaoFengMah(mahjongs)
        for i,v in ipairs(mahjongs) do 
            self.m_pPlayAI[0]:delVMahjong(v)
            self:round_delMahjong( 0)
        end
        self.m_bCanFangFeng = false
        self:myMahjong_allGrey(false)
        self:myMahjongs_refresh(false)
    else
        for i=1 ,count do 
            self.m_pPlayAI[order_type]:delVMahjongWithIndex(1)
            self:round_delMahjong(order_type)
        end
    end

    self:resetTableMahjongs( order_type)

end

-- 跑风之后 服务器返回的处理
function CDLayerTable_mjzy:operatePaoFeng(order_type,mahjong)
    print("operatePaoFeng")
    --跑风的特效
    self:showEffectWithOperate( order_type,99)
    --跑风的语音

    --将跑风的牌加入到放风的牌组中去
    
    self.m_pPlayAI[order_type]:addPaoFMahjong(mahjong)
    local hua_wait = 0.01
    local count = self.m_pPlayAI[order_type]:getPaoFMahjongSize()
    local paofengArr = self.m_pPlayAI[order_type]:getPaoFMahjong()

    
    self:round_addFangFengMah(order_type,count,paofengArr[count],true,true, hua_wait)
 
    if order_type == 0 then
        self.m_pPlayAI[0]:delVMahjong(mahjong)
        self:round_delMahjong(0)

        self:myMahjongs_refresh()
        self:resetTableMahjongs(0)
    else
        self.m_pPlayAI[order_type]:delVMahjongWithIndex(1)
        self:round_delMahjong(order_type)
    end

    self:resetTableMahjongs( order_type)
end


-- 吃牌之后 服务器返回的处理 
function CDLayerTable_mjzy:operateChi( order_type, array, target_id,target_card)
    cclog("CDLayerTable_mjzy::operateChi(type = %u, id = %u)", order_type, target_id)

    self:showEffectWithOperate( order_type, 200)  -- 吃的特效
    self:readMahjong( 1, 200, order_type)        -- 吃 语音
    self.m_pPlayAI[order_type]:addSMahjong( array)               -- 把牌加到摊派组中
    self.m_pPlayAI[order_type]:addNMahjong( array, self:changeOrder(self:getTableIndexWithID(target_id)), DEF_MJZY_OP_CHI,order_type,target_card)
    
    local del_mahjong = {}

    del_mahjong = self.mahjong_MJZY:getOwnArrFromArr( array, target_card)
    
    if  order_type == 0 then                -- 如果是自己的话

        self.m_sChiArr = {}
        self.mahjong_MJZY:push_back(self.m_sChiArr,del_mahjong,1,TABLE_SIZE(del_mahjong))

        self.m_pPlayAI[0]:delVMahjongs( del_mahjong)        --  把自己的两张牌添加到无效的牌组中

        self:round_addMahjong( target_card, 0)
        self:resetMahjongWithArray( order_type, array)
        self:myMahjongs_refresh( false)

    else                                    -- 别人

        self:round_addMahjong( 0, order_type)
        self:resetMahjongWithArray( order_type, array)
    end

    self:resetTableMahjongs( order_type)
    -- 删除被吃的玩家的碰牌
    self:deleteMahjong( order_type, target_id)
    -- 添加已经用掉的牌
    for i = 1, TABLE_SIZE( del_mahjong) do
        self.m_pPlayAI[order_type]:addIMahjong( del_mahjong[i])
    end
    -- 关闭最后牌指定标记
    self:showLastMahjongFlag( false)
    -- 刷新晃操作按钮
    if  order_type == 0 then
        self:myMahjong_vaildHuangButton( true)
    end
end
----------------------------------------------------------------------------
-- 补杠带来的刷新
-- 参数: 位置
function CDLayerTable_mjzy:operateGang_buRefresh( order_type)
    cclog("CDLayerTable_mjzy::operateGang_buRefresh")

    -- 找出按顺序排列的第一个有效对象转为无效对象
    local ref_idx = self:getMahjongIndexWithVaild( order_type, true)
    local index = MJZY_INDEX_ITOG( order_type, ref_idx)

    self.m_pPMahjongs[order_type][index].m_bVaild = false
    self.m_pPMahjongs[order_type][index].m_nMahjong = 0

    -- 根据无效牌，和摊牌组的对象比对来进行刷新
    ref_idx = self:getMahjongIndexWithVaild( order_type, false)
    local size = self.m_pPlayAI[order_type]:getNMahjongSize()
    for i = 1, size do

        local group_s = self.m_pPlayAI[order_type]:getNMahjongWithIndex( i)
        local count = TABLE_SIZE( group_s.mahjongs)
        for j = 1, count do

            index = MJZY_INDEX_ITOG( order_type, ref_idx)
            if  self.m_pPMahjongs[order_type][index].m_nMahjong ~= group_s.mahjongs[j] then

                self.m_pPMahjongs[order_type][index].m_nMahjong = group_s.mahjongs[j]
                self.m_pPMahjongs[order_type][index].m_pMahjong:setMahjongNumber( group_s.mahjongs[j])
                if order_type == 0 then
                    self.m_pPMahjongs[0][index].m_pMahjong:setMahjong( string.format( "out_b_%u.png", group_s.mahjongs[j]))
                    self:myMahjong_setIcoLai( self.m_pPMahjongs[0][index])
                elseif order_type == 1 then
                    -- if  group_s.type_op == DEF_MJZY_OP_GANG_A then
                    --     self.m_pPMahjongs[1][index].m_pMahjong:setMahjong( "l_back.png")
                    -- else
                        self.m_pPMahjongs[1][index].m_pMahjong:setMahjong( string.format( "l_%u.png", group_s.mahjongs[j]))
                    -- end
                elseif order_type == 2 then
                    -- if  group_s.type_op == DEF_MJZY_OP_GANG_A then
                    --     self.m_pPMahjongs[2][index].m_pMahjong:setMahjong( "t_back.png")
                    -- else
                        self.m_pPMahjongs[2][index].m_pMahjong:setMahjong( string.format( "t_%u.png", group_s.mahjongs[j]))
                    -- end
                elseif order_type == 3 then
                    -- if  group_s.type_op == DEF_MJZY_OP_GANG_A then
                    --     self.m_pPMahjongs[3][index].m_pMahjong:setMahjong( "r_back.png")
                    -- else
                        self.m_pPMahjongs[3][index].m_pMahjong:setMahjong( string.format( "r_%u.png", group_s.mahjongs[j]))
                    -- end
                end
            end
            ref_idx = ref_idx + 1
        end
    end
end

----------------------------------------------------------------------------
-- 杠牌处理
function CDLayerTable_mjzy:operateGang( mahjong, gang_type, order_type, target_id)
    cclog( "CDLayerTable_mjzy:operateGang(%u)", gang_type)

    local s_count = 0
    local v_count = 0
    local type = 0
    local tag_idx = 0
    if  gang_type == casino_mjzy.MJZY_OP_TYPE_DIANXIAO then            --点笑
        s_count = 4
        v_count = 3
        type = DEF_MJZY_OP_GANG_M
        tag_idx = self:changeOrder(self:getTableIndexWithID( target_id))
        self:deleteMahjong( order_type, target_id)
    elseif gang_type == casino_mjzy.MJZY_OP_TYPE_MENGXIAO then        --闷笑
        s_count = 4
        v_count = 4
        tag_idx = order_type
        type = DEF_MJZY_OP_GANG_A
    elseif gang_type == casino_mjzy.MJZY_OP_TYPE_HUITOUXIAO then      --回头笑
        s_count = 1
        v_count = 1
        tag_idx = order_type
        type = DEF_MJZY_OP_GANG_B
    elseif gang_type == casino_mjzy.MJZY_OP_TYPE_XIAOCHAOTIAN then    --翻牌点笑
        s_count = 3
        v_count = 2
        type = DEF_MJZY_OP_GANG_M
        tag_idx = self:changeOrder(self:getTableIndexWithID( target_id))
        self:deleteMahjong( order_type, target_id)
    elseif gang_type == casino_mjzy.MJZY_OP_TYPE_DACHAOTIAN then      --翻牌闷笑
        s_count = 3
        v_count = 3
        tag_idx = order_type
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

    if  order_type == 0 then
        self.m_pPlayAI[0]:setGangType(true)
        self.m_pPlayAI[0]:delVMahjongs( array)
        -- 只有明杠才需要补充一张牌，自己要在这里先加
        if  type == DEF_MJZY_OP_GANG_M then
            self:round_addMahjong( mahjong, 0)
        end
    else
        if  type == DEF_MJZY_OP_GANG_M then
            self:round_addMahjong( 0, order_type)
        end
    end        

    if  type == DEF_MJZY_OP_GANG_B then
        self:operateGang_buRefresh( order_type, mahjong)
    else
        self:resetMahjongWithArray( order_type, array)
    end

    if  order_type == 0 then
        self:myMahjongs_refresh( false)
    end

    self:resetTableMahjongs( order_type)

    if  order_type == 0 then
        self:myMahjong_vaildHuangButton( true)
    end

    for i = 1, v_count do
        self.m_pPlayAI[order_type]:addIMahjong( mahjong)
    end

    if  type == DEF_MJZY_OP_GANG_M then
        self:showLastMahjongFlag( false)
    end
end

----------------------------------------------------------------------------
function CDLayerTable_mjzy:getFlashEffectPos( ... )
    if  self.m_nLastOutPlayer >= 0 and self.m_nLastOutPlayer < DEF_MJZY_MAX_PLAYER then
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
-- 显示胡牌处理
-- 参数: 位置对象, 胡牌组
function CDLayerTable_mjzy:displayHu( order_type, score)
    cclog("CDLayerTable_mjzy::displayHu")

    -- 获取胡的类型
    local hu_type = DEF_MJZY_TYPE_ZM
    local op_count = TABLE_SIZE(score.opscores)
    for i = 1, op_count do

        local op_scores = score.opscores[i]
        if  op_scores.type == DEF_MJZY_TYPE_ZC or 
            op_scores.type == DEF_MJZY_TYPE_QG then

            hu_type = DEF_MJZY_TYPE_ZC
        end
    end

    print("==============displayHu===============")
    print("order_type", order_type)
    print("hu_type", hu_type)
    print("==============displayHu===============")
    self:showEffectWithOperate( order_type, hu_type)
    self:readMahjong( 1, hu_type, order_type)

    -- 排除已经扑到的牌后，用胡牌来进行牌型组合
    local copy_array = {}

    self.mahjong_MJZY:push_back( copy_array, score.cards, 1, TABLE_SIZE( score.cards))
    -- local s_array = self.m_pPlayAI[ order_type]:getAllSMahjongs_define()
    local s_array = self.m_pPlayAI[ order_type]:drawByOutPai()
    self.mahjong_MJZY:pop_array( copy_array, s_array)
    self.mahjong_MJZY:defMahjongSort_stb( copy_array)
    local bHu, mahjongs = self.mahjong_MJZY:canHuPai_def( copy_array, self.m_pPlayAI[order_type]:getNMahjong())

    if  not bHu then
        return
    end
    self.mahjong_MJZY:push_back( s_array, mahjongs, 1, TABLE_SIZE( mahjongs))

    -- 绘制胡牌
    if  order_type == 0 then

        if  TABLE_SIZE( score.cards) > self.m_nPMahjongs[0] then
            self:round_addMahjong( score.cards[1], 0)
        end
        self:resetMahjongWithArray( order_type, s_array, true)
        self:myMahjong_allGrey( false)
    else

        if  TABLE_SIZE( score.cards) > self.m_nPMahjongs[order_type] then
            self:round_addMahjong( 0, order_type)
        end
        self:resetMahjongWithArray( order_type, s_array, true)
    end
    self:resetTableMahjongs( order_type)
    self:showHuPaiEffect( order_type)

    -- 假如最后打出的牌就是胡的对手牌那么标记最后打的这张牌
    if  hu_type == DEF_MJZY_TYPE_ZC then

        local nTag = (self.m_nLastOutPlayer+1)*DEF_MJZY_OUT_IDX + self:getPlayerOutNumber( self.m_nLastOutPlayer) --self.m_sOutNumber[ self.m_nLastOutPlayer]
        local pUsefulMahjong = self.m_pMahjongOut:getChildByTag( nTag)
        if  pUsefulMahjong then
            pUsefulMahjong:setGrey( true)

            local pos = self:getFlashEffectPos()
            if  pos then
                local eff = CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_flash.ccbi", pos, 0)
                if  eff ~= nil then
                    self.m_pEffFlagLast:endRelease( true)
                    self.m_pEffFlagLast:endVisible( true)
                end
                dtPlaySound( DEF_MJZY_SOUND_MJ_FLASH)
            end
        end
    end
end

----------------------------------------------------------------------------
-- 播放特效根据操作
-- 参数:位置索引，操作类型
function CDLayerTable_mjzy:showEffectWithOperate( order_type, operate_type)
    cclog( "CDLayerTable_mjzy:showEffectWithOperate => (%u)", operate_type)

    local pos = cc.p(   self.m_pPlayer[order_type].tab_center.x + self.m_pPlayer[order_type].m_sNumSpace.x,
                        self.m_pPlayer[order_type].tab_center.y + self.m_pPlayer[order_type].m_sNumSpace.y)

    if      operate_type == DEF_MJZY_PENG+1000 then

        CDCCBAniObject.createCCBAniObject( self, "x_tx_peng.ccbi", pos, 0)
    elseif  operate_type == casino_mjzy.MJZY_OP_TYPE_DIANXIAO then    --点笑

        CDCCBAniObject.createCCBAniObject( self, "x_tx_gang.ccbi", pos, 0)
    elseif  operate_type == casino_mjzy.MJZY_OP_TYPE_MENGXIAO then    -- 闷笑

        CDCCBAniObject.createCCBAniObject( self, "x_tx_gang.ccbi", pos, 0)
    elseif  operate_type == casino_mjzy.MJZY_OP_TYPE_HUITOUXIAO then  -- 回头笑

        CDCCBAniObject.createCCBAniObject( self, "x_tx_gang.ccbi", pos, 0)
    elseif  operate_type == DEF_MJZY_TYPE_ZM or operate_type == DEF_MJZY_TYPE_ZC then -- 胡

        CDCCBAniObject.createCCBAniObject( self, "x_tx_hu.ccbi", pos, 0)
        if  order_type == 0 then
            dtPlaySound( DEF_SOUND_WIN)
        end
    elseif operate_type == 98 then  -- 放风

         CDCCBAniObject.createCCBAniObject( self, "x_tx_fangfeng.ccbi", pos, 0)

    elseif operate_type == 99 then  -- 跑风

        CDCCBAniObject.createCCBAniObject( self, "x_tx_paofeng.ccbi", pos, 0)

    elseif  operate_type == 200 then

        CDCCBAniObject.createCCBAniObject( self, "x_tx_chi.ccbi", pos, 0)
    end

    -- 灯光亮起来
    if  self.m_pLighting ~= nil then

        self.m_pLighting:stopAllActions()
        self.m_pLighting:runAction( cc.Sequence:create( cc.FadeTo:create( 0.2, 1), cc.DelayTime:create( 0.3), cc.FadeTo:create( 0.5, 50)))
    end
end

----------------------------------------------------------------------------
-- 表演最后四张牌阶段显示
-- function CDLayerTable_mjzy:showEndCard()
--     if  self.m_nEndCardType == 0 then

--         self:setTimeLeftVisible( false)

--         local effect = nil
--         if  self.m_nPlayers == 2 then -- 最后两张
--             CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_zhlz.ccbi", g_pGlobalManagement:getWinCenter(), 0)
--         else -- 最后四张
--             CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_zhsz.ccbi", g_pGlobalManagement:getWinCenter(), 0)
--         end
--         if  effect then
--             effect:endVisible( true)
--             effect:endRelease( true)
--         end

--         self.m_nEndCardType = 1
--         self:runAction( cc.Sequence:create( cc.DelayTime:create( 2.5), cc.CallFunc:create( CDLayerTable_mjzy.showEndCard)))
--         dtPlaySound( DEF_MJZY_SOUND_MJ_ZHSZ)

--     elseif self.m_nEndCardType == 1 then
--         for i = 0, self.m_nPlayers-1 do
--             if  self.m_pHuIndex ~= self:changeOrder(i) then
--                 self:round_MoMahjong( i, self.m_nEndCard)
--             end
--         end

--         self.mahjong_MJZY:mahjongTotal_set((14+self.m_nPlayers))
--         self:refreshTableInfo()        
--     end
-- end

----------------------------------------------------------------------------
-- 设置/获取倒计时时间
-- 参数:时间
function CDLayerTable_mjzy:setTimeLeft( time)

    self.m_nTimeLeft = time
    if  self.m_pTimeLeftNum ~= nil then
        self.m_pTimeLeftNum:setString( string.format("%u", time))
    end
end
function CDLayerTable_mjzy:getTimeLeft()
    return self.m_nTimeLeft
end

----------------------------------------------------------------------------
-- 设置中间倒计时时钟是否显示
-- 参数:是否显示
function CDLayerTable_mjzy:setTimeLeftVisible(visible,vis_pan)
    cclog( "CDLayerTable_mjzy:setTimeLeftVisible")

    if  vis_pan == nil then
        self.m_pOrderIco:setVisible( visible)
    else
        self.m_pOrderIco:setVisible( vis_pan)
    end

    if  not visible then
        --  清空方位文字
        if  self.m_pOrderIcoP ~= nil then
            self.m_pOrderIcoP:removeAllChildren()

            for i = 0, DEF_MJZY_MAX_PLAYER-1 do
                self.m_pPlayer[i].m_pOrderText = nil
            end
        end
    end

    self.m_pOrderIcoP:setVisible( visible)
    self.m_pTimeLeftNum:setVisible( visible)

    if  not visible then
        self.m_pTimeLeftNum:stopAllActions()
    end
end

-- 重置位置文字
-- 
function CDLayerTable_mjzy:resetOrderText()
    cclog( "CDLayerTable_mjzy:resetOrderText")

    -- 设置空
    if  self.m_pOrderIcoP ~= nil then
        self.m_pOrderIcoP:removeAllChildren()

        for i = 0, DEF_MJZY_MAX_PLAYER-1 do
            self.m_pPlayer[i].m_pOrderText = nil
        end
    end

    -- 先获取我的索引
    local data  = casinoclient.getInstance():getTable()
    local count = TABLE_SIZE( data.players)
    local my_id = casinoclient.getInstance():getPlayerData():getId()

    local index = -1
    for i = 1, count do

        if  data.players[i].id == my_id then
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

        cclog( "CDLayerTable_mjzy:resetOrderText = %d", index)
        for i = 0, DEF_MJZY_MAX_PLAYER-1 do

            local file_name = string.format( "x_mj_vec%d.png", index)
            self.m_pPlayer[i].m_pOrderText = cc.Sprite:createWithSpriteFrameName( file_name)
            self.m_pPlayer[i].m_pOrderText:setPosition( pos[i+1])
            self.m_pOrderIcoP:addChild( self.m_pPlayer[i].m_pOrderText)
            index = index + 1
            if  index > DEF_MJZY_MAX_PLAYER-1 then
                index = 0
            end
        end
    end
end

----------------------------------------------------------------------------
-- 显示和刷新倒计时
function CDLayerTable_mjzy:showTimeLeft( time)
    cclog( "CDLayerTable_mjzy:showTimeLeft")

    local function leftTime_refresh()

        if  self.m_nTimeLeft <= 0 then
            return
        end
        self.m_nTimeLeft = self.m_nTimeLeft - 1

        if  self.m_nTimeLeft <= 5 and self.m_pOrderIco:isVisible() then
            dtPlaySound( DEF_SOUND_TIME)
        end

        if  self.m_nTimeLeft <= 0 then

            self:setTimeLeft( 0)
            self.m_pTimeLeftNum:stopAllActions()

            -- 假如倒计时到0，那么显示时间
            if  casinoclient.getInstance():isSelfBuildTable() then
                self:initTablePauseTime( casinoclient:getInstance():getServerTime()+600)
            end
        else

            self:setTimeLeft( self.m_nTimeLeft)
            self.m_pTimeLeftNum:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( leftTime_refresh)))
        end
    end

    if  time > 0 then
        self:setTimeLeft( time)
        self.m_pTimeLeftNum:stopAllActions()
        self.m_pTimeLeftNum:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( leftTime_refresh)))
    else
        self:setTimeLeft( 0)
        self.m_pTimeLeftNum:stopAllActions()
    end
end

----------------------------------------------------------------------------
-- 显示数字
-- 参数: 位置索引, 数字
function CDLayerTable_mjzy:showNumber( order_type, number)
    cclog( "CDLayerTable_mjzy:showNumber")

    if  order_type < 0 or order_type >= DEF_MJZY_MAX_PLAYER then
        return
    end

    local b_pos = cc.p( self.m_pPlayer[order_type].m_pNumDemo:getPositionX() + self.m_pPlayer[order_type].m_sNumSpace.x,  
                        self.m_pPlayer[order_type].m_pNumDemo:getPositionY() + self.m_pPlayer[order_type].m_sNumSpace.y)
    local e_pos = cc.p( b_pos.x, b_pos.y+50)
    if  number < 0 then
        self.m_pPlayer[order_type].m_pNumber1:setString( dtGetFloatString( number))
        self.m_pPlayer[order_type].m_pNumber1:setVisible( true)
        self.m_pPlayer[order_type].m_pNumber1:setScale( 2.5)
        self.m_pPlayer[order_type].m_pNumber1:setPosition( b_pos)
        self.m_pPlayer[order_type].m_pNumber1:stopAllActions()
        self.m_pPlayer[order_type].m_pNumber1:setOpacity( 255)

        self.m_pPlayer[order_type].m_pNumber1:runAction( 
            cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 0.90)), cc.DelayTime:create( 2.5), 
                cc.Spawn:create( cc.MoveTo:create( 0.25, e_pos), cc.FadeOut:create( 0.25))))

        self.m_pPlayer[order_type].m_pNumber2:setVisible( false)
    else
        self.m_pPlayer[order_type].m_pNumber2:setString( "+"..dtGetFloatString( number))
        self.m_pPlayer[order_type].m_pNumber2:setVisible( true)
        self.m_pPlayer[order_type].m_pNumber2:setScale( 2.5)
        self.m_pPlayer[order_type].m_pNumber2:setPosition( b_pos)
        self.m_pPlayer[order_type].m_pNumber2:stopAllActions()
        self.m_pPlayer[order_type].m_pNumber2:setOpacity( 255)

        self.m_pPlayer[order_type].m_pNumber2:runAction( 
            cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 0.90)), cc.DelayTime:create( 2.5), 
                cc.Spawn:create( cc.MoveTo:create( 0.25, e_pos), cc.FadeOut:create( 0.25))))

        self.m_pPlayer[order_type].m_pNumber1:setVisible( false)
    end
end

----------------------------------------------------------------------------
-- 中途积分显示
-- 参数: 积分
function CDLayerTable_mjzy:showScoreNumber( scores)
    cclog( "CDLayerTable_mjzy:showScoreNumber")

    local size = TABLE_SIZE( scores)
    if  size <= 0 then
        return
    end

    local function hideAllNumber()

        for i = 0, DEF_MJZY_MAX_PLAYER-1 do
            self.m_pPlayer[i].m_pNumber1:setVisible( false)
            self.m_pPlayer[i].m_pNumber2:setVisible( false)
        end
    end

    for i = 1, size do

        local player_score = scores[i]
        local order_type = self:changeOrder( self:getTableIndexWithID( player_score.player_id))
        self:showNumber( order_type, player_score.score_add) 

        cclog( "showScoreNumber(%u, %d)", order_type, player_score.score_add)

        self.m_pPlayer[order_type].m_pData.score_total = player_score.score_total
        self:refreshTablePlayer( order_type, self.m_pPlayer[order_type].m_pData)
    end
    self.m_pPlayer[0].m_pNumber1:runAction( cc.Sequence:create( cc.DelayTime:create( 2.9), cc.CallFunc:create( hideAllNumber)))
end

----------------------------------------------------------------------------
-- 设置按钮组默认（关闭）
function CDLayerTable_mjzy:setGroupButtonToDefine()
    cclog( " CDLayerTable_mjzy:setGroupButtonToDefine")

    if self:setGroupButtonVisible( false) then

        for i = 1, DEF_MJZY_BUT_TYPE_PAOFENG do
            self.m_pBut_Type[i]:setGrey( true)
            self.m_pBut_Text[i]:setGrey( true)
        end
    end
    
end

function CDLayerTable_mjzy:closeAllBtnGroup( ... )
    for i = 1, DEF_MJZY_BUT_TYPE_PAOFENG do
        self.m_pBut_Type[i]:setGrey( true)
        self.m_pBut_Text[i]:setGrey( true)
    end
end
----------------------------------------------------------------------------
-- 设置相同对象颜色
-- 参数: 数字
function CDLayerTable_mjzy:setSameMahjongWithAll( mahjong)

    local nOutMaxMahjongs = self:changeMaxOutMahjongs()
    local order_idx = 0
    -- 判断打出的牌
    for i = 0, self.m_nPlayers-1 do

        order_idx = self:changeOrder( i)
        for j = 1, nOutMaxMahjongs do

            local nTag = (order_idx+1)*DEF_MJZY_OUT_IDX + j
            local child = self.m_pMahjongOut:getChildByTag( nTag)
            if  child ~= nil and child:isVisible() then
                -- child:setSameColorWithPutCard( mahjong, self.mahjong_MJZY:getMahjongLaiZi(),51)
                child:setSameColorWithPutCard( mahjong, self.mahjong_MJZY:getMahjongLaiZi())
            end
        end
    end

    -- 判断玩家的摊牌和手牌
    for i = 0, self.m_nPlayers-1 do

        order_idx = self:changeOrder( i)
        local count = self.m_nPMahjongs[order_idx]
        for j = 1, self.m_nPMahjongs[order_idx] do

            if  not self.m_pPMahjongs[order_idx][j].m_bVaild then
                self.m_pPMahjongs[order_idx][j].m_pMahjong:setSameColor( mahjong, self.mahjong_MJZY:getMahjongLaiZi())
            end
        end
    end
end

----------------------------------------------------------------------------
-- 设置相同对象颜色
-- 参数: 数字
function CDLayerTable_mjzy:setSameMahjongWithMyMahjongs( mahjong)
    cclog("CDLayerTable_mjzy:setSameMahjongWithMyMahjongs")

    for i = 1, self.m_nPMahjongs[0] do

        if  self.m_pPMahjongs[0][i].m_pMahjong:isGrey() then
            self.m_pPMahjongs[0][i].m_pMahjong:setGrey(false)
        end
        if  self.m_pPMahjongs[0][i].m_bVaild then
            self.m_pPMahjongs[0][i].m_pMahjong:setSameColor( mahjong, self.mahjong_MJZY:getMahjongLaiZi())
        end
    end
end
----------------------------------------------------------------------------
-- 设置吃的对象颜色
-- 参数: 吃的2张牌
function CDLayerTable_mjzy:setSameMahjongWithChi( mahjong_1,mahjong_2)
    cclog("CDLayerTable_mjzy:setSameMahjongWithChi")
    local check_1 = true
    local check_2 = true
    for i = 1, self.m_nPMahjongs[0] do
        if  self.m_pPMahjongs[0][i].m_bVaild and check_1 then
            local isFind = self.m_pPMahjongs[0][i].m_pMahjong:setSameColorWihtChi( mahjong_1)
            if  isFind then
                check_1 = false
            end
        end
        if  self.m_pPMahjongs[0][i].m_bVaild and check_2 then
            local isFind = self.m_pPMahjongs[0][i].m_pMahjong:setSameColorWihtChi( mahjong_2)
            if  isFind then
                check_2 = false
            end
        end
        
        if not check_1 and not check_2 then
            break
        end
    end
end
--===============================回合相关处理================================-

----------------------------------------------------------------------------
-- 整理牌效果
function CDLayerTable_mjzy:round_arrangeMahjongs()
    cclog("CDLayerTable_mjzy::round_arrangeMahjongs")

    local index = 0
    dtPlaySound( DEF_MJZY_SOUND_MJ_OUT)
    if  self.m_nArrangeType == 0 then

        for i = 0, self.m_nPlayers-1 do

            local order_idx = self:changeOrder( i)
            local size = self.m_nPMahjongs[order_idx]
            for j = 1, size do

                index = MJZY_INDEX_ITOG( order_idx, j)
                self.m_pPMahjongs[order_idx][index].m_pMahjong:setBackVisible( true)
                self.m_pPMahjongs[order_idx][index].m_pMahjong:setFaceVisible( false)
            end
        end

        self.m_nArrangeType = 1
        self:runAction( cc.Sequence:create( cc.DelayTime:create( 0.5), cc.CallFunc:create( CDLayerTable_mjzy.round_arrangeMahjongs)))
    else

        local array = self.m_pPlayAI[0]:getAllVMahjongs()
        local size = 0
        table.sort( array, mahjong_MJZY_table_comps_stb)--显示排序，赖子 与 红中 依次放到最左边

        for i = 0, self.m_nPlayers-1 do

            local order_idx = self:changeOrder( i)
            size = self.m_nPMahjongs[order_idx]
            for j = 1, size do

                index = MJZY_INDEX_ITOG( order_idx, j)
                self.m_pPMahjongs[order_idx][index].m_pMahjong:setBackVisible( false)
                self.m_pPMahjongs[order_idx][index].m_pMahjong:setFaceVisible( true)

                if  order_idx == 0 then
                    self.m_pPMahjongs[order_idx][index].m_nMahjong = array[j].mahjong
                    self.m_pPMahjongs[order_idx][index].m_pMahjong:setMahjong( string.format( "my_b_%u.png", self.m_pPMahjongs[order_idx][index].m_nMahjong))
                    self.m_pPMahjongs[order_idx][index].m_pMahjong:setMahjongNumber( self.m_pPMahjongs[order_idx][index].m_nMahjong)
                    self:myMahjong_setIcoLai( self.m_pPMahjongs[order_idx][index])
                    self.m_pPMahjongs[order_idx][index].m_pMahjong:setIcoTingVisible(false)
                end
            end
        end

        local table_data = casinoclient:getInstance():getTable()
        size = TABLE_SIZE( table_data.players)
        for i = 1, size do

            local table_player = table_data.players[i]
            local order_type = self:changeOrder( self:getTableIndexWithID( table_player.id))
            self:refreshTablePlayer( order_type, table_player)
        end

        self.m_pPlayAI[0]:sortAllVMahjongs( self.mahjong_MJZY)
        self.m_nOrderType = -1
        self:setTimeLeftVisible( true,false)

        if  not casinoclient.getInstance():isSelfBuildTable() then
            self.m_pButRobot:setVisible( true)
            self.m_pButSponsor:setVisible( false)
            --MapLocation
            if  self.m_pButLocation ~= nil then
                self.m_pButLocation:setVisible( false)
            end
        else
            self.m_pButRobot:setVisible( false)
            self.m_pButSponsor:setVisible( true)
            if  self.m_pButLocation ~= nil and self.m_nPlayers==4 then
                self.m_pButLocation:setVisible( true)
            end
        end
    end
end

----------------------------------------------------------------------------
-- 向玩家发牌
function CDLayerTable_mjzy:round_licensingPlayer()
    cclog("CDLayerTable_mjzy::round_licensingPlayer")

    if  self.m_nLicensingType == 0 then -- 开局文字(自建房才有)    
        local effect = CDCCBAniObject.createCCBAniObject(self.m_pMahjongEff, "x_tx_kaiju.ccbi", g_pGlobalManagement:getWinCenter(), 0)
        if  effect then
            effect:endVisible(true)
            effect:endRelease(true)
        end

        self.m_nLicensingType = 1
        self:runAction( cc.Sequence:create(cc.DelayTime:create(0.7), cc.CallFunc:create(CDLayerTable_mjzy.round_licensingPlayer)))
        dtPlaySound(DEF_MJZY_SOUND_MJ_KJ)

    elseif  self.m_nLicensingType == 1 then -- 进入位置(自建房才有）
        for i = 0, self.m_nPlayers - 1 do
            local order_idx = self:changeOrder(i)
            self.m_pPlayer[order_idx].m_pFrame:runAction( 
                cc.Sequence:create(cc.EaseBackOut:create(cc.MoveTo:create(0.3, self.m_pPlayer[order_idx].m_sPosEnd)), cc.ScaleTo:create(0.1, 0.85)))
        end
        self.m_nLicensingType = 2
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(CDLayerTable_mjzy.round_licensingPlayer)))
        
        self.m_pGroupSelfBuild:setVisible(false)

        local e_pos = cc.p(self.m_pGroupBar:getPositionX(), self.m_pGroupBar:getPositionY())
        local b_pos = cc.p(e_pos.x, e_pos.y - 50)
        self.m_pGroupBar:setVisible(true)
        self.m_pGroupBar:setPosition(b_pos)
        self.m_pGroupBar:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.2, e_pos)))
        dtPlaySound(DEF_SOUND_MOVE)

    elseif self.m_nLicensingType == 2 then -- 定庄

        self.m_pPlayer[0].m_pFrame:setVisible(false)
        local zhuang_idx = self:changeOrder(self:getTableIndexWithID(self.m_nLordID))
        if  zhuang_idx >= 0 and zhuang_idx <= self.m_nPlayers then
            if  casinoclient.getInstance():isSelfBuildTable() then
                if  self.m_nSaveLordIdx >= 0 then
                    local zhuang_eff = nil
                    if  self.m_nSaveLordIdx == zhuang_idx then
                        zhuang_eff = CDCCBAniObject.createCCBAniObject(self.m_pMahjongEff, "x_tx_lianzhuang.ccbi", g_pGlobalManagement:getWinCenter(), 0)
                    else
                        zhuang_eff = CDCCBAniObject.createCCBAniObject(self.m_pMahjongEff, "x_tx_huanzhuang.ccbi", g_pGlobalManagement:getWinCenter(), 0)
                    end
                    if  zhuang_eff then
                        zhuang_eff:endRelease( true)
                        zhuang_eff:endVisible( true)
                    end
                end
                self.m_nSaveLordIdx = zhuang_idx
            end

            local zhuang_ico = CDCCBAniObject.createCCBAniObject(self.m_pMahjongEff, "x_tx_zhuang.ccbi", g_pGlobalManagement:getWinCenter(), 0)
            if  zhuang_ico then
                zhuang_ico:endRelease(false)
                zhuang_ico:endVisible(false)

                local e_pos = cc.p(self.m_pPlayer[zhuang_idx].m_pFrame:getPositionX() + 22, self.m_pPlayer[zhuang_idx].m_pFrame:getPositionY() - 20)
                zhuang_ico:runAction(cc.Sequence:create(cc.DelayTime:create(1.2), cc.MoveTo:create(0.3, e_pos)))
                dtPlaySound(DEF_SOUND_ZHUANG)
            end
        end

        self.m_pGroupLeftTop:setVisible(true)
        self.m_nLicensingType = 3
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(CDLayerTable_mjzy.round_licensingPlayer)))

    elseif self.m_nLicensingType == 3 then -- 翻赖子
        local b_pos = cc.p( 0, 0)
        local center= cc.p( 0, 0)

        --  显示赖皮
        if  self.m_pLGMahjong then
            self.m_pLGMahjong:setMahjong(string.format("t_%u.png", self.mahjong_MJZY:getMahjongFan()))
            center = cc.p(g_pGlobalManagement:getWinWidth() * 0.5 - 40, g_pGlobalManagement:getWinHeight() * 0.5)
            b_pos = self.m_pLaiGenDemo:convertToNodeSpace(center)

            self.m_pLGMahjong:setScale(1.2)
            self.m_pLGMahjong:setPosition(b_pos)
            self.m_pLGMahjong:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 0.98)), cc.DelayTime:create(0.3), cc.EaseBackOut:create(cc.MoveTo:create(0.3, cc.p(0, 0)))))
        end

        --  显示赖子
        if  self.m_pLZMahjong then
            self.m_pLZMahjong:setMahjong(string.format("t_%u.png", self.mahjong_MJZY:getMahjongLaiZi()))
            center = cc.p(g_pGlobalManagement:getWinWidth() * 0.5 + 40, g_pGlobalManagement:getWinHeight() * 0.5)
            b_pos = self.m_pLaiZiDemo:convertToNodeSpace(center)

            self.m_pLZMahjong:setScale(0.0)
            self.m_pLZMahjong:setPosition(b_pos)
            self.m_pLZMahjong:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.ScaleTo:create(0.01, 1.2), cc.EaseBackOut:create(cc.ScaleTo:create(0.3, 0.98)), cc.DelayTime:create(0.3), cc.EaseBackOut:create(cc.MoveTo:create(0.5, cc.p(0, 0)))))
            self.m_pLZMahjong:setIcoLaiVisible(false, true)
        end
        dtPlaySound(DEF_SOUND_MJ_OUT)

        self.m_nLicensingOrder = 0
        self.m_nLicensingType = 4
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(CDLayerTable_mjzy.round_licensingPlayer)))

    elseif self.m_nLicensingType == 4 then -- 发牌
        local size = self.m_pPlayAI[self.m_nLicensingOrder]:getVMahjongsSize()
        local index = size - self.m_sLicensingTotal[self.m_nLicensingOrder]
        local number = 0

        if  self.m_sLicensingTotal[self.m_nLicensingOrder] > 0 then
            number = self.m_sLicensingTotal[self.m_nLicensingOrder]
            if  number >= 4 then
                number = 4
            end
        end

        for i = 1, number do
            self.m_pPMahjongs[self.m_nLicensingOrder][MJZY_INDEX_ITOG(self.m_nLicensingOrder, index + i)].m_pMahjong:stopAllActions()
            self.m_pPMahjongs[self.m_nLicensingOrder][MJZY_INDEX_ITOG(self.m_nLicensingOrder, index + i)].m_pMahjong:setScale(1.0)
            self.m_pPMahjongs[self.m_nLicensingOrder][MJZY_INDEX_ITOG(self.m_nLicensingOrder, index + i)].m_pMahjong:setVisible(true)
        end

        dtPlaySound(DEF_MJZY_SOUND_MJ_CLICK)
        self.m_sLicensingTotal[self.m_nLicensingOrder] = self.m_sLicensingTotal[self.m_nLicensingOrder] - number

        local over = true
        for i = 0, self.m_nPlayers - 1 do
            local order_idx = self:changeOrder(i)
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
            self.m_nLicensingOrder = self:changeOrder(self.m_nLicensingOrder)            
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(CDLayerTable_mjzy.round_licensingPlayer)))
        else
            -- 确保所有牌已经正常显示(遍历一边)
            for i = 0, self.m_nPlayers - 1 do
                local order_idx = self:changeOrder(i)
                size = self.m_pPlayAI[order_idx]:getVMahjongsSize()
                for j = 1, size do
                    self.m_pPMahjongs[order_idx][MJZY_INDEX_ITOG(order_idx, j)].m_pMahjong:stopAllActions()
                    self.m_pPMahjongs[order_idx][MJZY_INDEX_ITOG(order_idx, j)].m_pMahjong:setScale(1.0)
                    self.m_pPMahjongs[order_idx][MJZY_INDEX_ITOG(order_idx, j)].m_pMahjong:setVisible(true)
                end
            end

            -- 定位显示MapLocation
            if  casinoclient.getInstance():isSelfBuildTable() then
                if self.m_nPlayers == 4 then
                    local data = casinoclient.getInstance():getTable()
                    if  data.play_total == 0 then -- 第一局主动显示定位
                        self:getAllPositionInfo()
                        self:showLocation(true, true, true)
                    end
                end
            end

            -- 进入到下一个阶段round_arrangeMahjongs
            self.m_nArrangeType = 0        
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(CDLayerTable_mjzy.round_arrangeMahjongs)))
        end
    end
end

----------------------------------------------------------------------------
-- 预创建麻将牌
function CDLayerTable_mjzy:preCreateMahjong()
    cclog( "CDLayerTable_mjzy:preCreateMahjong")

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
        for i = 1, DEF_MJZY_MAX_GETMAHJONG do

            local mahjong = X_MAHJONG:new()
            if  order_idx == 0 then
                mahjong.m_pMahjong = CDMahjong.createCDMahjong( self.m_pCenterDemo[0])
            else
                mahjong.m_pMahjong = CDMahjong.createCDMahjong( self.m_pMahjongOwn)
            end
            mahjong.m_nMahjong = 11
            mahjong.m_pMahjong:setMahjongNumber( 11)
            if     order_idx == 0 then
                mahjong.m_pMahjong:initMahjongWithFile( "my_b_11.png",   "mj_b_back.png",nil,DEF_CASINO_MJZY)
            elseif order_idx == 1 then
                mahjong.m_pMahjong:initMahjongWithFile( "mj_r_side.png", "mj_lr_back.png",nil,DEF_CASINO_MJZY)
            elseif order_idx == 2 then
                mahjong.m_pMahjong:initMahjongWithFile( "mj_s_def.png",  "mj_s_back.png",nil,DEF_CASINO_MJZY)
            elseif order_idx == 3 then
                mahjong.m_pMahjong:initMahjongWithFile( "mj_l_side.png", "mj_lr_back.png",nil,DEF_CASINO_MJZY)
            end
            mahjong.m_pMahjong:setVisible( false)
            mahjong.m_pMahjong:setScale( 1.0)
            mahjong.m_pMahjong:setMahjongScale( 1.0)
            table.insert( self.m_pPMahjongs[order_idx], mahjong)
        end

        -- 打出的牌
        for i = 1, nMaxOutMahjongs do

            local pMahjong = CDMahjong.createCDMahjong( self.m_pMahjongOut)
            if  pMahjong ~= nil then

                if     order_idx == 0 then
                    pMahjong:initMahjongWithFile( string.format( "t_%u.png", 11),nil,nil,DEF_CASINO_MJZY)
                    pMahjong:setMahjongScale( DEF_MJZY_BT_OUTSCALE)
                elseif order_idx == 1 then
                    pMahjong:initMahjongWithFile( string.format( "l_%u.png", 11),nil,nil,DEF_CASINO_MJZY)
                    pMahjong:setMahjongScale( DEF_MJZY_LR_OUTSCALE)
                elseif order_idx == 2 then
                    pMahjong:initMahjongWithFile( string.format( "t_%u.png", 11),nil,nil,DEF_CASINO_MJZY)
                    pMahjong:setMahjongScale( DEF_MJZY_BT_OUTSCALE)
                elseif order_idx == 3 then
                    pMahjong:initMahjongWithFile( string.format( "r_%u.png", 11),nil,nil,DEF_CASINO_MJZY)
                    pMahjong:setMahjongScale( DEF_MJZY_LR_OUTSCALE)
                end

                pMahjong:setTag( (order_idx+1)*DEF_MJZY_OUT_IDX+i)
                pMahjong:setVisible( false)
            end
        end
    end

    -- 听牌预创建
    if  self.m_pTingGroup ~= nil and self.m_pTingList ~= nil then
    
        self.m_pTingList:removeAllChildren()
        for i = 1, DEF_MJZY_TING_LIST_MAX do

            self.m_pTingMahjong[i] = CDMahjong.createCDMahjong( self.m_pTingList)
            self.m_pTingMahjong[i]:initMahjongWithFile( "mj_b_back.png",nil,nil,DEF_CASINO_MJZY)
            self.m_pTingMahjong[i]:setVisible( false)
            self.m_pTingMahjong[i]:setScale( 0.85)

            self.m_pTingNumText[i]:setVisible( false)
            self.m_pTingNumFrame[i]:setVisible( false)
        end
        self.m_pTingGroup:setVisible( false)
    end

    -- 杠牌预创建 
    if  self.m_pGangGroup and self.m_pGangList then
        self.m_pGangList:removeAllChildren()
        for i=1,DEF_MJZY_GANG_LIST_MAX do
            self.m_pGangMahjong[i] = CDMahjong.createCDMahjong( self.m_pGangList)
            self.m_pGangMahjong[i]:initMahjongWithFile( "mj_b_back.png",nil,nil,DEF_CASINO_MJZY)
            self.m_pGangMahjong[i]:setVisible( false)
            self.m_pGangMahjong[i]:setScale( 0.65)
        end
        self.m_pGangGroup:setVisible( false)
    end

    -- 演示牌预创建
    if  self.m_pOutMahjongGroup ~= nil and self.m_pOutMahjong == nil then

        self.m_pOutMahjong = X_MAHJONG:new()
        self.m_pOutMahjong.m_pMahjong = CDMahjong.createCDMahjong( self.m_pOutMahjongGroup)
        self.m_pOutMahjong.m_nMahjong = 11

        self.m_pOutMahjong.m_pMahjong:initMahjongWithFile( "out_b_11.png", "mj_b_back.png",nil,DEF_CASINO_MJZY)
        self.m_pOutMahjong.m_pMahjong:setMahjongNumber( self.m_pOutMahjong.m_nMahjong)
        self.m_pOutMahjong.m_pMahjong:setMahjongScale( 0.85)
    end

    -- 赖子赖皮
    if  self.m_pLaiZiDemo then

        self.m_pLZMahjong = CDMahjong.createCDMahjong( self.m_pLaiZiDemo)
        self.m_pLZMahjong:initMahjongWithFile( "t_11.png", "mj_b_back.png",nil,DEF_CASINO_MJZY)
        self.m_pLZMahjong:setScale( 0.0)
        self.m_pLZMahjong:setIcoLaiVisible( false, true)
    end
    if  self.m_pLaiGenDemo then

        self.m_pLGMahjong = CDMahjong.createCDMahjong( self.m_pLaiGenDemo)
        self.m_pLGMahjong:initMahjongWithFile( "t_11.png", "mj_b_back.png",nil,DEF_CASINO_MJZY)
        self.m_pLGMahjong:setScale( 0.0)
    end

    -- 麻将操作预创建
    self.m_pMahjongBut = {}         -- 麻将操作按钮
    for i = 1, DEF_MJZY_MAHJONG_MAX_BUT do

        self.m_pMahjongBut[i] = {}
        self.m_pMahjongBut[i].m_nMahjong = 0
        self.m_pMahjongBut[i].m_pEffect = CDCCBAniObject.createCCBAniObject( self.m_pCenterDemo[0], "x_tx_but_huang.ccbi", cc.p( 0, 0), 0)
        if  self.m_pMahjongBut[i].m_pEffect ~= nil then

            self.m_pMahjongBut[i].m_pEffect:endRelease( false)
            self.m_pMahjongBut[i].m_pEffect:endVisible( false)
            self.m_pMahjongBut[i].m_pEffect:setVisible( false)
        end
        self.m_pMahjongBut[i].m_bVaild = false
    end

    -- 吃牌与创建
    if self.m_pChiGroup and self.m_nChiList then
        self.m_nChiList:removeAllChildren()
        for i=1,DEF_MJZY_CHI_LIST_MAX do
            for j=1,3 do
                self.m_pChiFarme[i]["m_pChiFarme"..j] = CDMahjong.createCDMahjong( self.m_nChiList)
                self.m_pChiFarme[i]["m_pChiFarme"..j]:initMahjongWithFile("mj_b_back.png")
                self.m_pChiFarme[i]["m_pChiFarme"..j]:setVisible( false)
                self.m_pChiFarme[i]["m_pChiFarme"..j]:setScale( DEF_MJZY_BT_OUTSCALE)
            end
        end
        self.m_pChiGroup:setVisible(false)
    end
    self.m_bPreCreate = true
end

----------------------------------------------------------------------------
-- 发牌
function CDLayerTable_mjzy:round_startLicensing()
    cclog("CDLayerTable_mjzy::round_startLicensing")

    -- 发牌需要的数据记录
    for i = 0, self.m_nPlayers - 1 do
        local order_idx = self:changeOrder(i)
        self.m_sLicensingTotal[order_idx] = self.m_pPlayAI[order_idx]:getVMahjongsSize()

        -- 设置摸到的牌        
        for j = 1, DEF_MJZY_DEF_MAHJONGS do
            self.m_nPMahjongs[order_idx] = j

            local pMahjong = self.m_pPMahjongs[order_idx][MJZY_INDEX_ITOG(order_idx, j)]
            pMahjong.m_nMahjong = self.m_pPlayAI[order_idx]:getVMahjong(j)
            pMahjong.m_pMahjong:setMahjongNumber(pMahjong.m_nMahjong)
            if  order_idx == 0 then
                pMahjong.m_pMahjong:setMahjong(string.format("my_b_%u.png", pMahjong.m_nMahjong))
            end
        end

        -- 重置桌子
        self:resetTableMahjongs(order_idx)

        -- 准备图标隐藏
        self.m_pPlayer[order_idx].m_pIcoReady:setVisible(false)
    end

    -- 最后一张牌标记
    if  self.m_pEffFlagLast == nil then
        self.m_pEffFlagLast = CDCCBAniObject.createCCBAniObject(self.m_pMahjongEff, "x_tx_last.ccbi", cc.p(0, 0), 0)

        if  self.m_pEffFlagLast ~= nil then
            self.m_pEffFlagLast:endRelease(false)
            self.m_pEffFlagLast:endVisible(false)
            self.m_pEffFlagLast:setVisible(false)
        end
    end

    -- 开始动态发牌
    self:stopAllActions()
    self.m_nLicensingType = 2
    if  self.m_pPlayer[0].m_pFrame:isVisible() then
        self.m_nLicensingType = 0
    end
    self:round_licensingPlayer()
end

----------------------------------------------------------------------------
-- 出牌处理效果(自己)
-- 参数: 所出的牌索引
function CDLayerTable_mjzy:round_SendOutMahjong( index)
    cclog( "CDLayerTable_mjzy:round_OutMahjong_self(index[%u])", index)

    dtPlaySound( DEF_MJZY_SOUND_MJ_OUT)
    if  index > 0 and index <= DEF_MJZY_MAX_GETMAHJONG then

        mahjong = self.m_pPMahjongs[0][index].m_nMahjong
        
        --发送消息等待确认

        if self.m_bPaoFeng then
            if self.m_nPaoFengType == 3 and self.m_nPaoFengOutMah == 0 then
                self.m_nPaoFengOutMah = mahjong
            end
            print("self.m_nPaoFengOutMah--------->",self.m_nPaoFengOutMah)
            casinoclient:getInstance():mjzy_sendOpReq(DEF_MJZY_FANGFENG,mahjong,nil,2)
            self.m_bPaoFeng = false
            self.m_bCanOutMahjong = false
        else
            self:round_OutMahjongShow_Self( mahjong) -- 表现
            casinoclient:getInstance():mjzy_sendOutCardReq( mahjong)
        end
        dtOpenWaiting( self)
        self.m_bMoveSelect = false
    end
end

----------------------------------------------------------------------------
-- 出牌(自己)前半段
-- 参数: mahjong牌
function CDLayerTable_mjzy:round_OutMahjongShow_Self( mahjong)
    cclog( "CDLayerTable_mjzy:round_OutMahjongShow_FSelf mahjong = (%u)", mahjong)

    -- 打出的牌放下后的处理
    local function playOutMahjongSound_self()

        dtPlaySound( DEF_MJZY_SOUND_MJ_OUT)
        self:showLastMahjongFlag( true)

        if  self.m_nLastOutMahjongTag <= 0 then
            return
        end

        local child = self.m_pMahjongOut:getChildByTag( self.m_nLastOutMahjongTag)
        if  child == nil then
            return
        end

        -- if  child:isLaiZi( self.mahjong_MJZY:getMahjongLaiZi()) then
        --     local curEffect = "x_lz_gang.ccbi"
        --     local pos = cc.p( child:getPositionX(), child:getPositionY())
        --     local eff = CDCCBAniObject.createCCBAniObject( self, curEffect, pos, 0)
        --     if  eff ~= nil then
        --         self.m_pEffFlagLast:endRelease( true)
        --         self.m_pEffFlagLast:endVisible( true)
        --     end
        --     dtPlaySound( DEF_MJZY_SOUND_MJ_LZ_PIAO)
        -- end

    end

    self.m_sOutNumber[0] = self.m_sOutNumber[0]+1
    self:changeNowOutMahjongs( 0) -- 新增加
    -- 找到与创建牌后使用
    local nTag = DEF_MJZY_OUT_IDX+self.m_sOutNumber[0]
    local pMahjong = self.m_pMahjongOut:getChildByTag( nTag)
    if  pMahjong then

        pMahjong:setMahjong( string.format( "t_%u.png", mahjong))
        pMahjong:setMahjongNumber( mahjong)
        self.m_nLastOutMahjongTag = nTag
        if  mahjong == self.mahjong_MJZY:getMahjongLaiZi() then-- or mahjong == 51 then
            pMahjong:setLaiZiColor()
        end
        local index = self:myMahjong_getIndexWithOutMahjong( mahjong)
        self.m_pPMahjongs[0][index].m_pMahjong:setScale( 0.0)
        local start = cc.p( self.m_pPMahjongs[0][index].m_pMahjong:getPositionX(), self.m_pPMahjongs[0][index].m_pMahjong:getPositionY())
        start = self.m_pCenterDemo[0]:convertToWorldSpace( start)

        local toPos = cc.p( 0, 0)
        local x_total = self:changeXMahjongs()
        local nWarp = math.floor( (self.m_sOutNumber[0]-1)/x_total)
        local nNum = (self.m_sOutNumber[0]-1)%x_total
        toPos = cc.p(   self.m_sOutStart[0].x + nNum * self.m_sOutSpace[0].x + nWarp * self.m_sOutWrap[0].x, 
                        self.m_sOutStart[0].y + nNum * self.m_sOutSpace[0].y + nWarp * self.m_sOutWrap[0].y)

        pMahjong:setVisible( true)
        pMahjong:setMahjongScale( DEF_MJZY_BT_OUTSCALE)
        pMahjong:setPosition( start)
        pMahjong:setScale( 1.25)
        pMahjong:stopAllActions()
        pMahjong:runAction( cc.Sequence:create( cc.MoveTo:create( 0.15, toPos), cc.ScaleTo:create( 0.15, 1), 
            cc.CallFunc:create( playOutMahjongSound_self)))
    end
    self.m_sOutNumber[0] = self.m_sOutNumber[0]-1
    self.m_bSaveSlfFlag = true
end

----------------------------------------------------------------------------
-- 重登后的－出牌(前半段)表现
-- 参数: mahjong牌, order_type位置
function CDLayerTable_mjzy:reset_OutMahjongShow_Front( mahjong, order_type)

    if  order_type < 0 or mahjong <= 0 then
        return
    end

    -- 大牌显示，打出的牌
    self.m_pOutMahjong.m_pMahjong:setMahjong( string.format( "my_b_%u.png", mahjong))
    self.m_pOutMahjong.m_pMahjong:setMahjongNumber( mahjong)
    self.m_pOutMahjong.m_nMahjong = mahjong
    self:myMahjong_setIcoLai( self.m_pOutMahjong)

    local start = cc.p( 0, 0)
    local pos = cc.p( self.m_pOutDemo[order_type]:getPositionX(), self.m_pOutDemo[order_type]:getPositionY())

    self.m_pOutMahjongGroup:stopAllActions()
    self.m_pOutMahjongGroup:setVisible( true)
    self.m_pOutMahjongGroup:setPosition( start)
    self.m_pOutMahjongGroup:setScale( 1.0)
    self.m_pOutMahjongGroup:runAction( cc.EaseBackOut:create( cc.MoveTo:create( 0.15, pos)))

end
-----------------------------------------------------------------------------
-- 添加放风牌
-- 参数：玩家位置，放风牌索引位置(1开始），牌数值，放风还是跑风,是否需要特效, 动画等待时间
function CDLayerTable_mjzy:round_addFangFengMah( order_type, index, mahjong,isFf_Or_Pf ,bEff, waitTime)

    if  bEff == nil then
        bEff = false
    end
    if  waitTime == nil then
        waitTime = 0.0
    end

    local sBPos = cc.p( 0, 0)
    local sEPos = cc.p( 0, 0)

    -- local hSpace = 40
    -- local vSpace = 40
    local hSpace = 40
    local vSpace = 35

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
        if index > 8 then
            sEPos = cc.p(self.m_pPlayer[order_type].tab_fangFeng_space.x +11 , 
                          self.m_pPlayer[order_type].tab_fangFeng_space.y - vSpace*((index-8)+offsetIndex))
        else
            sEPos = cc.p( self.m_pPlayer[order_type].tab_fangFeng_space.x , 
                          self.m_pPlayer[order_type].tab_fangFeng_space.y - vSpace*(index+offsetIndex))
        end
        sBPos = cc.p( sEPos.x - 30, sEPos.y)
    elseif order_type ==1 then
        if index > 8 then
            sEPos = cc.p(self.m_pPlayer[order_type].tab_fangFeng_space.x-11,
                         self.m_pPlayer[order_type].tab_fangFeng_space.y + vSpace*((index-8)+offsetIndex))
        else
            sEPos = cc.p( self.m_pPlayer[order_type].tab_fangFeng_space.x , 
                          self.m_pPlayer[order_type].tab_fangFeng_space.y + vSpace*(index+offsetIndex))
        end
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
        hua_ico:setScale(0.8)
    elseif order_type == 3 then
        hua_ico:setRotation(90)
        hua_ico:setScale(0.8)
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
-- 出牌(前半段)
-- 参数: mahjong牌, order_type位置
function CDLayerTable_mjzy:round_OutMahjongShow_Front( mahjong, order_type)
    cclog( "CDLayerTable_mjzy:round_OutMahjongShow_Front mahjong = (%u)", mahjong)

    if  order_type < 0 then
        return
    end

    -- 大牌显示，打出的牌
    self.m_pOutMahjong.m_pMahjong:setMahjong(string.format("my_b_%u.png", mahjong))
    self.m_pOutMahjong.m_pMahjong:setMahjongNumber(mahjong)
    self.m_pOutMahjong.m_nMahjong = mahjong
    self:myMahjong_setIcoLai(self.m_pOutMahjong)

    local start = cc.p(0, 0)
    local index = 0
    local size = 0
    if  order_type == 0 then
        index = self:myMahjong_getIndexWithOutMahjong(mahjong)
        if  index > 0 then
            index = MJZY_INDEX_ITOG(0, index)
            start = cc.p(self.m_pPMahjongs[0][index].m_pMahjong:getPositionX(), self.m_pPMahjongs[0][index].m_pMahjong:getPositionY())
            start = self.m_pCenterDemo[0]:convertToWorldSpace(start)
        end

    else
        index = self.m_nPMahjongs[order_type]
        index = MJZY_INDEX_ITOG(order_type, index)
        start = cc.p(self.m_pPMahjongs[order_type][index].m_pMahjong:getPositionX(),
                     self.m_pPMahjongs[order_type][index].m_pMahjong:getPositionY())
    end
    local pos = cc.p(self.m_pOutDemo[order_type]:getPositionX(), self.m_pOutDemo[order_type]:getPositionY())

    self.m_pOutMahjongGroup:stopAllActions()
    self.m_pOutMahjongGroup:setVisible(true)
    self.m_pOutMahjongGroup:setPosition(start)
    self.m_pOutMahjongGroup:setScale(1.0)
    self.m_pOutMahjongGroup:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.15, pos)))

    -- 玩家出牌数量加1，并且朗读牌面，记录出牌索引及牌
    self.m_sOutNumber[order_type] = self.m_sOutNumber[order_type] + 1
    self:changeNowOutMahjongs(order_type) -- 新增加
    self:readMahjong(mahjong, 0, order_type)
    self.m_nOutMahjong_p = order_type
    self.m_nOutMahjong_m = mahjong

    -- 假如是自己那么删除打出的牌，别人隐藏最后一张牌
    if  order_type == 0 then
        self.m_pPlayAI[0]:delVMahjong(self.m_pPMahjongs[0][index].m_nMahjong)
        self:round_delMahjong(0)

        self:myMahjongs_refresh()
        self:resetTableMahjongs(0)
    else
        self.m_pPlayAI[order_type]:delVMahjongWithIndex(1)
        self:round_delMahjong(order_type)
    end
end

----------------------------------------------------------------------------
-- 出牌(后半段)
-- 参数: mahjong牌, order_type位置
function CDLayerTable_mjzy:round_OutMahjongShow_Back( op_ack)
    cclog( "CDLayerTable_mjzy:round_OutMahjongShow_Back ok_ack = (%u)", op_ack)

    -- 打出的牌放下后的处理
    local function playOutMahjongSound()
        dtPlaySound( DEF_MJZY_SOUND_MJ_OUT)
        self:showLastMahjongFlag(true)

        if  self.m_nLastOutMahjongTag <= 0 then
            return
        end

        local child = self.m_pMahjongOut:getChildByTag(self.m_nLastOutMahjongTag)
        if  child == nil then
            return
        end

        -- if  child:isLaiZi(self.mahjong_MJZY:getMahjongLaiZi()) then
        --     local curEffect = "x_lz_gang.ccbi"
        --     local pos = cc.p(child:getPositionX(), child:getPositionY())
        --     local eff = CDCCBAniObject.createCCBAniObject(self, curEffect, pos, 0)
        --     if  eff ~= nil then
        --         self.m_pEffFlagLast:endRelease(true)
        --         self.m_pEffFlagLast:endVisible(true)
        --     end
        --     dtPlaySound(DEF_MJZY_SOUND_MJ_LZ_PIAO)
        -- end 
      
    end

    self.m_pOutMahjongGroup:setVisible(false)
    if  self.m_nOutMahjong_p < 0 or self.m_nOutMahjong_m == 0 then
        return
    end
    local order_type = self.m_nOutMahjong_p
    local mahjong = self.m_nOutMahjong_m

    -- 碰、点笑、笑朝天 吃 不进行牌放出，直接返回
    if  op_ack == DEF_MJZY_PENG + 1000 or 
        op_ack == DEF_MJZY_CHI + 1000 or
        op_ack == casino_mjzy.MJZY_OP_TYPE_DIANXIAO or 
        op_ack == casino_mjzy.MJZY_OP_TYPE_XIAOCHAOTIAN then

        self.m_nOutMahjong_p = -1
        self.m_nOutMahjong_m = 0
        self.m_bSaveSlfFlag = false
        return
    end

    -- 找到与创建牌后使用
    local number = self:getPlayerOutNumber(order_type)
    local nTag = (order_type + 1) * DEF_MJZY_OUT_IDX + number
    local pMahjong = self.m_pMahjongOut:getChildByTag(nTag)
    if  pMahjong then
        if     order_type == 0 then
            -- 是自己的话那么这里退出，因为进入这里只是为了纠正打出的牌而已
            if  self.m_bSaveSlfFlag then
                if  pMahjong:getMahjongNumber() ~= mahjong then
                    pMahjong:setMahjong(string.format("t_%u.png", mahjong))
                    pMahjong:setMahjongNumber(mahjong)
                end
                self.m_bSaveSlfFlag = false
                return
            else
                pMahjong:setMahjong(string.format("t_%u.png", mahjong))
            end
            pMahjong:setMahjongScale(DEF_MJZY_BT_OUTSCALE)

        elseif order_type == 1 then
            pMahjong:setMahjong(string.format("l_%u.png", mahjong))
            pMahjong:setMahjongScale(DEF_MJZY_LR_OUTSCALE)

        elseif order_type == 2 then
            pMahjong:setMahjong(string.format("t_%u.png", mahjong))
            pMahjong:setMahjongScale(DEF_MJZY_BT_OUTSCALE)

        elseif order_type == 3 then
            pMahjong:setMahjong(string.format("r_%u.png", mahjong))
            pMahjong:setMahjongScale(DEF_MJZY_LR_OUTSCALE)
        end

        pMahjong:setMahjongNumber(mahjong)
        self.m_nLastOutMahjongTag = nTag
        if  mahjong == self.mahjong_MJZY:getMahjongLaiZi() then -- or mahjong == 51 then
            pMahjong:setLaiZiColor()
        end

        local w_total = self:changeXMahjongs()
        local start = cc.p(self.m_pOutMahjongGroup:getPositionX(), self.m_pOutMahjongGroup:getPositionY())
        local toPos = cc.p(0, 0)
        local nWarp = math.floor((number - 1) / w_total)
        local nNum = (number - 1) % w_total

        toPos = cc.p(self.m_sOutStart[order_type].x + nNum * self.m_sOutSpace[order_type].x + nWarp * self.m_sOutWrap[order_type].x, 
                     self.m_sOutStart[order_type].y + nNum * self.m_sOutSpace[order_type].y + nWarp * self.m_sOutWrap[order_type].y)

        pMahjong:setVisible(true)

        -- 假如op不是胡那么播放牌动画，否则直接放下牌
        if  op_ack ~= DEF_MJZY_HU + 1000 and op_ack ~= DEF_MJZY_ZIMO + 1000 then
            pMahjong:setPosition(start)
            pMahjong:setScale(1.25)
            pMahjong:stopAllActions()
            pMahjong:runAction(cc.Sequence:create( 
                cc.MoveTo:create(0.15, toPos), cc.ScaleTo:create(0.15, 1), cc.CallFunc:create(playOutMahjongSound)))

        else
            pMahjong:setPosition(toPos)
            pMahjong:setScale(1.0)
            playOutMahjongSound()
        end
    end
end

function CDLayerTable_mjzy:setAllPlayerData( ... )
    local allPlayerData = {}
    for i = 0, self.m_nPlayers-1 do
        local curPlayerData = {}
        local order_idx = self:changeOrder( i)
        curPlayerData.outGroup = self.m_pPlayAI[order_idx]:getNMahjong()
        curPlayerData.putGroup = self.m_pPlayAI[order_idx]:getOutCards()
        allPlayerData[order_idx]=curPlayerData
    end

    return allPlayerData
end

----------------------------------------------------------------------------
--提示平胡不能胡（用户客户端显示）
function CDLayerTable_mjzy:canNotHu(  )
    
    local bOldVis = self.m_pGroupForgo:isVisible()
    self.m_pForgoMessage:setString( casinoclient:getInstance():findString("cannothu_nokk") )
    self.m_pForgoMessage:setColor(cc.c3b(254,253,223))
    self.m_pGroupForgo:setVisible(true)
    if  not bOldVis then
        self.m_pGroupForgo:setScale( 0.3)
        self.m_pGroupForgo:runAction( cc.EaseBackOut:create( cc.ScaleTo:create( 0.2, 1)))
    end
    
end

-- 回合思考 
function CDLayerTable_mjzy:round_MyThink()
    cclog("CDLayerTable_mjzy::round_MyThink")

    self:setCanOutCards(true)

    self.m_bCanOutMahjong = true -- 可以选择出牌

    self.m_bSaveZCHFlag = false
    self.m_bOPSelf = false

    self.m_bSaveOPGFlag = false
    self.m_nSaveOPGMahjong = 0 

    self.m_bSaveOPPFlag = false
    self.m_nSaveOPPMahjong = 0


    self.canhuNow = false

    for i = 1, DEF_MJZY_BUT_TYPE_PAOFENG do

        self.m_pBut_Type[i]:setGrey( true)
        self.m_pBut_Text[i]:setGrey( true)
    end

    local bVisible = false
    local bWinning = false

    --是否能跑风
    --重新计算self.m_nPaoFengType
    self.m_nPaoFengType = self.mahjong_MJZY:judgePaoFengMah(self.m_FangFengArr)
    self.m_nPaoFengArr = {}
    self.m_nPaoFengArr = self.mahjong_MJZY:findPaoFMahByType(self.m_pPlayAI[0]:getAllVMahjongs(),self.m_nPaoFengType,self.m_nPaoFengOutMah)
    print("self.m_nPaoFengType--------->",self.m_nPaoFengType)
    print("self.m_nPaoFengOutMah----->",self.m_nPaoFengOutMah)
    dumpArray(self.m_nPaoFengArr)
    if TABLE_SIZE(self.m_nPaoFengArr) > 0 and TABLE_SIZE(self.m_FangFengArr) == 3 then
        self.m_pBut_Type[DEF_MJZY_BUT_TYPE_PAOFENG]:setGrey(false)
        self.m_pBut_Text[DEF_MJZY_BUT_TYPE_PAOFENG]:setGrey(false)
        bVisible = true
    end

    if  self.m_bCanCheck then
        if  self.mahjong_MJZY:canHuPai(self.m_pPlayAI[0]:getAllVMahjongs()) then
    
            self.m_pBut_Type[DEF_MJZY_BUT_TYPE_HU]:setGrey(false)
            self.m_pBut_Text[DEF_MJZY_BUT_TYPE_HU]:setGrey(false)
            
            self.canhuNow = true
            bVisible = true
            bWinning = true
        end
    end

    -- 底牌大于最后牌剩余牌数量才能做杠牌判断
    if self.m_bCanCheck then
        if  self.mahjong_MJZY:mahjongTotal_get() >= DEF_MJZY_GANG_CARDS then
    
            local can_gang, array = self.mahjong_MJZY:canGangPai_withAll( 
                self.m_pPlayAI[0]:getAllVMahjongs(), self.m_pPlayAI[0]:getAllSMahjongs(), 
                nil, self:myMahjong_getHuangButtons(),self.m_nLastMoMahjong)
    
            if  can_gang  then
                self:setSameMahjongWithMyMahjongs( array[1])
            
                self.m_bSaveOPGFlag = true
                self.m_nSaveOPGMahjong = array[1]
            
                self.m_pBut_Type[DEF_MJZY_BUT_TYPE_GANG]:setGrey( false)
                self.m_pBut_Text[DEF_MJZY_BUT_TYPE_GANG]:setGrey( false)
    
                bVisible = true
            end
            self:myMahjong_vaildHuangButton( true) --晃晃牌按钮激活 
        end
    end
    -- 当听牌状态下需要不破坏听才可以杠
    self:setGroupButtonVisible( bVisible)
    self.m_bCanCheck = true 
    -- self:checkHuTypeWithText(false)

end

-- 测试牌型
-- function CDLayerTable_mjzy:checkHuTypeWithText( isZC,curMahjong )
--     if  isZC then
--         local curHandCards = self.mahjong_MJZY:getValueFromArr(self.m_pPlayAI[0]:getAllVMahjongs())
--         local curOutCards = self.mahjong_MJZY:getValueFromArr(self.m_pPlayAI[0]:getAllSMahjongs())
--         self.mahjong_MJZY:push_mahjong(curHandCards,curMahjong)
--         self.mahjong_MJZY:defMahjongSort_stb(curHandCards)
--         local curType = self.mahjong_MJZY:getAllType(curHandCards,curOutCards,DEF_MJZY_TYPE_ZC)
--         for i,v in ipairs(curType) do
--             print("zc...v.type---->",v.type)
--         end
--     else
--         local curHandCards = self.mahjong_MJZY:getValueFromArr(self.m_pPlayAI[0]:getAllVMahjongs())
--         local curOutCards = self.mahjong_MJZY:getValueFromArr(self.m_pPlayAI[0]:getAllSMahjongs())
--         local curType = self.mahjong_MJZY:getAllType(curHandCards,curOutCards,DEF_MJZY_TYPE_ZM)
--         for i,v in ipairs(curType) do
--             print("zm...v.type---->",v.type)
--         end
--     end
-- end

----------------------------------------------------------------------------
-- 回合操作可能判断
-- 参数: 打出牌的玩家的id 吃 需要 只能吃上家的牌
function CDLayerTable_mjzy:round_MyOPThink(target_id,my_op,canchi)
    if  my_op and my_op == DEF_MJZY_CHI then
        canchi = true
    end

    self.m_bSaveZCHFlag = false
    
    self.m_bSaveOPGFlag = false
    self.m_nSaveOPGMahjong = 0

    self.m_bSaveOPPFlag = false
    self.m_nSaveOPPMahjong = 0

    local bVisible = false

    for i = 1, DEF_MJZY_BUT_TYPE_PAOFENG do

        self.m_pBut_Type[i]:setGrey( true)
        self.m_pBut_Text[i]:setGrey( true)
    end
    -- 可否胡牌
    local index = self:changeOrder( self:getTableIndexWithID(target_id))
    local bHu, vecHuPai = self.m_pPlayAI[0]:canHu_WithOther( self.mahjong_MJZY, self.m_nLastOutMahjong)
    print("=============round_MyOPThink===============")
    print("bHu",bHu)
    print("=============round_MyOPThink===============")
    if  bHu then

        self.m_bSaveZCHFlag = true
        self.m_pBut_Type[DEF_MJZY_BUT_TYPE_HU]:setGrey( false)
        self.m_pBut_Text[DEF_MJZY_BUT_TYPE_HU]:setGrey( false)
        bVisible = true
        -- self:checkHuTypeWithText(true,self.m_nLastOutMahjong)
    end
    -- 可否杠牌
    local bGang, vecGang = self.m_pPlayAI[0]:canGang_WithOther( self.mahjong_MJZY, self.m_nLastOutMahjong)
    if  bGang then
        if  self.mahjong_MJZY:mahjongTotal_get() >= DEF_MJZY_GANG_CARDS then
            
            self.m_pBut_Type[DEF_MJZY_BUT_TYPE_GANG]:setGrey( false)
            self.m_pBut_Text[DEF_MJZY_BUT_TYPE_GANG]:setGrey( false)

            self.m_bSaveOPGFlag = true
            self.m_nSaveOPGMahjong = vecGang[1]

            self:setSameMahjongWithMyMahjongs( vecGang[1])
            bVisible = true
        end
    end
    -- 可否碰牌
    local bPeng, vecPeng = self.m_pPlayAI[0]:canPeng_WithOther( self.mahjong_MJZY, self.m_nLastOutMahjong)
    if  bPeng then
       
        self.m_pBut_Type[DEF_MJZY_BUT_TYPE_PENG]:setGrey( false)
        self.m_pBut_Text[DEF_MJZY_BUT_TYPE_PENG]:setGrey( false)

        self.m_bSaveOPPFlag = true
        self.m_nSaveOPPMahjong = vecPeng[1]

        self:setSameMahjongWithMyMahjongs( vecPeng[1])
        bVisible = true
    end
    -- 是否可以吃
    if  self:lastPlayer(target_id) and canchi then 

        local bChi,vecChi = self.mahjong_MJZY:canChi(self.m_pPlayAI[0]:getAllVMahjongs(),self.m_nLastOutMahjong)
        if  bChi then
            self.m_pcanChi = true
            self.m_pChiList = {}
    
            self.m_nSaveOPCMahjong = self.m_nLastOutMahjong
            self.m_pBut_Type[DEF_MJZY_BUT_TYPE_CHI]:setGrey(false)
            self.m_pBut_Text[DEF_MJZY_BUT_TYPE_CHI]:setGrey(false)
        
            self.m_pChiList = vecChi
            local canChiLast = true
            if  TABLE_SIZE(self.m_pChiList) == 1 then
                local curTable = self.mahjong_MJZY:getOwnArrFromArr(self.m_pChiList[1],self.m_nLastOutMahjong)
                local index_1,index_2 = self.mahjong_MJZY:getPaiFromArr(curTable)
                self:setSameMahjongWithChi(index_1,index_2)
            end
            bVisible = true
        end
    end
    self:setGroupButtonVisible( bVisible)
end

----------------------------------------------------------------------------
-- 吃牌
function CDLayerTable_mjzy:onChiPai( ... )
    cclog("CDLayerTable_mjzy::onChiPai")
    if  self.m_pGroupButton:isVisible() and 
        (not self.m_pBut_Type[DEF_MJZY_BUT_TYPE_CHI]:isGrey()) then
        self:onShowChiList()
    end
end

-- 结束后清空吃的列表 并且隐藏
function CDLayerTable_mjzy:onChiEnd( ... )

    self.m_pChiList = {}

    for i=1,DEF_MJZY_CHI_LIST_MAX do

        self.m_pChiFarme[i].m_pChiButton:setVisible(false)
        for j=1,3 do

            self.m_pChiFarme[i]["m_pChiFarme"..j]:setVisible( false)
        end
    end

    self.m_pChiGroup:setVisible(false)
end

-- 显示自己手中组成吃的牌
function CDLayerTable_mjzy:getChiPaiFromOwn( index )
    local arr = {}
    if index and self.m_pChiList[index] and self.m_nSaveOPCMahjong ~=0 then
        
        for i,v in ipairs(self.m_pChiList[index]) do
            if v ~= self.m_nSaveOPCMahjong then
                arr[TABLE_SIZE(arr)+1] = v
            end
        end 
    end

    return arr
end

function CDLayerTable_mjzy:onChi_Group_one( ... )
    cclog("CDLayerTable_mjzy::onChi_Group_one")
    if  self.m_pChiList[1] then

        self:getSendData(1)
    end
    self:onChiEnd()
end

function CDLayerTable_mjzy:onChi_Group_two( ... )
    cclog("CDLayerTable_mjzy::onChi_Group_two")
    if  self.m_pChiList[2] then

        self:getSendData(2)
    end

    self:onChiEnd()
end

function CDLayerTable_mjzy:onChi_Group_three( ... )
    cclog("CDLayerTable_mjzy::onChi_Group_three")
    if  self.m_pChiList[3] then
        self:getSendData(3)
    end
    self:onChiEnd()
end

function CDLayerTable_mjzy:getSendData( index )
    dtOpenWaiting( self) -- 新加

    casinoclient:getInstance():mjzy_sendOpReq( DEF_MJZY_CHI, self.m_nSaveOPCMahjong,self:getChiPaiFromOwn(index))
end
-- 吃牌列表的显示（当大于1组的时候显示）
function CDLayerTable_mjzy:onShowChiList(  )

    local chiSpace = 60
    -- local threeSize_X = {45,-155,-355} 
    local threeSize_X = {-355,-155,45} 
    local twoSize_x ={-155,45}
    -- local butThreeSize_X = {-150,-340,-530}
    local butThreeSize_X = {-530,-340,-150}
    local butTwoSize_X = {-340,-150}

    if  TABLE_SIZE(self.m_pChiList) >= 2 and TABLE_SIZE(self.m_pChiList) <= 3 then

        local curSize_x = {}
        local curButSize_x = {}
        if  TABLE_SIZE(self.m_pChiList) == 2 then
            curSize_x = twoSize_x
            curButSize_x = butTwoSize_X
        else
            curSize_x = threeSize_X
            curButSize_x = butThreeSize_X
        end

        self.m_pChiGroupFarme:setContentSize( cc.size( 270*TABLE_SIZE(self.m_pChiList), 120))

        for i=1,TABLE_SIZE(self.m_pChiList) do

            local beginX = curSize_x[i]

            self.m_pChiFarme[i].m_pChiButton:setVisible(true)
            self.m_pChiFarme[i].m_pChiButton:setPosition(cc.p(curButSize_x[i],self.m_pChiFarme[i].m_pChiButton:getPositionY()))

            for j=1,3 do

                beginX = beginX + chiSpace

                local curPos = cc.p(beginX,0)

                self.m_pChiFarme[i]["m_pChiFarme"..j]:setVisible( true)
                self.m_pChiFarme[i]["m_pChiFarme"..j]:setMahjong( string.format( "out_b_%u.png", self.m_pChiList[i][j]))
                self.m_pChiFarme[i]["m_pChiFarme"..j]:setPosition( curPos )
                self.m_pChiFarme[i]["m_pChiFarme"..j]:setIcoLaiVisible( false, false)
                
            end

        end

        self.m_pChiGroup:setVisible(true)

        local position = cc.p( self.m_sChiPosition.x, self.m_sChiPosition.y - 50)
        self.m_pChiGroup:setPosition( position)
        self.m_pChiGroup:runAction( cc.EaseBackOut:create( cc.MoveTo:create( 0.15, self.m_sChiPosition)))

    else
        self:onChi_Group_one()
    end 

    self:setGroupButtonVisible( false)
end

--关闭吃
function CDLayerTable_mjzy:onCloseChi( ... )
    if  self.m_pChiGroup:isVisible() then

        self:detailCloseFrame(true)
        self:onChiEnd()
    end
end

--判断吃
function CDLayerTable_mjzy:lastPlayer( target_id )
    local index = self:changeOrder( self:getTableIndexWithID(target_id))
    if index ~= -1 then 
        if self.m_nPlayers == 2 then
            if  index == 2 then
                return true
            end
        elseif self.m_nPlayers == 4 then
            if  index == 3 then
                return true
            end
        end
    end
    return false
end
----------------------------------------------------------------------------
-- 回合添加／删除牌
-- 参数: 牌，位置
function CDLayerTable_mjzy:round_addMahjong( mahjong, order_type)
    cclog("CDLayerTable_mjzy::round_addMahjong")

    self.m_nPMahjongs[order_type] = self.m_nPMahjongs[order_type] + 1
    if  self.m_nPMahjongs[order_type] > DEF_MJZY_MAX_GETMAHJONG then
        self.m_nPMahjongs[order_type] = DEF_MJZY_MAX_GETMAHJONG
    end

    local index = MJZY_INDEX_ITOG( order_type, self.m_nPMahjongs[order_type])

    self.m_pPMahjongs[ order_type][index].m_nMahjong = mahjong
    self.m_pPMahjongs[ order_type][index].m_pMahjong:setMahjongNumber( mahjong)
    self.m_pPMahjongs[ order_type][index].m_pMahjong:setVisible( true)

    if  order_type == 0 and mahjong ~= 0 then

        self.m_pPMahjongs[ order_type][index].m_pMahjong:setMahjong( string.format( "my_b_%u.png", mahjong))
        self.m_pPMahjongs[ order_type][index].m_pMahjong:setIcoTingVisible( false)
        self:myMahjong_setIcoLai( self.m_pPMahjongs[ order_type][index])
    end
end

function CDLayerTable_mjzy:round_delMahjong( order_type)
    cclog("CDLayerTable_mjzy::round_delMahjong")

    local index = MJZY_INDEX_ITOG( order_type, self.m_nPMahjongs[order_type])
    self.m_nPMahjongs[order_type] = self.m_nPMahjongs[order_type]-1
    if  self.m_nPMahjongs[order_type] < 1 then
        self.m_nPMahjongs[order_type] = 1
    end

    self.m_pPMahjongs[ order_type][index].m_nMahjong = 0
    self.m_pPMahjongs[ order_type][index].m_pMahjong:setMahjongNumber( 0)
    self.m_pPMahjongs[ order_type][index].m_pMahjong:setVisible( false)
end

----------------------------------------------------------------------------
-- 回合位置变更及摸牌处理
function CDLayerTable_mjzy:round_MoMahjong( order_type, mahjong,isFangFeng)
    cclog("CDLayerTable_mjzy::round_MoMahjong")

    print("order_type----------->",order_type)

    self.m_nOrderType = self:changeOrder( order_type)
    self:setOrderType( self.m_nOrderType)

   -- 对应位置处理回合出牌
    if  self.m_nOrderType == 0 then     -- 我

        self.m_nLastMoMahjong = mahjong
        self.m_pPlayAI[0]:addVMahjong( mahjong)
        self.m_pPlayAI[0]:sortAllVMahjongs( self.mahjong_MJZY)
        self:round_addMahjong( self.m_nLastMoMahjong, 0)

        
        self.m_bCanFangFeng = isFangFeng or false
        self:setGroupFangFengBtnVisible(self.m_bCanFangFeng)

        print("self.m_bCanFangFeng------------------->",self.m_bCanFangFeng)
        print("-------放风操作---------")
    
        --放风按钮组不显示时再进行
        if not self.m_bCanFangFeng then
            self:round_MyThink()
        end
    else

        self.m_pPlayAI[self.m_nOrderType]:addVMahjong( mahjong)
        self.m_pPlayAI[self.m_nOrderType]:sortAllVMahjongs( self.mahjong_MJZY)
        self:round_addMahjong( 0, self.m_nOrderType)
    end

    self:resetTableMahjongs( self.m_nOrderType, nil, true)
    dtPlaySound( DEF_MJZY_SOUND_MJ_MO)
end

--==============================自己牌组相关处理===============================-

----------------------------------------------------------------------------
-- 自己准备等待其他玩家准备
function CDLayerTable_mjzy:myMahjong_ready()
    cclog( "CDLayerTable_mjzy:myMahjong_ready")
    self.isReconnect = false  -- 防止断线重连卡住  只有在得分界面继续会发生
    if  self.m_pPlayer ~= nil and self.m_pPlayer[0].m_pIcoReady ~= nil then
        
        self.m_pPlayer[0].m_pIcoReady:stopAllActions()
        self.m_pPlayer[0].m_pIcoReady:setScale( 1.3)
        self.m_pPlayer[0].m_pIcoReady:setVisible( true)
        self.m_pPlayer[0].m_pIcoReady:runAction( cc.EaseBackOut:create( cc.ScaleTo:create( 0.3, 1.0)))

        self.m_pGroupPushMsg:setVisible( true)
        self.m_pPushMessage:setString( casinoclient:getInstance():findString("wait_ready"))
    end
end

----------------------------------------------------------------------------
-- 刷新自己的牌，排序后的调整
function CDLayerTable_mjzy:myMahjongs_refresh( refresh_huang)
    cclog("CDLayerTable_mjzy::myMahjongs_refresh")

    if  refresh_huang == nil then
        refresh_huang = true
    end

    local array = self.m_pPlayAI[0]:getAllVMahjongs()

    table.sort( array, mahjong_MJZY_table_comps_stb)         --显示排序，赖子放到最左边

    local size  = TABLE_SIZE( array)
    local index = self:getMahjongIndexWithVaild( 0, true)
    local count = self.m_nPMahjongs[0]
    for i = 1, size do

        if  index <= count then

            if  self.m_pPMahjongs[0][index].m_nMahjong ~= array[i].mahjong then

                self.m_pPMahjongs[0][index].m_nMahjong = array[i].mahjong
                self.m_pPMahjongs[0][index].m_pMahjong:setMahjong( string.format( "my_b_%u.png", array[i].mahjong))
                self.m_pPMahjongs[0][index].m_pMahjong:setMahjongNumber( array[i].mahjong)
                self.m_pPMahjongs[0][index].m_pMahjong:setVisible( true)

                self:myMahjong_setIcoLai( self.m_pPMahjongs[0][index])
            end

            self.m_pPMahjongs[0][index].m_bSelect = false
            self.m_pPMahjongs[0][index].m_pMahjong:setIcoTingVisible( false) -- 取消听牌ICO的显示
        end
        index = index + 1
    end
    self.m_nSaveSelectIndex = 0

    -- 刷新麻将晃按钮组
    if  refresh_huang then
        self:myMahjong_vaildHuangButton( false)
    end
end

----------------------------------------------------------------------------
-- 自己的牌停牌表现设置
function CDLayerTable_mjzy:myMahjongs_ting( out_mahjongs)
    cclog("CDLayerTable_mjzy::myMahjongs_ting")

    if  out_mahjongs == nil then -- 恢复听表现前的显示

        for i = 1, self.m_nPMahjongs[0] do

            if  self.m_pPMahjongs[0][i].m_pMahjong ~= nil then
                self.m_pPMahjongs[0][i].m_pMahjong:setGrey( false)
            end
        end
        return
    end

    local out_size = TABLE_SIZE( out_mahjongs)
    for i = 1, self.m_nPMahjongs[0] do

        local find = false
        for j = 1, out_size do

            if  self.m_pPMahjongs[0][i].m_nMahjong == out_mahjongs[j] then
                find = true
                break
            end
        end

        if  find then

            if  self.m_pPMahjongs[0][i].m_pMahjong ~= nil then
                self.m_pPMahjongs[0][i].m_pMahjong:setGrey( false)
            end 
        else

            if  self.m_pPMahjongs[0][i].m_pMahjong ~= nil then
                self.m_pPMahjongs[0][i].m_pMahjong:setGrey( true)
            end
        end
    end
end

----------------------------------------------------------------------------
-- 搜索自己有效牌开始的位置
function CDLayerTable_mjzy:myMahjong_getValueIndex()
    cclog("CDLayerTable_mjzy::myMahjong_getValueIndex")

    for i = 1, self.m_nPMahjongs[0] do

        if  self.m_pPMahjongs[0][i].m_bVaild then
            return i
        end
    end
    return -1
end

----------------------------------------------------------------------------
-- 搜索指定牌在自己牌组中的位置
-- 参数: 指定牌
function CDLayerTable_mjzy:myMahjong_getMahjongIndex( mahjong)
    cclog("CDLayerTable_mjzy::myMahjong_getMahjongIndex")

    local count = self.m_nPMahjongs[0]
    local index = 0
    for i = 1, count do

        if  self.m_pPMahjongs[0][i].m_bVaild and self.m_pPMahjongs[0][i].m_nMahjong == mahjong then
            return i
        end
    end
    return -1
end

----------------------------------------------------------------------------
-- 搜索索引根据打出的牌
-- 参数: 指定牌
function CDLayerTable_mjzy:myMahjong_getIndexWithOutMahjong( mahjong)

    local count = self.m_nPMahjongs[0]
    local index = 0
    for i = 1, count do

        index = MJZY_INDEX_ITOG( 0, i)
        if  self.m_pPMahjongs[0][index].m_nMahjong == mahjong and
            self.m_pPMahjongs[0][index].m_pMahjong:getPositionY() > self.m_pPMahjongs[0][index].m_sPosition.y then
            return i
        end
    end
    return self:myMahjong_getMahjongIndex( mahjong)
end

----------------------------------------------------------------------------
-- 设置自己所有牌的灰度
-- 参数: 是否黑白
function CDLayerTable_mjzy:myMahjong_allGrey( bGrey)
    cclog("CDLayerTable_mjzy::myMahjong_allGrey")

    local size = self.m_nPMahjongs[0]

    for i = 1, size do

        if  self.m_pPMahjongs[0][i].m_pMahjong then

            self.m_pPMahjongs[0][i].m_pMahjong:setGrey( bGrey)            
        end
    end
end

----------------------------------------------------------------------------
-- 设置牌中的赖子标示是否显示
-- 参数: 需要判断的牌对象
function CDLayerTable_mjzy:myMahjong_setIcoLai( pMahjong)
    cclog("CDLayerTable_mjzy::myMahjong_setIcoLai")

    if  pMahjong == nil then
        return
    end

    -- 赖子设置
    if  pMahjong.m_nMahjong == self.mahjong_MJZY:getMahjongLaiZi() then
        pMahjong.m_pMahjong:setIcoLaiVisible( true, true)
    -- elseif pMahjong.m_nMahjong == 51 then
    --     pMahjong.m_pMahjong:changeLaiIcon()
    --     pMahjong.m_pMahjong:setIcoLaiVisible( true, false)
    else
        pMahjong.m_pMahjong:setIcoLaiVisible( false, false)
    end
end

----------------------------------------------------------------------------
-- 设置牌中的停牌标示是否显示
function CDLayerTable_mjzy:myMahjong_setIcoTing()

    local index = self:getMahjongIndexWithVaild( 0, true)
    if  index > self.m_nPMahjongs[0] or index <= 0 then
        return
    end

    for i = index, self.m_nPMahjongs[0] do
        if  self.m_pPMahjongs[0][i].m_nMahjong then
            local ting = self.mahjong_MJZY:canTingPai(self.m_pPlayAI[0]:getAllVMahjongs(), self.m_pPMahjongs[0][i].m_nMahjong)
            if  ting then
                self.m_pPMahjongs[0][i].m_pMahjong:setIcoTingVisible(true)
            else
                self.m_pPMahjongs[0][i].m_pMahjong:setIcoTingVisible(false)
            end
        end
    end
end

----------------------------------------------------------------------------
-- 设置显示听牌组:假如mahjong不等于0那么表示开启，否则表示关闭
-- 参数: 要打出的牌
function CDLayerTable_mjzy:myMahjong_showTingGroup(out_mahjong)
    cclog("CDLayerTable_mjzy::myMahjong_showTingGroup")

    if  self.m_pTingGroup == nil or self.m_pTingList == nil then
        return
    end

    -- 没有出牌那么关闭听牌提示
    if  out_mahjong == 0 then
        self.m_pTingGroup:setVisible(false)
        return
    end

    -- 不能听牌的情况下关闭听牌提示
    local ting = self.mahjong_MJZY:canTingPai(self.m_pPlayAI[0]:getAllVMahjongs(), out_mahjong) --,self.m_pPlayAI[0]:getNMahjong(),self:setAllPlayerData())
    if  not ting then
        self.m_pTingGroup:setVisible(false)
        return
    end
    
    -- 开始听牌检查
    local array = self.m_pPlayAI[0]:getAllVMahjongs_delMahjong(out_mahjong)
    local size = TABLE_SIZE(array)

    local check_mahjong = { 11, 12, 13, 14, 15, 16, 17, 18, 19, 
                            21, 22, 23, 24, 25, 26, 27, 28, 29, 
                            31, 32, 33, 34, 35, 36, 37, 38, 39,
                            41, 42, 43, 44, 51, 52, 53 }
    --self.mahjong_MJZY:pop_mahjong(check_mahjong, self.mahjong_MJZY:getMahjongLaiZi())
    local check_size = TABLE_SIZE(check_mahjong)
    local total = 0
    local ting_mahjong = {}

    for i = 1, check_size do
        local bHuPai = self.mahjong_MJZY:canHuPai_WithOther(array, check_mahjong[i]) --, self.m_pPlayAI[0]:getNMahjong(),self:setAllPlayerData())
        if  bHuPai and TABLE_SIZE(ting_mahjong) < DEF_MJZY_TING_LIST_MAX  then

            -- 检查牌剩余数量
            total = self:getMahjongLaveNumber(check_mahjong[i])
            if  total > 0 then
                ting_mahjong[TABLE_SIZE(ting_mahjong) + 1] = check_mahjong[i]
                self.m_pTingNumText[TABLE_SIZE(ting_mahjong)]:setString(string.format("%u", total))
            end
        end
    end
   
    size = TABLE_SIZE(ting_mahjong)
    if  size > DEF_MJZY_TING_LIST_MAX then
        size = DEF_MJZY_TING_LIST_MAX
        cclog( "CDLayerTable_mjzy:myMahjong_showTingGroup, ting_size >  9")
    elseif size == 0 then
        cclog( "CDLayerTable_mjzy:myMahjong_showTingGroup, ting_size == 0")
        self.m_pTingGroup:setVisible(false)
        return
    end

    local frame_w = (size - 1) * DEF_MJZY_TING_ITEM_SPACE + DEF_MJZY_TING_FRAME_SPACE
    self.m_pTingFrame:setContentSize(cc.size(frame_w, 120))

    local beginX = -(size - 1) * DEF_MJZY_TING_ITEM_SPACE * 0.5
    for i = 1, DEF_MJZY_TING_LIST_MAX do
        if  i > size then
            self.m_pTingMahjong[i]:setVisible(false)
            self.m_pTingNumText[i]:setVisible(false)
            self.m_pTingNumFrame[i]:setVisible(false)
        else
            self.m_pTingMahjong[i]:setVisible(true)
            self.m_pTingMahjong[i]:setMahjong(string.format("out_b_%u.png", ting_mahjong[i]))
            self.m_pTingMahjong[i]:setPositionX(beginX)
            if  ting_mahjong[i] == self.mahjong_MJZY:getMahjongLaiZi() then
                self.m_pTingMahjong[i]:setIcoLaiVisible(true, true)
            else
                self.m_pTingMahjong[i]:setIcoLaiVisible(false, false)
            end

            self.m_pTingNumText[i]:setVisible(true)
            self.m_pTingNumText[i]:setPositionX(beginX)

            self.m_pTingNumFrame[i]:setVisible(true)
            self.m_pTingNumFrame[i]:setPositionX(beginX)

            beginX = beginX + DEF_MJZY_TING_ITEM_SPACE
        end
    end

    self.m_pTingGroup:setVisible(true)
    local position = cc.p(self.m_sTingPosition.x, self.m_sTingPosition.y - 50)
    self.m_pTingGroup:setPosition(position)
    self.m_pTingGroup:runAction(cc.EaseBackOut:create(cc.MoveTo:create(0.15, self.m_sTingPosition)))
end

----------------------------------------------------------------------------
-- 添加放弃的操作并且显示提示
-- type 0杠，1碰，2杠＋碰, mahjong牌, clear是否要清空储存值
function CDLayerTable_mjzy:myMahjong_addForgo( type, mahjong, clear)
    cclog( "CDLayerTable_mjzy:myMahjong_addForgo(%u, %u, %u)", type, mahjong, self.m_nSaveOPGMahjong)

    local opg_mahjong = 0
    local opp_mahjong = 0

    if      type == 0 then      -- 弃杠

        self.m_pPlayAI[0]:addForgoGang( self.m_nSaveOPGMahjong)
        if  clear then
            self.m_bSaveOPGFlag = false
            opg_mahjong = self.m_nSaveOPGMahjong
            self.m_nSaveOPGMahjong = 0
        end
    elseif  type == 1 then      -- 弃碰

        self.m_pPlayAI[0]:addForgoPeng( self.m_nSaveOPPMahjong)
        if  clear then
            self.m_bSaveOPPFlag = false
            opp_mahjong = self.m_nSaveOPPMahjong
            self.m_nSaveOPPMahjong = 0
        end
    elseif  type == 2 then      -- 弃杠、碰

        self.m_pPlayAI[0]:addForgoGang( self.m_nSaveOPGMahjong)
        if  clear then
            self.m_bSaveOPGFlag = false
            opg_mahjong = self.m_nSaveOPGMahjong
            self.m_nSaveOPGMahjong = 0
        end

        self.m_pPlayAI[0]:addForgoPeng( self.m_nSaveOPPMahjong)
        if  clear then
            self.m_bSaveOPPFlag = false
            opp_mahjong = self.m_nSaveOPPMahjong
            self.m_nSaveOPPMahjong = 0
        end
    end
    self:myMahjong_updateForgoMessage()

    if  opg_mahjong ~= 0 then

        if  type == 2 then -- 点笑

            return true

        -- 假如不是放弃补杠，那么不用做记录应该在这里删除
        else
            return true
        end
    end
    cclog( "CDLayerTable_mjzy:myMahjong_addForgo(%u) true", opg_mahjong)

    return true
end

----------------------------------------------------------------------------
-- 更新放弃操作的信息
function CDLayerTable_mjzy:myMahjong_updateForgoMessage()
    cclog("CDLayerTable_mjzy:myMahjong_updateForgoMessage")
    if  self.m_pPlayAI ~= nil then

        local bVisible, message = self.m_pPlayAI[0]:getForgoMessage()
        local bOldVis = self.m_pGroupForgo:isVisible()

        self.m_pGroupForgo:setVisible( bVisible)
        if  bVisible then
            self.m_pForgoMessage:setString( message)
            if  not bOldVis then
                self.m_pGroupForgo:setScale( 0.3)
                self.m_pGroupForgo:runAction( cc.EaseBackOut:create( cc.ScaleTo:create( 0.2, 1)))
            end
        end
    end
end

--提示本轮弃胡（用户客户端显示）
function CDLayerTable_mjzy:forgotHuTip( ... )
    -- print("self.canhuNow---->",self.canhuNow)
    if  self.canhuNow then
        local bOldVis = self.m_pGroupForgo:isVisible()
        self.m_pForgoMessage:setString( casinoclient:getInstance():findString("forgo_hu") )
        self.m_pGroupForgo:setVisible(true)
        self.canhuNow = false
    end
end
----------------------------------------------------------------------------
-- 获取指定麻将牌在手牌中的位置
function CDLayerTable_mjzy:myMahjong_getPosition( mahjong )

    local size = self.m_nPMahjongs[0]
    if  size > TABLE_SIZE( self.m_pPMahjongs[0]) then
        size = TABLE_SIZE( self.m_pPMahjongs[0])
    end

    local nCount = 0
    local bFind = false
    local fX = 0.0

    local nMax = 4
    -- if  mahjong == self.mahjong_MJZY:getMahjongFan() then
    --     nMax = 3
    -- end

    for i = 1, size do

        if  self.m_pPMahjongs[0][i].m_pMahjong ~= nil and
            self.m_pPMahjongs[0][i].m_nMahjong == mahjong and
            self.m_pPMahjongs[0][i].m_bVaild then

            nCount = nCount + 1
            if  not bFind then
                bFind = true
                fX = self.m_pPMahjongs[0][i].m_sPosition.x
            end
        end
    end
    
    local canshow,showGangArr = self.mahjong_MJZY:canGangAfterPeng(self.m_pPlayAI[0]:getAllVMahjongs(),false,self.m_pPlayAI[0]:getNMahjong())
    local function canShowGang( showGangArr )
        for i,v in ipairs(showGangArr) do
            if v == mahjong then
                return true    
            end
        end
        return false
    end
    
    if  nCount >= nMax or canShowGang(showGangArr) then 
        return true, fX
    end
    return false, 0.0
end

----------------------------------------------------------------------------
-- 点击判断晃按钮
function CDLayerTable_mjzy:myMahjong_touchHuangButton( point)
    cclog("CDLayerTable_mjzy::myMahjong_touchHuangButton")

    for i = 1, DEF_MJZY_MAHJONG_MAX_BUT do

        if  self.m_pMahjongBut[i].m_nMahjong ~= 0 and 
            self.m_pMahjongBut[i].m_bVaild and
            self.m_pMahjongBut[i].m_pEffect ~= nil and 
            self.m_pMahjongBut[i].m_pEffect:isVisible() then

            local start = cc.p( self.m_pMahjongBut[i].m_pEffect:getPositionX(), 
                                self.m_pMahjongBut[i].m_pEffect:getPositionY())
            start = self.m_pCenterDemo[0]:convertToWorldSpace( start)
            if  point.x >= (start.x - 45) and 
                point.x <= (start.x + 45) and
                point.y >= (start.y - 45) and 
                point.y <= (start.y + 45) then

                dtOpenWaiting( self)
                self:setGroupButtonVisible( false)
                casinoclient:getInstance():mjzy_sendOpReq( DEF_MJZY_GANG, self.m_pMahjongBut[i].m_nMahjong)
                dtPlaySound( DEF_SOUND_TOUCH)
                return true
            end
        end
    end
    return false
end

----------------------------------------------------------------------------
-- 搜索麻将牌晃操作按钮（只有可杠的才可以添加）
function CDLayerTable_mjzy:myMahjong_findHuangButton( mahjong)
    cclog("CDLayerTable_mjzy::myMahjong_findHuangButton")

    if  self.m_pMahjongBut == nil or mahjong == 0 then
        return false
    end

    for i = 1, DEF_MJZY_MAHJONG_MAX_BUT do

        if  self.m_pMahjongBut[i].m_nMahjong == mahjong and 
            self.m_pMahjongBut[i].m_pEffect ~= nil then

            self.m_pMahjongBut[i].m_pEffect:setGrey( false)
            self.m_pMahjongBut[i].m_pEffect:setVisible( true)
            self.m_pMahjongBut[i].m_pEffect:runAnimations( 0, 0)
            self.m_pMahjongBut[i].m_bVaild = true
            return true
        end
    end
    return false
end

----------------------------------------------------------------------------
-- 获取所有自己牌除晃按钮牌
function CDLayerTable_mjzy:myMahjong_getHuangButtons()
    cclog("CDLayerTable_mjzy::myMahjong_getHuangButtons")

    local huang_buttons = {}
    local index = 1
    for i = 1, DEF_MJZY_MAHJONG_MAX_BUT do

        if  self.m_pMahjongBut[i].m_nMahjong ~= 0 then

            huang_buttons[index] = self.m_pMahjongBut[i].m_nMahjong
            index = index + 1
        end
    end
    return huang_buttons
end

----------------------------------------------------------------------------
-- 添加麻将牌晃操作按钮（只有可杠的才可以添加）
function CDLayerTable_mjzy:myMahjong_addHuangButton( mahjong)
    cclog("CDLayerTable_mjzy::myMahjong_addHuangButton")

    if  self.m_pMahjongBut == nil or mahjong == 0 then
        return false
    end

    -- 先寻找是否有相同的
    local pNewMahjongBut = nil
    for i = 1, DEF_MJZY_MAHJONG_MAX_BUT do

        if  self.m_pMahjongBut[i].m_nMahjong == mahjong and 
            self.m_pMahjongBut[i].m_pEffect ~= nil then

            self.m_pMahjongBut[i].m_pEffect:setGrey( false)
            self.m_pMahjongBut[i].m_pEffect:setVisible( true)
            self.m_pMahjongBut[i].m_pEffect:runAnimations( 0, 0)
            self.m_pMahjongBut[i].m_bVaild = true
            return false
        elseif  self.m_pMahjongBut[i].m_nMahjong == 0 and
                pNewMahjongBut == nil then

            pNewMahjongBut = self.m_pMahjongBut[i]
        end
    end

    -- 设置新的麻将操作按钮
    if  pNewMahjongBut ~= nil then

        local b, x = self:myMahjong_getPosition( mahjong)
        if  b then

            pNewMahjongBut.m_nMahjong = mahjong
            pNewMahjongBut.m_pEffect:setGrey( true)
            pNewMahjongBut.m_pEffect:setVisible( true)
            pNewMahjongBut.m_pEffect:runAnimations( 0, 0)
            pNewMahjongBut.m_pEffect:setPosition( cc.p( x, DEF_MJZY_MAHJONG_SPC_BUT))
            pNewMahjongBut.m_bVaild = false
            dtPlaySound( DEF_MJZY_SOUND_MJ_SHOWB)
            return true
        end
    end

    return false
end

----------------------------------------------------------------------------
-- 不可用所有麻将牌操作按钮
function CDLayerTable_mjzy:myMahjong_vaildHuangButton( vaild,mahjong)
    cclog("CDLayerTable_mjzy::myMahjong_vaildHuangButton")

    if  self.m_pMahjongBut == nil then
        return false
    end

    -- 遍历所有的然后设置为不可用
    for i = 1, DEF_MJZY_MAHJONG_MAX_BUT do

        if  self.m_pMahjongBut[i].m_nMahjong ~= 0 and 
            self.m_pMahjongBut[i].m_pEffect ~= nil then

            self.m_pMahjongBut[i].m_pEffect:setVisible( true)
            if  self.m_pMahjongBut[i].m_nMahjong == mahjong then
                self.m_pMahjongBut[i].m_bVaild = false
                self.m_pMahjongBut[i].m_pEffect:setGrey( true)
            else
                self.m_pMahjongBut[i].m_bVaild = vaild
                self.m_pMahjongBut[i].m_pEffect:setGrey( not vaild )
            end

            local b, x = self:myMahjong_getPosition( self.m_pMahjongBut[i].m_nMahjong)
            if  b then

                self.m_pMahjongBut[i].m_pEffect:setPosition( cc.p( x, DEF_MJZY_MAHJONG_SPC_BUT))
            else

                self.m_pMahjongBut[i].m_nMahjong = 0
                self.m_pMahjongBut[i].m_pEffect:setVisible( false)
            end
        end
    end
end

----------------------------------------------------------------------------
-- 是否显示所有麻将牌操作按钮
function CDLayerTable_mjzy:myMahjong_visibleHuangButton( visible,isClearValue)
    cclog("CDLayerTable_mjzy::myMahjong_visibleHuangButton")

    if  self.m_pMahjongBut == nil then
        return false
    end

    if isClearValue == nil then
        isClearValue = true
    end

    -- 遍历所有的然后设置为不可用
    for i = 1, DEF_MJZY_MAHJONG_MAX_BUT do

        if  self.m_pMahjongBut[i].m_nMahjong ~= 0 and 
            self.m_pMahjongBut[i].m_pEffect ~= nil then

            if  not visible and isClearValue then
                self.m_pMahjongBut[i].m_nMahjong = 0
            end
            self.m_pMahjongBut[i].m_pEffect:setVisible( visible)
        end
    end
end

--===============================界面函数绑定===============================--

----------------------------------------------------------------------------
-- 出牌
function CDLayerTable_mjzy:onFix()
    cclog("CDLayerTable_mjzy::onFix")
end

----------------------------------------------------------------------------
-- 重置
function CDLayerTable_mjzy:onDeal()
    cclog("CDLayerTable_mjzy::onDeal")

--    self.m_pBut_Ready:setVisible( true)
--    self:onReady()
end

----------------------------------------------------------------------------
-- 退出桌子到大厅
function CDLayerTable_mjzy:onGotoHall()
    cclog("CDLayerTable_mjzy::onExit")

    g_pSceneTable:gotoSceneHall()
    dtPlaySound( DEF_SOUND_TOUCH)
end

----------------------------------------------------------------------------
-- 音乐设置
function CDLayerTable_mjzy:onMusic()

    local bMusic = g_pGlobalManagement:isEnableMusic()
    g_pGlobalManagement:enableMusic( not bMusic)
end

----------------------------------------------------------------------------
-- 音效设置
function CDLayerTable_mjzy:onSound()

    local bSound = g_pGlobalManagement:isEnableSound()
    g_pGlobalManagement:enableSound( not bSound)
end

----------------------------------------------------------------------------
-- 准备（这里当作发牌)
function CDLayerTable_mjzy:onReady()
    cclog("CDLayerTable_mjzy::onReady")

    if  not self.m_pBut_Ready:isVisible() then
        return
    else
        self.m_pBut_Ready:setVisible( false)
        self.m_pPic_Ready:setVisible( false)
    end

    casinoclient:getInstance():sendTableReadyReq()
    dtPlaySound( DEF_SOUND_TOUCH)
end

----------------------------------------------------------------------------
--  点击托管
function CDLayerTable_mjzy:onRobot()
    cclog("CDLayerTable_mjzy::onRobot")

    if  self.m_pButRobot ~= nil and 
        self.m_pButRobot:isVisible() and 
        (not self.m_bTrusteeship) then

        casinoclient.getInstance():sendTableManagedReq( true)
        dtPlaySound( DEF_SOUND_TOUCH)
    end
end

----------------------------------------------------------------------------
--  设置托管
function CDLayerTable_mjzy:setTrusteeship( value)
    cclog("CDLayerTable_mjzy::setTrusteeship")

    self.m_pBut_Cancel:setVisible( value)
    self.m_pRobotFlag:setVisible( value)
    self.m_pTxt_Robot:setVisible( value)

    self.m_bTrusteeship = value
    if value then

        if  self.m_pChiGroup and self.m_pChiGroup:isVisible() then

            self:onChiEnd()
        end
        self.m_pRobotFlag:setScaleY( 0.3)
        self.m_pRobotFlag:stopAllActions()
        self.m_pRobotFlag:runAction( cc.ScaleTo:create( 0.15, 1.0))

    end    
end

----------------------------------------------------------------------------
--  取消托管
function CDLayerTable_mjzy:onCancelRobot()
    cclog("CDLayerTable_mjzy::onCancelRobot")

    if  not self.m_pBut_Cancel:isVisible() then
        return
    end
    casinoclient.getInstance():sendTableManagedReq( false)
    dtPlaySound( DEF_SOUND_TOUCH)
end

----------------------------------------------------------------------------
-- 切换AI的卡牌显示
function CDLayerTable_mjzy:onInfo()
    cclog("CDLayerTable_mjzy::onInfo")

end

----------------------------------------------------------------------------
--放风
function CDLayerTable_mjzy:onSendFangFeng()
    cclog("CDLayerTable_mjzy::onSendFangFeng")
    if self.m_pGroupFangFengBtn:isVisible() then
        self.m_bCanFangFeng = true
        self:setGroupFangFengBtnVisible(false)
        --将不能放风的牌全部置灰
        local needArr = self.mahjong_MJZY:saveFangFengMah(self.m_pPlayAI[0]:getAllVMahjongs())
        self:setMyMahjongGrayAfterFangFeng(needArr)
    end
end

----------------------------------------------------------------------------
--不放风 
function CDLayerTable_mjzy:onCloseFangFeng()
    cclog("CDLayerTable_mjzy::onCloseFangFeng")
    if self.m_pGroupFangFengBtn:isVisible() then
        self.m_bCanFangFeng = false
        self:setGroupFangFengBtnVisible(false)
        self.m_bCanOutMahjong =true
        self:round_MyThink()
    end
end
----------------------------------------------------------------------------
-- 放风确定
function CDLayerTable_mjzy:onSendQueDing()
    if self.m_pGroupFangFengChooseBtn:isVisible() then
        self.m_pGroupFangFengChooseBtn:setVisible(false)
       
        casinoclient:getInstance():mjzy_sendOpReq( DEF_MJZY_FANGFENG, 0,self.m_FangFengArr)
    end
end
----------------------------------------------------------------------------
function CDLayerTable_mjzy:onCloseQuXiao()

    if self.m_pGroupFangFengChooseBtn:isVisible() then
        self.m_pGroupFangFengChooseBtn:setVisible(false)
        --所有点击上移的牌回到原来位置
        self.m_bCanFangFeng = true
        self.m_nNeedNumForFangFeng = 0
        local size = self.m_nPMahjongs[0]
        for i=1,size do
            if self.m_pPMahjongs[0][i].m_bSelect then
                self.m_pPMahjongs[0][i].m_bSelect = false
                self.m_pPMahjongs[0][i].m_pMahjong:setPosition(self.m_pPMahjongs[0][i].m_sPosition)
                self.m_pPMahjongs[0][i].m_pMahjong:setScale(1.0)
            end
        end
        self.m_FangFengArr = {}
    end
end

function CDLayerTable_mjzy:onPaoFeng()
    cclog("CDLayerTable_mjzy::onPaoFeng")
    if  self.m_pGroupButton:isVisible() and
        (not self.m_pBut_Type[DEF_MJZY_BUT_TYPE_PAOFENG]:isGrey()) then

        -- 隐藏所有晃按钮
        self:myMahjong_visibleHuangButton( false,false)

        self:setGroupButtonVisible( false)
        self.m_bPaoFeng = true
        if TABLE_SIZE(self.m_nPaoFengArr)>0 then
            self:setMyMahjongGrayAfterFangFeng(self.m_nPaoFengArr)
        end
    end
end
----------------------------------------------------------------------------
-- 胡牌
function CDLayerTable_mjzy:onHuPai()
    cclog("CDLayerTable_mjzy::onHuPai")

    if  self.m_pGroupButton:isVisible() and 
        (not self.m_pBut_Type[DEF_MJZY_BUT_TYPE_HU]:isGrey()) then

        dtOpenWaiting( self) -- 新加
        self:setGroupButtonVisible( false)
        if  self.m_bCanOutMahjong then
            casinoclient:getInstance():mjzy_sendOpReq( DEF_MJZY_ZIMO, 0)
        else
            casinoclient:getInstance():mjzy_sendOpReq( DEF_MJZY_HU, 0)
        end
    end
end

----------------------------------------------------------------------------
-- 碰牌
function CDLayerTable_mjzy:onPengPai()
    cclog("CDLayerTable_mjzy::onPengPai")

    if  self.m_pGroupButton:isVisible() and
        (not self.m_pBut_Type[DEF_MJZY_BUT_TYPE_PENG]:isGrey()) then

        dtOpenWaiting( self) -- 新加
        self:setGroupButtonVisible( false)
        casinoclient:getInstance():mjzy_sendOpReq( DEF_MJZY_PENG, 0)
    end
end

----------------------------------------------------------------------------
-- 杠牌
function CDLayerTable_mjzy:onGangPai()
    cclog("CDLayerTable_mjzy::onGangPai")

    if  self.m_pGroupButton:isVisible() and
        (not self.m_pBut_Type[DEF_MJZY_BUT_TYPE_GANG]:isGrey()) then

        dtOpenWaiting( self) -- 新加
        self:setGroupButtonVisible( false)
        casinoclient:getInstance():mjzy_sendOpReq( DEF_MJZY_GANG, self.m_nSaveOPGMahjong)
    end
end

----------------------------------------------------------------------------
-- 关闭按钮组处理
function CDLayerTable_mjzy:onCloseFrame()
    cclog("CDLayerTable_mjzy::onCloseFrame")

    --如果剩下的手牌都是跑风的牌，点击无效
    local arr = self.mahjong_MJZY:getValueFromArr(self.m_pPlayAI[0]:getAllVMahjongs())
    if TABLE_SIZE(self.m_nPaoFengArr) == TABLE_SIZE(arr) then 
        return
    end

    if  self.m_pGroupButton:isVisible() then

        self:setSameMahjongWithMyMahjongs(0)

        self:setGroupButtonVisible( false)
        self:detailCloseFrame()
    end
end

----------------------------------------------------------------------------
-- 解散房间
function CDLayerTable_mjzy:onOverRoom()

    if  (not self.m_pGroupSelfBuild:isVisible()) or
        self.m_pButOver == nil or 
        (not self.m_pButOver:isVisible()) or 
        self.m_pButOver:isGrey() then
        return
    end

    local function sendOverRoom()

        if  not self.m_bInTheGame then

            self.m_pButOver:setGrey( true)
            self.m_pButLeave:setGrey( true)
            self.m_pButShare:setGrey( true)
            self.m_pButToOther:setGrey( true)

            dtOpenWaiting( self)
            casinoclient:getInstance():sendTableDisbandReq()
        end
    end

    g_pSceneTable.m_pPromptDialog:open( 
        casinoclient:getInstance():findString("send_disband"), 
        cc.CallFunc:create( sendOverRoom), 2)

    dtPlaySound( DEF_SOUND_TOUCH)
end

----------------------------------------------------------------------------
-- 离开房间
function CDLayerTable_mjzy:onLeaveRoom()

    if  (not self.m_pGroupSelfBuild:isVisible()) or
        self.m_pButLeave == nil or
        (not self.m_pButLeave:isVisible()) or
        self.m_pButLeave:isGrey() then
        return
    end

    local function sendLeaveRoom()

        if  not self.m_bInTheGame then

            self.m_pButOver:setGrey( true)
            self.m_pButLeave:setGrey( true)
            self.m_pButShare:setGrey( true)
            self.m_pButToOther:setGrey( true)

            dtOpenWaiting( self)
            casinoclient.getInstance():sendTableLeaveReq()
        end
    end

    g_pSceneTable.m_pPromptDialog:open( 
        casinoclient.getInstance():findString("send_leave"), 
        cc.CallFunc:create( sendLeaveRoom), 2)

    dtPlaySound( DEF_SOUND_TOUCH)
end

----------------------------------------------------------------------------
-- 为他人开房
function CDLayerTable_mjzy:onToOther()

    if  (not self.m_pGroupSelfBuild:isVisible()) or
        self.m_pButToOther == nil or
        (not self.m_pButToOther:isVisible()) or
        self.m_pButToOther:isGrey() then
        return
    end

    local function share_roomID()

        if  Channel.openWXapp == nil then

            dtAddMessageToScene( self, casinoclient.getInstance():findString("share_roomid_error"))
        else

            local nickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
            if  nickname == nil or string.len( nickname) == 0 then
                 nickname = casinoclient.getInstance():getPlayerData():getNickname()
            end

            local table_data = casinoclient.getInstance():getTable()
            local text = string.format( casinoclient.getInstance():findString(string.format("%u_share_other_yh", DEF_CASINO_AREA)), 
                                        nickname, self.m_nPlayers, table_data.tag, 
                                        dtGetFloatString(table_data.base), table_data.round,
                                        casinoclient.getInstance():findString(string.format("table_join%d", table_data.join)))

            platform_help.setPasteData(text)--设置缓冲
            g_pGlobalManagement:setPasteCatch( true)
            Channel:getInstance():openWXapp()

            self.m_pButOver:setGrey( true)
            self.m_pButLeave:setGrey( true)
            self.m_pButShare:setGrey( true)
            self.m_pButToOther:setGrey( true)

            dtOpenWaiting( self)
            casinoclient.getInstance():sendTableLeaveReq()
        end
    end

    local function sendToOtherRoom()

        -- 假如游戏进行了那么不回再把消息发送出去
        if  not self.m_bInTheGame then

            local table_data = casinoclient.getInstance():getTable()
            if  table_data ~= nil then

                -- 1便捷式分享， 0复杂分享
                if  casinoclient.getInstance().share_type ~= 1 then

                    if  g_pSceneTable.m_pLayerSharePrompt ~= nil then

                        g_pSceneTable.m_pLayerSharePrompt:open( 
                            string.format( casinoclient.getInstance():findString("share_roomid_title"), table_data.tag),
                            cc.CallFunc:create( share_roomID))
                    end
                else

                    self.m_pButOver:setGrey( true)
                    self.m_pButLeave:setGrey( true)
                    self.m_pButShare:setGrey( true)
                    self.m_pButToOther:setGrey( true)

                    dtOpenWaiting( self)
                    casinoclient.getInstance():sendTableLeaveReq()

                    local nickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
                    if  nickname == nil or string.len( nickname) == 0 then
                        nickname = casinoclient.getInstance():getPlayerData():getNickname()
                    end
                    local text = string.format( casinoclient.getInstance():findString(string.format("%u_share_other2_yh", DEF_CASINO_AREA)), 
                                                nickname, self.m_nPlayers,
                                                dtGetFloatString(table_data.base), table_data.round,
                                                casinoclient.getInstance():findString(string.format("table_join%d", table_data.join)))

                    local weblink = string.format(  casinoclient.getInstance():findString(string.format("%u_share_room_ex", DEF_CASINO_AREA)),
                                                    table_data.tag, nickname, self.m_nPlayers, 
                                                    dtGetFloatString(table_data.base), table_data.round)
                                                    

                    local roomid = string.format( casinoclient.getInstance():findString("share_roomid"), table_data.tag)
                    Channel:getInstance():share( text, DEF_SHARE_TYPE5, weblink, roomid)
                end
            end
        end
    end

    -- local function sendToOtherRoom()

    --     -- 假如游戏进行了那么不回再把消息发送出去
    --     if  not self.m_bInTheGame then

    --         self.m_pButOver:setGrey( true)
    --         self.m_pButLeave:setGrey( true)
    --         self.m_pButShare:setGrey( true)
    --         self.m_pButToOther:setGrey( true)

    --         dtOpenWaiting( self)
    --         casinoclient.getInstance():sendTableLeaveReq()

    --         local table_data = casinoclient.getInstance():getTable()
    --         if  table_data ~= nil and g_pGlobalManagement:getWeiXinLoginEnable() then

    --             local nickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
    --             if  nickname == nil or string.len( nickname) == 0 then
    --                 nickname = casinoclient.getInstance():getPlayerData():getNickname()
    --             end
    --             local text = string.format( casinoclient.getInstance():findString("share_other_yh"), 
    --                                         nickname, self.m_nPlayers, table_data.tag, 
    --                                         dtGetFloatString(table_data.base), table_data.round)
    --             Channel:getInstance():share( text, DEF_SHARE_TYPE0, "")
    --         end
    --     end
    -- end

    g_pSceneTable.m_pPromptDialog:open( 
        casinoclient.getInstance():findString("send_toother"),
        cc.CallFunc:create( sendToOtherRoom), 2)

    dtPlaySound( DEF_SOUND_TOUCH)
end

----------------------------------------------------------------------------
-- 分享房间
function CDLayerTable_mjzy:onShareRoomID()

    if  not self.m_pGroupSelfBuild:isVisible() or 
        self.m_pButShare == nil or
        (not self.m_pButShare:isVisible()) or
        self.m_pButShare:isGrey() or 
        self.m_bInTheGame then
        return
    end

    local function share_roomID()

        if  Channel.openWXapp == nil then

            dtAddMessageToScene( self, casinoclient.getInstance():findString("share_roomid_error"))
        else

            local nickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
            if  nickname == nil or string.len( nickname) == 0 then
                nickname = casinoclient.getInstance():getPlayerData():getNickname()
            end

            local table_data = casinoclient.getInstance():getTable()
            local text = string.format( casinoclient.getInstance():findString(string.format("%u_share_room_yh", DEF_CASINO_AREA)), 
                                        nickname, self.m_nPlayers, table_data.tag, 
                                        dtGetFloatString(table_data.base), table_data.round,
                                        casinoclient.getInstance():findString(string.format("table_join%d", table_data.join)))

            platform_help.setPasteData(text)--设置缓冲
            g_pGlobalManagement:setPasteCatch( true)
            Channel:getInstance():openWXapp()
        end
    end
 

    local table_data = casinoclient.getInstance():getTable()
    if  table_data ~= nil then

        -- 1便捷式分享， 0复杂分享
        if  casinoclient.getInstance().share_type ~= 1 then

            if  g_pSceneTable.m_pLayerSharePrompt ~= nil then

                g_pSceneTable.m_pLayerSharePrompt:open( 
                    string.format( casinoclient.getInstance():findString("share_roomid_title"), table_data.tag),
                    cc.CallFunc:create( share_roomID))
            end
        else

            local nickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
            if  nickname == nil or string.len( nickname) == 0 then
                nickname = casinoclient.getInstance():getPlayerData():getNickname()
            end

            local text = string.format( casinoclient.getInstance():findString(string.format("%u_share_room2_yh", DEF_CASINO_AREA)),
                                        nickname, self.m_nPlayers, 
                                        dtGetFloatString(table_data.base), table_data.round,
                                        casinoclient.getInstance():findString(string.format("table_join%d", table_data.join)))

            local weblink = string.format(  casinoclient.getInstance():findString(string.format("%u_share_room_ex", DEF_CASINO_AREA)),
                                            table_data.tag, nickname, self.m_nPlayers, 
                                            dtGetFloatString(table_data.base), table_data.round)
                                            

            local roomid = string.format( casinoclient.getInstance():findString("share_roomid"), table_data.tag)
            Channel:getInstance():share( text, DEF_SHARE_TYPE5, weblink, roomid)
        end
    end

    -- local table_data = casinoclient.getInstance():getTable()
    -- if  table_data ~= nil then

    --     local nickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
    --     if  nickname == nil or string.len( nickname) == 0 then
    --         nickname = casinoclient.getInstance():getPlayerData():getNickname()
    --     end
    --     local text = string.format( casinoclient.getInstance():findString("share_room_yh"), 
    --                                 nickname, self.m_nPlayers, table_data.tag, 
    --                                 dtGetFloatString(table_data.base), table_data.round)
    --     Channel:getInstance():share( text, DEF_SHARE_TYPE0, "")
    -- end
end

----------------------------------------------------------------------------
-- 聊天
function CDLayerTable_mjzy:onChat()

    if  not self.m_pGroupBar:isVisible() then
        return
    end

    g_pSceneTable:closeAllUserInterface()

    local pos = cc.p( g_pGlobalManagement:getWinWidth()-500, self.m_pButChat:getPositionY())
    g_pSceneTable.m_pLayerChatDialog:setPosition( pos)
    g_pSceneTable.m_pLayerChatDialog:open()
    --no over
end

----------------------------------------------------------------------------
-- 设置
function CDLayerTable_mjzy:onSetting()
    cclog( "CDLayerTable_mjzy:onSetting")

    if  not self.m_pGroupBar:isVisible() then
        return
    end

    g_pSceneTable:closeAllUserInterface()

    local pos = cc.p( 0.0, self.m_pButSetting:getPositionY())
    g_pSceneTable.m_pLayerTipBar:setPosition( pos)
    g_pSceneTable.m_pLayerTipBar:open(casinoclient.getInstance():isSelfBuildTable())
end

----------------------------------------------------------------------------
-- 发起解散
function CDLayerTable_mjzy:onSponsor()
    cclog( "CDLayerTable_mjzy:onSponsor")

    local function sendDisband()
        casinoclient.getInstance():sendTableDisbandReq()
    end

    -- 假如发起按钮非空，并且是显示着的那么发送发起解散处理
    if  self.m_pButSponsor ~= nil and self.m_pButSponsor:isVisible() then

        g_pSceneTable.m_pPromptDialog:open( 
        casinoclient.getInstance():findString("sned_disband"), 
        cc.CallFunc:create( sendDisband), 2)
    end
end

----------------------------------------------------------------------------
function CDLayerTable_mjzy:getMatchChat( chatid )
    if  chatid>0 and chatid< 15 then
        local curChatData = {}
        curChatData.text = nil
        curChatData.res = nil
        if  chatid>0 and chatid<=4 then
            curChatData.res = "xn_phiz_cc.png"
        elseif chatid>4 and chatid<=8 then
            curChatData.res = "xn_phiz_wq.png"
        elseif chatid>8 and chatid<=12 then
            curChatData.res = "xn_phiz_dy.png"
        elseif chatid>=13 and chatid<=14 then
            curChatData.res = "xn_phiz_dzh.png"
        end
        curChatData.text = casinoclient.getInstance():findString( DEF_CASINO_AREA.."_scene_chat"..chatid)
        return curChatData
    end
    return false
end
-- 显示冒泡框
function CDLayerTable_mjzy:showPlayerBubble( player_id, chat_id, text)
    cclog( "CDLayerTable_mjzy:showPlayerBubble( chat_id = %u)", chat_id)

    if  player_id <= 0 then
        return
    end

    local function hidePlayer0Bubble()
        self.m_pPlayer[0].m_pBubbleGroup:setVisible( false)
    end
    local function hidePlayer1Bubble()
        self.m_pPlayer[1].m_pBubbleGroup:setVisible( false)
    end
    local function hidePlayer2Bubble()
        self.m_pPlayer[2].m_pBubbleGroup:setVisible( false)
    end
    local function hidePlayer3Bubble()
        self.m_pPlayer[3].m_pBubbleGroup:setVisible( false)
    end

    local idx = self:changeOrder( self:getTableIndexWithID( player_id))
    if  idx < 0 then
        return
    end

    self.m_pPlayer[idx].m_pBubbleGroup:setVisible( true)
    self.m_pPlayer[idx].m_pBubbleGroup:stopAllActions()

    local child = self.m_pPlayer[idx].m_pBubbleGroup:getChildByTag( 200)
    if  child ~= nil then
        self.m_pPlayer[idx].m_pBubbleGroup:removeChildByTag( 200)
    end

    self.m_pPlayer[idx].m_pBubbleGroup:setScale( 0.6)

    local sMsg = ""
    if  chat_id ~= 0 then

        local chat_data = self:getMatchChat( chat_id)
        if  chat_data then

            sMsg = chat_data.text
            self:readMahjong( 0, chat_id, idx)
            child = cc.Sprite:createWithSpriteFrameName( chat_data.res)
            child:setTag( 200)
            child:setAnchorPoint( cc.p( 1.0, 0.5))
            child:setPosition( cc.p( 22, 44))
            child:setScale( 0.85)
            self.m_pPlayer[idx].m_pBubbleGroup:addChild( child)
        end
    else
        sMsg = text
    end
    self.m_pPlayer[idx].m_pBubbleMsg:setString( sMsg)
    local total = string.len( sMsg)
    local width = total / 3 * 24 + 50
    if  width < 200 then
        width = 200
    end
    self.m_pPlayer[idx].m_pBubbleBox:setContentSize( cc.size( width, 80))

    if  idx == 0 then
        self.m_pPlayer[idx].m_pBubbleGroup:runAction( 
        cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.20, 1.0)), cc.DelayTime:create( 2.8),
            cc.CallFunc:create( hidePlayer0Bubble)))
    elseif idx == 1 then
        self.m_pPlayer[idx].m_pBubbleGroup:runAction( 
        cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1.0)), cc.DelayTime:create( 2.8),
            cc.CallFunc:create( hidePlayer1Bubble)))
    elseif idx == 2 then
        self.m_pPlayer[idx].m_pBubbleGroup:runAction( 
        cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1.0)), cc.DelayTime:create( 2.8),
            cc.CallFunc:create( hidePlayer2Bubble)))
    elseif idx == 3 then
        self.m_pPlayer[idx].m_pBubbleGroup:runAction( 
        cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1.0)), cc.DelayTime:create( 2.8),
            cc.CallFunc:create( hidePlayer3Bubble)))
    end
end

----------------------------------------------------------------------------
function CDLayerTable_mjzy:quitNIMTeam( ... )
    if  DEF_OPEN_NIMSDK and G_SPEAK_CANUSE then
        if dtIsAndroid() then
            platform_help.quitAllTeam()
            -- platform_help.setIsGame(0)
        else
            NIMSDKopen:getInstance():quitAllTeam()
            -- NIMSDKopen:getInstance():setIsInGame(false)
        end
    end
end
-- 创建云信 房主掉线无法创建群聊天  在收到飘消息的时候就创建
-- 安卓需要整包更新 苹果热更（等通知开放） 
-- self.isCreateNIM 用于检测是否创建了
function CDLayerTable_mjzy:checkAndCreatNIM( ... )
    cclog("CDLayerTable_mjzy:checkAndCreatNIM")
    self.isCreateNIM = true
    local hadTeam =  true
   
    if dtIsAndroid() then
        
        if  canUse_ByVersion(5) then
            
            if  tonumber(platform_help.getTeamId()) == 0 then
                self.isCreateNIM = false
                hadTeam = false
            end
            if  hadTeam then
                self:setVisibleSpeakResource(1) -- 开启语音聊天按钮
            end
        else
            
            self.isCreateNIM = false
        end
        
    else
        if  canUse_ByVersion(11) then
            if  tonumber(NIMSDKopen:getInstance():getTeamId()) == 0 then
                
                self.isCreateNIM = false
                hadTeam = false
            end
            if  hadTeam then
                self:setVisibleSpeakResource(1) -- 开启语音聊天按钮
            end
        else
            self.isCreateNIM = false
        end
    end

    if  not hadTeam then
         --创建云信
        if  DEF_OPEN_NIMSDK and G_SPEAK_CANUSE and casinoclient.getInstance():isSelfBuildTable() then
            self:setInGameToNIM()
            self.isCreateNIM = true
            self:sp_startCreateTeam()
            self:setVisibleSpeakResource(1) -- 开启语音聊天按钮
        end
    end

end

----------------------------------------------------------------------------

-- 显示中间倒计时
function CDLayerTable_mjzy:showWaitTime( time,boolean )

    if  time then

        self:setTimeLeftVisible(true,false)
        if  casinoclient:getInstance():isSelfBuildTable() then

            if boolean then
                self:showTimeLeft(time)
                self:initTablePauseTime(0)
            
            else
                self:showTimeLeft(5)
                self:initTablePauseTime()
            end
        else
            self:showTimeLeft(time)
            self:initTablePauseTime()
        end
    end
end



function CDLayerTable_mjzy:releaseOnQianZzhuangTip( ... )
    self.isQianZhuang = false
    self.m_pTipMessage:setString(casinoclient.getInstance():findString("tip_message2"))
    self:setGroupTipVisible( false)
end

----------------------------------------------------------------------------
-- MapLocation
-- 定位按钮
function CDLayerTable_mjzy:onLocation()
    cclog( "CDLayerTable_mjzy:onLocation")
    if  self.isShowLocation then
        self.isShowLocation = false
        self.isShowPosTip = true
        self:getAllPositionInfo()
        self:showLocation( true,true)
    else
        self:onCloseLocation( )
    end
end

function CDLayerTable_mjzy:onCloseLocation( ... )
    if  not self.isShowLocation then
        self:showLocation( false)
        self.isShowLocation = true
    end
    
end
----------------------------------------------------------------------------
-- 当位置玩家离开时清空该位置的数据
-- 参数：位置索引
function CDLayerTable_mjzy:clearTargetIPPos( index )
    local table_data=casinoclient:getInstance():getTable()
    for i,v in ipairs(table_data.players) do
        local curIndex = self:changeOrder( self:getTableIndexWithID( v.id))
        if  curIndex > 0 then
            if  curIndex == index then
                v.coord.latitude = 0
                v.coord.longitude = 0
                v.coord.address = ""
                v.coord.ip = ""
                break
            end
        end
    end
    if  self.m_pPlayer and  self.m_pPlayer[index] then
        self.m_pPlayer[index].lat = 0
        self.m_pPlayer[index].lng = 0
        self.m_pPlayer[index].address = ""
        self.m_pPlayer[index].ip_address = ""
        self.m_pPlayer[index].nickname = ""
        self.m_pPlayer[index].channel_nickname = ""
    end
end

function CDLayerTable_mjzy:Handle_MJZY_CoorDinate(__event)
    cclog("CDLayerTable_mjzy:Handle_MJZY_CoorDinate")
    local pAck = __event.packet
    if  not pAck or self.m_bReConnection then
        return false
    end

    self:setAllCoord(pAck.player_id,pAck.latitude,pAck.longitude,pAck.address,pAck.ip)
end

function CDLayerTable_mjzy:getAllPositionInfo( ... )
    local table_data=casinoclient:getInstance():getTable()
    for i,v in ipairs(table_data.players) do
        local curIndex = self:changeOrder( self:getTableIndexWithID( v.id))
        if  curIndex > 0 then
            if  not self:getValueIsTrue(self.m_pPlayer[curIndex].lat) then 
                self.m_pPlayer[curIndex].lat =v.coord.latitude
            end
            if  not self:getValueIsTrue(self.m_pPlayer[curIndex].lng) then
                self.m_pPlayer[curIndex].lng =v.coord.longitude
            end
            if  not self.m_pPlayer[curIndex].address or string.len(self.m_pPlayer[curIndex].address) <=1 then
                self.m_pPlayer[curIndex].address = v.coord.address
            end
            if  not self.m_pPlayer[curIndex].ip_address or string.len(self.m_pPlayer[curIndex].ip_address) <=1 then
                self.m_pPlayer[curIndex].ip_address = v.coord.ip
            end
            self.m_pPlayer[curIndex].nickname = v.nickname
            self.m_pPlayer[curIndex].channel_nickname = v.channel_nickname
        end
    end
end

function CDLayerTable_mjzy:setAllCoord( player_id,lat,lng,address,ip )
    if  player_id == casinoclient:getInstance():getPlayerData():getId() then
        self.m_pPlayer[0].lat = lat                   
        self.m_pPlayer[0].lng = lng 
        self.m_pPlayer[0].address =  address  
        self.m_pPlayer[0].ip_address =  ip  
    else
        local curIndex = self:changeOrder( self:getTableIndexWithID( player_id))
        if  curIndex ~= -1 then
            self.m_pPlayer[curIndex].lat = lat 
            self.m_pPlayer[curIndex].lng = lng 
            self.m_pPlayer[curIndex].address =  address
            self.m_pPlayer[curIndex].ip_address = ip
        end
    end
    self:getAllPositionInfo()
end

function CDLayerTable_mjzy:getVersionCanUsePos( ... )

    return true
end

-- 获取位置信息
function CDLayerTable_mjzy:getPosWithSelf( ... )
    -- 获取位置信息
    if  casinoclient:getInstance():isSelfBuildTable() then
        if  self:getVersionCanUsePos() and self.m_nPlayers == 4 then
            if  dtIsAndroid() then
                platform_help.startLocationPos()
            else
                MyObject:getInstance():startLocation()
            end
        end
    end
    
end

-- 计时等待获取位置信息的回吊
function CDLayerTable_mjzy:waitGetPosCB( boolean )
    
    self.isShowPos = boolean

    if  self.m_nPlayers < 4 or not casinoclient:getInstance():isSelfBuildTable() then
        return
    end

    -- if  not self:getVersionCanUsePos() then
        casinoclient:getInstance():sendPosWithLatLngReq(0,0,"")
        return
    -- end
    --[[
    local waitTime=0
    local function waitPosInfo( event )
        waitTime=waitTime+1
        if  waitTime>=2 or POS_ISOPENLOCATION_SERVICE~=0 then
            waitTime = 0
            if  POS_ISOPENLOCATION_SERVICE and POS_ISOPENLOCATION_SERVICE~=0 then -- 成功获取到了位置信息
                casinoclient:getInstance():sendPosWithLatLngReq(POS_PLAYER_LATITUDE,POS_PLAYER_LONGITUDE,POS_PLAYER_ADDRESS)
                if  self.isShowPos  then
                    self:getAllPositionInfo()
                    self:showLocation(true,false)
                end

            else  -- 没有打开位置权限
                casinoclient:getInstance():sendPosWithLatLngReq(0,0,"")
                if  self.isShowPosTip then
                    if dtIsAndroid() then
                        dtAddMessageToScene( self, casinoclient.getInstance():findString("poserror_android"))
                    else
                        dtAddMessageToScene( self, casinoclient.getInstance():findString("poserror_phone"))
                    end 
                end
            end
            if  self.waitGetPosID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.waitGetPosID)   
                self.waitGetPosID=nil
            end
        end
    end
    if  self.waitGetPosID ==nil then
        self.waitGetPosID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(waitPosInfo,1,false)
    end
    --]]
end
function CDLayerTable_mjzy:showLocationAfterGetService( isOutoClose )

    if  POS_ISOPENLOCATION_SERVICE and POS_ISOPENLOCATION_SERVICE~=0 then
        casinoclient:getInstance():sendPosWithLatLngReq(POS_PLAYER_LATITUDE,POS_PLAYER_LONGITUDE,POS_PLAYER_ADDRESS)
        self:getAllPositionInfo()
        self:showLocation(true,false,isOutoClose)
    else

        self:getPosWithSelf()
        self:waitGetPosCB(true)
    end
end
-- 刷新位置信息
function CDLayerTable_mjzy:getLocationService( isOutoClose )
    if  self:getVersionCanUsePos() then
        self:showLocationAfterGetService(isOutoClose)
    else
        dtAddMessageToScene( self, casinoclient.getInstance():findString("versionerror"))
    end
    return true
end

function CDLayerTable_mjzy:getValueIsTrue( value )
    if  value and value~=0 then
        return true
    end
    return false
end

-- 显示定位相关 1 右  2 上  3 左   space 1(1-2) 2(2-3) 3(3-1)
function CDLayerTable_mjzy:showLocation( visible,isGetService,isOutoClose)

    if  self.m_pGroupLocation == nil or self.m_nPlayers < 4 then
        return
    end
    -- 不开启位置信息时调用
    if  visible then
        self:waitGetPosCB(false)
    end

    local function hideLocation()

        for i = 1, DEF_MJZY_MAX_PLAYER-1 do

            if  self.m_pIcoLocation[i] ~= nil then
                self.m_pIcoLocation[i]:stopAllActions()
            end
            if  self.m_pGroupAddress[i] ~= nil then
                self.m_pGroupAddress[i]:stopAllActions()
            end
            if  self.m_pIPFrame[i] ~= nil then
                self.m_pIPFrame[i]:stopAllActions()
                self.m_pIPFrame[i]:setVisible( false)
            end

        end
        self.m_pGroupLocation:stopAllActions()
        self.m_pGroupLocation:setVisible( false)
    end

    local function showDistance( ... )
        for i=1,3 do
            local curOrder_1 = i
            local curOrder_2 = i+1
            if  curOrder_2 >3 then
                curOrder_2 = 1
            end
            local lat_1 = self.m_pPlayer[curOrder_1].lat
            local lng_1 = self.m_pPlayer[curOrder_1].lng
            local lat_2 = self.m_pPlayer[curOrder_2].lat
            local lng_2 = self.m_pPlayer[curOrder_2].lng
            local firstService = false
            local secondService = false
            if  self:getValueIsTrue(lat_1) and self:getValueIsTrue(lng_1) then
                firstService = true
            end
            if  self:getValueIsTrue(lat_2) and self:getValueIsTrue(lng_2) then
                secondService = true
            end
            if  firstService and secondService then
                local curDistance = math.ceil(GetDistance(lat_1,lng_1,lat_2,lng_2))
                if  self.m_pTxtLocation[i] ~= nil then
                    --正常 184  235  235 
                    --过近 254  250    0
                    local curString = nil
                    if  curDistance <=10 then
                        self.m_pTxtLocation[i]:setColor(cc.c3b(254,250,0))
                        curString =string.format(casinoclient.getInstance():findString("otherdistance_m"),curDistance)
                        self.m_pTxtLocation[i]:setString(curString)
                    else
                        if  curDistance>100000 then
                            curDistance = math.ceil(curDistance / 1000)
                            curString =string.format(casinoclient.getInstance():findString("otherdistance_km"),curDistance)
                        else
                            curString =string.format(casinoclient.getInstance():findString("otherdistance_m"),curDistance) 
                        end
                        if  curString then
                            self.m_pTxtLocation[i]:setColor(cc.c3b(184,235,235))
                            self.m_pTxtLocation[i]:setString(curString)
                        end
                    end
                end
            end
            if  not firstService and not secondService then
                local curString = casinoclient.getInstance():findString("allnoservice")
                self.m_pTxtLocation[i]:setColor(cc.c3b(254,250,0))
                self.m_pTxtLocation[i]:setString(curString)
            end
            local curName = nil
            if  not firstService and secondService then -- 第一个玩家没有开启
                curName = dtGetNickname(self.m_pPlayer[curOrder_1].nickname,self.m_pPlayer[curOrder_1].channel_nickname)
                
            end
            if  not secondService and firstService then  -- 第二个玩家没有开启
                curName = dtGetNickname(self.m_pPlayer[curOrder_2].nickname,self.m_pPlayer[curOrder_2].channel_nickname)
         
            end
            if  curName then
                local curString = string.format(casinoclient.getInstance():findString("othernoservice"),curName)
                self.m_pTxtLocation[i]:setColor(cc.c3b(254,250,0))
                self.m_pTxtLocation[i]:setString(curString)
            end
        end
    end

    local function hideIPString( ... )

        for i = 1, DEF_MJZY_MAX_PLAYER-1 do
            if  self.m_pIPFrame[i] and self.m_pIPFrame[i]:isVisible() then
                self.m_pIPFrame[i]:setVisible(false)
            end
        end
    end

    local function checkIpAddress( ... )
        local curSameArr = {}
        for i = 1, DEF_MJZY_MAX_PLAYER-2 do
            for j=2,DEF_MJZY_MAX_PLAYER-1 do
                if  i~=j then
                    if  self.m_pPlayer[i].ip_address and string.len(self.m_pPlayer[i].ip_address)>0 and 
                        self.m_pPlayer[j].ip_address and string.len(self.m_pPlayer[j].ip_address)>0 then

                        if  self.m_pPlayer[i].ip_address == self.m_pPlayer[j].ip_address then
                            if  not self.mahjong_MJZY:isFind(curSameArr,i) then
                                curSameArr[TABLE_SIZE(curSameArr)+1] = i
                            end
                            if  not self.mahjong_MJZY:isFind(curSameArr,j) then
                                curSameArr[TABLE_SIZE(curSameArr)+1] = j
                            end
                        end
                    end
                end
            
            end
        end
        return curSameArr
    end  

    if  visible then

        -- IP相关
        if  not self.m_pIPFrame[1]:isVisible() then
            local sameIP = checkIpAddress()

            local index = 0 
            for i = 1, DEF_MJZY_MAX_PLAYER-1 do
   
                if  self.m_pPlayer[i].ip_address and string.len(self.m_pPlayer[i].ip_address)>0 then

                    self.m_pIPFrame[i]:setVisible( true)
                    --  设置IP显示

                    if  self.mahjong_MJZY:isFind(sameIP,i) then
                        self.m_pIPString[i]:setColor(cc.c3b(254,255,255))
                        self.m_pIPString[i]:enableOutline( cc.c4b( 254, 0, 0, 255), 2)
                    else
                        self.m_pIPString[i]:setColor(cc.c3b(184,235,235))
                        self.m_pIPString[i]:enableOutline( cc.c4b( 255, 255, 255, 255), 0)
                    end
                    self.m_pIPString[i]:setString( string.format("IP:%s",self.m_pPlayer[i].ip_address))
                   
                    index = i
                end
            end

            if  index>0 and index <4 and isOutoClose then
                self.m_pIPFrame[index]:runAction( cc.Sequence:create( cc.DelayTime:create( 4), cc.CallFunc:create( hideIPString)))
            end
    
        end
        --[[
        if  isGetService then
            if  self:getLocationService(isOutoClose) then
                return 
            end
        end

        if  self.m_pGroupLocation:isVisible() then
            return
        end
        self.m_pGroupLocation:setVisible( true)
        -- 设置距离信息
        showDistance()

        -- 定位图标表现效果
        local fWaitB = 0.2
        local fWaitE = 1.0
        for i = 1, DEF_MJZY_MAX_PLAYER-1 do

            if  self.m_pIcoLocation[i] ~= nil then

                local sMoveBegin = self.m_pGroupLocation:convertToNodeSpace( self.m_pPlayer[i].m_sPosEnd)
                local sMoveTo = cc.p( self.m_pPosLocation[i].x, self.m_pPosLocation[i].y + 32)

                self.m_pIcoLocation[i]:setPosition( cc.p( sMoveBegin.x, sMoveBegin.y))
                self.m_pIcoLocation[i]:runAction(
                    cc.Sequence:create( 
                        cc.EaseBackOut:create( cc.MoveTo:create( 0.3, self.m_pPosLocation[i])),
                        cc.DelayTime:create( fWaitB), cc.EaseBackOut:create( cc.MoveTo:create( 0.25, sMoveTo)), 
                        cc.MoveTo:create( 0.25, self.m_pPosLocation[i]), cc.DelayTime:create( fWaitE)))

                self.m_pGroupAddress[i]:setScaleX( 0.0)
                local curLat = self.m_pPlayer[i].lat
                local curLng = self.m_pPlayer[i].lng
                local curAddress = self.m_pPlayer[i].address
                if  self:getValueIsTrue(curLat) and self:getValueIsTrue(curLng) then
                    if  curAddress and string.len(curAddress)>0 then
                        self.m_pTxtAddress[i]:setString( curAddress)
                        self.m_pGroupAddress[i]:runAction(
                            cc.Sequence:create( cc.DelayTime:create( 0.3), 
                            cc.EaseBackOut:create( cc.ScaleTo:create( 0.2, 1.0))))
                    end
                end
            end
            fWaitB = fWaitB + 0.5
        end

        -- 倒计时关闭
        if  isOutoClose then
            self.m_pGroupLocation:runAction( 
                    cc.Sequence:create( cc.DelayTime:create( 4), cc.CallFunc:create( hideLocation)))
        end
        --]]
    else

        hideLocation()
    end
end

----------------------------------------------------------------------------


----------------------------------------------------------------------------
-- 在进入飘选择界面的时候玩家就要各自归位了
-- function CDLayerTable_mjzy:onGoSelfPos(  )

--     local function closeMyFarme( ... )
--         self.m_pPlayer[0].m_pFrame:setVisible( false)
--     end

--     if  self.m_nLicensingType == 0 then
--         local effect = CDCCBAniObject.createCCBAniObject( self.m_pMahjongEff, "x_tx_kaiju.ccbi", g_pGlobalManagement:getWinCenter(), 0)
--         if  effect then
--             effect:endVisible( true)
--             effect:endRelease( true)
--         end
    
--         self.m_nLicensingType = 1
--         self:runAction( cc.Sequence:create( cc.DelayTime:create( 0.7), cc.CallFunc:create( CDLayerTable_mjzy.onGoSelfPos)))
--         dtPlaySound( DEF_MJZY_SOUND_MJ_KJ)

--     elseif self.m_nLicensingType == 1 then

--         for i = 0, self.m_nPlayers-1 do
--             local order_idx = self:changeOrder( i)
--             self.m_pPlayer[order_idx].m_pFrame:runAction( 
--                 cc.Sequence:create( cc.EaseBackOut:create( cc.MoveTo:create( 0.3, self.m_pPlayer[order_idx].m_sPosEnd)), cc.ScaleTo:create( 0.1, 0.85)))
--         end
    
--         self.m_pGroupSelfBuild:setVisible( false)
        
--         local e_pos = cc.p( self.m_pGroupBar:getPositionX(), self.m_pGroupBar:getPositionY())
--         local b_pos = cc.p( e_pos.x, e_pos.y - 50)
--         self.m_pGroupBar:setVisible( true)
--         self.m_pGroupBar:setPosition( b_pos)
--         self.m_pGroupBar:runAction( cc.EaseBackOut:create( cc.MoveTo:create( 0.2, e_pos)))
--         self.m_pGroupBar:runAction( cc.Sequence:create( cc.DelayTime:create( 0.3), cc.CallFunc:create( closeMyFarme)))
--         dtPlaySound( DEF_SOUND_MOVE)
--         self:onShowPiao(true)
--         self:showWaitTime(5)
--     end
    
-- end

----------------------------------------------------------------------------
-- 重新进入游戏加载桌面显示数据（由于飘阶段也会用到 所以提取出来）
function CDLayerTable_mjzy:detailTableData( data )
    self.m_bInTheGame = true
    -- 初始化必要元素: 湖北江陵晃晃数学库，赖子，初始化桌子
    if  not self.mahjong_MJZY then
        self.mahjong_MJZY = CDMahjongMJZY.create()
    end
    self.mahjong_MJZY:setMahjongLaiZi(data.laizi)
    self.mahjong_MJZY:setMahjongFan(data.fanpai)
    g_pGlobalManagement:setLaiZi(data.laizi)
    self:initTable()

    -- 设置及显示麻将牌剩余总数
    local client_tabledata = casinoclient:getInstance():getTable()
    if  client_tabledata.play_total > 0 then
        client_tabledata.play_total = client_tabledata.play_total - 1
    end --重连的时候服务器会把游玩次数加一，这里要减一才对上
    self.mahjong_MJZY:mahjongTotal_set( data.cardcount)
    self:refreshTableInfo()
end

----------------------------------------------------------------------------
-- 关闭按钮组处理
function CDLayerTable_mjzy:detailCloseFrame(boolean)
    cclog( "CDLayerTable_mjzy:detailCloseFrame")
    -- local forgotType = 0
    -- local curCancelType = -1 
    if  boolean == nil then
        boolean = false
    end

    if not boolean then
        -- 弃杠后，需要对可以杠的牌进行标记
        if  self.m_bSaveOPGFlag and self.m_nSaveOPGMahjong ~= 0 then
            local opg_mahjong = self.m_nSaveOPGMahjong  -- 记录因为myMahjong_addForgo中会清除
            self:myMahjong_addHuangButton( opg_mahjong) -- 添加麻将操作按钮

        -- 弃碰，把被弃掉的牌添加到弃牌组中
        elseif  self.m_bSaveOPPFlag and self.m_nSaveOPPMahjong ~= 0 then
            self:myMahjong_addForgo( 1, self.m_nSaveOPPMahjong, true)
            casinoclient.getInstance():mjzy_sendOpReq(DEF_MJZY_PENG, self.m_nSaveOPPMahjong, 0, DEF_MJZY_PENG, DEF_MJZY_PENG)
        end
            
        -- 弃胡，假如之前OP是捉铳
        if  self.m_bSaveZCHFlag then
            casinoclient.getInstance():mjzy_sendOpReq(DEF_MJZY_BUZHUOCHONG, 0, 0, 1)
            self.m_bSaveZCHFlag = false

        elseif self.m_bOPSelf then
            casinoclient.getInstance():mjzy_sendOpReq(0, 0, 0, 1)
        end

        -- 放弃后提示自己打牌
        if  (not self.m_bOPSelf) and self.m_nOrderType == 0 then
            self:setGroupTipVisible(true)
        end
        self:forgotHuTip()
    else
        casinoclient.getInstance():mjzy_sendOpReq(0, 0, 0, 1)
    end

    --跑风
    if not self.m_pBut_Type[DEF_MJZY_BUT_TYPE_PAOFENG]:isGrey() then
        self:setMyMahjongGrayAfterFangFeng(self.m_nPaoFengArr,false)
    end

end

----------------------------------------------------------------------------
-- ccb处理
-- 变量绑定
function CDLayerTable_mjzy:onAssignCCBMemberVariable(loader)
    cclog("CDLayerTable_mjzy::onAssignCCBMemberVariable")

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

    for i = 1, DEF_MJZY_TING_LIST_MAX do
        self.m_pTingNumFrame[i] = loader["lost_frame_"..i]
        self.m_pTingNumText[i] = loader["lost_number_"..i]        
    end

    for i = 0, DEF_MJZY_MAX_PLAYER-1 do
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
    end

    self.m_pRecordButton = loader["record_demo"]

    self.m_pCenterDire = loader["dire_demo"]

    for i = 1, DEF_MJZY_BUT_TYPE_PAOFENG do
        self.m_pBut_Type[i] = loader["button_type"..i]
        self.m_pBut_Text[i] = loader["button_text"..i]
    end

    --放风的节点组
    self.m_pGroupFangFengBtn = loader["fangfeng_group"]
    --放风的按钮 
    for i = 1, 2 do
        self.m_pFangFengBut_Type[i] = loader["btn_fangfeng"..i]
        self.m_pFangFengText[i]     = loader["text_fangfeng"..i]
    end

    self.m_pGroupFangFengChooseBtn = loader["fangfeng_mahSelect_group"]
    for i=1,2 do
        self.m_pFangFengChooseBut[i] = loader["btn_queding"..i]
        self.m_pFangFengChooseText = loader["text_queding"..i]
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
    self.m_pTipMessage = loader["tip_message"]

    self.m_pStageDemo = loader["stage_demo"]
    self.m_pLighting = loader["pic_alpha"]

    self.m_pGroupForgo = loader["group_forgo"]
    self.m_pForgoMessage = loader["message_forgo"]

     --吃
    self.m_pChiGroup = loader["chi_group"]
    for i=1,DEF_MJZY_CHI_LIST_MAX do
        self.m_pChiFarme[i].m_pChiButton = loader["button_chi_"..i]
    end
    self.m_nChiList = loader["chi_list"]
    self.m_pButtonChi = loader["buttonChi"]
    self.m_pChiGroupFarme = loader["chi_group_frame"]

    -- 开局飘
    -- self.m_pPiaoGroup = loader["piao_group"]
    -- for i=1,DEF_MJZY_MAX_BUT_PIAO do
    --     self.m_pPiaoButton[i].m_pButton = loader["piaoButton_"..i]
    --     self.m_pPiaoButton[i].m_pText = loader["piaoText_"..i]
    -- end

    self.m_pJoinTypeMsg = loader["join_type"]

    -- 定位相关变量绑定--MapLocation
    self.m_pButLocation = loader["but_location"]
    self.m_pGroupLocation = loader["group_location"]
    for i = 1, DEF_MJZY_MAX_PLAYER-1 do
        self.m_pIcoLocation[i] = loader["location"..i]
        self.m_pTxtLocation[i] = loader["space"..i]
        self.m_pGroupAddress[i]= loader["group_address"..i]
        self.m_pTxtAddress[i]  = loader["txt_address"..i]
        if  self.m_pIcoLocation[i] ~= nil then
            self.m_pPosLocation[i] = cc.p( self.m_pIcoLocation[i]:getPositionX(), self.m_pIcoLocation[i]:getPositionY())
        end
    end

    -- IP相关
    for i = 1, DEF_MJZY_MAX_PLAYER-1 do
        self.m_pIPFrame[i] = loader["player_ipframe"..i]
        self.m_pIPString[i] = loader["player_ip"..i]
    end
end

----------------------------------------------------------------------------
-- ccb处理
-- 函数绑定
function CDLayerTable_mjzy:onResolveCCBCCControlSelector(loader)

    cclog("CDLayerTable_mjzy::onResolveCCBCCControlSelector")
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

    loader["onChi"] = function() self:onChiPai() end
    loader["onChi_one"] = function() self:onChi_Group_one() end  
    loader["onChi_two"] = function() self:onChi_Group_two() end 
    loader["onChi_three"] = function() self:onChi_Group_three() end  
    loader["onCloseChi"] = function() self:onCloseChi() end

 
    loader["onSendFangFeng"]  = function() self:onSendFangFeng()  end
    loader["onCloseFangFeng"] = function() self:onCloseFangFeng() end

    loader["onSendQueDing"]   = function() self:onSendQueDing() end
    loader["onCloseQuXiao"]   = function() self:onCloseQuXiao() end
    loader["onPaoFeng"]       = function() self:onPaoFeng() end

    --MapLocation
    loader["onLocation"] = function() self:onLocation() end

end

----------------------------------------------------------------------------
-- create
function CDLayerTable_mjzy.createCDLayerTable_mjzy(pParent)
    cclog("CDLayerTable_mjzy::createCDLayerTable_mjzy")
    if not pParent then
        return nil
    end
    local layer = CDLayerTable_mjzy.new()
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
