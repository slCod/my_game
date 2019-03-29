--[[
/******************************************************
//Project:      ProjectX 
//Moudle:       CDLayerHHLLKMahjongTable_tpgs 仙桃赖子斗地主桌子
//File Name:    DLayerHHLLKMahjongTable_tpgs.h
//Author:       GostYe
//Start Data:   2016.12.27
//Language:     XCode 4.5
//Target:       IOS, Android

-- 在调用前，需要先设置 m_nHHLLKPlayers 玩家
-- 进入类后，先调用createUserInterface

******************************************************/
]]

require( REQUIRE_PATH.."DDefine")
require( REQUIRE_PATH.."DCCBLayer")
require( REQUIRE_PATH.."DTKDScene")
require( "tpgs_game.HHLLK_mahjong_tpgs_ai")
require( "tpgs_game.HHLLK_llk_item")
require( "tpgs_game.HHLLK_mahjong_define")

local casinoclient = require("script.client.casinoclient")
local platform_help = require("platform_help")

-- 音效定义
DEF_PROJCETHHLLK_SOUND_MJ_CLICK      = "tpgs_click_mahjong"..DEF_TKD_SOUND     -- 点中牌
DEF_PROJCETHHLLK_SOUND_MJ_KJ         = "mj_kj"..DEF_TKD_SOUND                  -- 开局

DEF_PROJCETHHLLK_SOUND_MJ_ERROR      = "tpgs_click_error"..DEF_TKD_SOUND       -- 选择错误
DEF_PROJCETHHLLK_SOUND_MJ_OK         = "tpgs_click_ok"..DEF_TKD_SOUND          -- 选择正确
DEF_PROJCETHHLLK_SOUND_MJ_COUNT_DOWN = "tpgs_count_down"..DEF_TKD_SOUND        -- 倒计时
DEF_PROJCETHHLLK_SOUND_MJ_SCORE      = "tpgs_score"..DEF_TKD_SOUND             -- 结算
DEF_PROJCETHHLLK_SOUND_MJ_TIME_OVER  = "tpgs_time_over"..DEF_TKD_SOUND         -- 时间结束

-----------------------------------------
-- 类定义
CDLayerHHLLKMahjongTable_tpgs = class("CDLayerHHLLKMahjongTable_tpgs", CDCCBLayer)    
CDLayerHHLLKMahjongTable_tpgs.__index = CDLayerHHLLKMahjongTable_tpgs
CDLayerHHLLKMahjongTable_tpgs.name = "CDLayerHHLLKMahjongTable_tpgs"

-- 构造函数
function CDLayerHHLLKMahjongTable_tpgs:ctor()
    cclog("CDLayerHHLLKMahjongTable_tpgs::ctor")
    CDLayerHHLLKMahjongTable_tpgs.super.ctor(self)
    CDLayerHHLLKMahjongTable_tpgs.initialMember(self)
    --reg enter and exit
    local function onNodeEvent(event)
        if "enter" == event then
            CDLayerHHLLKMahjongTable_tpgs.onEnter(self)
        elseif "exit" == event then
            CDLayerHHLLKMahjongTable_tpgs.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDLayerHHLLKMahjongTable_tpgs:onEnter()
    cclog("CDLayerHHLLKMahjongTable_tpgs::onEnter")

    -- 网络事件
    local   listeners = {
        -- { casino.MSG_PING,                      handler( self, self.Handle_Ping)},
        -- { casino.MSG_TABLE_SCORE,               handler( self, self.Handle_Table_Score)},
        -- { casino.MSG_TABLE_PAUSE,               handler( self, self.Handle_Table_Pause)},
    
        -- { casino_ddz.DDZ_MSG_SC_STARTPLAY,      handler(self, self.Handle_llk_StartPlay)},               -- 游戏开始消息

        -- 
    }

    casinoclient.getInstance():addEventListeners(self,listeners)

    --暂时使用的心跳循环
    self:createHeartbeatLoop()
    self:restoreTimeCount()
end

function CDLayerHHLLKMahjongTable_tpgs:onExit()
    cclog("CDLayerHHLLKMahjongTable_tpgs::onExit")

    -- 关闭计时器
    if self.m_pRestoreTime then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_pRestoreTime)   
        self.m_pRestoreTime = nil
    end
    self:stopGameRestoreTime()

    -- 退出时，停止发送心跳
    self:stopHeartLoop()
    self:stopAllActions()

    casinoclient.getInstance():removeListenerAllEvents(self)
    CDLayerHHLLKMahjongTable_tpgs.releaseMember(self)
    self:unregisterScriptHandler()
end

-----------------------------------------
-- 计时器
function CDLayerHHLLKMahjongTable_tpgs:restoreTimeCount()
    local nTmpTimeTotle = g_pHHLLKGlobalManagment.m_nTiming

    local function countTiming()
        nTmpTimeTotle = nTmpTimeTotle + 1
        if nTmpTimeTotle >= DEF_PROJCETHHLLK_LLK_PHY_RESTORE_TIME then
            nTmpTimeTotle = 0

            local nTmpPhysicalValue = g_pHHLLKGlobalManagment.nTmpPhysicalValue + DEF_PROJCETHHLLK_LLK_PHY_RESTORE
            if  nTmpPhysicalValue > DEF_PROJCETHHLLK_LLK_PHY_TOTLE then
                nTmpPhysicalValue = DEF_PROJCETHHLLK_LLK_PHY_TOTLE
            end
            g_pHHLLKGlobalManagment:setLLKTmpPhysical(nTmpPhysicalValue)

            -- 恢复体力刷新界面
            -- self:refreshTableCheckPoint()
        end
        g_pHHLLKGlobalManagment:setLLKTiming(nTmpTimeTotle)
    end

    if  self.m_pRestoreTime == nil then
        self.m_pRestoreTime = cc.Director:getInstance():getScheduler():scheduleScriptFunc(countTiming, 1, false)
    end
end

function CDLayerHHLLKMahjongTable_tpgs:gameRestoreTimeCount()
    local function gameRestore()
        self.m_nHHLLKLeftTime = self.m_nHHLLKLeftTime - 1
        self.m_nUsedTime = self.m_nUsedTime +1
        self.m_pHHLLKLableLeftSecond:setString(self.m_nHHLLKLeftTime)
        if  self.m_nHHLLKLeftTime <= 0 then
            self:stopGameRestoreTime()
            self:dataToDetermine(nil, true)
        end
        --另一种模式下倒计时10秒再播放声音
        if self.m_nHHLLKFlag == 4 then
            if self.m_nHHLLKLeftTime < 10 then
                dtPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_COUNT_DOWN)
            end
        else
            dtPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_COUNT_DOWN)
        end
    end

    if  self.m_pGameRestoreTime == nil then
        self.m_pGameRestoreTime = cc.Director:getInstance():getScheduler():scheduleScriptFunc(gameRestore, 1, false)
    end
end

function CDLayerHHLLKMahjongTable_tpgs:stopGameRestoreTime()

    self.m_pHHLLKPlayAI:addTotalTime(self.m_nUsedTime)
    print("总计时间------",self.m_pHHLLKPlayAI:getTotalTime())
    self.m_nUsedTime = 0
    if self.m_pGameRestoreTime then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.m_pGameRestoreTime)   
        self.m_pGameRestoreTime = nil
    end
end

-----------------------------------------
-- 初始化
function CDLayerHHLLKMahjongTable_tpgs:initialMember()
    cclog("CDLayerHHLLKMahjongTable_tpgs::initialMember")

    ---------------------------------------------------
    -- 底部的状态信息 
    self.m_pHHLLKGroupBar        = nil        -- 状态按钮根节点
    self.m_pHHLLKButSetting      = nil        -- 设置按钮
    self.m_pHHLLKSelfInfo        = nil        -- 自己的信息
    self.m_pHHLLKTableInfo       = nil        -- 桌子的信息

    ---------------------------------------------------
    -- 桌子中相关'节点'与'层''
    self.m_pHHLLKNewEffLayer     = nil        -- 特效层
    self.m_pHHLLKNewLayerRoot    = nil        -- 桌面麻将放置的根节点
    self.m_pHHLLKLighting        = nil        -- 灯光
    self.m_pHHLLKMahjongEffDemo  = nil        -- 特效放置层
    self.m_pHHLLKMahjongDemo     = nil        -- 麻将放置层

    ---------------------------------------------------
    -- 电池
    self.m_pHHLLKIcoPower        = nil        -- 电池图标

    ---------------------------------------------------
    -- 技能
    self.m_pHHLLKSkillBar        = nil        -- 技能根Node
    self.m_pHHLLKOnTipBtn        = nil        -- 技能：提示按钮
    self.m_pHHLLKOnResetBtn      = nil        -- 技能：重置按钮
    self.m_pHHLLKTipExpLabel     = nil        -- 提示技能消耗文本
    self.m_pHHLLKResetExpLabel   = nil        -- 重置技能消耗文本

    ---------------------------------------------------
    -- 游戏相关变量定义
    self.m_pHHLLKPlayAI          = nil        -- 玩家AI
    ---------------------------------------------------
    self.m_pHHLLKPlayer          = {}         -- 玩家
    self.m_pHHLLKPlayer.name     = ""         -- 玩家姓名
    self.m_pHHLLKPlayer.gold     = 0          -- 玩家货币
    ---------------------------------------------------
    self.m_pHHLLKListener        = nil        -- 监听对象
    self.mahjongMath_llk         = nil        -- 麻将连连看数学库  

    self.m_pHHLLKEffNetLow       = nil        -- 网络连接缓慢提示特效
    self.m_bHHLLKPreCreate       = false      -- 是否预创建过
    self.m_bHHLLKCanTouch        = false      -- 是否可以进行点击

    ---------------------------------------------------
    -- UI对象
    self.m_pHHLLKSpriteLiftGroup = nil        -- 心图片控件集合
    self.m_pHHLLKLableLevelTitle = nil        -- 关卡title控件
    self.m_pHHLLKLableMaxScore   = nil        -- 最大积分控件
    self.m_pHHLLKNodeNaoZhong    = nil        -- 闹子节点控件
    self.m_pHHLLKLableLeftSecond = nil        -- 剩余时间控件
    self.m_pHHLLKLayerTip        = nil        -- 提示层控件
    self.m_pHHLLKSpriteTimeOver  = nil        -- 时间到图片控件
    self.m_pHHLLKSpriteOk        = nil        -- 正确图片控件
    self.m_pHHLLKSpriteErr       = nil        -- 错误图片控件
    self.m_pHHLLKLableTotleScore = nil        -- 总积分控件
    self.m_pHHLLKTableTotalRound = nil        -- 总局数控件
    self.m_pHHLLKTableTotalTime  = nil        -- 总时间控件


    self.m_pHHLLKButtonGoHome    = nil        -- 回到大厅控件
    self.m_pHHLLKButtonReGame    = nil        -- 重新开始游戏控件

    ---------------------------------------------------
    -- 数据对象
    self.m_nHHLLKFlag            = nil        -- 游戏类型(1、简单 2、普通 3、困难)
    self.m_nHHLLKNowCheckPoint   = 1          -- 当前关卡
    self.m_nHHLLKLeftTime        = 0          -- 倒计时
    self.m_nUsedTime             = 0          -- 用的时间
    self.m_pHHLLKArrayShowMahjong = nil        -- 胡字麻将选择组(二维)
    self.m_pHHLLKArrayMahjongs   = nil        -- 手中的听牌组麻将
    self.m_pHHLLKConfigData      = {}         -- 棋牌的配置数据

    self.m_bIsFirstTouch         = true       -- 是否第一次点击
    self.m_canTouchMah           = {}

    self.m_bNeedRefreshData      = true       -- 是否要刷新麻将的数据
end

function CDLayerHHLLKMahjongTable_tpgs:releaseMember()
    cclog("CDLayerHHLLKMahjongTable_tpgs::releaseMember")

    if  self.m_pHHLLKNewEffLayer then
        self.m_pHHLLKNewEffLayer:removeAllChildren()
    end

    if  self.m_pHHLLKNewLayerRoot ~= nil then
        self.m_pHHLLKNewLayerRoot:removeAllChildren()
        self.m_pHHLLKEffNetLow = nil
    end

    --模拟析构父类
    CDLayerHHLLKMahjongTable_tpgs.super.releaseMember(self)
    if  DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end

    if self.m_pHHLLKListener then
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:removeEventListener(self.m_pHHLLKListener)
        self.m_pHHLLKListener = nil
    end
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------

--===============================网络消息处理===============================--

-- 心跳包
-- 参数: 数据包
function CDLayerHHLLKMahjongTable_tpgs:Handle_Ping( __event)
    cclog("CDLayerHHLLKMahjongTable_tpgs:Handle_Ping")
    local function badNetWork() -- 网络恢复缓慢
        if  self.m_bHHLLKInTheGame then

            self.m_pHHLLKNewLayerRoot:stopAllActions()
            self.m_pHHLLKEffNetLow:setVisible( false)

            casinoclient.getInstance().m_socket:onDisconnect() --超时太多断线重连
            dtPlaySound( DEF_SOUND_ERROR)
        end
    end

    local function netRefreshTimeOut()
        if  self.m_bHHLLKInTheGame then
            self.m_nHHLLKTimeOut = self.m_nHHLLKTimeOut - 1
            if  self.m_nHHLLKTimeOut < 0 then
                self.m_nHHLLKTimeOut = 0
            end
            self.m_pHHLLKEffNetLow:setDefineText( 
                string.format( casinoclient.getInstance():findString("net_low"), self.m_nHHLLKTimeOut))

            if  self.m_nHHLLKTimeOut > 0 then

                self.m_pHHLLKNewLayerRoot:stopAllActions()
                self.m_pHHLLKNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( netRefreshTimeOut)))
            else
                self.m_pHHLLKNewLayerRoot:stopAllActions()
                self.m_pHHLLKNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( badNetWork)))
            end
        end
    end

    local function netTimeOut() -- 超时提示
        if self.m_bHHLLKInTheGame then
            self.m_nHHLLKTimeOut = DEF_TIMEOUT1
            self.m_pHHLLKEffNetLow:setVisible( true)
            self.m_pHHLLKEffNetLow:setDefineText( 
                string.format( casinoclient.getInstance():findString("net_low"), self.m_nHHLLKTimeOut))

            self.m_pHHLLKNewLayerRoot:stopAllActions()
            self.m_pHHLLKNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( 1.0), cc.CallFunc:create( netRefreshTimeOut)))
            dtPlaySound( DEF_SOUND_ERROR)
        end
    end

    -- 假如提示资源存在那么显示
    if  self.m_pHHLLKNewLayerRoot ~= nil and self.m_pHHLLKEffNetLow ~= nil then
        self.m_pHHLLKEffNetLow:setVisible( false)
        self.m_pHHLLKNewLayerRoot:stopAllActions()
        self.m_pHHLLKNewLayerRoot:runAction( cc.Sequence:create( cc.DelayTime:create( DEF_PROJCETHHLLK_HEARTBEAT_SPACETIME), cc.CallFunc:create( netTimeOut)))
    end
    return true
end

-- 循环发送心跳包
function CDLayerHHLLKMahjongTable_tpgs:createHeartbeatLoop( ... )
    local waitTime=0
    local function sendHeartLoop( event )
        waitTime=waitTime+1
        if  waitTime > 30 then
            waitTime = 0
            casinoclient.getInstance():sendPong()
        end
    end
    if  not self.schedulerID then
        self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(sendHeartLoop,1,false)
    end
end

-- 停止发送心跳包
function CDLayerHHLLKMahjongTable_tpgs:stopHeartLoop( ... )
    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
end

----------------------------------------------------------------------------
-- 暂停
-- 参数: 数据包
function CDLayerHHLLKMahjongTable_tpgs:Handle_Table_Pause( __event)
    cclog("CDLayerHHLLKMahjongTable_tpgs:Handle_Table_Pause")
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
-- 所有玩家准备结束，可以进行发牌的反馈
-- 参数: 数据包
function CDLayerHHLLKMahjongTable_tpgs:Handle_llk_StartPlay(__event)
    cclog("CDLayerHHLLKMahjongTable_tpgs:Handle_llk_StartPlay")

    -- 开始游戏后，关闭主场景中的不相关场景
    g_pSceneTable:closeAllUserInterface()

    --模式4下重置
    if self.m_nHHLLKFlag == 4 then
        self.m_bIsFirstTouch = true
    end

    -- 更新 
    self:refreshTableLeftScore()

    -- 重置桌面上的牌
    self:initAllMahjong()

    -- title设置
    local sTmpTitleStr = string.format(casinoclient.getInstance():findString("llk_level"), self.m_nHHLLKNowCheckPoint)
    self.m_pHHLLKLableLevelTitle:setString(sTmpTitleStr)

    -- 获取当前局的配置数据(先清空数据)

    if self.m_bNeedRefreshData then
        self.m_pHHLLKConfigData = {}
        self.m_pHHLLKConfigData = self.mahjongMath_llk:getRandmMahjongConfig()
    end

    -- 开始生成牌数据
    self.m_bHHLLKInTheGame = true
    self:stopAllActions()
    self.m_nHHLLKLicensingType = 0

    self:round_licensingPlayer()

    return true
end

----------------------------------------------------------------------------
-- 重连
-- 参数: 数据包
function CDLayerHHLLKMahjongTable_tpgs:Handle_xtlzddz_Reconnect( __event)
    cclog("CDLayerHHLLKMahjongTable_tpgs:Handle_xtlzddz_Reconnect")

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    -- 重连上来获取报警牌数据
    self.m_nHHLLKLeftCardWarning = casinoclient:getInstance():getTable().fanpai

    local index = self:getTableIndexWithID(pAck.player_id)
    if self.m_pHHLLKPlayAI[index] then
        self.m_pHHLLKPlayAI[index]:addMultiple(pAck.card)

        if index == 0 then
            self:refreshMultiple()
        end
    end

    return true
end

----------------------------------------------------------------------------
-- 重置电量
function CDLayerHHLLKMahjongTable_tpgs:resetPower()
    local function updatePower()
        local power = platform_help.getBatterLevel()
        if  power > 100 then
            power = 100
        elseif power < 0 then
            power = 0
        end
    
        local width = power * 0.01 * 33
        local size = self.m_pHHLLKIcoPower:getContentSize()
        size.width = width
        self.m_pHHLLKIcoPower:setContentSize(size)
        self.m_pHHLLKIcoPower:runAction(cc.Sequence:create(cc.DelayTime:create(60.0), cc.CallFunc:create(updatePower)))
    end
    updatePower()
end

----------------------------------------------------------------------------
-- 重置桌子数据
-- 参数: data桌子数据
function CDLayerHHLLKMahjongTable_tpgs:resetTableData(data)
    cclog( "CDLayerHHLLKMahjongTable_tpgs:resetTableData")
end

--=================================基本方法=================================--
----------------------------------------------------------------------------
-- 倒计时转到结算
-- function CDLayerHHLLKMahjongTable_tpgs:showLeftTimeGotoScore()
--     cclog( "CDLayerHHLLKMahjongTable_tpgs:showLeftTimeGotoScore")

--     if  not self.m_pHHLLKTimeLeftTTF:isVisible() then
--         self.m_pHHLLKTimeLeftTTF:setVisible( true)
--     end

--     local function leftTime_low()
--         self.m_pHHLLKTimeLeftTTF:stopAllActions()
--         if  self.m_nHHLLKTimeLeft <= 0 then

--             -- 临时增加的判断为了避免在下一局开始的时候进入到结算画面
--             if  not self.m_bHHLLKInTheGame then
--                 self:initTable()

--                 self.m_pHHLLKPlayer[0].m_pHHLLKFrame:setPosition(self.m_pHHLLKPlayer[0].m_sPosEnd)
--                 self.m_pHHLLKPlayer[0].m_pHHLLKFrame:setVisible(false)

--                 g_pSceneTable:closeAllUserInterface()
--                 g_pSceneTable.m_pHHLLKLayerMJScore:open(g_pHHLLKGlobalManagment:getScoreData(), self.mahjongMath_llk, self.m_nHHLLKScoreTime)
--                 self:showLocation(false)
--             end
--         else
--             self.m_pHHLLKTimeLeftTTF:setString( string.format( "%d", self.m_nHHLLKTimeLeft))
--             self.m_pHHLLKTimeLeftTTF:setScale( 3.0)
--             self.m_pHHLLKTimeLeftTTF:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1.0)), cc.DelayTime:create( 0.75), cc.CallFunc:create( leftTime_low)))

--             self.m_nHHLLKTimeLeft = self.m_nHHLLKTimeLeft - 1
--             if  self.m_nHHLLKTimeLeft < 0 then
--                 self.m_nHHLLKTimeLeft = 0
--             end
--         end
--     end
--     leftTime_low()
-- end

----------------------------------------------------------------------------
-- 设置玩家自己的昵称
function CDLayerHHLLKMahjongTable_tpgs:refreshSelfInfo()
    local tmpStr = string.format(casinoclient.getInstance():findString("llk_name"), self.m_pHHLLKPlayer.name)
    self.m_pHHLLKSelfInfo:setString(tmpStr)
end

-- 设置玩家积分信息
function CDLayerHHLLKMahjongTable_tpgs:refreshTableLeftScore()
    local tmpStr = 0
    if  self.m_pHHLLKPlayAI then
        tmpStr = string.format(casinoclient.getInstance():findString("llk_left_sorce"), self.m_pHHLLKPlayAI.m_nHHLLKTableLeftScore)
    end
    self.m_pHHLLKTableInfo:setString(tmpStr)
end

function CDLayerHHLLKMahjongTable_tpgs:refreshTableMaxScore()
    self.m_pHHLLKLableMaxScore:setString(g_pHHLLKGlobalManagment.m_tTotleScore[self.m_nHHLLKFlag])
end

-- 初始化界面
----------------------------------------------------------------------------
-- 创建用户界面
function CDLayerHHLLKMahjongTable_tpgs:createUserInterface(flag)
    cclog("CDLayerHHLLKMahjongTable_tpgs::createUserInterface")

    -- 设置难度、行列数据
    self.m_nHHLLKFlag = flag

    g_pHHLLKGlobalManagment:setLLKMode(self.m_nHHLLKFlag)
    -- 创建数学库
    self.mahjongMath_llk = CDMahjongHHLLKTPGSMath.create()
    -- 创建AI库
    self.m_pHHLLKPlayAI = CDMahjongHHLLKTPGS_AI.create()
    self.m_nHHLLKLeftTime, self.m_pHHLLKPlayAI.m_nLeftLife = self.mahjongMath_llk:getFlagConfig(self.m_nHHLLKFlag)

    -- 生命值图标显示
    for i, v in ipairs( self.m_pHHLLKSpriteLiftGroup ) do
        if  i <= self.m_pHHLLKPlayAI.m_nLeftLife then
            v:setVisible(true)
        else
            v:setVisible(false)
        end
    end

    -- 获取并生产玩家数据
    local nickname = casinoclient.getInstance():getPlayerData():getNickname()
    local channelNickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
    self.m_pHHLLKPlayer.name = dtGetNickname(nickname, channelNickname)
    self.m_pHHLLKPlayer.gold = casinoclient:getInstance():getPlayerData():getPlayerResourceGold()
    self:refreshSelfInfo()
    self:refreshTableMaxScore()

    -- 创建桌面需要特效放置层
    self.m_pHHLLKMahjongEffDemo = cc.Layer:create()
    self.m_pHHLLKNewLayerRoot:addChild(self.m_pHHLLKMahjongEffDemo)

    self.m_pHHLLKMahjongDemo = cc.Layer:create()
    self.m_pHHLLKNewLayerRoot:addChild(self.m_pHHLLKMahjongDemo)

    self.m_pHHLLKOnResetBtn:setVisible(false)
    self.m_pHHLLKOnTipBtn:setVisible(false)

    -- 预创建牌
    self.m_bHHLLKPreCreate = false
    self:preCreateLLKMahjong()

    -- 重置电量
    self:resetPower()

    -- 进入准备流程
    self:onReady()
end

-- 预创建牌
function CDLayerHHLLKMahjongTable_tpgs:preCreateLLKMahjong()
    cclog( "CDLayerHHLLKMahjongTable_tpgs:preCreateLLKMahjong")

    if  self.m_bHHLLKPreCreate then
        return
    end

    -- 计算桌面中心点位置
    local offset_y = self.m_pHHLLKNewLayerRoot:getContentSize().height * (self.m_pHHLLKGroupBar:getContentSize().height - 120) / 640
    local offset_my_y = self.m_pHHLLKGroupBar:getContentSize().height

    local center_x = self.m_pHHLLKNewLayerRoot:getPositionX()
    local center_show_y = self.m_pHHLLKNewLayerRoot:getPositionY() - offset_y
    local center_my_y = self.m_pHHLLKNewLayerRoot:getPositionY() - offset_my_y
    print("center_x----------->",center_x)
    -- 预创建手上的牌组
    self.m_pHHLLKArrayMahjongs = {}
    local nTmpMaxMahjongNum = 13

    --另一种模式下要展示14张牌，其中两张背面显示
    if self.m_nHHLLKFlag == 4 then
        nTmpMaxMahjongNum = 14
    end

    local nTmpFirst_x = 0
    local nTmpFirst_y = 0
    for i = 1, nTmpMaxMahjongNum do
        local mahjong = X_MAHJONG:new()
        mahjong.m_pMahjong = CDHHLLKMahjong.createCDMahjong(self.m_pHHLLKMahjongDemo)
        if self.m_nHHLLKFlag == 4 then
            mahjong.m_pMahjong:setMahjongScale(0.9)
            mahjong.m_pMahjong.m_nSizeW = mahjong.m_pMahjong.m_nSizeW * 0.9
        end

        if  i == 1 then
            local nTmpTotleMahjongWidth = mahjong.m_pMahjong.m_nSizeW * nTmpMaxMahjongNum
            nTmpFirst_x = center_x - nTmpTotleMahjongWidth / 2 + mahjong.m_pMahjong.m_nSizeW / 2 
            if self.m_nHHLLKFlag == 4 then
                nTmpFirst_x = nTmpFirst_x +12
            end
            nTmpFirst_y = offset_my_y + mahjong.m_pMahjong.m_nSizeH / 2 + 10
        end
        mahjong.m_nMahjong = 11
        mahjong.m_pMahjong:setMahjongNumber( 11)
        mahjong.m_pMahjong:initMahjongWithFile( "my_b_11.png",  "mj_b_back.png")
        mahjong.m_pMahjong:setVisible( false)
        mahjong.m_pMahjong:setPosition(cc.p(nTmpFirst_x + mahjong.m_pMahjong.m_nSizeW * (i - 1), nTmpFirst_y))
        table.insert( self.m_pHHLLKArrayMahjongs, mahjong)
    end

    -- 预创建展示用听牌牌组
    self.m_pHHLLKArrayShowMahjong = {}
    nTmpMaxMahjongNum = 9
    nTmpFirst_x = 0
    nTmpFirst_y = 0
    for i = 1, 2 do
        for j = 1, nTmpMaxMahjongNum do
            local mahjongItem = CDTPGSMahjongItem.createCDMahjong(self.m_pHHLLKMahjongDemo)
            if i == 1 and j == 1 then
                nTmpFirst_x = center_x - (mahjongItem.m_nHHLLKSizeW * nTmpMaxMahjongNum) / 2 + mahjongItem.m_nHHLLKSizeW / 2
                nTmpFirst_y = center_show_y + mahjongItem.m_nHHLLKSizeH / 2
            elseif i == 2 and j == 1 then
                nTmpFirst_y = center_show_y - mahjongItem.m_nHHLLKSizeH / 2
            end

            mahjongItem:setVisible(false)
            mahjongItem:setPosition(cc.p(nTmpFirst_x + mahjongItem.m_nHHLLKSizeW * (j - 1), nTmpFirst_y))
            table.insert(self.m_pHHLLKArrayShowMahjong, mahjongItem)
        end
    end

    self.m_bHHLLKPreCreate = true
end

----------------------------------------------------------------------------
-- 根据指定的坐标点选择牌
-- 参数: 坐标点
function CDLayerHHLLKMahjongTable_tpgs:touchMahjongFromPoint(point)
    cclog("CDLayerHHLLKMahjongTable_tpgs::touchMahjongFromPoint")
    for i, v in ipairs(self.m_pHHLLKArrayShowMahjong) do
        if v:checkWithTouchPoint(point) then
            dtPlaySound(DEF_PROJCETHHLLK_SOUND_MJ_CLICK)
            -- 判断点选的是否正确
            self:dataToDetermine(v,false,self.m_nHHLLKFlag)
    
            return true
        end
    end
    return false
end

--另一种模式下，能否继续点击
function CDLayerHHLLKMahjongTable_tpgs:canContinueTouch(mahValue)
    local tempArr = {}
    self.mahjongMath_llk:push_back(tempArr,self.m_pHHLLKConfigData.t_ShowMj,1,TABLE_SIZE(self.m_pHHLLKConfigData.t_ShowMj))
   
    dumpArray(tempArr)

    local bCanContinueTouch ,saveTouchArr = self.mahjongMath_llk:checkCanHu(tempArr,mahValue)
    if bCanContinueTouch then
      
        self.m_canTouchMah = {}
        self.mahjongMath_llk:push_back(self.m_canTouchMah,saveTouchArr,1,TABLE_SIZE(saveTouchArr))
        dumpArray(self.m_canTouchMah)
        return true
    else
        return false
    end
end

function CDLayerHHLLKMahjongTable_tpgs:showTouchMahjong(index,mahjong)
    if self.m_pHHLLKArrayMahjongs[index] then
        self.m_pHHLLKArrayMahjongs[index].m_pMahjong:setMahjong( string.format( "my_b_%s.png", mahjong))
        self.m_pHHLLKArrayMahjongs[index].m_pMahjong:setVisible(true)
        self.m_pHHLLKArrayMahjongs[index].m_pMahjong:setBackVisible(false)
        self.m_pHHLLKArrayMahjongs[index].m_pMahjong:setFaceVisible(true)
    end
end


function CDLayerHHLLKMahjongTable_tpgs:dataToDetermine(_selectMahjong, _isTimeOver,mode)
    -- 刷新记录数据
    local bTmpIsOk = false
    if  _isTimeOver then
        _isTimeOver = true 
    else
        _isTimeOver = false
    end

    local _selectMahjongNumber  = 0

    if _selectMahjong ~= nil then
        _selectMahjongNumber = _selectMahjong:getMahjongNumber()
    end

    if mode == 4 then
        if not _isTimeOver then
            if  self.m_bIsFirstTouch then
                if self:canContinueTouch(_selectMahjongNumber) then
                    
                    self.m_bIsFirstTouch = false
                    _selectMahjong:runAction(cc.Sequence:create(cc.CallFunc:create(_selectMahjong.setSelectedColor_true),cc.DelayTime:create(0.4),cc.CallFunc:create(_selectMahjong.setSelectedColor_false)))
                    self:showTouchMahjong(13,_selectMahjongNumber)
                    return
                else
                    print("点错啦1111111")
                    _selectMahjong:showErrorSprite(true)
                end
            else
                print("第二次点击")
                print("_selectMahjongNumber---------------->",_selectMahjongNumber)
    
                if self.mahjongMath_llk:isFind(self.m_canTouchMah,_selectMahjongNumber) then
                    local tempArr = {}
                    if not self.mahjongMath_llk:isMoreThanFour(self.m_pHHLLKConfigData.t_ShowMj,_selectMahjongNumber) then
                        self:showTouchMahjong(14,_selectMahjongNumber)
                        _selectMahjong:setSelectedColor(true)
                        bTmpIsOk = true
                    else
                        print("点错啦2222222")
                        _selectMahjong:showErrorSprite(true)
                    end
                else
                    print("点错啦33333333333")
                    _selectMahjong:showErrorSprite(true)
                end                   
            end
        end

    else
        if  not _isTimeOver then
            for i, v in ipairs( self.m_pHHLLKConfigData.t_TingMj ) do
                if  v == _selectMahjongNumber then
                    bTmpIsOk = true
                    _selectMahjong:setSelectedColor(true)
                    break
                else
                     print("点错啦44444444")
                     _selectMahjong:showErrorSprite(true)
                end
            end
        end
    end

    self:stopGameRestoreTime()

    -- 选择正确
    if  bTmpIsOk then
        local nTmpScore = self.mahjongMath_llk:getScore(self.m_nHHLLKFlag, self.m_nHHLLKLeftTime)
        local nTmpNowTotleScore =  self.m_pHHLLKPlayAI:addScore(nTmpScore)

        g_pHHLLKGlobalManagment:refreshLLKTotleScore(self.m_nHHLLKFlag, nTmpNowTotleScore)
        
        --刷新最高分记录
        if self.m_nHHLLKFlag == 4 then
            self:refreshTableMaxScore()
        end

        self:refreshTableLeftScore()
        self:onTips(1)

    -- 选择错误
    else
        local nTmpNowLeftLift = self.m_pHHLLKPlayAI:deductLife() 
        self.m_pHHLLKSpriteLiftGroup[nTmpNowLeftLift + 1]:setGrey(true)
        local bTmpIsOver = false
        if  nTmpNowLeftLift <= 0 then
            local sTmpScoreStr = string.format(casinoclient.getInstance():findString("llk_left_sorce"), self.m_pHHLLKPlayAI.m_nHHLLKTableLeftScore)
            self.m_pHHLLKLableTotleScore:setString(sTmpScoreStr)

            bTmpIsOver = true
        --     self:onTips(4)
        -- else
        --     if  _isTimeOver then
        --         self:onTips(3)
        --     else
        --         self:onTips(2)
        --     end
        end

        if  _isTimeOver then
            self:onTips(3, bTmpIsOver)
        else
            self:onTips(2, bTmpIsOver)
        end
    end
    if bTmpIsOk then
        self.m_bNeedRefreshData = true
        self.m_nHHLLKNowCheckPoint = self.m_nHHLLKNowCheckPoint + 1
    else
        self.m_bNeedRefreshData = false
    end

    print("self.m_nHHLLKNowCheckPoint------>",self.m_nHHLLKNowCheckPoint)
    if  (self.m_nHHLLKNowCheckPoint~= 1) and (self.m_nHHLLKNowCheckPoint-1) % 10 == 0 then
        if bTmpIsOk then
            self.mahjongMath_llk:reduceTime(self.m_nHHLLKFlag)
        end
    end
end

----------------------------------------------------------------------------
-- 关闭所有界面
function CDLayerHHLLKMahjongTable_tpgs:closeAllUserInterface()
    cclog("CDLayerHHLLKMahjongTable_tpgs::closeAllUserInterface")

    local pTable = dtGetSceneTableFromParent( self)
    if  pTable then
        pTable:closeAllUserInterface()
        return
    end
end

----------------------------------------------------------------------------
-- 初始化桌子
-- 删除所有打出以及手上的牌，并且清除所有玩家桌面
function CDLayerHHLLKMahjongTable_tpgs:initTable()
    cclog("CDLayerHHLLKMahjongTable_tpgs::initTable")

    if  self.m_pHHLLKNewEffLayer then
        self.m_pHHLLKNewEffLayer:removeAllChildren()
    end

    self.m_sSavePutArr   = {}
    self.m_sLastPutCards = {}
    self.m_sOutInfo = {}

    self.m_bHHLLKCanOutCard = false
    self.m_bHHLLKTouchTable = false 
    self.m_pHHLLKLastSelectCard = nil

    self:refreshTableInfo()
    if  self.m_pHHLLKPlayAI == nil then
        self.m_pHHLLKPlayAI = CDMahjongHHLLKLLK_AI.create()
    end
end

function CDLayerHHLLKMahjongTable_tpgs:initAllMahjong()
    if  self.m_pHHLLKArrayShowMahjong then
        for i, v in ipairs( self.m_pHHLLKArrayShowMahjong ) do
            v:setSelectedColor(false)
            v:setVisible(false)
            v:showErrorSprite(false)
        end
    end

    if  self.m_pHHLLKArrayMahjongs then
        for i, v in ipairs( self.m_pHHLLKArrayMahjongs ) do
            v.m_pMahjong:setFaceVisible(false)
            v.m_pMahjong:setBackVisible(true)
            v.m_pMahjong:setVisible(true)
        end
    end

    self.m_nHHLLKLeftTime = self.mahjongMath_llk:getFlagSecondConfig(self.m_nHHLLKFlag)
    self.m_pHHLLKLableLeftSecond:setString(self.m_nHHLLKLeftTime)
    self.m_pHHLLKLableLeftSecond:setColor(cc.c3b(0,0,1))
end

----------------------------------------------------------------------------
-- 初始化
function CDLayerHHLLKMahjongTable_tpgs:init()
    cclog("CDLayerHHLLKMahjongTable_tpgs::init")
    
    -- touch事件
    local function onTouchBegan(touch, event)
        cclog("CDLayerHHLLKMahjongTable_tpgs:onTouchBegan")

        -- 没有开始游戏，不能进行点击
        if not self.m_bHHLLKInTheGame or not self.m_bHHLLKCanTouch then
            return
        end
        self.m_bHHLLKTouchTable = true 

        -- 点选自己的手牌(游戏中才能使用，发牌阶段不能使用)
        local point = touch:getLocation()
        if self.m_bHHLLKInTheGame then
            self:touchMahjongFromPoint(point)
        end
        return true
    end

    local function onTouchMoved(touch, event)
    end

    local function onTouchEnded(touch, event)
        self.m_bHHLLKTouchTable = false
    end

    self.m_pHHLLKListener = cc.EventListenerTouchOneByOne:create()
    self.m_pHHLLKListener:setSwallowTouches(true)
    self.m_pHHLLKListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.m_pHHLLKListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self.m_pHHLLKListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pHHLLKListener, self)
end

--===============================回合相关处理================================-
----------------------------------------------------------------------------
-- 向玩家发牌
function CDLayerHHLLKMahjongTable_tpgs:round_licensingPlayer()
    if  self.m_nHHLLKLicensingType == 0 then
        local effect = CDCCBAniObject.createCCBAniObject(self.m_pHHLLKMahjongEffDemo, "x_tx_kaiju.ccbi", g_pHHLLKGlobalManagment:getWinCenter(), 0)
        if  effect then
            effect:endVisible( true)
            effect:endRelease( true)
        end

        self.m_nHHLLKLicensingType = 1
        self:runAction( cc.Sequence:create(cc.DelayTime:create(0.7), cc.CallFunc:create(CDLayerHHLLKMahjongTable_tpgs.round_licensingPlayer)))
        dtPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_KJ)

    elseif self.m_nHHLLKLicensingType == 1 then -- 发牌
        -- 选择牌的选择组
        for i, v in ipairs(self.m_pHHLLKArrayShowMahjong) do
            local nMahjong = self.m_pHHLLKConfigData.t_SelectMj[i]
            v:setMahjong( string.format( "out_b_%s.png", nMahjong))
            v:setMahjongNumber(nMahjong)
            v:setVisible(true)
        end

        -- 手牌组显示
        for i, v in ipairs(self.m_pHHLLKArrayMahjongs) do
            if self.m_pHHLLKConfigData.t_ShowMj[i] then
                local nMahjong = self.m_pHHLLKConfigData.t_ShowMj[i]
                v.m_pMahjong:setMahjong( string.format( "my_b_%s.png", nMahjong))
                v.m_pMahjong:setMahjongNumber(nMahjong)
    
                v.m_pMahjong:setVisible(true)
                v.m_pMahjong:setBackVisible(false)
                v.m_pMahjong:setFaceVisible(true)
            end
        end

        --这个模式下要展示14张牌
        if self.m_nHHLLKFlag == 4 then
            if self.m_pHHLLKArrayMahjongs[13] and self.m_pHHLLKArrayMahjongs[14] then
                for i = 13 ,14 do
                    self.m_pHHLLKArrayMahjongs[i].m_pMahjong:setVisible(true)
                    self.m_pHHLLKArrayMahjongs[i].m_pMahjong:setBackVisible(true)
                    self.m_pHHLLKArrayMahjongs[i].m_pMahjong:setFaceVisible(false)
                end
            end
        end

        -- 开启游戏倒计时
        self:gameRestoreTimeCount()

        -- 开启允许点击
        self.m_bHHLLKCanTouch = true
    end
end

--_type：类型说明
--1：正确
--2：错误
--3：时间到
--4：结算、失败
function CDLayerHHLLKMahjongTable_tpgs:onTips(_type, _isGameOver)
    if  self.m_pHHLLKLayerTip == nil then
        return
    end

    if  _isGameOver then
        _isGameOver = true
    else
        _isGameOver = false
    end

    -- 进入判断流程，关闭点击
    self.m_bHHLLKCanTouch = false

    function closeType1()
        self.m_pHHLLKLayerTip:setVisible(false)
        self.m_pHHLLKSpriteOk:setVisible(false)
        self:onReady()
    end

    function closeType2()
        self.m_pHHLLKLayerTip:setVisible(false)
        self.m_pHHLLKSpriteErr:setVisible(false)
        if  _isGameOver then
            self:onTips(4)            
        else
            self:onReady()
        end
    end

    function closeType3( ... )
        self.m_pHHLLKLayerTip:setVisible(false)
        self.m_pHHLLKSpriteTimeOver:setVisible(false)
        if  _isGameOver then
            self:onTips(4)            
        else
            self:onReady()
        end
    end
    self.m_pHHLLKLayerTip:setVisible(true)
    if  _type == 1 then
        self.m_pHHLLKSpriteOk:setVisible(true)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(closeType1)))
        dtPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_OK)
    elseif  _type == 2 then
        self.m_pHHLLKSpriteErr:setVisible(true)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(closeType2)))
        dtPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_ERROR)
        
    elseif  _type == 3 then
        self.m_pHHLLKSpriteTimeOver:setVisible(true)
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(closeType3)))
        dtPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_TIME_OVER)
        
    elseif  _type == 4 then
        local tmpTotle = string.format(casinoclient.getInstance():findString("llk_left_sorce"), self.m_pHHLLKPlayAI.m_nHHLLKTableLeftScore)
        self.m_pHHLLKLableTotleScore:setString(tmpTotle)
        self.m_pHHLLKLableTotleScore:setVisible(true)

        tmpTotle = string.format(casinoclient.getInstance():findString("llk_left_time"), self.m_pHHLLKPlayAI:getTotalTime())
        self.m_pHHLLKTableTotalTime:setString(tmpTotle)
        self.m_pHHLLKTableTotalTime:setVisible(true)

        tmpTotle = string.format(casinoclient.getInstance():findString("llk_left_round"),self.m_nHHLLKNowCheckPoint-1)
        self.m_pHHLLKTableTotalRound:setString(tmpTotle)
        self.m_pHHLLKTableTotalRound:setVisible(true)

        self.m_pHHLLKButtonGoHome:setVisible(true)
        self.m_pHHLLKButtonReGame:setVisible(true)
        dtPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_SCORE)
    end
end

--===============================界面函数绑定===============================--
----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- 退出桌子到大厅
function CDLayerHHLLKMahjongTable_tpgs:onGotoHall()
    cclog("CDLayerHHLLKMahjongTable_tpgs::onExit")

    -- 关闭提示界面
    self.m_pHHLLKLayerTip:setVisible(false)
    self.m_pHHLLKButtonGoHome:setVisible(false)

    g_pSceneTable:gotoSceneHall()
    dtPlaySound(DEF_SOUND_TOUCH)
end

function CDLayerHHLLKMahjongTable_tpgs:onReStart()
    -- 关闭提示界面
    self.m_pHHLLKLayerTip:setVisible(false)
    self.m_pHHLLKLableTotleScore:setVisible(false)
    self.m_pHHLLKTableTotalRound:setVisible(false)
    self.m_pHHLLKTableTotalTime:setVisible(false)

    self.m_pHHLLKButtonReGame:setVisible(false)
    self.m_pHHLLKButtonGoHome:setVisible(false)

    -- 增加关卡数，并刷新本地数据
    -- local nTmpLeftPhy = g_pHHLLKGlobalManagment.m_nTmpPhysical - DEF_PROJCETHHLLK_LLK_PHY_EXP
    -- if  nTmpLeftPhy >= 0 then

        local nTmpGameCount = g_pHHLLKGlobalManagment.m_nGameCount + 1
        g_pHHLLKGlobalManagment:setLLKTmpPhysical(nTmpLeftPhy)
        g_pHHLLKGlobalManagment:setLLKGameCount(nTmpGameCount)

        -- 重置数据
        self.m_pHHLLKPlayAI:clearTotalTime()
        self.mahjongMath_llk:init()
        self.m_nHHLLKLeftTime, self.m_pHHLLKPlayAI.m_nLeftLife = self.mahjongMath_llk:getFlagConfig(self.m_nHHLLKFlag)
        self.m_pHHLLKPlayAI.m_nHHLLKTableLeftScore = 0
        for i, v in ipairs( self.m_pHHLLKSpriteLiftGroup ) do
            if  v:isVisible() then
                v:setGrey(false)
            end
        end

        -- 重新开始，需要刷新关卡、历史最高积分
        self.m_nHHLLKNowCheckPoint = 1
        self.m_bNeedRefreshData = true
        self:refreshTableMaxScore()
        self:Handle_llk_StartPlay()
    -- else
    --     g_pSceneTable:gotoSceneHall()
    -- end

    dtPlaySound(DEF_SOUND_TOUCH)
end

----------------------------------------------------------------------------
-- 音乐设置
function CDLayerHHLLKMahjongTable_tpgs:onMusic()

    local bMusic = g_pHHLLKGlobalManagment:isEnableMusic()
    g_pHHLLKGlobalManagment:enableMusic(not bMusic)
end

----------------------------------------------------------------------------
-- 音效设置
function CDLayerHHLLKMahjongTable_tpgs:onSound()

    local bSound = g_pHHLLKGlobalManagment:isEnableSound()
    g_pHHLLKGlobalManagment:enableSound( not bSound)
end

----------------------------------------------------------------------------
-- 设置
function CDLayerHHLLKMahjongTable_tpgs:onSetting()
    cclog( "CDLayerHHLLKMahjongTable_tpgs:onSetting")

    if  not self.m_pHHLLKGroupBar:isVisible() then
        return
    end

    g_pSceneTable:closeAllUserInterface()

    local pos = cc.p( 0.0, self.m_pHHLLKButSetting:getPositionY())
    g_pSceneTable.m_pLayerTipBar:setPosition(pos)
    g_pSceneTable.m_pLayerTipBar:open(casinoclient.getInstance():isSelfBuildTable())
end

function CDLayerHHLLKMahjongTable_tpgs:onReady()
    cclog("CDLayerHHLLKMahjongTable_tpgs:onReady")

    -- 开始游戏
    self:Handle_llk_StartPlay()
end

----------------------------------------------------------------------------
-- ccb处理
-- 变量绑定
function CDLayerHHLLKMahjongTable_tpgs:onAssignCCBMemberVariable(loader)
    cclog("CDLayerHHLLKMahjongTable_tpgs::onAssignCCBMemberVariable")

    -- 灯光
    self.m_pHHLLKLighting     = loader["pic_alpha"]

    -- 底部的状态信息
    self.m_pHHLLKGroupBar     = loader["group_bar"]
    self.m_pHHLLKButSetting   = loader["but_setting"]
    self.m_pHHLLKSelfInfo     = loader["self_info"]
    self.m_pHHLLKTableInfo    = loader["table_info"]

    self.m_pHHLLKNewLayerRoot    = loader["new_layer"]

    -- 电池
    self.m_pHHLLKIcoPower        = loader["power"]
    self.m_pHHLLKNewEffLayer     = loader["newEfflayer"]

    --------------------------------------------------------
    -- 技能相关绑定
    self.m_pHHLLKSkillBar        = loader["skill_bar"]               -- 技能根Node
    self.m_pHHLLKOnTipBtn        = loader["but_tip"]                 -- 技能：提示按钮
    self.m_pHHLLKOnResetBtn      = loader["but_reset"]               -- 技能：重置按钮
    self.m_pHHLLKTipExpLabel     = loader["tip_expend_gold"]         -- 提示技能消耗文本
    self.m_pHHLLKResetExpLabel   = loader["reset_expend_gold"]       -- 重置技能消耗文本

    --------------------------------------------------------
    -- 相关绑定
    self.m_pHHLLKSpriteLiftGroup      = {}
    for i = 1, 3 do
        self.m_pHHLLKSpriteLiftGroup[i] = loader["sp_lift_"..i]
    end
    self.m_pHHLLKLableLevelTitle   = loader["level_label"]
    self.m_pHHLLKLableMaxScore     = loader["max_score_label"]
    self.m_pHHLLKNodeNaoZhong      = loader["time_group_node"]
    self.m_pHHLLKLableLeftSecond   = loader["second_label"]
    self.m_pHHLLKLayerTip          = loader["layer_group"]
    self.m_pHHLLKSpriteTimeOver    = loader["sp_tip_time_over"]
    self.m_pHHLLKSpriteOk          = loader["sp_tip_ok"]
    self.m_pHHLLKSpriteErr         = loader["sp_tip_error"]
    self.m_pHHLLKLableTotleScore   = loader["label_tip_totle_score"]
    self.m_pHHLLKTableTotalRound   = loader["label_tip_total_round"]
    self.m_pHHLLKTableTotalTime    = loader["label_tip_totle_time"]

    self.m_pHHLLKButtonGoHome      = loader["button_go_home"]
    self.m_pHHLLKButtonReGame      = loader["button_re_start"]
end

----------------------------------------------------------------------------
-- ccb处理
-- 函数绑定
function CDLayerHHLLKMahjongTable_tpgs:onResolveCCBCCControlSelector(loader)
    cclog("CDLayerHHLLKMahjongTable_tpgs::onResolveCCBCCControlSelector")
    
    loader["onSetting"]     = function() self:onSetting() end         
    loader["onGotoHall"]    = function() self:onGotoHall() end
    loader["onReStart"]     = function() self:onReStart() end
    ----------------------------------------------------------------
    -- 技能相关
end

--------------------------------------------------------------------------
function CDLayerHHLLKMahjongTable_tpgs.createCDLayerTable_xtlzddz(pParent)
    cclog("CDLayerHHLLKMahjongTable_tpgs::createCDLayerTable_xtlzddz")
    if not pParent then
        return nil
    end
    local insLayer = CDLayerHHLLKMahjongTable_tpgs.new()
    insLayer:init()
    local loader = insLayer.m_ccbLoader
    insLayer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerHHLLKMahjongTable_tpgs.ccbi",proxy,loader)
    insLayer.m_ccBaseLayer = node
    insLayer:onAssignCCBMemberVariable(loader)
    insLayer:addChild(node)
    pParent:addChild(insLayer)
    return insLayer
end
