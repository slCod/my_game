--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDMahjongLlkItem
//File Name:    HHLLK_llk_item.h
//Author:       GostYe
//Start Data:   2016.03.1
//Language:     XCode 4.5
//Target:       IOS, Android
****************************************************************************/
]]

require( REQUIRE_PATH.."DCCBLayer")

----------------------------------------------------------------------------
CDMahjongLlkItem = class( "CDMahjongLlkItem", CDCCBLayer)
CDMahjongLlkItem.__index = CDMahjongLlkItem

----------------------------------------------------------------------------
function CDMahjongLlkItem:ctor()
    CDMahjongLlkItem.super.ctor(self)
    CDMahjongLlkItem.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDMahjongLlkItem.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:onExit()
    self:stopAllActions()
    CDMahjongLlkItem.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
CDMahjongLlkItem.m_pHHLLKRoot = nil        
CDMahjongLlkItem.m_pHHLLKTouch = nil       

CDMahjongLlkItem.m_pHHLLKDefine = nil      

CDMahjongLlkItem.m_nHHLLKSizeW = 0         
CDMahjongLlkItem.m_nHHLLKSizeH = 0         

CDMahjongLlkItem.m_pHHLLKAniManager = nil  
CDMahjongLlkItem.m_nHHLLKDelayAniID = 0    
CDMahjongLlkItem.m_pHHLLKEffect = nil      

CDMahjongLlkItem.m_nHHLLKMahjong = 0       

CDMahjongLlkItem.x = 0       
CDMahjongLlkItem.y = 0       
CDMahjongLlkItem.isisible = false       


----------------------------------------------------------------------------
-- 初始化
function CDMahjongLlkItem:initialMember()
    cclog("CDMahjongLlkItem::initialMember")

    self.m_pHHLLKRoot = nil
    self.m_pHHLLKFace = nil
    self.m_pHHLLKTouch = nil

    self.m_pHHLLKDefine = nil
    self.m_pHHLLKBack = nil
    self.m_pHHLLKMask = nil

    self.m_nHHLLKSizeW = nil
    self.m_nHHLLKSizeH = nil
    self.m_pHHLLKAniManager = nil
    self.m_nHHLLKDelayAniID = 0
    self.m_pHHLLKEffect = nil

    self.m_nHHLLKMahjong = 0

    self.x = 0       
    self.y = 0       
    self.isisible = false       
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:releaseMember()
    cclog("CDMahjongLlkItem::releaseMember")
    CDMahjongLlkItem.super.releaseMember(self)

    CC_SAFE_RELEASE_NULL(self.m_pHHLLKAniManager)
    self.m_pHHLLKAniManager = nil

    if  self.m_pHHLLKRoot then
        self.m_pHHLLKRoot:removeAllChildren(true)
    end

    if  self.m_pHHLLKEffect ~= nil then
        self:removeChild( self.m_pHHLLKEffect)
        self.m_pHHLLKEffect = nil
    end

    self.m_pHHLLKRoot = nil
    self.m_pHHLLKTouch = nil

    self.m_pHHLLKDefine = nil

    if DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end
    CDMahjongLlkItem.initialMember(self)
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:init()
    cclog("CDMahjongLlkItem::init")
    return true
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:setMahjong( file_mahjong)

    if  self.m_pHHLLKRoot then

        self.m_pHHLLKRoot:removeAllChildren()
        self.m_pHHLLKDefine = nil
    end

    if  file_mahjong ~= nil then

        self.m_pHHLLKDefine = cc.Sprite:createWithSpriteFrameName( file_mahjong)
        self.m_pHHLLKRoot:addChild(self.m_pHHLLKDefine)
        self.m_pHHLLKDefine:setVisible(true)
    end
end

function CDMahjongLlkItem:setMahjongNumber( mahjong)
    self.m_nHHLLKMahjong = mahjong
end

function CDMahjongLlkItem:getMahjongNumber()
    return self.m_nHHLLKMahjong
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:setMahjongScale( scale)
    if  self.m_pHHLLKRoot then
        self.m_pHHLLKRoot:setScale( scale)
    end
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:setSelectedColor(bSelect)
    bSelect = bSelect or false

    if  self.m_pHHLLKDefine then

        if  bSelect then
            self.m_pHHLLKDefine:setColor(cc.c3b(255,255,0))
        else
            self.m_pHHLLKDefine:setColor(cc.c3b(255,255,255))
        end
    end
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:initMahjongWithFile(file_mahjong)
    cclog("CDMahjongLlkItem::initMahjongWithFile")

    if  self.m_pHHLLKRoot == nil then
        return
    else
        self.m_pHHLLKRoot:removeAllChildren()
        self.m_pHHLLKDefine = nil
    end

    if  file_mahjong ~= nil then
        self.m_pHHLLKDefine = cc.Sprite:createWithSpriteFrameName( file_mahjong)
        self.m_pHHLLKRoot:addChild(self.m_pHHLLKDefine)
        self.m_pHHLLKDefine:setVisible(true)
    else
        self.m_pHHLLKDefine = nil
    end
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:checkWithTouchPoint(point)
    if  self.m_pHHLLKTouch == nil then
        return false
    end

    local sPoint = self.m_pHHLLKTouch:getParent():convertToNodeSpace(point)
    local rect = self.m_pHHLLKTouch:getBoundingBox()
    if cc.rectContainsPoint( rect, sPoint) then
        return true
    end
    return false
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:getMahjongSize()
    if  self.m_pHHLLKTouch ~= nil then
        local size = self.m_pHHLLKTouch:getContentSize()
        self.m_nHHLLKSizeW = size.width
        self.m_nHHLLKSizeH = size.height
    end
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:addEffect( file, time)

    self:stopAllActions()

    if  self.m_pHHLLKEffect ~= nil then
        self:removeChild( self.m_pHHLLKEffect)
        self.m_pHHLLKEffect = nil
    end

    local function removeEffect()

        if  self.m_pHHLLKEffect ~= nil then
            self:removeChild( self.m_pHHLLKEffect)
            self.m_pHHLLKEffect = nil
        end
    end

    self.m_pHHLLKEffect = CDCCBHHLLKBaseAniObject.createCCBBaseAniObject( self, file, cc.p( 0, 0), 0)
    if  self.m_pHHLLKEffect then

        self.m_pHHLLKEffect:setScale( self.m_pHHLLKRoot:getScaleX())
        self.m_pHHLLKEffect:endBaseVisible( false)
        self.m_pHHLLKEffect:endBaseRelease( false)
        self:runAction( cc.Sequence:create( cc.DelayTime:create( time), cc.CallFunc:create( removeEffect)))
    end
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:onAssignCCBMemberVariable(loader)

    self.m_pHHLLKRoot  = loader["scale_root"]
    self.m_pHHLLKTouch = loader["touch"]

    if  nil ~= loader["mAnimationManager"] then
        local animationMgr = loader["mAnimationManager"]
        self:setAniManager(animationMgr)
    end

    return true
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:onResolveCCBCCControlSelector(loader)
end

----------------------------------------------------------------------------
-- 延迟动画播放
function CDMahjongLlkItem:delayAnimations( delay_ani_id, time)

    function delay_run_animation()

        self:runAnimations( self.m_nHHLLKDelayAniID, 0)
    end

    if  time <= 0 then
        self:runAnimations( delay_ani_id, 0)
    else
        self.m_nHHLLKDelayAniID = delay_ani_id
        self:runAction( cc.Sequence:create( cc.DelayTime:create( time), cc.CallFunc:create( delay_run_animation)))
    end
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:setAniManager( pM)

    CC_SAFE_RELEASE_NULL(self.m_pHHLLKAniManager)
    self.m_pHHLLKAniManager = pM;
    if  self.m_pHHLLKAniManager then
        self.m_pHHLLKAniManager:retain()
    end
end
function CDMahjongLlkItem:getAniManager()
    return self.m_pHHLLKAniManager
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:runAnimations( nSeqId, fTweenDuration)
    if  self.m_pHHLLKAniManager then
        cclog("CDMahjongLlkItem::runAnimations seqid")
        self.m_pHHLLKAniManager:runAnimationsForSequenceIdTweenDuration( nSeqId, fTweenDuration)
        self:setCompletedCallback(fTweenDuration)
    end
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:setCompletedCallback(fTweenDuration)
    if  self.m_pHHLLKAniManager then
        local name = self.m_pHHLLKAniManager:getRunningSequenceName()
        if name == "" then
            cclog("no running animation")
            return
        end
        local duration = self.m_pHHLLKAniManager:getSequenceDuration(name)
        local function onCompleted()
            self:completedAnimationSequenceNamed(name)
        end
        self:stopAllActions()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(duration + fTweenDuration), cc.CallFunc:create(onCompleted)))
    end
end

----------------------------------------------------------------------------
function CDMahjongLlkItem:completedAnimationSequenceNamed(name)
end

----------------------------------------------------------------------------
function CDMahjongLlkItem.createCDMahjong( pParent)
    cclog("CDMahjongLlkItem::createCDMahjong")

    if not pParent then
        return nil
    end

    local insLayer = CDMahjongLlkItem.new()
    insLayer:init()
    local loader = insLayer.m_ccbLoader
    insLayer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad( "CDMahjong_llk.ccbi",proxy,loader)

    insLayer:setAnchorPoint( node:getAnchorPoint())
    insLayer:setContentSize( node:getContentSize())

    insLayer.m_ccBaseLayer = node
    insLayer:onAssignCCBMemberVariable(loader)
    insLayer:addChild( node)
    pParent:addChild(insLayer)
    insLayer:getMahjongSize()
    return insLayer
end