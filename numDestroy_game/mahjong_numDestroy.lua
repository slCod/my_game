--[[
/****************************************************************************
//Project:      ProjectX
//Moudle:       CDMahjong_NUM
//File Name:    mahjong_define.h
//Author:       GostYe
//Start Data:   2016.03.1
//Language:     XCode 4.5
//Target:       IOS, Android
****************************************************************************/
]]

require( REQUIRE_PATH.."DCCBLayer")

----------------------------------------------------------------------------
-- 类定义
CDMahjong_NUM = class( "CDMahjong_NUM", CDCCBLayer)
CDMahjong_NUM.__index = CDMahjong_NUM

----------------------------------------------------------------------------
-- 构造函数
function CDMahjong_NUM:ctor()
    CDMahjong_NUM.super.ctor(self)
    CDMahjong_NUM.initialMember(self)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CDMahjong_NUM.onExit(self)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

----------------------------------------------------------------------------
-- 释放
function CDMahjong_NUM:onExit()
    self:stopAllActions()
    CDMahjong_NUM.releaseMember(self)
    self:unregisterScriptHandler()
end

----------------------------------------------------------------------------
-- 成员变量定义
CDMahjong_NUM.m_pRoot = nil        -- 根节点用于在上面放字等
CDMahjong_NUM.m_pFace = nil        -- 牌面

CDMahjong_NUM.m_pTouch = nil       -- 点击范围

CDMahjong_NUM.m_pDefine = nil      -- 默认样子
CDMahjong_NUM.m_pOut = nil         -- 出牌样子
CDMahjong_NUM.m_pBack = nil        -- 背面
CDMahjong_NUM.m_pMask = nil        -- 遮罩层

CDMahjong_NUM.m_pIcoLai = nil      -- 赖子标示
CDMahjong_NUM.m_pIcoTing = nil     -- 听牌标示

CDMahjong_NUM.m_nSizeW = 0         -- 点击位置宽    
CDMahjong_NUM.m_nSizeH = 0         -- 点击位置高

CDMahjong_NUM.m_pAniManager = nil  -- 动画管理器
CDMahjong_NUM.m_nDelayAniID = 0    -- 延迟播放的动画编号
CDMahjong_NUM.m_pEffect = nil      -- 特效对象

----------------------------------------------------------------------------
-- 初始化
function CDMahjong_NUM:initialMember()
    cclog("CDMahjong_NUM::initialMember")

    self.m_pRoot = nil
    self.m_pFace = nil
    self.m_pTouch = nil

    self.m_pDefine = nil
    self.m_pBack = nil
    self.m_pMask = nil

    self.m_pIcoLai = nil
    self.m_pIcoTing = nil

    self.m_nSizeW = nil
    self.m_nSizeH = nil
    self.m_pAniManager = nil
    self.m_nDelayAniID = 0
    self.m_pEffect = nil

    self.m_nShowNum     = 0
    self.m_pIndex_h     = 0
    self.m_pIndex_v     = 0

    self.m_pTargetPos_h  = 0
    self.m_pTargetPos_v  = 0 

    self.m_pInitPosX   = 29.5
    self.m_pInitPosY   = 410 
    self.m_pInitSpace  = 54.5

end

----------------------------------------------------------------------------
-- 释放
function CDMahjong_NUM:releaseMember()
    cclog("CDMahjong_NUM::releaseMember")
    --模拟析构父类
    CDMahjong_NUM.super.releaseMember(self)

    CC_SAFE_RELEASE_NULL(self.m_pAniManager)
    self.m_pAniManager = nil

    if  self.m_pRoot then
        if  self.m_pFace then
            self.m_pFace:removeAllChildren( ture)
        end
        self.m_pRoot:removeAllChildren(true)
    end

    if  self.m_pEffect ~= nil then
        self:removeChild( self.m_pEffect)
        self.m_pEffect = nil
    end

    self.m_pRoot = nil
    self.m_pTouch = nil

    self.m_pDefine = nil
    self.m_pBack = nil
    self.m_pMask = nil

    if DEF_MANUAL_RELEASE then
        self:removeAllChildren(true)
    end
    CDMahjong_NUM.initialMember(self)
end

----------------------------------------------------------------------------
-- 初始化
function CDMahjong_NUM:init()
    cclog("CDMahjong_NUM::init")
    return true
end

----------------------------------------------------------------------------


function CDMahjong_NUM:setItemNum( _num )
    self.m_nShowNum = _num
end

function CDMahjong_NUM:setShowNum( _num )
    self.m_nShowNum = _num
    self:setMahjong(string.format("my_b_%u.png",_num))
end

function CDMahjong_NUM:getShowNum( ... )
    return self.m_nShowNum
end

function CDMahjong_NUM:setRGBColor( _color )
    self.m_pDefine:setColor(cc.c3b(_color.r,_color.g,_color.b))
end

-- 设置牌
-- 参数: 默认状态
function CDMahjong_NUM:setMahjong( file_mahjong)

    if  self.m_pDefine ~= nil then
        self.m_pDefine:removeAllChildren()
    end

    if  self.m_pFace ~= nil then
        self.m_pFace:removeAllChildren()
        self.m_pDefine = nil
    end

    if  file_mahjong ~= nil then

        self.m_pDefine = cc.Sprite:createWithSpriteFrameName( file_mahjong)
        self.m_pFace:addChild( self.m_pDefine)
        self.m_pDefine:setVisible( true)
    end
end

function CDMahjong_NUM:setItemInitPosition( _h,_v )
    self.m_pIndex_h     = _h
    self.m_pIndex_v     = _v
    local startPos = cc.p(self.m_pInitSpace*(self.m_pIndex_h-1)+self.m_pInitPosX,self.m_pInitPosY-self.m_pInitSpace*(self.m_pIndex_v-1))
    self:setPosition(startPos)

end

function CDMahjong_NUM:getSelfPos( ... )
    local curPos = cc.p(self:getPositionX(),self:getPositionY())
    return curPos
end

function CDMahjong_NUM:setItemPosition( _h,_v )
    self.m_pTargetPos_h  = _h
    self.m_pTargetPos_v  = _v
end

function CDMahjong_NUM:moveToPos( _isMove,_second )

    local targetPos = cc.p(self.m_pInitSpace*(self.m_pTargetPos_h-1)+self.m_pInitPosX,self.m_pInitPosY-self.m_pInitSpace*(self.m_pTargetPos_v-1))
    if  _isMove then
        if  not _second or _second <= 0 then
            _second = 0.5
        end
       self:runAction( cc.MoveTo:create( _second, targetPos))
    else
        self:setPosition(targetPos)
    end
end

function CDMahjong_NUM:getTargetIndex( ... )
    return self.m_pTargetPos_v,self.m_pTargetPos_h
end

----------------------------------------------------------------------------
-- 设置牌缩放
function CDMahjong_NUM:setMahjongScale( scale)

    if  self.m_pRoot then
        self.m_pRoot:setScaleX(scale)
        self.m_pRoot:setScaleY(scale-0.2)
    end
end

----------------------------------------------------------------------------
-- 设置赖子标示是否显示
-- 图标是否显示,颜色是否显示
function CDMahjong_NUM:setIcoLaiVisible( bVisible, bColor)

    if  bVisible == nil then
        bVisible = true
    end
    if  bColor == nil then
        bColor = true
    end

    if  self.m_pIcoLai then
        self.m_pIcoLai:setVisible( bVisible)
    end

    if  self.m_pDefine and (not self.m_pDefine:isGrey()) then

        if  bColor then
            self.m_pDefine:setColor(cc.c3b(255,255,0))
        else
            self.m_pDefine:setColor(cc.c3b(255,255,255))
        end
    end
end

----------------------------------------------------------------------------
-- 设置听牌标示是否显示
-- 图标是否显示
function CDMahjong_NUM:setIcoTingVisible( bVisible)

    if  bVisible == nil then
        bVisible = true
    end
    
    if  self.m_pIcoTing then
        self.m_pIcoTing:setVisible( bVisible)
    end
end

----------------------------------------------------------------------------
-- 设置赖子颜色提示
function CDMahjong_NUM:setLaiZiColor()

    if  self.m_pDefine then
        self.m_pDefine:setColor( cc.c3b(255,255,0))
    end
end


----------------------------------------------------------------------------
-- 初始化牌
-- 参数: 排面, 背面, 遮罩层
function CDMahjong_NUM:initMahjongWithFile( file_mahjong, file_back, file_mash)
    cclog("CDMahjong_NUM::initMahjongWithFile")

    if  self.m_pRoot == nil then
        return
    end
    
    if  self.m_pDefine ~= nil then
        self.m_pDefine:removeAllChildren()
    end

    if  self.m_pFace ~= nil then
        self.m_pFace:removeAllChildren()
        self.m_pDefine = nil
    end
    self.m_pRoot:removeAllChildren()

    self.m_pFace = cc.Node:create()
    self.m_pRoot:addChild( self.m_pFace)

    if  file_mahjong ~= nil then
        self.m_pDefine = cc.Sprite:createWithSpriteFrameName( file_mahjong)
        self.m_pFace:addChild( self.m_pDefine)
        self.m_pDefine:setVisible( true)
    else
        self.m_pDefine = nil
    end

    if  file_back ~= nil then
        self.m_pBack = cc.Sprite:createWithSpriteFrameName( file_back)
        self.m_pRoot:addChild( self.m_pBack)
        self.m_pBack:setVisible( false)
    else
        self.m_pBack = nil
    end

    if  file_mash ~= nil then
        self.m_pMask = cc.Sprite:createWithSpriteFrameName( file_mash)
        self.m_pRoot:addChild( self.m_pMask)
        self.m_pMask:setVisible( false)
    else
        self.m_pMask = nil
    end
end

----------------------------------------------------------------------------
-- 是否点中
-- 参数: 点
-- 返回: 是否选中
function CDMahjong_NUM:touchInFromPoint( point)

    if  self.m_pTouch == nil then
        return false
    end

    local sPoint = self.m_pTouch:getParent():convertToNodeSpace( point)
    local rect = self.m_pTouch:getBoundingBox()
    if cc.rectContainsPoint( rect, sPoint) then
        return true
    end
    return false
end

----------------------------------------------------------------------------
-- 设置mask显示
function CDMahjong_NUM:setMaskVisible( visible)

    if  self.m_pMask ~= nil then
        self.m_pMask:setVisible( visible)
    end
end

----------------------------------------------------------------------------
-- 设置正面显示
function CDMahjong_NUM:setFaceVisible( visible)

    if  self.m_pFace ~= nil then
        self.m_pFace:setVisible( visible)
    end
end

----------------------------------------------------------------------------
-- 设置背面显示
function CDMahjong_NUM:setBackVisible( visible)

    if  self.m_pBack ~= nil then

        self.m_pBack:setVisible( visible)
        if  visible and self.m_pIcoLai ~= nil then
            self.m_pIcoLai:setVisible( false)
        end
    end
end
-------------------------------------------------------------------------------
----------------------------------------------------------------------------


function CDMahjong_NUM:setBVisible( b_visible )
    self:setVisible(b_visible)
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-- 获取尺寸
function CDMahjong_NUM:getMahjongSize()

    if  self.m_pTouch ~= nil then
        local size = self.m_pTouch:getContentSize()
        self.m_nSizeW = size.width
        self.m_nSizeH = size.height
    end
end

----------------------------------------------------------------------------
-- 添加特效
function CDMahjong_NUM:addEffect( file, time)

    self:stopAllActions()

    if  self.m_pEffect ~= nil then
        self:removeChild( self.m_pEffect)
        self.m_pEffect = nil
    end

    local function removeEffect()

        if  self.m_pEffect ~= nil then
            self:removeChild( self.m_pEffect)
            self.m_pEffect = nil
        end
    end

    self.m_pEffect = CDCCBAniObject.createCCBAniObject( self, file, cc.p( 0, 0), 0)
    if  self.m_pEffect then

        self.m_pEffect:setScale( self.m_pRoot:getScaleX())
        self.m_pEffect:endVisible( false)
        self.m_pEffect:endRelease( false)
        self:runAction( cc.Sequence:create( cc.DelayTime:create( time), cc.CallFunc:create( removeEffect)))
    end
end

----------------------------------------------------------------------------
-- ccb处理-变量绑定
function CDMahjong_NUM:onAssignCCBMemberVariable(loader)
    cclog("CDMahjong_NUM::onAssignCCBMemberVariable")

    self.m_pRoot  = loader["scale_root"]
    self.m_pTouch = loader["touch"]

    self.m_pIcoLai = loader["ico_laizi"]
    self.m_pIcoTing = loader["ico_ting"]

    if  nil ~= loader["mAnimationManager"] then
        local animationMgr = loader["mAnimationManager"]
        self:setAniManager(animationMgr)
    end

    return true
end

----------------------------------------------------------------------------
-- ccb处理-函数绑定
function CDMahjong_NUM:onResolveCCBCCControlSelector(loader)
    cclog("CDMahjong_NUM::onResolveCCBCCControlSelector")
end

----------------------------------------------------------------------------
-- 延迟动画播放
-- 参数: 动画编号, 延迟的时间
function CDMahjong_NUM:delayAnimations( delay_ani_id, time)

    function delay_run_animation()

        self:runAnimations( self.m_nDelayAniID, 0)
    end

    if  time <= 0 then
        self:runAnimations( delay_ani_id, 0)
    else
        self.m_nDelayAniID = delay_ani_id
        self:runAction( cc.Sequence:create( cc.DelayTime:create( time), cc.CallFunc:create( delay_run_animation)))
    end
end

----------------------------------------------------------------------------
-- 获取、设置动画控制器
function CDMahjong_NUM:setAniManager( pM)

    CC_SAFE_RELEASE_NULL(self.m_pAniManager)
    self.m_pAniManager = pM;
    if  self.m_pAniManager then
        self.m_pAniManager:retain()
    end
end
function CDMahjong_NUM:getAniManager()
    return self.m_pAniManager
end

----------------------------------------------------------------------------
-- 播放动画根据索引号，或者动画名
function CDMahjong_NUM:runAnimations( nSeqId, fTweenDuration)
    if  self.m_pAniManager then
        cclog("CDMahjong_NUM::runAnimations seqid")
        self.m_pAniManager:runAnimationsForSequenceIdTweenDuration( nSeqId, fTweenDuration)
        self:setCompletedCallback(fTweenDuration)
    end
end

----------------------------------------------------------------------------
-- 添加设置动画播放结束回调方法
function CDMahjong_NUM:setCompletedCallback(fTweenDuration)
    --cclog("CDCCBAniNode::setCompletedCallback")
    if  self.m_pAniManager then
        local name = self.m_pAniManager:getRunningSequenceName()
        if name == "" then
            cclog("no running animation")
            return
        end
        local duration = self.m_pAniManager:getSequenceDuration(name)
        local function onCompleted()
            self:completedAnimationSequenceNamed(name)
        end
        self:stopAllActions()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(duration + fTweenDuration), cc.CallFunc:create(onCompleted)))
    end
end

----------------------------------------------------------------------------
-- 动画播放完的回调处理
function CDMahjong_NUM:completedAnimationSequenceNamed(name)
    --cclog("CDCCBAniNode::completedAnimationSequenceNamed")
end

----------------------------------------------------------------------------
-- 创建卡牌对象
function CDMahjong_NUM.createCDMahjong_NUM( pParent)
    cclog("CDMahjong_NUM::createCDMahjong_NUM")

    if not pParent then
        return nil
    end

    local layer = CDMahjong_NUM.new()
    layer:init()
    local loader = layer.m_ccbLoader
    layer:onResolveCCBCCControlSelector(loader)
    local proxy = cc.CCBProxy:create()
    local node  = CCBReaderLoad( "CDMahjong.ccbi",proxy,loader)

    layer:setAnchorPoint( node:getAnchorPoint())
    layer:setContentSize( node:getContentSize())

    layer.m_ccbLayer = node
    layer:onAssignCCBMemberVariable(loader)
    layer:addChild( node)
    pParent:addChild(layer)
    layer:getMahjongSize()
    return layer
end