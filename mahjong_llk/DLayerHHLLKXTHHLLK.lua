--[[
/******************************************************
//Project:      ProjectX
//Moudle:       CDLayerHHLLKXTHHLLK
//File Name:    DLayerHHLLKXTHHLLK.lua
//Author:       Gostye
//Start Data:   2018.06.22
//Language:     XCode 9.4
//Target:       IOS, Android

ProjectX - 连连看选择界面

******************************************************/
]]

require( REQUIRE_PATH.."DTKDTableView")

local casinoclient = require("script.client.casinoclient")

-----------------------------------------
-- 类定义
CDLayerHHLLKXTHHLLK = class("CDLayerHHLLKXTHHLLK", CDTKDTableView)
CDLayerHHLLKXTHHLLK.__index = CDLayerHHLLKXTHHLLK

-- 构造函数
function CDLayerHHLLKXTHHLLK:ctor()
    cclog("CDLayerHHLLKXTHHLLK::ctor")
    CDLayerHHLLKXTHHLLK.super.ctor(self)
    CDLayerHHLLKXTHHLLK.initialMember(self)

    local function onNodeEvent(event)
    	if "enter" == event then
            -- 网络事件
            local   listeners = {
                -- { casino.MSG_ACT_ACK,                handler( self, self.Handle_Act_Ack)},
            }
            casinoclient.getInstance():addEventListeners(self,listeners)
        elseif "exit" == event then
            CDLayerHHLLKXTHHLLK.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
end

function CDLayerHHLLKXTHHLLK:onEnter( ... )

	cclog("CDLayerHHLLKXTHHLLK::onEnter")
	-- dtOpenWaittingLayer(self)

end

function CDLayerHHLLKXTHHLLK:onExit()
    cclog("CDLayerHHLLKXTHHLLK::onExit")

    self:stopAllActions()
    self:enableTouch(false)
    --模拟析构自身
    CDLayerHHLLKXTHHLLK.releaseMember(self)
    self:unregisterScriptHandler()
    casinoclient.getInstance():removeListenerAllEvents(self)
end


-- 设置点击标志的开启和关闭
function CDLayerHHLLKXTHHLLK:enableTouch( bEnable)

	if bEnable then
    
        if self.m_bHHLLKTouch then
            return
        end
        
        -- touch事件
        local function onTouchBegan(touch, event)
            if  not self:isVisible() then
                return
            end
            return true
        end
    
        local function onTouchMoved(touch, event)
        end
    
        local function onTouchEnded(touch, event)
            cclog("CDLayerHHLLKXTHHLLK::onTouchEnded")
            if self.m_pHHLLKGroupGame == nil then
                return
            end

            local touchPoint = touch:getLocation()
            local sJudge = self.m_pHHLLKGroupGame:convertToNodeSpace(touchPoint)

            local sRect = self.m_pHHLLKSimpleTouch:getBoundingBox()
            if cc.rectContainsPoint(sRect, sJudge) then
                self.m_nHHLLKFlag = 1
                self.m_nHHLLKNeedGold = 5000
                self:joinLlkTable()
                return
            end

            sRect = self.m_pHHLLKNormalTouch:getBoundingBox()
            if cc.rectContainsPoint(sRect, sJudge) then
                self.m_nHHLLKFlag = 2
                self.m_nHHLLKNeedGold = 10000
                self:joinLlkTable()
                return
            end

            sRect = self.m_pHHLLKHardTouch:getBoundingBox()
            if cc.rectContainsPoint(sRect, sJudge) then
                self.m_nHHLLKFlag = 3
                self.m_nHHLLKNeedGold = 50000
                self:joinLlkTable()
                return
            end
        end
        
        self.m_pHHLLKListener = cc.EventListenerTouchOneByOne:create()
        self.m_pHHLLKListener:setSwallowTouches(false)
        self.m_pHHLLKListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
        self.m_pHHLLKListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
        self.m_pHHLLKListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(self.m_pHHLLKListener, self)

    end
    self.m_bHHLLKTouch = bEnable

end

CDLayerHHLLKXTHHLLK.m_pHHLLKSimpleTouch = nil         -- 简单场按钮
CDLayerHHLLKXTHHLLK.m_pHHLLKNormalTouch = nil         -- 普通场按钮
CDLayerHHLLKXTHHLLK.m_pHHLLKHardTouch   = nil         -- 困难场按钮

CDLayerHHLLKXTHHLLK.m_pHHLLKSimpleGoldNode = nil      -- 简单场金币特效图标挂载点
CDLayerHHLLKXTHHLLK.m_pHHLLKNormalGoldNode = nil      -- 普通场金币特效图标挂载点
CDLayerHHLLKXTHHLLK.m_pHHLLKHardGoldNode   = nil      -- 困了场金币特效图标挂载点

CDLayerHHLLKXTHHLLK.m_pHHLLKSimpleGoldLabel = nil     -- 简单场金币消耗文本显示框
CDLayerHHLLKXTHHLLK.m_pHHLLKNormalGoldLabel = nil     -- 普通场金币消耗文本显示框
CDLayerHHLLKXTHHLLK.m_pHHLLKHardGoldLabel   = nil     -- 困难场金币消耗文本显示框

CDLayerHHLLKXTHHLLK.m_pHHLLKGroupGame = nil

-- 初始化
function CDLayerHHLLKXTHHLLK:initialMember()
    cclog("CDLayerHHLLKXTHHLLK::initialMember")

    self.m_pHHLLKSimpleTouch = nil 
    self.m_pHHLLKNormalTouch = nil
    self.m_pHHLLKHardTouch   = nil

    self.m_pHHLLKSimpleGoldNode = nil
    self.m_pHHLLKNormalGoldNode = nil
    self.m_pHHLLKHardGoldNode   = nil

    self.m_pHHLLKSimpleGoldLabel = nil
    self.m_pHHLLKNormalGoldLabel = nil
    self.m_pHHLLKHardGoldLabel   = nil
    self.m_pHHLLKGroupGame = nil

    self.m_nHHLLKNeedGold = nil -- 开启连连看需要的金币数量
    self.m_nHHLLKFlag     = nil -- 选择的难度
end

function CDLayerHHLLKXTHHLLK:releaseMember()
    cclog("CDLayerHHLLKXTHHLLK::releaseMember")

    --模拟析构父类
    CDTKDTableView.releaseMember(self)
    if 	DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end
    CDLayerHHLLKXTHHLLK.initialMember(self)
end

-- 初始化
function CDLayerHHLLKXTHHLLK:init()
    cclog("CDLayerHHLLKXTHHLLK::init")
    self:setVisible(false)
    return true
end

-- 开启界面
function CDLayerHHLLKXTHHLLK:open()
    cclog("CDLayerHHLLKXTHHLLK::open")
    if 	self:isVisible() then
        return
    end

    self:onLoadUI()
    self:refreshInterface()
    -- self:runBaseAnimations(0, 0.0)

    -- 锁屏
    CDHHLLKGlobalMgr:sharedGlobalMgr():setOpenTouch(false)
    
    self:enableTouch(true)

    self:setVisible(true)
end


-- 添加所有节点
function CDLayerHHLLKXTHHLLK:refreshInterface()
    cclog("CDLayerHHLLKXTHHLLK::refreshInterface")

    -- if not self.m_pHHLLKSimpleGoldNode:getChildByTag(0) then
    --     local eff_gold1 = CDCCBHHLLKBaseAniObject.createCCBBaseAniObject( self.m_pHHLLKSimpleGoldNode, "x_tx_gold.ccbi", pos, 0)
    --     eff_gold1:setTag(0)
    --     if  eff_gold1 ~= nil then
    --         eff_gold1:endBaseRelease( false)
    --         eff_gold1:endBaseVisible( false)
    --     end
    -- end

    -- if not self.m_pHHLLKNormalGoldNode:getChildByTag(0) then
    --     local eff_gold2 = CDCCBHHLLKBaseAniObject.createCCBBaseAniObject( self.m_pHHLLKNormalGoldNode, "x_tx_gold.ccbi", pos, 0)
    --     eff_gold2:setTag(0)
    --     if  eff_gold2 ~= nil then
    --         eff_gold2:endBaseRelease( false)
    --         eff_gold2:endBaseVisible( false)
    --     end
    -- end

    -- if not self.m_pHHLLKHardGoldNode:getChildByTag(0) then
    --     local eff_gold3 = CDCCBHHLLKBaseAniObject.createCCBBaseAniObject( self.m_pHHLLKHardGoldNode, "x_tx_gold.ccbi", pos, 0)
    --     eff_gold3:setTag(0)
    --     if  eff_gold3 ~= nil then
    --         eff_gold3:endBaseRelease( false)
    --         eff_gold3:endBaseVisible( false)
    --     end
    -- end

    -- self.m_pHHLLKSimpleGoldLabel:setString("5000")
    -- self.m_pHHLLKNormalGoldLabel:setString("10000")
    -- self.m_pHHLLKHardGoldLabel:setString("50000")
end

function CDLayerHHLLKXTHHLLK:joinLlkTable()
    
    g_pSceneHall:gotoSceneTableLlk(self.m_nHHLLKFlag)
   
end

-- 关闭界面
function CDLayerHHLLKXTHHLLK:close()

    self:enableTouch( false)
    self:setVisible( false)
end

-- 关闭界面
function CDLayerHHLLKXTHHLLK:onClose()

    self:close()
    g_pSceneHall:gotoPriorToHall()
    dtProjectHHLLKPlaySound( DEF_SOUND_TOUCH)
end

-----------------------------------------
-- 网络相关处理
function CDLayerHHLLKXTHHLLK:Handle_Act_Ack( __event)

    local pAck = __event.packet
    if  not pAck then
        return false
    end

    dtCloseWaitingLayer( self)
    if  self:isVisible() then
        if  pAck.type == casino.ACT_RED_RAIN then
            self:refreshInterface()
        end
    end
    
    return true
end

-----------------------------------------
-- ccb处理
function CDLayerHHLLKXTHHLLK:onAssignCCBMemberVariable(loader)
    cclog("CDLayerHHLLKXTHHLLK::onAssignCCBMemberVariable")

    -- 简单、普通、困难 点选图片
    self.m_pHHLLKSimpleTouch= loader["touch_simple"]
    self.m_pHHLLKNormalTouch= loader["touch_normal"]
    self.m_pHHLLKHardTouch= loader["touch_hard"]

    -- 简单、普通、困难 金币特效图片挂载点
    self.m_pHHLLKSimpleGoldNode = loader["simple_gold_node"]
    self.m_pHHLLKNormalGoldNode = loader["normal_gold_node"]
    self.m_pHHLLKHardGoldNode = loader["hard_gold_node"]

    -- 简单、普通、困难 金币消耗文本显示控件
    self.m_pHHLLKSimpleGoldLabel = loader["label_simple"]
    self.m_pHHLLKNormalGoldLabel = loader["label_normal"]
    self.m_pHHLLKHardGoldLabel = loader["label_hard"]

    -- 场次选择父节点
    self.m_pHHLLKGroupGame = loader["group_game"]
    
    -- 基类注册
    self:assignCCBMemberVariable(loader)
end


function CDLayerHHLLKXTHHLLK:onResolveCCBCCControlSelector(loader)
    cclog("CDLayerHHLLKXTHHLLK::onResolveCCBCCControlSelector")
    loader["onClose"] = function() self:onClose() end
end

-----------------------------------------
-- create
function CDLayerHHLLKXTHHLLK.createCDLayerLLK(pParent)
    if  not pParent then
        return nil
    end
    local layer = CDLayerHHLLKXTHHLLK.new()
    layer:init()
    pParent:addChild( layer)
    return layer
end

function CDLayerHHLLKXTHHLLK:onLoadUI()

    if  self.m_ccBaseLayer then
        return self
    end
    local insLayer = self
    local loader = insLayer.m_ccbLoader
    insLayer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad("CDLayerQPHHMahjongLLK.ccbi",proxy,loader)
    insLayer.m_ccBaseLayer = node
    insLayer:onAssignCCBMemberVariable(loader)
    insLayer:addChild(node)
    return self
end
