--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDTPGSMahjongItem
//File Name:    HHLLK_llk_item.h
//Author:       GostYe
//Start Data:   2016.03.1
//Language:     XCode 4.5
//Target:       IOS, Android
****************************************************************************/
]]

require( REQUIRE_PATH.."DCCBLayer")

----------------------------------------------------------------------------
CDTPGSMahjongItem = class( "CDTPGSMahjongItem", CDCCBLayer)
CDTPGSMahjongItem.__index = CDTPGSMahjongItem

----------------------------------------------------------------------------
function CDTPGSMahjongItem:ctor()
    CDTPGSMahjongItem.super.ctor(self)
    CDTPGSMahjongItem.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDTPGSMahjongItem.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:onExit()
    self:stopAllActions()
    CDTPGSMahjongItem.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
CDTPGSMahjongItem.m_pHHLLKRoot = nil        
CDTPGSMahjongItem.m_pHHLLKTouch = nil       
CDTPGSMahjongItem.m_pHHLLKSelect = nil
CDTPGSMahjongItem.m_pHHLLKError = nil
CDTPGSMahjongItem.m_pHHLLKDefine = nil      

CDTPGSMahjongItem.m_nHHLLKSizeW = 0         
CDTPGSMahjongItem.m_nHHLLKSizeH = 0         

CDTPGSMahjongItem.m_pHHLLKAniManager = nil  
CDTPGSMahjongItem.m_nHHLLKDelayAniID = 0    
CDTPGSMahjongItem.m_pHHLLKEffect = nil      

CDTPGSMahjongItem.m_nHHLLKMahjong = 0       

CDTPGSMahjongItem.x = 0       
CDTPGSMahjongItem.y = 0       
CDTPGSMahjongItem.isisible = false       


----------------------------------------------------------------------------
-- 初始化
function CDTPGSMahjongItem:initialMember()
    cclog("CDTPGSMahjongItem::initialMember")

    self.m_pHHLLKRoot = nil
    self.m_pHHLLKFace = nil
    self.m_pHHLLKTouch = nil
    self.m_pHHLLKSelect = nil
    self.m_pHHLLKError = nil

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
function CDTPGSMahjongItem:releaseMember()
    cclog("CDTPGSMahjongItem::releaseMember")
    CDTPGSMahjongItem.super.releaseMember(self)

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
    self.m_pHHLLKSelect = nil
    self.m_pHHLLKError = nil

    self.m_pHHLLKDefine = nil

    if DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end
    CDTPGSMahjongItem.initialMember(self)
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:init()
    cclog("CDTPGSMahjongItem::init")
    return true
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:setMahjong( file_mahjong)

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

function CDTPGSMahjongItem:setMahjongNumber( mahjong)
    self.m_nHHLLKMahjong = mahjong
end

function CDTPGSMahjongItem:getMahjongNumber()
    return self.m_nHHLLKMahjong
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:setMahjongScale( scale)
    if  self.m_pHHLLKRoot then
        self.m_pHHLLKRoot:setScale( scale)
    end
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:setSelectedColor(bSelect)
    bSelect = bSelect or false

    -- if  self.m_pHHLLKDefine and self.m_pHHLLKSelect then
    --     self.m_pHHLLKSelect:setVisible(bSelect)
    --     -- if  bSelect then
    --         -- self.m_pHHLLKDefine:setColor(cc.c3b(255,255,0))
    --     -- else
    --         -- self.m_pHHLLKDefine:setColor(cc.c3b(255,255,255))
    --     -- end
    -- end
    if  self.m_pHHLLKDefine then
        if  bSelect then
            self.m_pHHLLKDefine:setColor(cc.c3b(255,255,0))
        else
            self.m_pHHLLKDefine:setColor(cc.c3b(255,255,255))
        end
    end
end

function CDTPGSMahjongItem:setSelectedColor_true()

    if  self.m_pHHLLKDefine then
        self.m_pHHLLKDefine:setColor(cc.c3b(255,255,0))
    end
end


function CDTPGSMahjongItem:setSelectedColor_false()

    if  self.m_pHHLLKDefine then
        self.m_pHHLLKDefine:setColor(cc.c3b(255,255,255))
    end
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:showErrorSprite(boolen)

    boolen = boolen or false
    if self.m_pHHLLKError then
        self.m_pHHLLKError:setVisible(boolen)
    end

end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:initMahjongWithFile(file_mahjong)
    cclog("CDTPGSMahjongItem::initMahjongWithFile")

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
function CDTPGSMahjongItem:checkWithTouchPoint(point)
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
function CDTPGSMahjongItem:getMahjongSize()
    if  self.m_pHHLLKTouch ~= nil then
        local size = self.m_pHHLLKTouch:getContentSize()
        self.m_nHHLLKSizeW = size.width
        self.m_nHHLLKSizeH = size.height
    end
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:addEffect( file, time)

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
function CDTPGSMahjongItem:onAssignCCBMemberVariable(loader)

    self.m_pHHLLKRoot  = loader["scale_root"]
    self.m_pHHLLKTouch = loader["touch"]
    self.m_pHHLLKSelect = loader["eff_select"]
    self.m_pHHLLKError  = loader["sprite_error"]

    if  nil ~= loader["mAnimationManager"] then
        local animationMgr = loader["mAnimationManager"]
        self:setAniManager(animationMgr)
    end

    return true
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:onResolveCCBCCControlSelector(loader)
end

----------------------------------------------------------------------------
-- 延迟动画播放
function CDTPGSMahjongItem:delayAnimations( delay_ani_id, time)

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
function CDTPGSMahjongItem:setAniManager( pM)

    CC_SAFE_RELEASE_NULL(self.m_pHHLLKAniManager)
    self.m_pHHLLKAniManager = pM;
    if  self.m_pHHLLKAniManager then
        self.m_pHHLLKAniManager:retain()
    end
end
function CDTPGSMahjongItem:getAniManager()
    return self.m_pHHLLKAniManager
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:runAnimations( nSeqId, fTweenDuration)
    if  self.m_pHHLLKAniManager then
        cclog("CDTPGSMahjongItem::runAnimations seqid")
        self.m_pHHLLKAniManager:runAnimationsForSequenceIdTweenDuration( nSeqId, fTweenDuration)
        self:setCompletedCallback(fTweenDuration)
    end
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem:setCompletedCallback(fTweenDuration)
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
function CDTPGSMahjongItem:completedAnimationSequenceNamed(name)
end

----------------------------------------------------------------------------
function CDTPGSMahjongItem.createCDMahjong( pParent)
    cclog("CDTPGSMahjongItem::createCDMahjong")

    if not pParent then
        return nil
    end

    local insLayer = CDTPGSMahjongItem.new()
    insLayer:init()
    local loader = insLayer.m_ccbLoader
    insLayer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad( "CDMahjong_tpgs.ccbi",proxy,loader)

    insLayer:setAnchorPoint( node:getAnchorPoint())
    insLayer:setContentSize( node:getContentSize())

    insLayer.m_ccBaseLayer = node
    insLayer:onAssignCCBMemberVariable(loader)
    insLayer:addChild( node)
    pParent:addChild(insLayer)
    insLayer:getMahjongSize()
    return insLayer
end