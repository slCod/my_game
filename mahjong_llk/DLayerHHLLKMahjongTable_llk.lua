--[[
/******************************************************
//Project:      ProjectX 
//Moudle:       CDLayerHHLLKMahjongTable_llk 仙桃赖子斗地主桌子
//File Name:    DLayerQPHHCardTable_xtlzddz.h
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
require( "mahjong_llk.HHLLK_mahjong_llk_ai")
require( "mahjong_llk.Mahjong_llk_item")

local casinoclient = require("script.client.casinoclient")
local platform_help = require("platform_help")

-- 音效定义
DEF_PROJCETHHLLK_SOUND_MJ_CLICK      = "sound_card_click"..DEF_TKD_SOUND     -- 点中牌
DEF_PROJCETHHLLK_SOUND_MJ_KJ         = "mj_kj"..DEF_TKD_SOUND                -- 开局

-----------------------------------------
-- 类定义
CDLayerHHLLKMahjongTable_llk = class("CDLayerHHLLKMahjongTable_llk", CDCCBLayer)    
CDLayerHHLLKMahjongTable_llk.__index = CDLayerHHLLKMahjongTable_llk
CDLayerHHLLKMahjongTable_llk.name = "CDLayerHHLLKMahjongTable_llk"

-- 构造函数
function CDLayerHHLLKMahjongTable_llk:ctor()
    cclog("CDLayerHHLLKMahjongTable_llk::ctor")
    CDLayerHHLLKMahjongTable_llk.super.ctor(self)
    CDLayerHHLLKMahjongTable_llk.initialMember(self)
    --reg enter and exit
    local function onNodeEvent(event)
        if "enter" == event then
            CDLayerHHLLKMahjongTable_llk.onEnter(self)
        elseif "exit" == event then
            CDLayerHHLLKMahjongTable_llk.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function CDLayerHHLLKMahjongTable_llk:onEnter()
    cclog("CDLayerHHLLKMahjongTable_llk::onEnter")

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
end

function CDLayerHHLLKMahjongTable_llk:onExit()
    cclog("CDLayerHHLLKMahjongTable_llk::onExit")

    -- 退出时，停止发送心跳
    self:stopHeartLoop()
    self:stopAllActions()

    casinoclient.getInstance():removeListenerAllEvents(self)
    CDLayerHHLLKMahjongTable_llk.releaseMember(self)
    self:unregisterScriptHandler()
end

-----------------------------------------
-- 初始化
function CDLayerHHLLKMahjongTable_llk:initialMember()
    cclog("CDLayerHHLLKMahjongTable_llk::initialMember")

    ---------------------------------------------------
    -- 底部的状态信息 
    self.m_pHHLLKGroupBar        = nil        -- 状态按钮根节点
    self.m_pHHLLKButSetting      = nil        -- 设置按钮
    self.m_pHHLLKSelfInfo        = nil        -- 自己的信息
    self.m_pHHLLKTableInfo       = nil        -- 桌子的信息

    ---------------------------------------------------
    -- 桌子中相关按钮
    self.m_pHHLLKReadyBtn        = nil        -- 准备按钮

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
    self.mahjongMath_llk    = nil        -- 麻将连连看数学库  

    self.m_pHHLLKEffNetLow       = nil        -- 网络连接缓慢提示特效
    self.m_bHHLLKPreCreate       = false      -- 是否预创建过

    self.m_nHHLLKFlag            = nil        -- 游戏类型(1、简单 2、普通 3、困难)
    self.m_nHHLLKRow             = 0          -- 行
    self.m_nHHLLKColumn          = 0          -- 列

    self.m_arrayMahjong     = nil        -- 连连看布局数组（二维）
    self.m_pHHLLKArrayDrawNode   = nil        -- 连线
    self.path               = {}         -- 路径点

    ---------------------------------------------------
    -- 数据对象

    -- 当前地图中选中的坐标
    self.m_sNowSelected     = {
        X = 0,
        Y = 0;
        isEmpty = function()
            if self.m_sNowSelected.X == 0 and self.m_sNowSelected.Y == 0 then
                return true
            end
            return false
        end;

        clear = function()
            self.m_sNowSelected.X = 0
            self.m_sNowSelected.Y = 0
        end;

        setData = function(_point)
            self.m_sNowSelected.X = _point.X
            self.m_sNowSelected.Y = _point.Y
        end;

        isSame = function(_point)
            if self.m_sNowSelected.X == _point.X and self.m_sNowSelected.Y == _point.Y then
                return true
            end
            return false
        end
    } 

    -- 提示组
    self.m_pHHLLKArrayTipsGroup  = {
        point1 = {X=0,Y=0},
        point2 = {X=0,Y=0},

        isEmpty = function()
            if self.m_pHHLLKArrayTipsGroup.point1.X == 0 and self.m_pHHLLKArrayTipsGroup.point1.Y == 0 and
               self.m_pHHLLKArrayTipsGroup.point2.X == 0 and self.m_pHHLLKArrayTipsGroup.point2.Y == 0 then
                return true
            end
            return false
        end;

        clear = function()
            self.m_pHHLLKArrayTipsGroup.point1.X = 0
            self.m_pHHLLKArrayTipsGroup.point1.Y = 0
            self.m_pHHLLKArrayTipsGroup.point2.X = 0
            self.m_pHHLLKArrayTipsGroup.point2.Y = 0
        end;

        setData = function(_point1, _point2)
            self.m_pHHLLKArrayTipsGroup.point1.X = _point1.X
            self.m_pHHLLKArrayTipsGroup.point1.Y = _point1.Y
            self.m_pHHLLKArrayTipsGroup.point2.X = _point2.X
            self.m_pHHLLKArrayTipsGroup.point2.Y = _point2.Y
        end;

        checkOneSame = function(_point)
            if self.m_pHHLLKArrayTipsGroup.point1.X == _point.X and self.m_pHHLLKArrayTipsGroup.point1.Y == _point.Y or 
               self.m_pHHLLKArrayTipsGroup.point2.X == _point.X and self.m_pHHLLKArrayTipsGroup.point2.Y == _point.Y then
                return true
            end
            return false
        end;

        checkTwoSame = function(_point1, _point2)
            if (self.m_pHHLLKArrayTipsGroup.point1.X == _point1.X and self.m_pHHLLKArrayTipsGroup.point1.Y == _point1.Y or self.m_pHHLLKArrayTipsGroup.point1.X == _point2.X and self.m_pHHLLKArrayTipsGroup.point1.Y == _point2.Y) and
               (self.m_pHHLLKArrayTipsGroup.point2.X == _point2.X and self.m_pHHLLKArrayTipsGroup.point2.Y == _point2.Y or self.m_pHHLLKArrayTipsGroup.point2.X == _point1.X and self.m_pHHLLKArrayTipsGroup.point2.Y == _point1.Y) then
                return true
            end
            return false
        end
    }

    self.m_arrayLastSelected = {}        -- 上一次选中的坐标集合
end

function CDLayerHHLLKMahjongTable_llk:releaseMember()
    cclog("CDLayerHHLLKMahjongTable_llk::releaseMember")

    if  self.m_pHHLLKNewEffLayer then
        self.m_pHHLLKNewEffLayer:removeAllChildren()
    end

    if  self.m_pHHLLKNewLayerRoot ~= nil then
        self.m_pHHLLKNewLayerRoot:removeAllChildren()
        self.m_pHHLLKEffNetLow = nil
    end

    --模拟析构父类
    CDLayerHHLLKMahjongTable_llk.super.releaseMember(self)
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
function CDLayerHHLLKMahjongTable_llk:Handle_Ping( __event)
    cclog("CDLayerHHLLKMahjongTable_llk:Handle_Ping")
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
function CDLayerHHLLKMahjongTable_llk:createHeartbeatLoop( ... )
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
function CDLayerHHLLKMahjongTable_llk:stopHeartLoop( ... )
    if  self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)   
        self.schedulerID=nil
    end
end

----------------------------------------------------------------------------
-- 暂停
-- 参数: 数据包
function CDLayerHHLLKMahjongTable_llk:Handle_Table_Pause( __event)
    cclog("CDLayerHHLLKMahjongTable_llk:Handle_Table_Pause")
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
function CDLayerHHLLKMahjongTable_llk:Handle_llk_StartPlay(__event)
    cclog("CDLayerHHLLKMahjongTable_llk:Handle_llk_StartPlay")

    -- 开始游戏后，关闭主场景中的不相关场景
    g_pSceneTable:closeAllUserInterface()

    -- 创建数学库
    if not self.mahjongMath_llk then
        self.mahjongMath_llk = CDMahjongHHLLKLLK.create()
    end

    -- 设置剩余牌总数
    if not self.m_pHHLLKPlayAI then
        self.m_pHHLLKPlayAI = CDMahjongHHLLKLLK_AI.create()
    end
    local nRow, nColumn = self:getFlagConfig()                            
    self.m_pHHLLKPlayAI:setLeftTableMahjong(nRow * nColumn)
    
    self:refreshTableLeftMahjong()

    -- 获取并生产玩家数据
    local nickname = casinoclient.getInstance():getPlayerData():getNickname()
    local channelNickname = casinoclient.getInstance():getPlayerData():getChannelNickname()
    self.m_pHHLLKPlayer.name = dtGetNickname(nickname, channelNickname)
    self.m_pHHLLKPlayer.gold = casinoclient:getInstance():getPlayerData():getPlayerResourceGold()
    self:refreshSelfInfo()
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
function CDLayerHHLLKMahjongTable_llk:Handle_xtlzddz_Reconnect( __event)
    cclog("CDLayerHHLLKMahjongTable_llk:Handle_xtlzddz_Reconnect")

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
function CDLayerHHLLKMahjongTable_llk:resetPower()
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
function CDLayerHHLLKMahjongTable_llk:resetTableData(data)
    cclog( "CDLayerHHLLKMahjongTable_llk:resetTableData")
end

--=================================基本方法=================================--
----------------------------------------------------------------------------
-- 倒计时转到结算
function CDLayerHHLLKMahjongTable_llk:showLeftTimeGotoScore()
    cclog( "CDLayerHHLLKMahjongTable_llk:showLeftTimeGotoScore")

    if  not self.m_pHHLLKTimeLeftTTF:isVisible() then
        self.m_pHHLLKTimeLeftTTF:setVisible( true)
    end

    local function leftTime_low()
        self.m_pHHLLKTimeLeftTTF:stopAllActions()
        if  self.m_nHHLLKTimeLeft <= 0 then

            -- 临时增加的判断为了避免在下一局开始的时候进入到结算画面
            if  not self.m_bHHLLKInTheGame then
                self:initTable()

                self.m_pHHLLKPlayer[0].m_pHHLLKFrame:setPosition(self.m_pHHLLKPlayer[0].m_sPosEnd)
                self.m_pHHLLKPlayer[0].m_pHHLLKFrame:setVisible(false)

                g_pSceneTable:closeAllUserInterface()
                g_pSceneTable.m_pHHLLKLayerMJScore:open(g_pHHLLKGlobalManagment:getScoreData(), self.mahjongMath_llk, self.m_nHHLLKScoreTime)
                self:showLocation(false)
            end
        else
            self.m_pHHLLKTimeLeftTTF:setString( string.format( "%d", self.m_nHHLLKTimeLeft))
            self.m_pHHLLKTimeLeftTTF:setScale( 3.0)
            self.m_pHHLLKTimeLeftTTF:runAction( cc.Sequence:create( cc.EaseBackOut:create( cc.ScaleTo:create( 0.25, 1.0)), cc.DelayTime:create( 0.75), cc.CallFunc:create( leftTime_low)))

            self.m_nHHLLKTimeLeft = self.m_nHHLLKTimeLeft - 1
            if  self.m_nHHLLKTimeLeft < 0 then
                self.m_nHHLLKTimeLeft = 0
            end
        end
    end
    leftTime_low()
end

----------------------------------------------------------------------------
-- 设置自己的信息
function CDLayerHHLLKMahjongTable_llk:refreshSelfInfo()
    self.m_pHHLLKSelfInfo:setString(self.m_pHHLLKPlayer.name)
end

----------------------------------------------------------------------------
-- 设置玩家信息
function CDLayerHHLLKMahjongTable_llk:refreshTableLeftMahjong()
    
    self.m_pHHLLKTableInfo:setString(self.m_pHHLLKPlayAI:getLeftTableMahjong())
end

-- 初始化界面
----------------------------------------------------------------------------
-- 创建用户界面
function CDLayerHHLLKMahjongTable_llk:createUserInterface(flag)
    cclog("CDLayerHHLLKMahjongTable_llk::createUserInterface")

    -- 设置难度、行列数据
    self.m_nHHLLKFlag = flag
    self.m_nHHLLKRow, self.m_nHHLLKColumn = self:getFlagConfig()

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
end

-- 预创建牌
function CDLayerHHLLKMahjongTable_llk:preCreateLLKMahjong()
    cclog( "CDLayerHHLLKMahjongTable_llk:preCreateLLKMahjong")

    if  self.m_bHHLLKPreCreate then
        return
    end

    local offset_x = self.m_pHHLLKNewLayerRoot:getContentSize().width * 85 / 960
    local offset_y = self.m_pHHLLKNewLayerRoot:getContentSize().height * (self.m_pHHLLKGroupBar:getContentSize().height + 20) / 640
    local center_x = self.m_pHHLLKNewLayerRoot:getPositionX() - offset_x
    local center_y = self.m_pHHLLKNewLayerRoot:getPositionY() + offset_y


    -- 用于保存地盘中的有效牌组
    self.m_arrayMahjong = {}

    -- 总棋盘个子数量，需要上下左右各留一条
    local nTotle = (self.m_nHHLLKRow + 2) * (self.m_nHHLLKColumn + 2) 

    -- 初始的x，y坐标值
    local nInitX = 0
    local nInitY = 0  

    -- 单个麻将的宽高
    local mahjongItemWidth = 0
    local mahjongItemHeight = 0

    -- 用于记录有效格子的顺序
    local isFirst = true

    -- 生成连连看棋盘
    for i = 1, nTotle do
        local nNowRow = math.floor((i - 1) / (self.m_nHHLLKColumn + 2)) + 1;
        local nNowColumn = (i - 1) % (self.m_nHHLLKColumn + 2) + 1; 
        --local str = nNowColumn .. "," .. nNowRow

        -- tips数据结构
        local tmpTable = {}
        tmpTable.X = 0
        tmpTable.Y = 0
        tmpTable.isDisplay = false
        tmpTable.mahjong = 0
        tmpTable.valid = false

        -- 预留的边框格子只用于寻路，需要标记为无效(方便寻路)
        if nNowRow == 1 or nNowRow == self.m_nHHLLKRow + 2 or
           nNowColumn == 1 or nNowColumn == self.m_nHHLLKColumn + 2 then
            tmpTable.X = nNowColumn
            tmpTable.Y = nNowRow

        else
            tmpTable.X = nNowColumn
            tmpTable.Y = nNowRow
            tmpTable.valid = true
            tmpTable.mahjongItem = CDMahjongHHLLKLlkItem.createCDMahjong(self.m_pHHLLKMahjongDemo)
            tmpTable.mahjongItem:setVisible(false)
            tmpTable.isDisplay = true

            -- 第一个有效数据时，该点为初始点，需要计算初始坐标，供后续使用
            if isFirst then
                tmpTable.mahjongItem:getMahjongSize()
                mahjongItemWidth = tmpTable.mahjongItem.m_nHHLLKSizeW
                mahjongItemHeight = tmpTable.mahjongItem.m_nHHLLKSizeH
                nInitX = center_x - (mahjongItemWidth * self.m_nHHLLKColumn) / 2 + mahjongItemWidth / 2
                nInitY = center_y + (mahjongItemHeight * self.m_nHHLLKRow) / 2 - mahjongItemHeight / 2

                -- 变更标记
                isFirst = false
            end

            -- 坐标设置
            tmpTable.mahjongItem:setPosition(cc.p(nInitX + (nNowColumn - 1) * mahjongItemWidth,
                                                                nInitY - (nNowRow - 1) * mahjongItemHeight))
        end

        if not self.m_arrayMahjong[nNowColumn] then
            self.m_arrayMahjong[nNowColumn] = {}
        end
        table.insert(self.m_arrayMahjong[nNowColumn], tmpTable)
    end

    -- 生成线
    self.m_pHHLLKArrayDrawNode = {}
    for i = 1, 3 do
        self.m_pHHLLKArrayDrawNode[i] = cc.DrawNode:create()
        self.m_pHHLLKArrayDrawNode[i]:setVisible(false)
        self.m_pHHLLKMahjongEffDemo:addChild(self.m_pHHLLKArrayDrawNode[i])
    end

    self.m_bHHLLKPreCreate = true
end

function CDLayerHHLLKMahjongTable_llk:getFlagConfig()
    if not self.m_nHHLLKFlag then
        return 0, 0
    end

    local nRow, nColumn = 0, 0
    if self.m_nHHLLKFlag == 1 then
        nRow = 6 
        nColumn = 10
    elseif self.m_nHHLLKFlag == 2 then
        nRow = 6
        nColumn = 12
    elseif self.m_nHHLLKFlag == 3 then
        nRow = 8 
        nColumn = 15
    end

    return nRow, nColumn
end

----------------------------------------------------------------------------
-- 根据指定的坐标点选择牌
-- 参数: 坐标点
function CDLayerHHLLKMahjongTable_llk:touchMahjongFromPoint(point)
    cclog("CDLayerHHLLKMahjongTable_llk::touchMahjongFromPoint")
    for i, v in ipairs(self.m_arrayMahjong) do
        for j, z in ipairs(v) do
            if z.isDisplay then
                 if z.mahjongItem:checkWithTouchPoint(point) then
                    dtPlaySound(DEF_PROJCETHHLLK_SOUND_MJ_CLICK)

                    -- 提示组存在，且有提示内容
                    if self.m_pHHLLKArrayTipsGroup and not self.m_pHHLLKArrayTipsGroup.isEmpty() then
                        local isTips = self.m_pHHLLKArrayTipsGroup.checkOneSame(z)

                        -- 所点击的麻将，不再提示组中，则取消提示标识，并清空提示组
                        if not isTips then
        
                            self.m_arrayMahjong[self.m_pHHLLKArrayTipsGroup.point1.X][self.m_pHHLLKArrayTipsGroup.point1.Y].mahjongItem:setSelectedColor(false)
                            self.m_arrayMahjong[self.m_pHHLLKArrayTipsGroup.point2.X][self.m_pHHLLKArrayTipsGroup.point2.Y].mahjongItem:setSelectedColor(false)
                            self.m_pHHLLKArrayTipsGroup.clear()
                            self.path = {}
                        end
                    end

                    -- 点中变色
                    if not self.m_sNowSelected or self.m_sNowSelected.isEmpty() or self.m_sNowSelected.isSame(z) then
                        self.m_arrayMahjong[z.X][z.Y].mahjongItem:setSelectedColor(true)
                        self.m_sNowSelected.setData(z)
                        return
                    end
                    if self.m_arrayMahjong[self.m_sNowSelected.X][self.m_sNowSelected.Y].mahjong ~= z.mahjong then
                        self.m_arrayMahjong[self.m_sNowSelected.X][self.m_sNowSelected.Y].mahjongItem:setSelectedColor(false)
                        self.m_sNowSelected.setData(z)
                        self.m_arrayMahjong[z.X][z.Y].mahjongItem:setSelectedColor(true)

                        return
                    else
                        self.m_arrayMahjong[z.X][z.Y].mahjongItem:setSelectedColor(true)
                        if self.m_pHHLLKArrayTipsGroup.checkTwoSame(self.m_sNowSelected, z) or self.mahjongMath_llk:isCanLigature(self.m_sNowSelected, z, self.m_arrayMahjong, self.path) then
                            print("can eliminate!")
                            local tmpPonitPath = self.mahjongMath_llk:getLlkPath(self.m_sNowSelected, z, self.path, self.m_arrayMahjong)

                            -- 提前将这对麻将的外置属性置为不可见
                            self.m_arrayMahjong[self.m_sNowSelected.X][self.m_sNowSelected.Y].isDisplay = false
                            self.m_arrayMahjong[z.X][z.Y].isDisplay = false

                            -- 播放连线效果
                            self:playOnlineEff(self.m_sNowSelected, z, tmpPonitPath)

                            -- 清空选中的点
                            self.m_sNowSelected.clear()
                        else
                            print("no can eliminate")
                            self.m_arrayMahjong[self.m_sNowSelected.X][self.m_sNowSelected.Y].mahjongItem:setSelectedColor(false)

                            -- 不可连线，则更改选中点
                            self.m_sNowSelected.setData(z)
                        end

                        -- 清除提示内容
                        self.m_pHHLLKArrayTipsGroup.clear()

                        -- 清空路径点
                        self.path = {}
                    end
                    return true
                end
            end
        end
    end
    return false
end

function CDLayerHHLLKMahjongTable_llk:playOnlineEff(oneSelect, twoSelect, pointPath)
    if not pointPath then
        return
    end

    -- 停止之前的动画
    self.m_pHHLLKMahjongEffDemo:stopAllActions()
    for i, v in ipairs(self.m_pHHLLKArrayDrawNode) do
        if v:isVisible() then
            v:setVisible(false)
        end
    end
    if TABLE_SIZE(self.m_arrayLastSelected) >= 2 then
        self:refreshData(self.m_arrayLastSelected)
    end

    -- 保存这次选中的对象
    self.m_arrayLastSelected[1] = {}
    self.m_arrayLastSelected[1].X = oneSelect.X
    self.m_arrayLastSelected[1].Y = oneSelect.Y
    self.m_arrayLastSelected[2] = {}
    self.m_arrayLastSelected[2].X = twoSelect.X
    self.m_arrayLastSelected[2].Y = twoSelect.Y

    local nDelayTime = 0
    local size = TABLE_SIZE(pointPath)

    print("===========pointPath============")
    print("size",size)
    for i, v in ipairs(pointPath) do
        print(i..":"..v.X..","..v.Y)
    end
    print("===========pointPath============")

    -----------------------------------------------
    -- 动画控制在0.1s的时间内完成
    -- 开始新的动画
    for i = 1, size do
        if i - size >= 0 then
            break
        end

        self.m_pHHLLKMahjongEffDemo:runAction(cc.Sequence:create(cc.DelayTime:create(nDelayTime),cc.CallFunc:create(function()
            self.m_pHHLLKArrayDrawNode[i]:setVisible(true)
            self.m_pHHLLKArrayDrawNode[i]:drawSegment(cc.p(pointPath[i].X, pointPath[i].Y), cc.p(pointPath[i + 1].X, pointPath[i + 1].Y), 3, cc.c4f(252 / 255, 64 / 255, 47 / 255, 1.0))
        end)))

        nDelayTime = nDelayTime + 0.03
    end

    -- 连线完毕后，淡出
    for i = 1, size - 1 do
        local tmpAct = cc.FadeOut:create(nDelayTime)
        self.m_pHHLLKArrayDrawNode[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), tmpAct, cc.CallFunc:create(function()
            self.m_pHHLLKArrayDrawNode[i]:clear()
            self.m_pHHLLKArrayDrawNode[i]:setVisible(false)
        end)))
    end

    -- 麻将闪烁淡出消失
    nDelayTime = nDelayTime + 0.1
    local nDelayTime_blink = 0.4
    for i, v in ipairs(self.m_arrayLastSelected) do
        self.m_arrayMahjong[v.X][v.Y].mahjongItem:runAction(cc.Sequence:create(cc.DelayTime:create(nDelayTime), cc.Blink:create(nDelayTime_blink, 3)))
    end

    -- 动画播放完毕后，设置隐藏
    nDelayTime = nDelayTime + nDelayTime_blink
    self.m_pHHLLKMahjongEffDemo:runAction(cc.Sequence:create(cc.DelayTime:create(nDelayTime), cc.CallFunc:create(function()
        -- 更新数据
        self:refreshData(self.m_arrayLastSelected)

        -- 清空之前的记录
        self.m_arrayLastSelected = {}
    end)))
end

function CDLayerHHLLKMahjongTable_llk:refreshData(selectData)
    if not selectData and TABLE_SIZE(selectData) < 2 then
        return
    end

    print("TABLE_SIZE(selectData):")

    for i, v in ipairs(selectData) do
        self.m_arrayMahjong[v.X][v.Y].mahjongItem:setSelectedColor(false)
        self.m_arrayMahjong[v.X][v.Y].mahjongItem:stopAllActions()
        self.m_arrayMahjong[v.X][v.Y].mahjongItem:setVisible(false)
        self.m_arrayMahjong[v.X][v.Y].isDisplay = false

        -- 变更tips项对应数据
        --self.mahjongMath_llk:changeItemVisible(self.testTable, self.m_dMapMahjong[v].x, self.m_dMapMahjong[v].y)
    end

    -- 刷新记录数据
    self.m_pHHLLKPlayAI:lessLeftTableMahjong()

    -- 刷新界面数据
    self:refreshTableLeftMahjong()

    function overGame()
        g_pSceneTable:gotoSceneHall()
    end

    -- 剩余麻将为0，则表示完成
    if self.m_pHHLLKPlayAI:getLeftTableMahjong() == 0 then
        --结束特效播放完毕后，跳转界面
        local overEff = CDCCBHHLLKBaseAniObject.createCCBBaseAniObject(self.m_pHHLLKMahjongEffDemo, "x_tx_llk.ccbi", g_pHHLLKGlobalManagment:getWinCenter(), 0)

        if  overEff then
            --overEff:setScale(0.8)
            overEff:endBaseRelease(false)
            overEff:endBaseVisible(false)

            overEff:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(overGame)))
        end
    end

    -- 确保剩余的麻将可以消除，否则进行麻将重置
    if not self.mahjongMath_llk:checkAllItemCanDestory(self.m_arrayMahjong) then
        self.nSkillId = 2
        self:canUseSkill(0)
    end
end

----------------------------------------------------------------------------
-- 关闭所有界面
function CDLayerHHLLKMahjongTable_llk:closeAllUserInterface()
    cclog("CDLayerHHLLKMahjongTable_llk::closeAllUserInterface")

    local pTable = dtGetSceneTableFromParent( self)
    if  pTable then
        pTable:closeAllUserInterface()
        return
    end
end

----------------------------------------------------------------------------
-- 初始化桌子
-- 删除所有打出以及手上的牌，并且清除所有玩家桌面
function CDLayerHHLLKMahjongTable_llk:initTable()
    cclog("CDLayerHHLLKMahjongTable_llk::initTable")

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

----------------------------------------------------------------------------
-- 初始化
function CDLayerHHLLKMahjongTable_llk:init()
    cclog("CDLayerHHLLKMahjongTable_llk::init")
    
    -- touch事件
    local function onTouchBegan(touch, event)
        cclog("CDLayerHHLLKMahjongTable_llk:onTouchBegan")

        -- 没有开始游戏，不能进行点击
        if not self.m_bHHLLKInTheGame then
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
function CDLayerHHLLKMahjongTable_llk:round_licensingPlayer()
    if  self.m_nHHLLKLicensingType == 0 then
        local effect = CDCCBAniObject.createCCBAniObject(self.m_pHHLLKMahjongEffDemo, "x_tx_kaiju.ccbi", g_pHHLLKGlobalManagment:getWinCenter(), 0)
        if  effect then
            effect:endVisible( true)
            effect:endRelease( true)
        end

        self.m_nHHLLKLicensingType = 1
        self:runAction( cc.Sequence:create(cc.DelayTime:create(0.7), cc.CallFunc:create(CDLayerHHLLKMahjongTable_llk.round_licensingPlayer)))
        dtPlaySound( DEF_PROJCETHHLLK_SOUND_MJ_KJ)

    elseif self.m_nHHLLKLicensingType == 1 then -- 发牌
        local mahjongConfig = self.mahjongMath_llk:getMahjongConfig()

        -- 设置随机种子
        math.randomseed(tonumber(tostring(os.time()):reverse():sub(1,6)))
        local tmpArr = {} 

        -- 简单
        if self.m_nHHLLKFlag == 1 then
            local nPos = math.random(DEF_LLK_MJ_WAN, DEF_LLK_MJ_TONG)
            for i = 1, self.m_nHHLLKRow * self.m_nHHLLKColumn, 2 do
                local p = math.random(1, TABLE_SIZE(mahjongConfig[nPos]))
                table.insert(tmpArr, mahjongConfig[nPos][p])
                table.insert(tmpArr, mahjongConfig[nPos][p])
            end

        -- 普通
        elseif self.m_nHHLLKFlag == 2 then
            local nPos = {}
            local tmpData = {}
            self.mahjongMath_llk:push_back(tmpData, mahjongConfig, 1, TABLE_SIZE(mahjongConfig))

            -- 取出2个不同的麻将种类
            for i = 1, 2 do
                local p = math.random(DEF_LLK_MJ_WAN, TABLE_SIZE(tmpData))
                table.insert(nPos, p)
                self.mahjongMath_llk:pop_card(tmpData, p)
            end
            for i = 1, self.m_nHHLLKRow * self.m_nHHLLKColumn, 4 do
                for j = 1, TABLE_SIZE(nPos) do
                    local p = math.random(DEF_LLK_MJ_WAN, TABLE_SIZE(mahjongConfig[nPos[j]]))
                    table.insert(tmpArr, mahjongConfig[nPos[j]][p])
                    table.insert(tmpArr, mahjongConfig[nPos[j]][p])
                end
            end

        -- 困难
        else
            for i = 1, self.m_nHHLLKRow * self.m_nHHLLKColumn, 6 do
                for i, v in ipairs(mahjongConfig) do
                    local p = math.random(1, TABLE_SIZE(v))
                    table.insert(tmpArr, mahjongConfig[i][p])
                    table.insert(tmpArr, mahjongConfig[i][p])
                end
            end 
        end

        -- 确保生成的棋盘有解
        while true do
            self.mahjongMath_llk:randmSort(tmpArr)
            self:setMahjongData(tmpArr) 

            if self.mahjongMath_llk:checkAllItemCanDestory(self.m_arrayMahjong) then
                self:setMahjongData(tmpArr, true) 
                break 
            end
        end

        self.m_pHHLLKOnResetBtn:setVisible(true)
        self.m_pHHLLKOnTipBtn:setVisible(true)

    end
end

function CDLayerHHLLKMahjongTable_llk:setMahjongData(arrayMahjong, isSetMahjongItem)
    if arrayMahjong then
        local tmpIndex = 1 
        for i, v in ipairs(self.m_arrayMahjong) do
            for j, z in ipairs(v) do
                if z.isDisplay then
                    z.mahjong = arrayMahjong[tmpIndex]
                    if isSetMahjongItem then
                        z.mahjongItem:setMahjongNumber(arrayMahjong[tmpIndex])
                            z.mahjongItem:setMahjong("t_" .. arrayMahjong[tmpIndex] .. ".png")
                        z.mahjongItem:setVisible(true)
                    end
                    tmpIndex = tmpIndex + 1
                end
            end
        end
    end
end

function CDLayerHHLLKMahjongTable_llk:showTestError(str)
    if  not self.m_pHHLLKTestError then
        self.m_pHHLLKTestError = cc.LabelTTF:create("","",30)
        self.m_pHHLLKTestError:setAnchorPoint(cc.p(1,1))
        self.m_pHHLLKTestError:setPosition(cc.p(960,640))
        self:addChild(self.m_pHHLLKTestError)
    end
    if  str and string.len(str) > 0 then
        self.m_pHHLLKTestError:setString(str)
    end
end

--===============================界面函数绑定===============================--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- 退出桌子到大厅
function CDLayerHHLLKMahjongTable_llk:onGotoHall()
    cclog("CDLayerHHLLKMahjongTable_llk::onExit")

    g_pSceneTable:gotoSceneHall()
    dtPlaySound(DEF_SOUND_TOUCH)
end

----------------------------------------------------------------------------
-- 音乐设置
function CDLayerHHLLKMahjongTable_llk:onMusic()

    local bMusic = g_pHHLLKGlobalManagment:isEnableMusic()
    g_pHHLLKGlobalManagment:enableMusic(not bMusic)
end

----------------------------------------------------------------------------
-- 音效设置
function CDLayerHHLLKMahjongTable_llk:onSound()

    local bSound = g_pHHLLKGlobalManagment:isEnableSound()
    g_pHHLLKGlobalManagment:enableSound( not bSound)
end

-- 提示
-- 点击间隔1秒
function CDLayerHHLLKMahjongTable_llk:onTip()
    dtPlaySound(DEF_SOUND_TOUCH)
    self.nSkillId = 1
    self:canUseSkill(10000)
end

-- 重置
-- 点击间隔1秒
function CDLayerHHLLKMahjongTable_llk:onReset()
    dtPlaySound(DEF_SOUND_TOUCH)

    self.nSkillId = 2
    self:canUseSkill(50000)
end


function CDLayerHHLLKMahjongTable_llk:canUseSkill(_goldExp)
    -- if self.m_pHHLLKPlayer.gold < _goldExp then
    --     return
    -- end

    -- 提示
    if self.nSkillId == 1 then
        if not self.m_pHHLLKArrayTipsGroup or self.m_pHHLLKArrayTipsGroup.isEmpty() then
            if not self.m_sNowSelected.isEmpty() then
                self.m_arrayMahjong[self.m_sNowSelected.X][self.m_sNowSelected.Y].mahjongItem:setSelectedColor(false)
                self.m_sNowSelected.clear()
            end

            local isOk = ture
            isOk, self.m_pHHLLKArrayTipsGroup.point1, self.m_pHHLLKArrayTipsGroup.point2 = self.mahjongMath_llk:checkAllItemCanDestory(self.m_arrayMahjong, self.path)

            if isOk then
               
                self.m_arrayMahjong[self.m_pHHLLKArrayTipsGroup.point1.X][self.m_pHHLLKArrayTipsGroup.point1.Y].mahjongItem:setSelectedColor(true)
                self.m_arrayMahjong[self.m_pHHLLKArrayTipsGroup.point2.X][self.m_pHHLLKArrayTipsGroup.point2.Y].mahjongItem:setSelectedColor(true)
            else
                self.m_pHHLLKArrayTipsGroup.clear()
            end
        end
        
    -- 重置
    elseif self.nSkillId == 2 then
        self.m_pHHLLKArrayTipsGroup.clear()
        self.path = {}
        local tmpArray = {}
        for i, v in ipairs(self.m_arrayMahjong) do
            for j, z in ipairs(v) do
                if z.isDisplay then
                    table.insert(tmpArray, z.mahjong)
                end
            end
        end

        -- 确保重置数据可以有消除的对象
        while self.m_pHHLLKPlayAI:getLeftTableMahjong() >= 4 do
            self.mahjongMath_llk:randmSort(tmpArray)
            self:setMahjongData(tmpArray)

            if self.mahjongMath_llk:checkAllItemCanDestory(self.m_arrayMahjong) then
                print("reset Ok!")
                self:setMahjongData(tmpArray, true)
                break
            end
        end
    end
end

----------------------------------------------------------------------------
-- 设置
function CDLayerHHLLKMahjongTable_llk:onSetting()
    cclog( "CDLayerHHLLKMahjongTable_llk:onSetting")

    if  not self.m_pHHLLKGroupBar:isVisible() then
        return
    end

    g_pSceneTable:closeAllUserInterface()

    local pos = cc.p( 0.0, self.m_pHHLLKButSetting:getPositionY())
    g_pSceneTable.m_pLayerTipBar:setPosition( pos)
    g_pSceneTable.m_pLayerTipBar:open(  casinoclient.getInstance():isSelfBuildTable())
end

function CDLayerHHLLKMahjongTable_llk:onReady()
    cclog("CDLayerHHLLKMahjongTable_llk:onReady")

    if not self.m_pHHLLKReadyBtn:isVisible() then
        return
    end

    self.m_pHHLLKReadyBtn:setVisible(false)

    -- 开始游戏
    self:Handle_llk_StartPlay()
    
end

----------------------------------------------------------------------------
-- ccb处理
-- 变量绑定
function CDLayerHHLLKMahjongTable_llk:onAssignCCBMemberVariable(loader)
    cclog("CDLayerHHLLKMahjongTable_llk::onAssignCCBMemberVariable")

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

    -- 开始按钮
    self.m_pHHLLKReadyBtn = loader["button_ready"]

    --------------------------------------------------------
    -- 技能相关绑定
    self.m_pHHLLKSkillBar        = loader["skill_bar"]               -- 技能根Node
    self.m_pHHLLKOnTipBtn        = loader["but_tip"]                 -- 技能：提示按钮
    self.m_pHHLLKOnResetBtn      = loader["but_reset"]               -- 技能：重置按钮
    self.m_pHHLLKTipExpLabel     = loader["tip_expend_gold"]        -- 提示技能消耗文本
    self.m_pHHLLKResetExpLabel   = loader["reset_expend_gold"]       -- 重置技能消耗文本
end

----------------------------------------------------------------------------
-- ccb处理
-- 函数绑定
function CDLayerHHLLKMahjongTable_llk:onResolveCCBCCControlSelector(loader)
    cclog("CDLayerHHLLKMahjongTable_llk::onResolveCCBCCControlSelector")
    
    -- 下方玩家功能区按钮
    loader["onSetting"]     = function() self:onSetting() end         

    -- 开始准备按钮
    loader["onReady"]       = function() self:onReady() end            

    ----------------------------------------------------------------
    -- 技能相关
    -- 提示技能按钮
    loader["onTip"]         = function() self:onTip() end               

    -- 重置技能按钮
    loader["onReset"]         = function() self:onReset() end               
end

--------------------------------------------------------------------------
function CDLayerHHLLKMahjongTable_llk.createCDLayerTable_xtlzddz(pParent)
    cclog("CDLayerHHLLKMahjongTable_llk::createCDLayerTable_xtlzddz")
    if not pParent then
        return nil
    end
    local insLayer = CDLayerHHLLKMahjongTable_llk.new()
    insLayer:init()
    local loader = insLayer.m_ccbLoader
    insLayer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerHHLLKMahjongTable_llk.ccbi",proxy,loader)
    insLayer.m_ccBaseLayer = node
    insLayer:onAssignCCBMemberVariable(loader)
    insLayer:addChild(node)
    pParent:addChild(insLayer)
    return insLayer
end
